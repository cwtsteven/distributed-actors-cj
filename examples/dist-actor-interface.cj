import std.collection.*

import serialization.serialization.*
import encoding.json.*

import actors.*
import actors.macros.*
import actors.distributed.*
import actors.tcp_actor_system.*

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
    let tcpHost = TCPActorHost(bindAt: 52165)
    tcpHost.export("myService", myService)
    tcpHost.serve()

    let tcpClient = TCPActorClient("client-1", "localhost", 52165)
    let proxy = ActorProxy("myService", tcpClient)
    let fut = proxy.ask("foo", [0.serialize()])
    println(Int64.deserialize(fut.get()))

    let typedProxy = Service.getProxy("myService", tcpClient)
    let typedFut: ActorFuture<Int64> = typedProxy.foo(0)
    println(typedFut.get())

    let infos = tcpClient.findAll()
    println("Metadata count: ${infos.size}")
    for (info in infos) {
        println("Service: ${info.name}")
        println("Metadata: ${info.metadata.toString()}")
        println()
    }
}