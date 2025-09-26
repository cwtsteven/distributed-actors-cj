package actors.tests

import std.unittest.*
import std.unittest.testmacro.*

import actors.*
import serialization.serialization.*

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
        future.execute()
        let exn = @AssertThrows[Exception](future.get())
        @Expect(exn.message, "Test exception")
    }

    @TestCase
    func testLocalActorFutureTryGetWithException() {
        let future = LocalActorFuture<Int64>({ =>
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
    func testMixedLocalActorFutures() {
        let successFuture = LocalActorFuture<Int64>({ => 42 })
        let failureFuture = LocalActorFuture<Int64>({ =>
            throw Exception("Task failed")
        })

        successFuture.execute()
        failureFuture.execute()

        @Expect(successFuture.get(), 42)
        let exn = @AssertThrows[Exception](failureFuture.get())
        @Expect(exn.message, "Task failed")
    }

}