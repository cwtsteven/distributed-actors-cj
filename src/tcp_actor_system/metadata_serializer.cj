/**
 * Metadata serialization and deserialization utilities
 * Created on 16/09/2025
 */

package actors.tcp_actor_system

import std.binary.*
import std.io.*
import std.collection.*

import actors.*
import actors.distributed.*

import encoding.json.*

/**
 * Serializes a Metadata object to a byte array
 * @param metadata - the Metadata object to serialize
 * @return the serialized byte array
 * @throws TCPActorSystemSerializationException - if the metadata serialization fails
 */
func serializeMetadata(metadata: Metadata): Array<Byte> {
    try {
        let buffer = ByteArrayStream()

        // Serialize receivers array
        let receivers = metadata.receivers
        let receiverCount = Int32(receivers.size)
        let receiverCountBytes = Array<Byte>(4, item: 0)
        receiverCount.writeLittleEndian(receiverCountBytes)
        buffer.write(receiverCountBytes)

        // Serialize each receiver
        for (receiver in receivers) {
            serializeReceiverInfo(buffer, receiver)
        }

        // Serialize description
        serializeString(buffer, metadata.description)

        // Serialize customInfo (JsonObject)
        serializeJsonObject(buffer, metadata.customInfo)

        // Get the serialized data
        let result = Array<Byte>(Int64(buffer.length), item: 0)
        buffer.read(result)
        result
    } catch (e: IllegalArgumentException) {
        throw TCPActorSystemSerializationException("Failed to serialize metadata: " + e.message)
    }
}

/**
 * Deserializes a byte array back to a Metadata object
 * @param bytes - the byte array to deserialize
 * @return the deserialized Metadata object
 * @throws TCPActorSystemDeserializationException - if the metadata deserialization fails
 */
func deserializeMetadata(bytes: Array<Byte>): Metadata {
    try {
        let buffer = ByteArrayStream()
        buffer.write(bytes)

        // Deserialize receivers array
        let receiverCountBytes = Array<Byte>(4, item: 0)
        buffer.read(receiverCountBytes)
        let receiverCount = Int32.readLittleEndian(receiverCountBytes)

        let receivers = ArrayList<ReceiverInfo>()
        for (_ in 0..receiverCount) {
            let receiver = deserializeReceiverInfo(buffer)
            receivers.append(receiver)
        }

        // Deserialize description
        let description = deserializeString(buffer)

        // Deserialize customInfo (JsonObject)
        let customInfo = deserializeJsonObject(buffer)

        Metadata(receivers: receivers.toArray(), description: description, customInfo: customInfo)
    } catch (e: IllegalArgumentException) {
        throw TCPActorSystemDeserializationException("Failed to deserialize metadata: " + e.message)
    }
}

/**
 * Serializes a ReceiverInfo object to the buffer
 */
func serializeReceiverInfo(buffer: ByteArrayStream, receiver: ReceiverInfo): Unit {
    // Serialize description
    serializeString(buffer, receiver.description)

    // Serialize customInfo
    serializeJsonObject(buffer, receiver.customInfo)

    // Serialize methodName
    serializeString(buffer, receiver.methodName)

    // Serialize paramSchema array
    let paramCount = Int32(receiver.paramSchema.size)
    let paramCountBytes = Array<Byte>(4, item: 0)
    paramCount.writeLittleEndian(paramCountBytes)
    buffer.write(paramCountBytes)

    for (param in receiver.paramSchema) {
        serializeString(buffer, param.name)
        serializeTypeModel(buffer, param.typeModel)
        serializeString(buffer, param.description)
    }

    // Serialize retTypeModel
    serializeTypeModel(buffer, receiver.retTypeModel)

    // Serialize mode
    serializeReceiverMode(buffer, receiver.mode)
}

/**
 * Deserializes a ReceiverInfo object from the buffer
 */
func deserializeReceiverInfo(buffer: ByteArrayStream): ReceiverInfo {
    // Deserialize description
    let description = deserializeString(buffer)

    // Deserialize customInfo
    let customInfo = deserializeJsonObject(buffer)

    // Deserialize methodName
    let methodName = deserializeString(buffer)

    // Deserialize paramSchema array
    let paramCountBytes = Array<Byte>(4, item: 0)
    buffer.read(paramCountBytes)
    let paramCount = Int32.readLittleEndian(paramCountBytes)

    let paramSchema = ArrayList<ReceiverParameter>()
    for (_ in 0..paramCount) {
        let paramName = deserializeString(buffer)
        let typeModel = deserializeTypeModel(buffer)
        let paramDescription = deserializeString(buffer)
        paramSchema.append(ReceiverParameter(name: paramName, typeModel: typeModel, description: paramDescription))
    }

    // Deserialize retTypeModel
    let retTypeModel = deserializeTypeModel(buffer)

    // Deserialize mode
    let mode = deserializeReceiverMode(buffer)

    ReceiverInfo(
        description: description,
        customInfo: customInfo,
        methodName: methodName,
        paramSchema: paramSchema.toArray(),
        retTypeModel: retTypeModel,
        mode: mode
    )
}

/**
 * Serializes a TypeModel enum to the buffer
 */
func serializeTypeModel(buffer: ByteArrayStream, typeModel: TypeModel): Unit {
    let typeBytes = Array<Byte>(1, item: 0)
    match (typeModel) {
        case IntType =>
            typeBytes[0] = 0
            buffer.write(typeBytes)
        case FloatType =>
            typeBytes[0] = 1
            buffer.write(typeBytes)
        case BoolType =>
            typeBytes[0] = 2
            buffer.write(typeBytes)
        case StringType =>
            typeBytes[0] = 3
            buffer.write(typeBytes)
        case UnitType =>
            typeBytes[0] = 4
            buffer.write(typeBytes)
        case StructType(fields) =>
            typeBytes[0] = 5
            buffer.write(typeBytes)
            // Serialize the fields array
            let fieldCount = Int32(fields.size)
            let fieldCountBytes = Array<Byte>(4, item: 0)
            fieldCount.writeLittleEndian(fieldCountBytes)
            buffer.write(fieldCountBytes)

            for (field in fields) {
                serializeFieldModel(buffer, field)
            }
        case ListType(itemType) =>
            typeBytes[0] = 6
            buffer.write(typeBytes)
            // Serialize the inner item type
            serializeTypeModel(buffer, itemType)
    }
}

/**
 * Deserializes a TypeModel enum from the buffer
 */
func deserializeTypeModel(buffer: ByteArrayStream): TypeModel {
    let typeBytes = Array<Byte>(1, item: 0)
    buffer.read(typeBytes)
    match (typeBytes[0]) {
        case 0 => IntType
        case 1 => FloatType
        case 2 => BoolType
        case 3 => StringType
        case 4 => UnitType
        case 5 =>
            // Deserialize StructType
            let fieldCountBytes = Array<Byte>(4, item: 0)
            buffer.read(fieldCountBytes)
            let fieldCount = Int32.readLittleEndian(fieldCountBytes)

            let fields = ArrayList<FieldModel>()
            for (_ in 0..fieldCount) {
                let field = deserializeFieldModel(buffer)
                fields.append(field)
            }
            StructType(fields.toArray())
        case 6 =>
            // Deserialize ListType by reading the inner item type model
            let itemType = deserializeTypeModel(buffer)
            ListType(itemType)
        case _ => throw TCPActorSystemDeserializationException("Invalid TypeModel value: " + typeBytes[0].toString())
    }
}

/**
 * Serializes a ReceiverMode enum to the buffer
 */
func serializeReceiverMode(buffer: ByteArrayStream, mode: ReceiverMode): Unit {
    let modeBytes = Array<Byte>(1, item: 0)
    match (mode) {
        case AskOnly => modeBytes[0] = 0
        case TellOnly => modeBytes[0] = 1
        case AskAndTell => modeBytes[0] = 2
    }
    buffer.write(modeBytes)
}

/**
 * Deserializes a ReceiverMode enum from the buffer
 */
func deserializeReceiverMode(buffer: ByteArrayStream): ReceiverMode {
    let modeBytes = Array<Byte>(1, item: 0)
    buffer.read(modeBytes)
    match (modeBytes[0]) {
        case 0 => AskOnly
        case 1 => TellOnly
        case 2 => AskAndTell
        case _ => throw TCPActorSystemDeserializationException("Invalid ReceiverMode value: " + modeBytes[0].toString())
    }
}

/**
 * Serializes a string to the buffer (UTF-8 encoded with length prefix)
 */
func serializeString(buffer: ByteArrayStream, str: String): Unit {
    let strBytes = str.toArray()
    let length = Int32(strBytes.size)
    let lengthBytes = Array<Byte>(4, item: 0)
    length.writeLittleEndian(lengthBytes)
    buffer.write(lengthBytes)
    buffer.write(strBytes)
}

/**
 * Deserializes a string from the buffer
 */
func deserializeString(buffer: ByteArrayStream): String {
    let lengthBytes = Array<Byte>(4, item: 0)
    buffer.read(lengthBytes)
    let length = Int32.readLittleEndian(lengthBytes)

    let strBytes = Array<Byte>(Int64(length), item: 0)
    buffer.read(strBytes)
    String.fromUtf8(strBytes)
}

/**
 * Serializes a JsonObject to the buffer
 */
func serializeJsonObject(buffer: ByteArrayStream, jsonObject: JsonObject): Unit {
    // Convert JsonObject to string and serialize as string
    let jsonString = jsonObject.toString()
    serializeString(buffer, jsonString)
}

/**
 * Deserializes a JsonObject from the buffer
 */
func deserializeJsonObject(buffer: ByteArrayStream): JsonObject {
    let jsonString = deserializeString(buffer)
    // Parse the JSON string back to JsonObject
    // Note: This is a simplified implementation - in practice you'd want proper JSON parsing
    // For now, we'll create a basic JsonObject representation
    try {
        JsonObject.fromStr(jsonString).asObject()
    } catch (_: JsonException) {
        throw TCPActorSystemDeserializationException("Failed to deserialize JsonObject: " + jsonString)
    }
}

/**
 * Serializes a FieldModel struct to the buffer
 */
func serializeFieldModel(buffer: ByteArrayStream, field: FieldModel): Unit {
    // Serialize field name
    serializeString(buffer, field.name)
    // Serialize field description
    serializeString(buffer, field.description)
    // Serialize field type model
    serializeTypeModel(buffer, field.typeModel)
}

/**
 * Deserializes a FieldModel struct from the buffer
 */
func deserializeFieldModel(buffer: ByteArrayStream): FieldModel {
    // Deserialize field name
    let name = deserializeString(buffer)
    // Deserialize field description
    let description = deserializeString(buffer)
    // Deserialize field type model
    let typeModel = deserializeTypeModel(buffer)

    FieldModel(name: name, description: description, typeModel: typeModel)
}
