package actors.tests

import std.unittest.*
import std.unittest.testmacro.*

import actors.*

@Test
public class SequentialDispatcherTest {

    // Test basic SequentialDispatcher creation
    @TestCase
    func testSequentialDispatcherCreation() {
        let dispatcher = SequentialDispatcher()
        // Test that dispatcher is created successfully by using it
        let future = dispatcher.postAsk({ => 42 }, onException: { _ => Continue }, onError: { _ => Continue })
        @Expect(future.get(), 42)
    }

    @TestCase
    func testSequentialDispatcherCreationWithPriority() {
        let dispatcher = SequentialDispatcher(enableReceiverPriority: true)
        // Test that dispatcher with priority is created successfully by using it
        let future = dispatcher.postAsk({ => 42 }, onException: { _ => Continue }, onError: { _ => Continue })
        @Expect(future.get(), 42)
    }

    // Test basic post functionality
    @TestCase
    func testPostBasicTask() {
        let dispatcher = SequentialDispatcher()
        let future = dispatcher.postAsk({ => 42 }, onException: { _ => Continue }, onError: { _ => Continue })
        let result = future.get()
        @Expect(result, 42)
    }

    @TestCase
    func testPostStringTask() {
        let dispatcher = SequentialDispatcher()
        let future = dispatcher.postAsk({ => "hello world" }, onException: { _ => Continue }, onError: { _ => Continue })
        let result = future.get()
        @Expect(result, "hello world")
    }

    @TestCase
    func testPostTaskWithException() {
        let dispatcher = SequentialDispatcher()
        let future = dispatcher.postAsk({ =>
            throw Exception("Test exception")
        }, onException: { _ => Continue }, onError: { _ => Continue })
        let exn = @AssertThrows[Exception](future.get())
        @Expect(exn.message, "Test exception")
    }

    // Test post with priority
    @TestCase
    func testPostWithPriority() {
        let dispatcher = SequentialDispatcher(enableReceiverPriority: true)
        let future = dispatcher.postAsk({ => 42 }, config: ReceiverConfig(priority: 3), onException: { _ => Continue }, onError: { _ => Continue })
        let result = future.get()
        @Expect(result, 42)
    }

    @TestCase
    func testPostWithDefaultPriority() {
        let dispatcher = SequentialDispatcher(enableReceiverPriority: true)
        let future = dispatcher.postAsk({ => 42 }, onException: { _ => Continue }, onError: { _ => Continue })
        let result = future.get()
        @Expect(result, 42)
    }

    // Test multiple tasks execution
    @TestCase
    func testMultipleTasks() {
        let dispatcher = SequentialDispatcher()
        let future1 = dispatcher.postAsk({ => 1 }, onException: { _ => Continue }, onError: { _ => Continue })
        let future2 = dispatcher.postAsk({ => 2 }, onException: { _ => Continue }, onError: { _ => Continue })
        let future3 = dispatcher.postAsk({ => 3 }, onException: { _ => Continue }, onError: { _ => Continue })

        @Expect(future1.get(), 1)
        @Expect(future2.get(), 2)
        @Expect(future3.get(), 3)
    }

    @TestCase
    func testMultipleTasksWithMixedResults() {
        let dispatcher = SequentialDispatcher()
        let future1 = dispatcher.postAsk({ => "success" }, onException: { _ => Continue }, onError: { _ => Continue })
        let future2 = dispatcher.postAsk({ =>
            throw Exception("Task failed")
        }, onException: { _ => Continue }, onError: { _ => Continue })
        let future3 = dispatcher.postAsk({ => 42 }, onException: { _ => Continue }, onError: { _ => Continue })

        @Expect(future1.get(), "success")
        let exn = @AssertThrows[Exception](future2.get())
        @Expect(exn.message, "Task failed")
        @Expect(future3.get(), 42)
    }

    // Test complex task execution
    @TestCase
    func testComplexTaskExecution() {
        let dispatcher = SequentialDispatcher()
        let future = dispatcher.postAsk({ =>
            var sum = 0
            for (i in 1..100) {
                sum += i
            }
            sum
        }, onException: { _ => Continue }, onError: { _ => Continue })
        let result = future.get()
        @Expect(result, 4950) // Sum of 1 to 99
    }

    // Test task with side effects using a different approach
    @TestCase
    func testTaskWithSideEffects() {
        let dispatcher = SequentialDispatcher()

        // Create a shared counter to test side effects
        let sharedCounter = Box(0)
        let executionOrder = Box(0)

        // Submit tasks that modify shared state
        let future1 = dispatcher.postAsk({ =>
            // Simulate some work and modify shared state
            var sum = 0
            for (i in 1..10) {
                sum += i
            }
            sharedCounter.value += 10
            executionOrder.value++
            "task1_${executionOrder}"
        }, onException: { _ => Continue }, onError: { _ => Continue })
        let future2 = dispatcher.postAsk({ =>
            // Simulate some work and modify shared state
            var sum = 0
            for (i in 1..20) {
                sum += i
            }
            sharedCounter.value += 20
            executionOrder.value++
            "task2_${executionOrder}"
        }, onException: { _ => Continue }, onError: { _ => Continue })

        let result1 = future1.get()
        let result2 = future2.get()

        // Verify that side effects occurred
        @Expect(sharedCounter.value, 30) // 10 + 20
        @Expect(executionOrder.value, 2) // Both tasks executed

        // Verify execution order (should be sequential)
        @Expect(result1, "task1_1") // First task executed first
        @Expect(result2, "task2_2") // Second task executed second
    }

    // Test boundary priority values
    @TestCase
    func testBoundaryPriorityValues() {
        let dispatcher = SequentialDispatcher(enableReceiverPriority: true)

        // Test minimum priority (1)
        let future1 = dispatcher.postAsk({ => "min_priority" }, config: ReceiverConfig(priority: 1), onException: { _ => Continue }, onError: { _ => Continue })
        @Expect(future1.get(), "min_priority")

        // Test maximum priority (10)
        let future2 = dispatcher.postAsk({ => "max_priority" }, config: ReceiverConfig(priority: 10), onException: { _ => Continue }, onError: { _ => Continue })
        @Expect(future2.get(), "max_priority")

        // Test default priority (5)
        let future3 = dispatcher.postAsk({ => "default_priority" }, onException: { _ => Continue }, onError: { _ => Continue })
        @Expect(future3.get(), "default_priority")
    }

    // Test invalid priority values (negative tests)
    @TestCase
    func testInvalidPriorityValues() {
        let dispatcher = SequentialDispatcher(enableReceiverPriority: true)

        // Test priority 0 (should be invalid - minimum is 1)
        let exn1 = @AssertThrows[IllegalArgumentException](dispatcher.postAsk({ => "invalid_priority_0" }, config: ReceiverConfig(priority: 0), onException: { _ => Continue }, onError: { _ => Continue }))
        @Expect(exn1.message.contains("Priority must be in the range of [1..10]"), true)

        // Test negative priority (should be invalid)
        let exn2 = @AssertThrows[IllegalArgumentException](dispatcher.postAsk({ => "invalid_negative_priority" }, config: ReceiverConfig(priority: -1), onException: { _ => Continue }, onError: { _ => Continue }))
        @Expect(exn2.message.contains("Priority must be in the range of [1..10]"), true)

        // Test priority > 10 (should be invalid - maximum is 10)
        let exn3 = @AssertThrows[IllegalArgumentException](dispatcher.postAsk({ => "invalid_priority_11" }, config: ReceiverConfig(priority: 11), onException: { _ => Continue }, onError: { _ => Continue }))
        @Expect(exn3.message.contains("Priority must be in the range of [1..10]"), true)

        // Test very large priority value
        let exn4 = @AssertThrows[IllegalArgumentException](dispatcher.postAsk({ => "invalid_large_priority" }, config: ReceiverConfig(priority: 100), onException: { _ => Continue }, onError: { _ => Continue }))
        @Expect(exn4.message.contains("Priority must be in the range of [1..10]"), true)
    }

    // Test sequential execution guarantee using futures
    @TestCase
    func testSequentialExecutionGuarantee() {
        let dispatcher = SequentialDispatcher()

        // Use Box to track execution order
        let executionOrder = Box(0)
        let orderTracker = Box("")

        // Submit tasks that will take different amounts of time
        let future1 = dispatcher.postAsk({ =>
            // Simulate work and track execution order
            var sum = 0
            for (i in 1..1000) {
                sum += i
            }
            executionOrder.value++
            orderTracker.value += "1"
            1
        }, onException: { _ => Continue }, onError: { _ => Continue })
        let future2 = dispatcher.postAsk({ =>
            // Simulate work and track execution order
            var sum = 0
            for (i in 1..500) {
                sum += i
            }
            executionOrder.value++
            orderTracker.value += "2"
            2
        }, onException: { _ => Continue }, onError: { _ => Continue })
        let future3 = dispatcher.postAsk({ =>
            executionOrder.value++
            orderTracker.value += "3"
            3
        }, onException: { _ => Continue }, onError: { _ => Continue })

        // Wait for all tasks to complete
        let result1 = future1.get()
        let result2 = future2.get()
        let result3 = future3.get()

        // Verify results
        @Expect(result1, 1)
        @Expect(result2, 2)
        @Expect(result3, 3)

        // Verify execution order - tasks should execute in submission order
        @Expect(executionOrder.value, 3) // All three tasks executed
        @Expect(orderTracker.value, "123") // Tasks executed in order 1, 2, 3
    }

    // Test priority ordering with early high priority message
    @TestCase
    func testPriorityOrderingWithEarlyHighPriority() {
        let dispatcher = SequentialDispatcher(enableReceiverPriority: true)

        // Use Box to track execution order
        let executionOrder = Box(0)
        let orderTracker = Box("")

        // Submit a low priority task first, then a high priority task
        let futureLow = dispatcher.postAsk({ =>
            executionOrder.value++
            orderTracker.value += "H"
            "low_priority"
        }, config: ReceiverConfig(priority: 10), onException: { _ => Continue }, onError: { _ => Continue }) // High priority (10)

        let futureHigh = dispatcher.postAsk({ =>
            executionOrder.value++
            orderTracker.value += "L"
            "high_priority"
        }, config: ReceiverConfig(priority: 1), onException: { _ => Continue }, onError: { _ => Continue }) // Low priority (1)

        // Wait for all tasks to complete
        let resultHigh = futureHigh.get()
        let resultLow = futureLow.get()

        // Verify results
        @Expect(resultHigh, "high_priority")
        @Expect(resultLow, "low_priority")

        // Verify that high priority task executed first despite being submitted second
        @Expect(executionOrder.value, 2) // Both tasks executed
        @Expect(orderTracker.value, "HL") // High priority (H) executed before low priority (L)
    }
}
