package actors.dummy_actor_system

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*

import stdx.encoding.json.*
import stdx.serialization.serialization.*

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
public class TestServiceImpl <: TestService & Supervisable {
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
        let system = DummyActorSystem()
        system.register<TestService>("testService", service)
        let proxy = ActorProxy("testService", system)
        let fut = proxy.post<Int64>("addTen", [5.serialize()])
        let result = fut.get()
        @Expect(result, 15)
        // Also check metadata
        let infos = system.findAll()
        @Expect(infos.size, 1)
        let (name, metadata) = infos[0]
        @Expect(name, "testService")
        @Expect(metadata.description, "Test distributed service")
    }
}
