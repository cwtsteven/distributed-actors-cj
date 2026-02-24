import actors.*
import actors.macros.*

import std.sync.*

let finalCount = AtomicInt64(0)

@Actor
class ForkJoinActor {
    var state = 0.0

    @Receiver
    func ping(): Unit {
        state += 37.2
    }

    ~init() {
        println("ForkJoinActor finalized.")
        finalCount.fetchAdd(1)
    }
}

public func run() {
    spawn {
        let actor = ForkJoinActor()
        actor.ping(tell: True)
    }
}

func createActor(numRuns: Int64) {
    for (_ in 0..numRuns) {
        run()
    }
}

main(): Unit {
    let numRuns = 100

    createActor(numRuns)

    for (_ in 0..numRuns) {
        sleep(Duration.millisecond * 100)
        if (finalCount.load() == numRuns) {
            break
        }
        println("Final count: ${finalCount.load()}") // 100
    }
}
