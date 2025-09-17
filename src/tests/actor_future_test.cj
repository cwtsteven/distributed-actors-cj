package actors.tests

import std.unittest.*
import std.unittest.testmacro.*

import actors.*

@Test
public class ActorFutureTest {

    // Test LocalActorFuture basic functionality
    @TestCase
    func testLocalActorFutureBasicExecution() {
        let future = LocalActorFuture<Int64>({ => 42 })
        future.execute()
        let result = future.get()
        @Expect(result, 42)
    }

    @TestCase
    func testLocalActorFutureTryGetBeforeExecution() {
        let future = LocalActorFuture<Int64>({ => 42 })
        let result = future.tryGet()
        @Expect(result.isSome(), false)
    }

    @TestCase
    func testLocalActorFutureTryGetAfterExecution() {
        let future = LocalActorFuture<Int64>({ => 42 })
        future.execute()
        let result = future.tryGet()
        @Expect(result.isSome(), true)
        @Expect(result.getOrThrow(), 42)
    }

    @TestCase
    func testLocalActorFutureWithString() {
        let future = LocalActorFuture<String>({ => "hello world" })
        future.execute()
        let result = future.get()
        @Expect(result, "hello world")
    }

    @TestCase
    func testLocalActorFutureWithException() {
        let future = LocalActorFuture<Int64>({ =>
            throw Exception("Test exception")
        })
        let exn1 = @AssertThrows[Exception](future.execute())
        let exn2 = @AssertThrows[Exception](future.get())
        @Expect(exn1.message, "Test exception")
        @Expect(exn2.message, "Test exception")
    }

    @TestCase
    func testLocalActorFutureTryGetWithException() {
        let future = LocalActorFuture<Int64>({ =>
            throw Exception("Test exception")
        })
        let exn = @AssertThrows[Exception](future.execute())
        @Expect(exn.message, "Test exception")
        // tryGet() should throw the exception directly, not return Some
        let thrownExn = @AssertThrows[Exception](future.tryGet())
        @Expect(thrownExn.message, "Test exception")
    }

    // Test DistributedActorFuture basic functionality
    @TestCase
    func testDistributedActorFutureBasicFulfill() {
        let future = DistributedActorFuture<Int64>()
        let success = future.fulfill(42)
        @Expect(success, true)
        let result = future.get()
        @Expect(result, 42)
    }

    @TestCase
    func testDistributedActorFutureFulfillWithString() {
        let future = DistributedActorFuture<String>()
        let success = future.fulfill("hello world")
        @Expect(success, true)
        let result = future.get()
        @Expect(result, "hello world")
    }

    @TestCase
    func testDistributedActorFutureFulfillWithException() {
        let future = DistributedActorFuture<Int64>()
        let err = Exception("Test error")
        let success = future.fulfill(err)
        @Expect(success, true)
        let thrownErr = @AssertThrows[Exception](future.get())
        @Expect(thrownErr.message, "Test error")
    }

    @TestCase
    func testDistributedActorFutureTryGetBeforeFulfill() {
        let future = DistributedActorFuture<Int64>()
        let result = future.tryGet()
        @Expect(result.isSome(), false)
    }

    @TestCase
    func testDistributedActorFutureTryGetAfterFulfill() {
        let future = DistributedActorFuture<Int64>()
        future.fulfill(42)
        let result = future.tryGet()
        @Expect(result.isSome(), true)
        @Expect(result.getOrThrow(), 42)
    }

    @TestCase
    func testDistributedActorFutureDoubleFulfill() {
        let future = DistributedActorFuture<Int64>()
        let success1 = future.fulfill(42)
        let success2 = future.fulfill(100)
        @Expect(success1, true)
        @Expect(success2, false) // Second fulfill should fail
        let result = future.get()
        @Expect(result, 42) // Should still be the first value
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
    func testMultipleLocalActorFutures() {
        let future1 = LocalActorFuture<Int64>({ => 1 })
        let future2 = LocalActorFuture<Int64>({ => 2 })
        let future3 = LocalActorFuture<Int64>({ => 3 })

        future1.execute()
        future2.execute()
        future3.execute()

        @Expect(future1.get(), 1)
        @Expect(future2.get(), 2)
        @Expect(future3.get(), 3)
    }

    @TestCase
    func testMultipleDistributedActorFutures() {
        let future1 = DistributedActorFuture<Int64>()
        let future2 = DistributedActorFuture<Int64>()
        let future3 = DistributedActorFuture<Int64>()

        future1.fulfill(10)
        future2.fulfill(20)
        future3.fulfill(30)

        @Expect(future1.get(), 10)
        @Expect(future2.get(), 20)
        @Expect(future3.get(), 30)
    }

    @TestCase
    func testMixedLocalActorFutures() {
        let successFuture = LocalActorFuture<Int64>({ => 42 })
        let failureFuture = LocalActorFuture<Int64>({ =>
            throw Exception("Task failed")
        })

        successFuture.execute()
        let exn1 = @AssertThrows[Exception](failureFuture.execute())
        @Expect(exn1.message, "Task failed")

        @Expect(successFuture.get(), 42)
        let exn2 = @AssertThrows[Exception](failureFuture.get())
        @Expect(exn2.message, "Task failed")
    }

    @TestCase
    func testMixedDistributedActorFutures() {
        let successFuture = DistributedActorFuture<Int64>()
        let failureFuture = DistributedActorFuture<Int64>()
        successFuture.fulfill(42)
        failureFuture.fulfill(Exception("Fulfill failed"))

        @Expect(successFuture.get(), 42)
        let exn = @AssertThrows[Exception](failureFuture.get())
        @Expect(exn.message, "Fulfill failed")
    }
}