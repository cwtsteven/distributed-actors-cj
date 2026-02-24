import std.runtime.*
import std.sync.*

import actors.*
import actors.macros.*

var isFinalized1 = AtomicBool(false)
var isFinalized2 = AtomicBool(false)

@Actor
class FinalizerActor {

    var state = 0.0

    @Receiver
    func foo(): Unit {
        state += 37.2
    }

    ~init() {
        println("FinalizerActor finalized.")
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

main() {
    createActor()

    // Give more time for GC to occur and force GC if possible
    for (_ in 0..100) {
        gc(heavy: true)
        sleep(Duration.millisecond * 100)
        if (isFinalized1.load() || isFinalized2.load()) {
            break
        }
    }

    println("isFinalized1: ${isFinalized1.load()}, isFinalized2: ${isFinalized2.load()}")
}
