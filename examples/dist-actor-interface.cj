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
    let host = DummyActorHost()
    let client = DummyActorClient(host)
    host.register("myService", myService)

    let proxy = ActorProxy("myService", client)
    let fut = proxy.post<Int64>("foo", [0.serialize()])
    println(fut.get())

    let infos = client.findAll()
    println("Metadata count: ${infos.size}")
    for (info in infos) {
        println("Service: ${info.name}")
        println("Metadata: ${info.metadata.toString()}")
        println()
    }
}