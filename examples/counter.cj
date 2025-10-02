import actors.*
import actors.macros.*

@Actor
public class Counter {
    private var value: Int64 = 0

    @Receiver
    public func increment(): Int64 {
        value += 1
        return value
    }

    @Receiver
    public func getValue(): Int64 {
        return value
    }
}

main() {
    let counter = Counter()
    let future = counter.increment()
    println("Counter value: ${future.get()}")
}