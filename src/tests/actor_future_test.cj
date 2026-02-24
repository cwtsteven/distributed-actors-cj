package actors.tests

import std.unittest.*
import std.unittest.testmacro.*

import actors.*
import stdx.serialization.serialization.*

@Test
public class ActorFutureTest {

    // Test ActorFuture basic functionality
    @TestCase
    func testActorFutureBasicExecution() {
        let future = ActorFuture<Int64>({ => 42 })
        future.execute()
        let result = future.get()
        @Expect(result, 42)
    }

    @TestCase
    func testActorFutureTryGetBeforeExecution() {
        let future = ActorFuture<Int64>({ => 42 })
        let result = future.tryGet()
        @Expect(result.isSome(), false)
    }

    @TestCase
    func testActorFutureTryGetAfterExecution() {
        let future = ActorFuture<Int64>({ => 42 })
        future.execute()
        let result = future.tryGet()
        @Expect(result.isSome(), true)
        @Expect(result.getOrThrow(), 42)
    }

    @TestCase
    func testActorFutureWithString() {
        let future = ActorFuture<String>({ => "hello world" })
        future.execute()
        let result = future.get()
        @Expect(result, "hello world")
    }

    @TestCase
    func testActorFutureWithException() {
        let future = ActorFuture<Int64>({ =>
            throw Exception("Test exception")
        })
        future.execute()
        let exn = @AssertThrows[Exception](future.get())
        @Expect(exn.message, "Test exception")
    }

    @TestCase
    func testActorFutureTryGetWithException() {
        let future = ActorFuture<Int64>({ =>
            throw Exception("Test exception")
        })
        future.execute()
        // tryGet() should throw the exception directly, not return Some
        let thrownExn = @AssertThrows[Exception](future.tryGet())
        @Expect(thrownExn.message, "Test exception")
    }


    // Test FutureResult
    @TestCase
    func testFutureResultOkay() {
        let result: FutureResult<Int64> = Okay(42)
        @Expect(result.getOrThrow(), 42)
    }

    @TestCase
    func testFutureResultExc() {
        let exn = Exception("Test exception")
        let result: FutureResult<Int64> = Exc(exn)
        let thrownExn = @AssertThrows[Exception](result.getOrThrow())
        @Expect(thrownExn.message, "Test exception")
    }

    // Test multiple futures
    @TestCase
    func testMultipleActorFutures() {
        let future1 = ActorFuture<Int64>({ => 1 })
        let future2 = ActorFuture<Int64>({ => 2 })
        let future3 = ActorFuture<Int64>({ => 3 })

        future1.execute()
        future2.execute()
        future3.execute()

        @Expect(future1.get(), 1)
        @Expect(future2.get(), 2)
        @Expect(future3.get(), 3)
    }


    @TestCase
    func testMixedActorFutures() {
        let successFuture = ActorFuture<Int64>({ => 42 })
        let failureFuture = ActorFuture<Int64>({ =>
            throw Exception("Task failed")
        })

        successFuture.execute()
        failureFuture.execute()

        @Expect(successFuture.get(), 42)
        let exn = @AssertThrows[Exception](failureFuture.get())
        @Expect(exn.message, "Task failed")
    }

}