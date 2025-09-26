package actors.tcp_actor_system.tests

import std.unittest.*
import std.unittest.testmacro.*
import std.collection.*
import encoding.json.*

import actors.*
import actors.distributed.*
import actors.tcp_actor_system.*

@Test
public class MetadataSerializationTest {

    @TestCase
    func testMetadataSerializationRoundTrip() {
        // Create test metadata with different receiver modes
        let paramSchema = ArrayList<ReceiverParameter>()
        paramSchema.append(ReceiverParameter(name: "message", typeModel: TypeModel.StringType, description: "Message to echo"))
        paramSchema.append(ReceiverParameter(name: "count", typeModel: TypeModel.IntType, description: "Number of times to echo"))

        let receiverInfo1 = ReceiverInfo(
            description: "Echo a message multiple times",
            customInfo: JsonObject.fromStr("{\"test\": true}").asObject(),
            methodName: "echo",
            paramSchema: paramSchema.toArray(),
            retTypeModel: TypeModel.StringType,
            mode: ReceiverMode.AskAndTell
        )

        let paramSchema2 = ArrayList<ReceiverParameter>()
        paramSchema2.append(ReceiverParameter(name: "value", typeModel: TypeModel.IntType, description: "Value to increment by"))

        let receiverInfo2 = ReceiverInfo(
            description: "Increment counter",
            customInfo: JsonObject.fromStr("{\"counter\": true}").asObject(),
            methodName: "increment",
            paramSchema: paramSchema2.toArray(),
            retTypeModel: TypeModel.IntType,
            mode: ReceiverMode.AskOnly
        )

        let receivers = ArrayList<ReceiverInfo>()
        receivers.append(receiverInfo1)
        receivers.append(receiverInfo2)

        let metadata = Metadata(
            receivers: receivers.toArray(),
            description: "Test actor for various operations",
            customInfo: JsonObject.fromStr("{\"test-actor\": true}").asObject()
        )

        // Serialize metadata
        let serializedBytes = serializeMetadata(metadata)
        @Expect(serializedBytes.size > 0, true)

        // Deserialize metadata
        let deserializedMetadata = deserializeMetadata(serializedBytes)

        // Verify receivers
        @Expect(deserializedMetadata.receivers.size, 2)

        // Verify first receiver
        let deserializedReceiver1 = deserializedMetadata.receivers[0]
        @Expect(deserializedReceiver1.methodName, "echo")
        @Expect(deserializedReceiver1.description, "Echo a message multiple times")
        @Expect(deserializedReceiver1.retTypeModel, TypeModel.StringType)
        @Expect(deserializedReceiver1.mode, ReceiverMode.AskAndTell)
        @Expect(deserializedReceiver1.paramSchema.size, 2)
        @Expect(deserializedReceiver1.paramSchema[0].name, "message")
        @Expect(deserializedReceiver1.paramSchema[0].typeModel, TypeModel.StringType)
        @Expect(deserializedReceiver1.paramSchema[0].description, "Message to echo")
        @Expect(deserializedReceiver1.paramSchema[1].name, "count")
        @Expect(deserializedReceiver1.paramSchema[1].typeModel, TypeModel.IntType)
        @Expect(deserializedReceiver1.paramSchema[1].description, "Number of times to echo")

        // Verify second receiver
        let deserializedReceiver2 = deserializedMetadata.receivers[1]
        @Expect(deserializedReceiver2.methodName, "increment")
        @Expect(deserializedReceiver2.description, "Increment counter")
        @Expect(deserializedReceiver2.retTypeModel, TypeModel.IntType)
        @Expect(deserializedReceiver2.mode, ReceiverMode.AskOnly)
        @Expect(deserializedReceiver2.paramSchema.size, 1)
        @Expect(deserializedReceiver2.paramSchema[0].name, "value")
        @Expect(deserializedReceiver2.paramSchema[0].typeModel, TypeModel.IntType)
        @Expect(deserializedReceiver2.paramSchema[0].description, "Value to increment by")

        // Verify metadata fields
        @Expect(deserializedMetadata.description, "Test actor for various operations")
    }

    @TestCase
    func testReceiverModeSerialization() {
        // Test all receiver modes
        let modes = [ReceiverMode.AskOnly, ReceiverMode.TellOnly, ReceiverMode.AskAndTell]

        for (mode in modes) {
            let paramSchema = ArrayList<ReceiverParameter>()
            let receiverInfo = ReceiverInfo(
                description: "Test receiver",
                customInfo: JsonObject.fromStr("{\"test\": true}").asObject(),
                methodName: "test",
                paramSchema: paramSchema.toArray(),
                retTypeModel: TypeModel.UnitType,
                mode: mode
            )

            let receivers = ArrayList<ReceiverInfo>()
            receivers.append(receiverInfo)

            let metadata = Metadata(
                receivers: receivers.toArray(),
                description: "Test actor",
                customInfo: JsonObject.fromStr("{\"test\": true}").asObject()
            )

            // Serialize and deserialize
            let serializedBytes = serializeMetadata(metadata)
            let deserializedMetadata = deserializeMetadata(serializedBytes)

            // Verify mode is preserved
            @Expect(deserializedMetadata.receivers[0].mode, mode)
        }
    }

    @TestCase
    func testEmptyMetadataSerialization() {
        // Test with empty receivers
        let metadata = Metadata(
            receivers: Array<ReceiverInfo>(
                0, item: ReceiverInfo(
                            description: "",
                            customInfo: JsonObject.fromStr("{}").asObject(),
                            methodName: "",
                            paramSchema: Array<ReceiverParameter>(0, item: ReceiverParameter(name: "", typeModel: TypeModel.UnitType, description: "")),
                            retTypeModel: TypeModel.UnitType,
                            mode: ReceiverMode.AskOnly)),
            description: "Empty actor",
            customInfo: JsonObject.fromStr("{\"empty\": true}").asObject()
        )

        // Serialize and deserialize
        let serializedBytes = serializeMetadata(metadata)
        let deserializedMetadata = deserializeMetadata(serializedBytes)

        // Verify empty metadata
        @Expect(deserializedMetadata.receivers.size, 0)
        @Expect(deserializedMetadata.description, "Empty actor")
    }

    @TestCase
    func testComplexMetadataSerialization() {
        // Test with complex parameter schemas and different types
        let paramSchema = ArrayList<ReceiverParameter>()
        paramSchema.append(ReceiverParameter(name: "name", typeModel: TypeModel.StringType, description: "User's name"))
        paramSchema.append(ReceiverParameter(name: "age", typeModel: TypeModel.IntType, description: "User's age"))
        paramSchema.append(ReceiverParameter(name: "height", typeModel: TypeModel.FloatType, description: "User's height"))
        paramSchema.append(ReceiverParameter(name: "isActive", typeModel: TypeModel.BoolType, description: "Whether user is active"))

        let receiverInfo = ReceiverInfo(
            description: "Complex receiver with multiple parameter types",
            customInfo: JsonObject.fromStr("{\"complex\": true}").asObject(),
            methodName: "processUser",
            paramSchema: paramSchema.toArray(),
            retTypeModel: TypeModel.StringType,
            mode: ReceiverMode.TellOnly
        )

        let receivers = ArrayList<ReceiverInfo>()
        receivers.append(receiverInfo)

        let metadata = Metadata(
            receivers: receivers.toArray(),
            description: "Complex actor with various parameter types",
            customInfo: JsonObject.fromStr("{\"complex-actor\": true}").asObject()
        )

        // Serialize and deserialize
        let serializedBytes = serializeMetadata(metadata)
        let deserializedMetadata = deserializeMetadata(serializedBytes)

        // Verify complex metadata
        @Expect(deserializedMetadata.receivers.size, 1)

        let deserializedReceiver = deserializedMetadata.receivers[0]
        @Expect(deserializedReceiver.methodName, "processUser")
        @Expect(deserializedReceiver.mode, ReceiverMode.TellOnly)
        @Expect(deserializedReceiver.paramSchema.size, 4)

        // Verify parameter types
        @Expect(deserializedReceiver.paramSchema[0].name, "name")
        @Expect(deserializedReceiver.paramSchema[0].typeModel, TypeModel.StringType)
        @Expect(deserializedReceiver.paramSchema[0].description, "User's name")
        @Expect(deserializedReceiver.paramSchema[1].name, "age")
        @Expect(deserializedReceiver.paramSchema[1].typeModel, TypeModel.IntType)
        @Expect(deserializedReceiver.paramSchema[1].description, "User's age")
        @Expect(deserializedReceiver.paramSchema[2].name, "height")
        @Expect(deserializedReceiver.paramSchema[2].typeModel, TypeModel.FloatType)
        @Expect(deserializedReceiver.paramSchema[2].description, "User's height")
        @Expect(deserializedReceiver.paramSchema[3].name, "isActive")
        @Expect(deserializedReceiver.paramSchema[3].typeModel, TypeModel.BoolType)
        @Expect(deserializedReceiver.paramSchema[3].description, "Whether user is active")
    }
}
