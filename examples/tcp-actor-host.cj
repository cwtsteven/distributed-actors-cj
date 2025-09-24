import std.collection.*
import std.collection.concurrent.*
import std.time.*
import std.sync.*
import std.socket.*

import actors.*
import actors.macros.*
import actors.tcp_actor_system.*
import serialization.serialization.*
import encoding.json.*

@ActorInterface[
    distributed: true,
    description: "Test distributed service"
]
public interface TestService {
    @Receiver[description: "Adds 10 to input"]
    func addTen(x: Int64): Int64
}

@Actor
public class TestServiceImpl <: TestService {
    @Receiver
    public func addTen(x: Int64): Int64 {
        x + 10
    }
}

main() {
    let service = TestServiceImpl()
    let host = TCPActorHost(bindAt: 52185)
    host.register("testService", service)
    host.serve()
    while (true) {
        sleep(Duration.second)
    }
}