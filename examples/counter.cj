import actors.*
import actors.macros.*

@Actor
public class Counter {
    private var count = 0

    @Receiver[mode: AskAndTell]
    public func incrementAndGet(): Int64 {
        count++
        return count
    }
}

main() {
    let counter = Counter()
    let limit = 100
    var res = None<Int64>
    for (i in 0..limit) {
        if (i == limit - 1) {
            // synchronize with the counter thread at the end
            res = counter.incrementAndGet().get()
        } else {
            // fire and forget
            counter.incrementAndGet(tell: True)
        }
    }
    println("Counted until ${limit}, got ${res}")
}
