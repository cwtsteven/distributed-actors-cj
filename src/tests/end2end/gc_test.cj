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

    @Receiver[mode: AskAndTell]
    func foo(): Unit {
        // Empty function body
    }

    ~init() {
        isFinalized1.store(true)
    }
}

class FinalizerClass {
    func foo(): Unit {
        // Empty function body
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
        spawn {
            let actor = FinalizerActor()
            let fut = actor.foo()
            actor.foo(tell: True)
            fut.get()

            let c = FinalizerClass()
            c.foo()
        }
    }

    @TestCase
    func testGarbageCollection() {
        createActor()

        // Give more time for GC to occur and force GC if possible
        for (_ in 0..100) {
            GC(heavy: true)
            sleep(Duration.millisecond * 100)
            if (isFinalized1.load() || isFinalized2.load()) {
                break
            }
        }

        @Expect(isFinalized1.load(), true)
        @Expect(isFinalized2.load(), true)
    }

    @TestCase
    public func testForkJoinGarbageCollection() {
        let numActors = 10
        ForkJoinActor.numFinalized.store(0)

        let futures = ArrayList<LocalActorFuture<Unit>>(numActors)
        for (_ in 0..numActors) {
            let actor = ForkJoinActor()
            futures.append(actor.ping())
        }

        for (future in futures) {
            future.get()
        }

        // Give more time for GC to occur
        for (_ in 0..100) {
            GC(heavy: true)
            sleep(Duration.millisecond * 100)
            if (ForkJoinActor.numFinalized.load() == numActors) {
                break
            }
        }

        @Expect(ForkJoinActor.numFinalized.load() == numActors)
    }
}