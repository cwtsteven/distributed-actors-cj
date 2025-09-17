import std.collection.*

import serialization.serialization.*
import encoding.json.*

import actors.*
import actors.macros.*
import actors.dummy_actor_system.*

@ActorInterface[
    distributed: true,
    description: "This is a test service",
    customInfo: """
        { "service": "test" }
    """
]
public interface Service {

    @Receiver[
        description: "This is foo function",
        customInfo: """
            { "foo": "bar" }
        """
    ]
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

main() {
    let myService = MyService()
    let system = DummyActorSystem()
    system.register<Service>("myService", myService)

    let proxy = ActorProxy("myService", system)
    let fut = proxy.post<Int64>("foo", [0.serialize()])
    println(fut.get())

    let infos = system.findAll()
    println("Metadata count: ${infos.size}")
    for ((name, metadata) in infos) {
        println("Service: ${name}")
        println("Metadata: ${metadata.toString()}")
        println()
    }
}