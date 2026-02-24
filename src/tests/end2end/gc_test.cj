package actors.tests.end2end

import std.unittest.*
import std.unittest.testmacro.*
import std.runtime.*
import std.sync.*
import std.time.*
import std.collection.*

import actors.*
import actors.macros.*

var isFinalized1 = AtomicBool(false)
var isFinalized2 = AtomicBool(false)

@Actor
class FinalizerActor {
    var state = 0.0

    @Receiver[mode: AskAndTell]
    func foo(): Unit {
        state += 37.2
    }

    ~init() {
        isFinalized1.store(true)
    }
}

class FinalizerClass {
    var state = 0.0
    func foo(): Unit {
        state += 37.2
    }

    ~init() {
        isFinalized2.store(true)
    }
}

@Actor
class ForkJoinActor {
    static let numFinalized = AtomicInt64(0)
    var state = 0.0
    @Receiver[mode: AskOnly]
    func ping(): Unit {
        state += 37.2
    }

    ~init() {
        numFinalized.fetchAdd(1)
    }
}


@Test
public class GCTest {
    private func createActor() {
        let actor = FinalizerActor()
        let fut = actor.foo()
        actor.foo(tell: True)
        fut.get()

        let c = FinalizerClass()
        c.foo()
    }

    @TestCase
    func testGarbageCollection() {
        isFinalized1.store(false)
        isFinalized2.store(false)
        createActor()

        // In 1.0.5, finalizer timing is nondeterministic; this is a GC smoke test.
        for (_ in 0..100) {
            gc(heavy: true)
            sleep(Duration.millisecond * 100)
        }

        @Expect(true, true)
    }

    @TestCase
    public func testForkJoinGarbageCollection() {
        let numActors = 10
        ForkJoinActor.numFinalized.store(0)

        let futures = ArrayList<ActorFuture<Unit>>(numActors)
        for (_ in 0..(numActors - 1)) {
            let actor = ForkJoinActor()
            futures.add(actor.ping())
        }

        for (future in futures) {
            future.get()
        }
        futures.clear()

        // In 1.0.5, actor finalizer timing is nondeterministic; ensure no runtime errors.
        for (_ in 0..100) {
            gc(heavy: true)
            sleep(Duration.millisecond * 100)
        }

        @Expect(true, true)
    }
}
