package actors.tcp_actor_system.tests

import std.unittest.*
import std.unittest.testmacro.*
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

@Test
public class TCPServerClientE2ETest {
    @TestCase
    func testTCPServerClientE2E() {
        let service = TestServiceImpl()
        let host = TCPActorHost(bindAt: 52185)
        host.register("testService", service)
        host.serve()

        let client = TCPActorClient("localhost", 5218)
        let proxy = ActorProxy("testService", client)
        let fut = proxy.post<Int64>("addTen", [5.serialize()])
        let result = fut.get()
        @Expect(result, 15)

        client.close()
        host.close()
    }
}