/**
 * Metadata serialization and deserialization utilities
 * Created on 16/09/2025
 */

package actors.tcp_actor_system

import std.binary.*
import std.io.*
import std.collection.*
import encoding.json.*

import actors.*

/**
 * Serializes a Metadata object to a byte array
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

        // Serialize customInfo (JsonValue)
        serializeJsonValue(buffer, metadata.customInfo)

        // Get the serialized data
        let result = Array<Byte>(Int64(buffer.length), item: 0)
        buffer.read(result)
        result
    } catch (e: Exception) {
        throw Exception("Failed to serialize metadata: " + e.message)
    }
}

/**
 * Deserializes a byte array back to a Metadata object
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
        for (i in 0..receiverCount) {
            let receiver = deserializeReceiverInfo(buffer)
            receivers.append(receiver)
        }

        // Deserialize description
        let description = deserializeString(buffer)

        // Deserialize customInfo (JsonValue)
        let customInfo = deserializeJsonValue(buffer)

        Metadata(receivers.toArray(), description, customInfo)
    } catch (e: Exception) {
        throw Exception("Failed to deserialize metadata: " + e.message)
    }
}

/**
 * Serializes a ReceiverInfo object to the buffer
 */
func serializeReceiverInfo(buffer: ByteArrayStream, receiver: ReceiverInfo): Unit {
    // Serialize description
    serializeString(buffer, receiver.description)

    // Serialize customInfo
    serializeJsonValue(buffer, receiver.customInfo)

    // Serialize methodName
    serializeString(buffer, receiver.methodName)

    // Serialize paramSchema array
    let paramCount = Int32(receiver.paramSchema.size)
    let paramCountBytes = Array<Byte>(4, item: 0)
    paramCount.writeLittleEndian(paramCountBytes)
    buffer.write(paramCountBytes)

    for ((paramName, typeModel) in receiver.paramSchema) {
        serializeString(buffer, paramName)
        serializeTypeModel(buffer, typeModel)
    }

    // Serialize retTypeModel
    serializeTypeModel(buffer, receiver.retTypeModel)
}

/**
 * Deserializes a ReceiverInfo object from the buffer
 */
func deserializeReceiverInfo(buffer: ByteArrayStream): ReceiverInfo {
    // Deserialize description
    let description = deserializeString(buffer)

    // Deserialize customInfo
    let customInfo = deserializeJsonValue(buffer)

    // Deserialize methodName
    let methodName = deserializeString(buffer)

    // Deserialize paramSchema array
    let paramCountBytes = Array<Byte>(4, item: 0)
    buffer.read(paramCountBytes)
    let paramCount = Int32.readLittleEndian(paramCountBytes)

    let paramSchema = ArrayList<(String, TypeModel)>()
    for (i in 0..paramCount) {
        let paramName = deserializeString(buffer)
        let typeModel = deserializeTypeModel(buffer)
        paramSchema.append((paramName, typeModel))
    }

    // Deserialize retTypeModel
    let retTypeModel = deserializeTypeModel(buffer)

    ReceiverInfo(description, customInfo, methodName, paramSchema.toArray(), retTypeModel)
}

/**
 * Serializes a TypeModel enum to the buffer
 */
func serializeTypeModel(buffer: ByteArrayStream, typeModel: TypeModel): Unit {
    let typeBytes = Array<Byte>(1, item: 0)
    match (typeModel) {
        case IntType => typeBytes[0] = 0
        case FloatType => typeBytes[0] = 1
        case BoolType => typeBytes[0] = 2
        case StringType => typeBytes[0] = 3
        case UnitType => typeBytes[0] = 4
    }
    buffer.write(typeBytes)
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
        case _ => throw Exception("Invalid TypeModel value: " + typeBytes[0].toString())
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
 * Serializes a JsonValue to the buffer
 */
func serializeJsonValue(buffer: ByteArrayStream, jsonValue: JsonValue): Unit {
    // Convert JsonValue to string and serialize as string
    let jsonString = jsonValue.toString()
    serializeString(buffer, jsonString)
}

/**
 * Deserializes a JsonValue from the buffer
 */
func deserializeJsonValue(buffer: ByteArrayStream): JsonValue {
    let jsonString = deserializeString(buffer)
    // Parse the JSON string back to JsonValue
    // Note: This is a simplified implementation - in practice you'd want proper JSON parsing
    // For now, we'll create a basic JsonValue representation
    JsonValue.fromStr(jsonString)
}
