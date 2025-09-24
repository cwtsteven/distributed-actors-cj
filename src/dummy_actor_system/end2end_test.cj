package actors.dummy_actor_system

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*

import encoding.json.*
import serialization.serialization.*

import actors.*
import actors.macros.*

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
public class DummyActorSystemEnd2EndTest {
    @TestCase
    func testDistributedActorInterfaceWithDummySystem() {
        let service = TestServiceImpl()
        let host = DummyActorHost()
        host.register("testService", service)
        let client = DummyActorClient(host)
        let proxy = ActorProxy("testService", client)
        let fut = proxy.post<Int64>("addTen", [5.serialize()])
        let result = fut.get()
        @Expect(result, 15)
        // Also check metadata
        let infos = client.findAll()
        @Expect(infos.size, 1)
        let info = infos[0]
        @Expect(info.name, "testService")
        @Expect(info.metadata.description, "Test distributed service")
    }
}
