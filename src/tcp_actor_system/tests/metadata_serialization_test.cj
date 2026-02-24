package actors.tcp_actor_system.tests

import std.unittest.*
import std.unittest.testmacro.*
import std.collection.*
import stdx.encoding.json.*

import actors.*
import actors.distributed.*
import actors.tcp_actor_system.*

@Test
public class MetadataSerializationTest {

    @TestCase
    func testMetadataSerializationRoundTrip() {
        // Create test metadata with different receiver modes
        let paramSchema = ArrayList<ReceiverParameter>()
        paramSchema.add(ReceiverParameter(name: "message", typeModel: TypeModel.StringType, description: "Message to echo"))
        paramSchema.add(ReceiverParameter(name: "count", typeModel: TypeModel.IntType, description: "Number of times to echo"))

        let receiverInfo1 = ReceiverInfo(
            description: "Echo a message multiple times",
            customInfo: JsonObject.fromStr("{\"test\": true}").asObject(),
            methodName: "echo",
            paramSchema: paramSchema.toArray(),
            retTypeModel: TypeModel.StringType,
            mode: ReceiverMode.AskAndTell
        )

        let paramSchema2 = ArrayList<ReceiverParameter>()
        paramSchema2.add(ReceiverParameter(name: "value", typeModel: TypeModel.IntType, description: "Value to increment by"))

        let receiverInfo2 = ReceiverInfo(
            description: "Increment counter",
            customInfo: JsonObject.fromStr("{\"counter\": true}").asObject(),
            methodName: "increment",
            paramSchema: paramSchema2.toArray(),
            retTypeModel: TypeModel.IntType,
            mode: ReceiverMode.AskOnly
        )

        let receivers = ArrayList<ReceiverInfo>()
        receivers.add(receiverInfo1)
        receivers.add(receiverInfo2)

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
            receivers.add(receiverInfo)

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
                0, { _ => ReceiverInfo(
                            description: "",
                            customInfo: JsonObject.fromStr("{}").asObject(),
                            methodName: "",
                            paramSchema: Array<ReceiverParameter>(0, { _ => ReceiverParameter(name: "", typeModel: TypeModel.UnitType, description: "") }),
                            retTypeModel: TypeModel.UnitType,
                            mode: ReceiverMode.AskOnly)}),
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
        paramSchema.add(ReceiverParameter(name: "name", typeModel: TypeModel.StringType, description: "User's name"))
        paramSchema.add(ReceiverParameter(name: "age", typeModel: TypeModel.IntType, description: "User's age"))
        paramSchema.add(ReceiverParameter(name: "height", typeModel: TypeModel.FloatType, description: "User's height"))
        paramSchema.add(ReceiverParameter(name: "isActive", typeModel: TypeModel.BoolType, description: "Whether user is active"))

        let receiverInfo = ReceiverInfo(
            description: "Complex receiver with multiple parameter types",
            customInfo: JsonObject.fromStr("{\"complex\": true}").asObject(),
            methodName: "processUser",
            paramSchema: paramSchema.toArray(),
            retTypeModel: TypeModel.StringType,
            mode: ReceiverMode.TellOnly
        )

        let receivers = ArrayList<ReceiverInfo>()
        receivers.add(receiverInfo)

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

    @TestCase
    func testStructTypeSerialization() {
        // Create a StructType with multiple fields
        let structFields = ArrayList<FieldModel>()
        structFields.add(FieldModel(name: "id", description: "User ID", typeModel: TypeModel.IntType))
        structFields.add(FieldModel(name: "name", description: "User name", typeModel: TypeModel.StringType))
        structFields.add(FieldModel(name: "isActive", description: "Active status", typeModel: TypeModel.BoolType))
        structFields.add(FieldModel(name: "score", description: "User score", typeModel: TypeModel.FloatType))

        let structType = TypeModel.StructType(structFields.toArray())

        // Create a receiver parameter using the StructType
        let paramSchema = ArrayList<ReceiverParameter>()
        paramSchema.add(ReceiverParameter(name: "user", typeModel: structType, description: "User information"))

        let receiverInfo = ReceiverInfo(
            description: "Process user with struct parameter",
            customInfo: JsonObject.fromStr("{\"struct-test\": true}").asObject(),
            methodName: "processUser",
            paramSchema: paramSchema.toArray(),
            retTypeModel: TypeModel.StringType,
            mode: ReceiverMode.AskAndTell
        )

        let receivers = ArrayList<ReceiverInfo>()
        receivers.add(receiverInfo)

        let metadata = Metadata(
            receivers: receivers.toArray(),
            description: "Actor with StructType parameter",
            customInfo: JsonObject.fromStr("{\"struct-actor\": true}").asObject()
        )

        // Serialize and deserialize
        let serializedBytes = serializeMetadata(metadata)
        let deserializedMetadata = deserializeMetadata(serializedBytes)

        // Verify StructType is preserved
        @Expect(deserializedMetadata.receivers.size, 1)
        let deserializedReceiver = deserializedMetadata.receivers[0]
        @Expect(deserializedReceiver.paramSchema.size, 1)

        let deserializedParam = deserializedReceiver.paramSchema[0]
        @Expect(deserializedParam.name, "user")
        @Expect(deserializedParam.description, "User information")

        // Verify the StructType and its fields
        match (deserializedParam.typeModel) {
            case StructType(fields) =>
                @Expect(fields.size, 4)
                @Expect(fields[0].name, "id")
                @Expect(fields[0].description, "User ID")
                @Expect(fields[0].typeModel, TypeModel.IntType)
                @Expect(fields[1].name, "name")
                @Expect(fields[1].description, "User name")
                @Expect(fields[1].typeModel, TypeModel.StringType)
                @Expect(fields[2].name, "isActive")
                @Expect(fields[2].description, "Active status")
                @Expect(fields[2].typeModel, TypeModel.BoolType)
                @Expect(fields[3].name, "score")
                @Expect(fields[3].description, "User score")
                @Expect(fields[3].typeModel, TypeModel.FloatType)
            case _ => @Expect(false, true) // Should not reach here
        }
    }

    @TestCase
    func testNestedStructTypeSerialization() {
        // Create a nested StructType (StructType containing another StructType)
        let innerFields = ArrayList<FieldModel>()
        innerFields.add(FieldModel(name: "x", description: "X coordinate", typeModel: TypeModel.FloatType))
        innerFields.add(FieldModel(name: "y", description: "Y coordinate", typeModel: TypeModel.FloatType))
        let innerStruct = TypeModel.StructType(innerFields.toArray())

        let outerFields = ArrayList<FieldModel>()
        outerFields.add(FieldModel(name: "position", description: "Entity position", typeModel: innerStruct))
        outerFields.add(FieldModel(name: "name", description: "Entity name", typeModel: TypeModel.StringType))
        let outerStruct = TypeModel.StructType(outerFields.toArray())

        // Create a receiver parameter using the nested StructType
        let paramSchema = ArrayList<ReceiverParameter>()
        paramSchema.add(ReceiverParameter(name: "entity", typeModel: outerStruct, description: "Entity with nested position"))

        let receiverInfo = ReceiverInfo(
            description: "Process entity with nested struct",
            customInfo: JsonObject.fromStr("{\"nested-test\": true}").asObject(),
            methodName: "processEntity",
            paramSchema: paramSchema.toArray(),
            retTypeModel: TypeModel.UnitType,
            mode: ReceiverMode.TellOnly
        )

        let receivers = ArrayList<ReceiverInfo>()
        receivers.add(receiverInfo)

        let metadata = Metadata(
            receivers: receivers.toArray(),
            description: "Actor with nested StructType parameter",
            customInfo: JsonObject.fromStr("{\"nested-actor\": true}").asObject()
        )

        // Serialize and deserialize
        let serializedBytes = serializeMetadata(metadata)
        let deserializedMetadata = deserializeMetadata(serializedBytes)

        // Verify nested StructType is preserved
        @Expect(deserializedMetadata.receivers.size, 1)
        let deserializedReceiver = deserializedMetadata.receivers[0]
        @Expect(deserializedReceiver.paramSchema.size, 1)

        let deserializedParam = deserializedReceiver.paramSchema[0]
        @Expect(deserializedParam.name, "entity")

        // Verify the nested StructType structure
        match (deserializedParam.typeModel) {
            case StructType(outerFields) =>
                @Expect(outerFields.size, 2)
                @Expect(outerFields[0].name, "position")
                @Expect(outerFields[0].description, "Entity position")
                @Expect(outerFields[1].name, "name")
                @Expect(outerFields[1].description, "Entity name")
                @Expect(outerFields[1].typeModel, TypeModel.StringType)

                // Verify the inner struct
                match (outerFields[0].typeModel) {
                    case StructType(innerFields) =>
                        @Expect(innerFields.size, 2)
                        @Expect(innerFields[0].name, "x")
                        @Expect(innerFields[0].description, "X coordinate")
                        @Expect(innerFields[0].typeModel, TypeModel.FloatType)
                        @Expect(innerFields[1].name, "y")
                        @Expect(innerFields[1].description, "Y coordinate")
                        @Expect(innerFields[1].typeModel, TypeModel.FloatType)
                    case _ => @Expect(false, true) // Should not reach here
                }
            case _ => @Expect(false, true) // Should not reach here
        }
    }

    @TestCase
    func testEmptyStructTypeSerialization() {
        // Create an empty StructType (no fields)
        let emptyStruct = TypeModel.StructType(Array<FieldModel>(0, { _ => FieldModel(name: "", description: "", typeModel: TypeModel.UnitType) }))

        // Create a receiver parameter using the empty StructType
        let paramSchema = ArrayList<ReceiverParameter>()
        paramSchema.add(ReceiverParameter(name: "empty", typeModel: emptyStruct, description: "Empty struct"))

        let receiverInfo = ReceiverInfo(
            description: "Process empty struct",
            customInfo: JsonObject.fromStr("{\"empty-struct\": true}").asObject(),
            methodName: "processEmpty",
            paramSchema: paramSchema.toArray(),
            retTypeModel: TypeModel.UnitType,
            mode: ReceiverMode.AskOnly
        )

        let receivers = ArrayList<ReceiverInfo>()
        receivers.add(receiverInfo)

        let metadata = Metadata(
            receivers: receivers.toArray(),
            description: "Actor with empty StructType parameter",
            customInfo: JsonObject.fromStr("{\"empty-actor\": true}").asObject()
        )

        // Serialize and deserialize
        let serializedBytes = serializeMetadata(metadata)
        let deserializedMetadata = deserializeMetadata(serializedBytes)

        // Verify empty StructType is preserved
        @Expect(deserializedMetadata.receivers.size, 1)
        let deserializedReceiver = deserializedMetadata.receivers[0]
        @Expect(deserializedReceiver.paramSchema.size, 1)

        let deserializedParam = deserializedReceiver.paramSchema[0]
        @Expect(deserializedParam.name, "empty")

        // Verify the empty StructType
        match (deserializedParam.typeModel) {
            case StructType(fields) =>
                @Expect(fields.size, 0)
            case _ => @Expect(false, true) // Should not reach here
        }
    }

    @TestCase
    func testComplexStructTypeSerialization() {
        // Create a complex StructType with all basic types and nested structures
        let addressFields = ArrayList<FieldModel>()
        addressFields.add(FieldModel(name: "street", description: "Street address", typeModel: TypeModel.StringType))
        addressFields.add(FieldModel(name: "city", description: "City name", typeModel: TypeModel.StringType))
        addressFields.add(FieldModel(name: "zipCode", description: "ZIP code", typeModel: TypeModel.IntType))
        let addressStruct = TypeModel.StructType(addressFields.toArray())

        let personFields = ArrayList<FieldModel>()
        personFields.add(FieldModel(name: "id", description: "Person ID", typeModel: TypeModel.IntType))
        personFields.add(FieldModel(name: "name", description: "Person name", typeModel: TypeModel.StringType))
        personFields.add(FieldModel(name: "age", description: "Person age", typeModel: TypeModel.IntType))
        personFields.add(FieldModel(name: "height", description: "Person height", typeModel: TypeModel.FloatType))
        personFields.add(FieldModel(name: "isActive", description: "Active status", typeModel: TypeModel.BoolType))
        personFields.add(FieldModel(name: "address", description: "Person address", typeModel: addressStruct))
        let personStruct = TypeModel.StructType(personFields.toArray())

        // Create a receiver parameter using the complex StructType
        let paramSchema = ArrayList<ReceiverParameter>()
        paramSchema.add(ReceiverParameter(name: "person", typeModel: personStruct, description: "Complex person with address"))

        let receiverInfo = ReceiverInfo(
            description: "Process complex person data",
            customInfo: JsonObject.fromStr("{\"complex-struct\": true}").asObject(),
            methodName: "processPerson",
            paramSchema: paramSchema.toArray(),
            retTypeModel: TypeModel.StringType,
            mode: ReceiverMode.AskAndTell
        )

        let receivers = ArrayList<ReceiverInfo>()
        receivers.add(receiverInfo)

        let metadata = Metadata(
            receivers: receivers.toArray(),
            description: "Actor with complex StructType parameter",
            customInfo: JsonObject.fromStr("{\"complex-actor\": true}").asObject()
        )

        // Serialize and deserialize
        let serializedBytes = serializeMetadata(metadata)
        let deserializedMetadata = deserializeMetadata(serializedBytes)

        // Verify complex StructType is preserved
        @Expect(deserializedMetadata.receivers.size, 1)
        let deserializedReceiver = deserializedMetadata.receivers[0]
        @Expect(deserializedReceiver.paramSchema.size, 1)

        let deserializedParam = deserializedReceiver.paramSchema[0]
        @Expect(deserializedParam.name, "person")

        // Verify the complex StructType structure
        match (deserializedParam.typeModel) {
            case StructType(personFields) =>
                @Expect(personFields.size, 6)
                @Expect(personFields[0].name, "id")
                @Expect(personFields[0].description, "Person ID")
                @Expect(personFields[0].typeModel, TypeModel.IntType)
                @Expect(personFields[1].name, "name")
                @Expect(personFields[1].description, "Person name")
                @Expect(personFields[1].typeModel, TypeModel.StringType)
                @Expect(personFields[2].name, "age")
                @Expect(personFields[2].description, "Person age")
                @Expect(personFields[2].typeModel, TypeModel.IntType)
                @Expect(personFields[3].name, "height")
                @Expect(personFields[3].description, "Person height")
                @Expect(personFields[3].typeModel, TypeModel.FloatType)
                @Expect(personFields[4].name, "isActive")
                @Expect(personFields[4].description, "Active status")
                @Expect(personFields[4].typeModel, TypeModel.BoolType)
                @Expect(personFields[5].name, "address")
                @Expect(personFields[5].description, "Person address")

                // Verify the nested address struct
                match (personFields[5].typeModel) {
                    case StructType(addressFields) =>
                        @Expect(addressFields.size, 3)
                        @Expect(addressFields[0].name, "street")
                        @Expect(addressFields[0].description, "Street address")
                        @Expect(addressFields[0].typeModel, TypeModel.StringType)
                        @Expect(addressFields[1].name, "city")
                        @Expect(addressFields[1].description, "City name")
                        @Expect(addressFields[1].typeModel, TypeModel.StringType)
                        @Expect(addressFields[2].name, "zipCode")
                        @Expect(addressFields[2].description, "ZIP code")
                        @Expect(addressFields[2].typeModel, TypeModel.IntType)
                    case _ => @Expect(false, true) // Should not reach here
                }
            case _ => @Expect(false, true) // Should not reach here
        }
    }

    @TestCase
    func testListTypeSerialization() {
        // List of primitive type
        let listOfInt = TypeModel.ListType(TypeModel.IntType)

        // List of struct type
        let itemFields = ArrayList<FieldModel>()
        itemFields.add(FieldModel(name: "id", description: "Item ID", typeModel: TypeModel.IntType))
        itemFields.add(FieldModel(name: "label", description: "Item label", typeModel: TypeModel.StringType))
        let itemStruct = TypeModel.StructType(itemFields.toArray())
        let listOfStruct = TypeModel.ListType(itemStruct)

        // Two parameters to exercise both cases
        let paramSchema = ArrayList<ReceiverParameter>()
        paramSchema.add(ReceiverParameter(name: "numbers", typeModel: listOfInt, description: "List of numbers"))
        paramSchema.add(ReceiverParameter(name: "items", typeModel: listOfStruct, description: "List of items"))

        let receiverInfo = ReceiverInfo(
            description: "Receiver with list parameters",
            customInfo: JsonObject.fromStr("{\"list\": true}").asObject(),
            methodName: "processLists",
            paramSchema: paramSchema.toArray(),
            retTypeModel: TypeModel.UnitType,
            mode: ReceiverMode.TellOnly
        )

        let receivers = ArrayList<ReceiverInfo>()
        receivers.add(receiverInfo)

        let metadata = Metadata(
            receivers: receivers.toArray(),
            description: "Actor using ListType in metadata",
            customInfo: JsonObject.fromStr("{\"list-actor\": true}").asObject()
        )

        // Serialize and deserialize
        let serializedBytes = serializeMetadata(metadata)
        let deserializedMetadata = deserializeMetadata(serializedBytes)

        @Expect(deserializedMetadata.receivers.size, 1)
        let deserializedReceiver = deserializedMetadata.receivers[0]
        @Expect(deserializedReceiver.paramSchema.size, 2)

        // Verify first parameter is List<Int>
        @Expect(deserializedReceiver.paramSchema[0].name, "numbers")
        @Expect(deserializedReceiver.paramSchema[0].description, "List of numbers")
        match (deserializedReceiver.paramSchema[0].typeModel) {
            case ListType(itemType) => @Expect(itemType, TypeModel.IntType)
            case _ => @Expect(false, true)
        }

        // Verify second parameter is List<Struct>
        @Expect(deserializedReceiver.paramSchema[1].name, "items")
        @Expect(deserializedReceiver.paramSchema[1].description, "List of items")
        match (deserializedReceiver.paramSchema[1].typeModel) {
            case ListType(inner) =>
                match (inner) {
                    case StructType(fields) =>
                        @Expect(fields.size, 2)
                        @Expect(fields[0].name, "id")
                        @Expect(fields[0].description, "Item ID")
                        @Expect(fields[0].typeModel, TypeModel.IntType)
                        @Expect(fields[1].name, "label")
                        @Expect(fields[1].description, "Item label")
                        @Expect(fields[1].typeModel, TypeModel.StringType)
                    case _ => @Expect(false, true)
                }
            case _ => @Expect(false, true)
        }
    }
}
