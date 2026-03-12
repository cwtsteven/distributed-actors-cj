import actors.*
import actors.macros.*

@ActorInterface[enableReceiverPriority: true]
public interface PriorityService {

    @Receiver[priority: 10]
    func highPriorityTask(): String

    @Receiver[priority: 1]
    func lowPriorityTask(): String
}

@Actor[enableReceiverPriority: true]
public class PriorityServiceImpl <: PriorityService {
    private var counter: Int64 = 0

    @Receiver[priority: 10]
    public func highPriorityTask(): String {
        counter++
        "high_priority_${counter}"
    }

    @Receiver[priority: 1]
    public func lowPriorityTask(): String {
        counter++
        "low_priority_${counter}"
    }
}

func run(service: PriorityService) {
    println(service.highPriorityTask(config: ReceiverConfig.default).get())
    println(service.lowPriorityTask(config: ReceiverConfig.default).get())
}

main() {
    let service = PriorityServiceImpl()
    run(service)
}
