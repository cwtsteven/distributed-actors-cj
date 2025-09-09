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
        let future = dispatcher.post({ => 42 })
        @Expect(future.get(), 42)
    }

    @TestCase
    func testSequentialDispatcherCreationWithPriority() {
        let dispatcher = SequentialDispatcher(enableReceiverPriority: true)
        // Test that dispatcher with priority is created successfully by using it
        let future = dispatcher.post({ => 42 })
        @Expect(future.get(), 42)
    }

    // Test basic post functionality
    @TestCase
    func testPostBasicTask() {
        let dispatcher = SequentialDispatcher()
        let future = dispatcher.post({ => 42 })
        let result = future.get()
        @Expect(result, 42)
    }

    @TestCase
    func testPostStringTask() {
        let dispatcher = SequentialDispatcher()
        let future = dispatcher.post({ => "hello world" })
        let result = future.get()
        @Expect(result, "hello world")
    }

    @TestCase
    func testPostTaskWithException() {
        let dispatcher = SequentialDispatcher()
        let future = dispatcher.post({ =>
            throw Exception("Test exception")
        })
        let exn = @AssertThrows[Exception](future.get())
        @Expect(exn.message, "Test exception")
    }

    // Test post with priority
    @TestCase
    func testPostWithPriority() {
        let dispatcher = SequentialDispatcher(enableReceiverPriority: true)
        let future = dispatcher.post({ => 42 }, priority: 3)
        let result = future.get()
        @Expect(result, 42)
    }

    @TestCase
    func testPostWithDefaultPriority() {
        let dispatcher = SequentialDispatcher(enableReceiverPriority: true)
        let future = dispatcher.post({ => 42 })
        let result = future.get()
        @Expect(result, 42)
    }

    // Test multiple tasks execution
    @TestCase
    func testMultipleTasks() {
        let dispatcher = SequentialDispatcher()
        let future1 = dispatcher.post({ => 1 })
        let future2 = dispatcher.post({ => 2 })
        let future3 = dispatcher.post({ => 3 })

        @Expect(future1.get(), 1)
        @Expect(future2.get(), 2)
        @Expect(future3.get(), 3)
    }

    @TestCase
    func testMultipleTasksWithMixedResults() {
        let dispatcher = SequentialDispatcher()
        let future1 = dispatcher.post({ => "success" })
        let future2 = dispatcher.post({ =>
            throw Exception("Task failed")
        })
        let future3 = dispatcher.post({ => 42 })

        @Expect(future1.get(), "success")
        let exn = @AssertThrows[Exception](future2.get())
        @Expect(exn.message, "Task failed")
        @Expect(future3.get(), 42)
    }

    // Test complex task execution
    @TestCase
    func testComplexTaskExecution() {
        let dispatcher = SequentialDispatcher()
        let future = dispatcher.post({ =>
            var sum = 0
            for (i in 1..100) {
                sum += i
            }
            sum
        })
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
        let future1 = dispatcher.post({ =>
            // Simulate some work and modify shared state
            var sum = 0
            for (i in 1..10) {
                sum += i
            }
            sharedCounter.value += 10
            executionOrder.value++
            "task1_${executionOrder}"
        })
        let future2 = dispatcher.post({ =>
            // Simulate some work and modify shared state
            var sum = 0
            for (i in 1..20) {
                sum += i
            }
            sharedCounter.value += 20
            executionOrder.value++
            "task2_${executionOrder}"
        })

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
        let future1 = dispatcher.post({ => "min_priority" }, priority: 1)
        @Expect(future1.get(), "min_priority")

        // Test maximum priority (10)
        let future2 = dispatcher.post({ => "max_priority" }, priority: 10)
        @Expect(future2.get(), "max_priority")

        // Test default priority (5)
        let future3 = dispatcher.post({ => "default_priority" })
        @Expect(future3.get(), "default_priority")
    }

    // Test invalid priority values (negative tests)
    @TestCase
    func testInvalidPriorityValues() {
        let dispatcher = SequentialDispatcher(enableReceiverPriority: true)

        // Test priority 0 (should be invalid - minimum is 1)
        let exn1 = @AssertThrows[IllegalArgumentException](dispatcher.post({ => "invalid_priority_0" }, priority: 0))
        @Expect(exn1.message.contains("Priority must be in the range of [1..10]"), true)

        // Test negative priority (should be invalid)
        let exn2 = @AssertThrows[IllegalArgumentException](dispatcher.post({ => "invalid_negative_priority" }, priority: -1))
        @Expect(exn2.message.contains("Priority must be in the range of [1..10]"), true)

        // Test priority > 10 (should be invalid - maximum is 10)
        let exn3 = @AssertThrows[IllegalArgumentException](dispatcher.post({ => "invalid_priority_11" }, priority: 11))
        @Expect(exn3.message.contains("Priority must be in the range of [1..10]"), true)

        // Test very large priority value
        let exn4 = @AssertThrows[IllegalArgumentException](dispatcher.post({ => "invalid_large_priority" }, priority: 100))
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
        let future1 = dispatcher.post({ =>
            // Simulate work and track execution order
            var sum = 0
            for (i in 1..1000) {
                sum += i
            }
            executionOrder.value++
            orderTracker.value += "1"
            1
        })
        let future2 = dispatcher.post({ =>
            // Simulate work and track execution order
            var sum = 0
            for (i in 1..500) {
                sum += i
            }
            executionOrder.value++
            orderTracker.value += "2"
            2
        })
        let future3 = dispatcher.post({ =>
            executionOrder.value++
            orderTracker.value += "3"
            3
        })

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
        let futureLow = dispatcher.post({ =>
            executionOrder.value++
            orderTracker.value += "H"
            "low_priority"
        }, priority: 10) // High priority (10)

        let futureHigh = dispatcher.post({ =>
            executionOrder.value++
            orderTracker.value += "L"
            "high_priority"
        }, priority: 1) // Low priority (1)

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