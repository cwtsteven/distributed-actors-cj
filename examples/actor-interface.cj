import actors.*
import actors.macros.*

@ActorInterface
public interface Service {

    @Receiver
    func foo(): Int64
}

@Actor
public class MyService <: Service & Supervisable {

    @Receiver
    public func foo(): Int64 { 42 }
}

func test(s: Service) {
    s.foo(config: ReceiverConfig.default).get()
}

main() {
    let myService = MyService()
    println(test(myService))
}