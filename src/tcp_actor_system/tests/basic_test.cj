package actors.tcp_actor_system.tests

import std.unittest.*
import std.unittest.testmacro.*
import std.collection.*
import std.time.*
import std.sync.*

import actors.*
import actors.macros.*
import actors.distributed.*
import actors.tcp_actor_system.*
import stdx.serialization.serialization.*

@Test
public class BasicTest {

    @TestCase
    func testPayloadCreation() {
        var findPayload = Payload.Find("testActor")
        @Expect(findPayload.toString(), "Find(testActor)")
    }

    @TestCase
    func testEnvelopeCreation() {
        var envelope = Envelope(123, Payload.Ok)
        @Expect(envelope.id, 123)
    }

    @TestCase
    func testReceiverConfig() {
        let config = ReceiverConfig(priority: 3)
        @Expect(config.priority, 3)

        let defaultConfig = ReceiverConfig()
        @Expect(defaultConfig.priority, 5)
    }

    @TestCase
    func testDataModelTypes() {
        // Test that DataModel classes can be created
        let stringData = DataModelString("hello")
        @Expect(true, true)  // Creation successful

        let intData = DataModelInt(42)
        @Expect(true, true)  // Creation successful

        let boolData = DataModelBool(true)
        @Expect(true, true)  // Creation successful
    }
}
