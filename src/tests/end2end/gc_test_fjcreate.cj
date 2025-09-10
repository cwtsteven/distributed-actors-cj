package actors.tests.end2end

import actors.*
import actors.macros.*

import std.unittest.*
import std.unittest.testmacro.*
import std.sync.*

import std.collection.ArrayList
import std.runtime.*


@Actor
class ForkJoinActor {
    public static let numFinalized = AtomicInt64(0)
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
class ForkJoinCreateTest {
    @TestCase
    public func testForkJoinGarbageCollection() {
        let numActors = 100
        ForkJoinActor.numFinalized.store(0)

        let futures = ArrayList<LocalActorFuture<Unit>>(numActors)
        for (_ in 0..numActors) {
            let actor = ForkJoinActor()
            futures.add(actor.ping())
        }

        for (future in futures) {
            future.get()
        }

        // Give more time for GC to occur and force GC if possible
        for (_ in 0..100) {
            gc(heavy: true)
            sleep(Duration.millisecond * 100)
            if (ForkJoinActor.numFinalized.load() == numActors) {
                break
            }
        }

        @Expect(ForkJoinActor.numFinalized.load() == numActors)
    }
}