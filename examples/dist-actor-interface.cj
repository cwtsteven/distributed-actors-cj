import std.collection.*

import stdx.serialization.serialization.*

import actors.*
import actors.macros.*

@ActorInterface[distributed: true]
public interface Service {

    @Receiver
    func foo(x: Int64): Int64
}

@Actor
public class MyService <: Service {

    @Receiver
    public func foo(x: Int64): Int64 { 
        println("inside foo")
        x + 42 
    }
}

func test(s: Service) {
    s.foo(0).get()
}

main() {
    let actorSystem = DummyActorSystem()
    let myService = MyService()
    println(actorSystem.register<Service>("myService", myService))
    println(test(myService))

    let proxy = actorSystem.findGeneric("myService").getOrThrow()
    let fut = proxy.post<Any>(ReceiverInfo("foo", [], AnyType), [10.serialize()])
    let res = fut.get()
    println((res as Int64).getOrThrow())
}