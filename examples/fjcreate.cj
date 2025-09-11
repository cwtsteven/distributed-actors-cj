import actors.*
import actors.macros.*

import std.collection.ArrayList

import std.runtime.*

@Actor
class ForkJoinActor {
    var state = 0.0
    @Receiver[mode: AskOnly]
    func ping(): Unit {
        state += 37.2
    }
}

public func run(numActors: Int64) {
    let futures = ArrayList<LocalActorFuture<Unit>>(numActors)
    for (_ in 0..numActors) {
        let actor = ForkJoinActor()
        futures.add(actor.ping())
    }

    for (future in futures) {
        future.get()
    }
}


main(): Unit {
    for (_ in 0..1000) {
        run(100)
        println("Num cangjie threads: ${getThreadCount()}")
        println("Garbage collector has been called ${getGCCount()} times")
    }
}