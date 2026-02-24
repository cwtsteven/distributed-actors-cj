/**
 * Envelope serialization and deserialization utilities
 * Created on 16/09/2025
 */

package actors.tcp_actor_system

import std.binary.*
import std.io.*
import std.collection.*

import actors.*
import actors.distributed.*

import stdx.encoding.json.*

import stdx.serialization.serialization.*

/*
 * Tries to get the id from the envelope bytes
 * @param bytes - the bytes to get the id from
 * @return the id if successful, None otherwise
 */
func tryGetIdFromEnvelopeBytes(bytes: Array<Byte>): Option<UInt64> {
    try {
        // Check minimum length (4 bytes for length prefix)
        if (bytes.size < 4) {
           return None
        }

        // Read length prefix (4 bytes)
        let lengthBytes = Array<Byte>(4, repeat: 0)
        lengthBytes[0..4] = bytes[0..4]
        let expectedLength = Int32.readLittleEndian(lengthBytes)

        // Validate length
        if (bytes.size != Int64(expectedLength + 4)) {
            return None
        }

        // Extract the actual data (skip the 4-byte length prefix)
        let dataBytes = Array<Byte>(Int64(expectedLength), repeat: 0)
        dataBytes[0..dataBytes.size] = bytes[4..bytes.size]

        let buffer = ByteArrayStream()
        buffer.write(dataBytes)

        // Deserialize id (UInt64)
        let idBytes = Array<Byte>(8, repeat: 0)
        buffer.read(idBytes)
        let id = UInt64.readLittleEndian(idBytes)
        Some(id)
    } catch (e: IllegalArgumentException) {
        None
    }
}

/**
 * Serializes an Envelope object to a byte array
 * @param envelope - the Envelope object to serialize
 * @return the serialized byte array
 * @throws TCPActorSystemSerializationException - if the envelope serialization fails
 */
func serializeEnvelope(envelope: Envelope): Array<Byte> {
    try {
        let buffer = ByteArrayStream()

        // Serialize id (UInt64)
        let idBytes = Array<Byte>(8, repeat: 0)
        envelope.id.writeLittleEndian(idBytes)
        buffer.write(idBytes)

        // Serialize payload
        serializePayload(buffer, envelope.msg)

        // Get the serialized data (without length prefix)
        let dataWithoutLength = Array<Byte>(Int64(buffer.length), repeat: 0)
        buffer.read(dataWithoutLength)

        // Create final result with length prefix
        let totalLength = Int32(dataWithoutLength.size)
        let result = Array<Byte>(Int64(totalLength + 4), repeat: 0)

        // Write length prefix (4 bytes)
        let lengthBytes = Array<Byte>(4, repeat: 0)
        totalLength.writeLittleEndian(lengthBytes)
        result[0..4] = lengthBytes

        // Write the actual data
        result[4..result.size] = dataWithoutLength

        result
    } catch (e: IllegalArgumentException) {
        throw TCPActorSystemSerializationException("Failed to serialize envelope: " + e.message + ".")
    }
}

/**
 * Deserializes a byte array back to an Envelope object
 * @param bytes - the byte array to deserialize
 * @return the deserialized Envelope object
 * @throws TCPActorSystemDeserializationException - if the envelope deserialization fails
 */
func deserializeEnvelope(bytes: Array<Byte>): Envelope {
    try {
        // Check minimum length (4 bytes for length prefix)
        if (bytes.size < 4) {
            throw TCPActorSystemDeserializationException("Invalid envelope data: too short.")
        }

        // Read length prefix (4 bytes)
        let lengthBytes = Array<Byte>(4, repeat: 0)
        lengthBytes[0..4] = bytes[0..4]
        let expectedLength = Int32.readLittleEndian(lengthBytes)

        // Validate length
        if (bytes.size != Int64(expectedLength + 4)) {
            throw TCPActorSystemDeserializationException("Invalid envelope data: length mismatch. Expected " + (expectedLength + 4).toString() + " bytes, got " + bytes.size.toString() + ".")
        }

        // Extract the actual data (skip the 4-byte length prefix)
        let dataBytes = Array<Byte>(Int64(expectedLength), repeat: 0)
        dataBytes[0..dataBytes.size] = bytes[4..bytes.size]

        let buffer = ByteArrayStream()
        buffer.write(dataBytes)

        // Deserialize id (UInt64)
        let idBytes = Array<Byte>(8, repeat: 0)
        buffer.read(idBytes)
        let id = UInt64.readLittleEndian(idBytes)

        // Deserialize payload
        let payload = deserializePayload(buffer)

        Envelope(id, payload)
    } catch (e: IllegalArgumentException) {
        throw TCPActorSystemDeserializationException("Failed to deserialize envelope: " + e.message + ".")
    }
}

/**
 * Serializes a Payload enum to the buffer
 */
func serializePayload(buffer: ByteArrayStream, payload: Payload): Unit {
    let kindBytes = Array<Byte>(1, repeat: 0)
    match (payload) {
        case Ok =>
            kindBytes[0] = 0
            buffer.write(kindBytes)
        case ErrorCode(errorCode) =>
            kindBytes[0] = 1
            buffer.write(kindBytes)
            serializeTCPActorSystemError(buffer, errorCode)
        case Find(name) =>
            kindBytes[0] = 2
            buffer.write(kindBytes)
            serializeString(buffer, name)
        case FindAll =>
            kindBytes[0] = 3
            buffer.write(kindBytes)
        case FindResponse(infos) =>
            kindBytes[0] = 4
            buffer.write(kindBytes)
            serializeActorInfoArray(buffer, infos)
        case Ask(name, methodName, args, config, futId) =>
            kindBytes[0] = 5
            buffer.write(kindBytes)
            serializeString(buffer, name)
            serializeString(buffer, methodName)
            serializeDataModelArray(buffer, args)
            serializeReceiverConfig(buffer, config)
            let futIdBytes = Array<Byte>(8, repeat: 0)
            futId.writeLittleEndian(futIdBytes)
            buffer.write(futIdBytes)
        case Tell(name, methodName, args, config) =>
            kindBytes[0] = 6
            buffer.write(kindBytes)
            serializeString(buffer, name)
            serializeString(buffer, methodName)
            serializeDataModelArray(buffer, args)
            serializeReceiverConfig(buffer, config)
        case Fulfill(futId, res) =>
            kindBytes[0] = 7
            buffer.write(kindBytes)
            let futIdBytes = Array<Byte>(8, repeat: 0)
            futId.writeLittleEndian(futIdBytes)
            buffer.write(futIdBytes)
            serializeDataModel(buffer, res)
        case ContainsActor(name) =>
            kindBytes[0] = 8
            buffer.write(kindBytes)
            serializeString(buffer, name)
        case ContainsActorResponse(b) =>
            kindBytes[0] = 9
            buffer.write(kindBytes)
            let bBytes = Array<Byte>(1, repeat: 0)
            bBytes[0] = if (b) { 1 } else { 0 }
            buffer.write(bBytes)
        case Heartbeat =>
            kindBytes[0] = 10
            buffer.write(kindBytes)
    }
}

/**
 * Deserializes a Payload enum from the buffer
 */
func deserializePayload(buffer: ByteArrayStream): Payload {
    let kindBytes = Array<Byte>(1, repeat: 0)
    buffer.read(kindBytes)
    match (kindBytes[0]) {
        case 0 => Ok
        case 1 =>
            let errorCode = deserializeTCPActorSystemError(buffer)
            ErrorCode(errorCode)
        case 2 =>
            let name = deserializeString(buffer)
            Find(name)
        case 3 => FindAll
        case 4 =>
            let infos = deserializeActorInfoArray(buffer)
            FindResponse(infos)
        case 5 =>
            let name = deserializeString(buffer)
            let methodName = deserializeString(buffer)
            let args = deserializeDataModelArray(buffer)
            let config = deserializeReceiverConfig(buffer)
            let futIdBytes = Array<Byte>(8, repeat: 0)
            buffer.read(futIdBytes)
            let futId = UInt64.readLittleEndian(futIdBytes)
            Ask(name, methodName, args, config, futId)
        case 6 =>
            let name = deserializeString(buffer)
            let methodName = deserializeString(buffer)
            let args = deserializeDataModelArray(buffer)
            let config = deserializeReceiverConfig(buffer)
            Payload.Tell(name, methodName, args, config)
        case 7 =>
            let futIdBytes = Array<Byte>(8, repeat: 0)
            buffer.read(futIdBytes)
            let futId = UInt64.readLittleEndian(futIdBytes)
            let res = deserializeDataModel(buffer)
            Fulfill(futId, res)
        case 8 =>
            let name = deserializeString(buffer)
            ContainsActor(name)
        case 9 =>
            let bBytes = Array<Byte>(1, repeat: 0)
            buffer.read(bBytes)
            let b = bBytes[0] != 0
            ContainsActorResponse(b)
        case 10 => Heartbeat
        case _ => throw TCPActorSystemDeserializationException("Invalid Payload kind: " + kindBytes[0].toString() + ".")
    }
}

/**
 * Serializes an array of ActorInfo to the buffer
 */
func serializeActorInfoArray(buffer: ByteArrayStream, infos: Array<ActorInfo>): Unit {
    let count = Int32(infos.size)
    let countBytes = Array<Byte>(4, repeat: 0)
    count.writeLittleEndian(countBytes)
    buffer.write(countBytes)

    for (info in infos) {
        // name
        serializeString(buffer, info.name)
        // metadata as length-prefixed bytes
        let metaBytes = serializeMetadata(info.metadata)
        let len = Int32(metaBytes.size)
        let lenBytes = Array<Byte>(4, repeat: 0)
        len.writeLittleEndian(lenBytes)
        buffer.write(lenBytes)
        buffer.write(metaBytes)
    }
}

/**
 * Deserializes an array of ActorInfo from the buffer
 */
func deserializeActorInfoArray(buffer: ByteArrayStream): Array<ActorInfo> {
    let countBytes = Array<Byte>(4, repeat: 0)
    buffer.read(countBytes)
    let count = Int32.readLittleEndian(countBytes)

    let list = ArrayList<ActorInfo>()
    for (_ in 0..count) {
        let name = deserializeString(buffer)
        let lenBytes = Array<Byte>(4, repeat: 0)
        buffer.read(lenBytes)
        let len = Int32.readLittleEndian(lenBytes)
        let metaBytes = Array<Byte>(Int64(len), repeat: 0)
        buffer.read(metaBytes)
        let metadata = deserializeMetadata(metaBytes)
        list.add(ActorInfo(name: name, metadata: metadata))
    }
    list.toArray()
}

/**
 * Serializes an array of DataModel objects to the buffer
 */
func serializeDataModelArray(buffer: ByteArrayStream, dataModels: Array<DataModel>): Unit {
    let count = Int32(dataModels.size)
    let countBytes = Array<Byte>(4, repeat: 0)
    count.writeLittleEndian(countBytes)
    buffer.write(countBytes)

    for (dataModel in dataModels) {
        serializeDataModel(buffer, dataModel)
    }
}

/**
 * Deserializes an array of DataModel objects from the buffer
 */
func deserializeDataModelArray(buffer: ByteArrayStream): Array<DataModel> {
    let countBytes = Array<Byte>(4, repeat: 0)
    buffer.read(countBytes)
    let count = Int32.readLittleEndian(countBytes)

    let dataModels = ArrayList<DataModel>()
    for (_ in 0..count) {
        let dataModel = deserializeDataModel(buffer)
        dataModels.add(dataModel)
    }

    dataModels.toArray()
}

/**
 * Serializes a DataModel object to the buffer
 * DataModel is already a serialized representation, so we need to serialize it to bytes
 */
func serializeDataModel(buffer: ByteArrayStream, dataModel: DataModel): Unit {
    // DataModel is already a serialized representation
    // We need to convert it to a byte array for transmission
    let dataModelBytes = serializeDataModelToBytes(dataModel)

    // Write the length of the DataModel bytes first
    let length = Int32(dataModelBytes.size)
    let lengthBytes = Array<Byte>(4, repeat: 0)
    length.writeLittleEndian(lengthBytes)
    buffer.write(lengthBytes)

    // Write the actual DataModel bytes
    buffer.write(dataModelBytes)
}

/**
 * Deserializes a DataModel object from the buffer
 */
func deserializeDataModel(buffer: ByteArrayStream): DataModel {
    // Read the length of the DataModel bytes
    let lengthBytes = Array<Byte>(4, repeat: 0)
    buffer.read(lengthBytes)
    let length = Int32.readLittleEndian(lengthBytes)

    // Read the actual DataModel bytes
    let dataModelBytes = Array<Byte>(Int64(length), repeat: 0)
    buffer.read(dataModelBytes)

    // Convert bytes back to DataModel
    deserializeDataModelFromBytes(dataModelBytes)
}

/**
 * Helper function to serialize DataModel to byte array
 * This is a simplified implementation that converts DataModel to bytes
 */
func serializeDataModelToBytes(dataModel: DataModel): Array<Byte> {
    let buffer = ByteArrayStream()

    match (dataModel) {
        case dm: DataModelNull =>
            // Type: 0, no additional data
            let typeBytes = Array<Byte>(1, repeat: 0)
            typeBytes[0] = 0
            buffer.write(typeBytes)
        case dm: DataModelBool =>
            // Type: 1, value: 1 byte
            let typeBytes = Array<Byte>(1, repeat: 0)
            typeBytes[0] = 1
            buffer.write(typeBytes)

            let valueBytes = Array<Byte>(1, repeat: 0)
            valueBytes[0] = if (dm.getValue()) { 1 } else { 0 }
            buffer.write(valueBytes)
        case dm: DataModelFloat =>
            // Type: 2, value: 8 bytes (Float64)
            let typeBytes = Array<Byte>(1, repeat: 0)
            typeBytes[0] = 2
            buffer.write(typeBytes)

            let valueBytes = Array<Byte>(8, repeat: 0)
            dm.getValue().writeLittleEndian(valueBytes)
            buffer.write(valueBytes)
        case dm: DataModelInt =>
            // Type: 3, value: 8 bytes (Int64)
            let typeBytes = Array<Byte>(1, repeat: 0)
            typeBytes[0] = 3
            buffer.write(typeBytes)

            let valueBytes = Array<Byte>(8, repeat: 0)
            dm.getValue().writeLittleEndian(valueBytes)
            buffer.write(valueBytes)
        case dm: DataModelString =>
            // Type: 4, value: string with length prefix
            let typeBytes = Array<Byte>(1, repeat: 0)
            typeBytes[0] = 4
            buffer.write(typeBytes)

            let strBytes = dm.getValue().toArray()
            let length = Int32(strBytes.size)
            let lengthBytes = Array<Byte>(4, repeat: 0)
            length.writeLittleEndian(lengthBytes)
            buffer.write(lengthBytes)
            buffer.write(strBytes)
        case dm: DataModelSeq =>
            // Type: 5, value: array of DataModels with length prefix
            let typeBytes = Array<Byte>(1, repeat: 0)
            typeBytes[0] = 5
            buffer.write(typeBytes)

            let items = dm.getItems()
            let count = Int32(items.size)
            let countBytes = Array<Byte>(4, repeat: 0)
            count.writeLittleEndian(countBytes)
            buffer.write(countBytes)

            for (item in items) {
                let itemBytes = serializeDataModelToBytes(item)
                let itemLength = Int32(itemBytes.size)
                let itemLengthBytes = Array<Byte>(4, repeat: 0)
                itemLength.writeLittleEndian(itemLengthBytes)
                buffer.write(itemLengthBytes)
                buffer.write(itemBytes)
            }
        case dm: DataModelStruct =>
            // Type: 6, value: map of string keys to DataModel values
            let typeBytes = Array<Byte>(1, repeat: 0)
            typeBytes[0] = 6
            buffer.write(typeBytes)

            let fields = dm.getFields()
            let count = Int32(fields.size)
            let countBytes = Array<Byte>(4, repeat: 0)
            count.writeLittleEndian(countBytes)
            buffer.write(countBytes)

            for (field in fields) {
                // Serialize field name
                let nameBytes = field.getName().toArray()
                let nameLength = Int32(nameBytes.size)
                let nameLengthBytes = Array<Byte>(4, repeat: 0)
                nameLength.writeLittleEndian(nameLengthBytes)
                buffer.write(nameLengthBytes)
                buffer.write(nameBytes)

                // Serialize field value
                let valueBytes = serializeDataModelToBytes(field.getData())
                let valueLength = Int32(valueBytes.size)
                let valueLengthBytes = Array<Byte>(4, repeat: 0)
                valueLength.writeLittleEndian(valueLengthBytes)
                buffer.write(valueLengthBytes)
                buffer.write(valueBytes)
            }
        case _ =>
            throw TCPActorSystemSerializationException("Invalid DataModel type.")
    }

    // Get the serialized data
    let result = Array<Byte>(Int64(buffer.length), repeat: 0)
    buffer.read(result)
    result
}

/**
 * Helper function to deserialize DataModel from byte array
 * This is a simplified implementation that creates a basic DataModel
 */
func deserializeDataModelFromBytes(dataModelBytes: Array<Byte>): DataModel {
    let buffer = ByteArrayStream()
    buffer.write(dataModelBytes)

    // Read the type byte
    let typeBytes = Array<Byte>(1, repeat: 0)
    buffer.read(typeBytes)

    match (typeBytes[0]) {
        case 0 => DataModelNull()
        case 1 =>
            // DataModelBool
            let valueBytes = Array<Byte>(1, repeat: 0)
            buffer.read(valueBytes)
            let value = valueBytes[0] != 0
            DataModelBool(value)
        case 2 =>
            // DataModelFloat
            let valueBytes = Array<Byte>(8, repeat: 0)
            buffer.read(valueBytes)
            let value = Float64.readLittleEndian(valueBytes)
            DataModelFloat(value)
        case 3 =>
            // DataModelInt
            let valueBytes = Array<Byte>(8, repeat: 0)
            buffer.read(valueBytes)
            let value = Int64.readLittleEndian(valueBytes)
            DataModelInt(value)
        case 4 =>
            // DataModelString
            let lengthBytes = Array<Byte>(4, repeat: 0)
            buffer.read(lengthBytes)
            let length = Int32.readLittleEndian(lengthBytes)

            let strBytes = Array<Byte>(Int64(length), repeat: 0)
            buffer.read(strBytes)
            let value = String.fromUtf8(strBytes)
            DataModelString(value)
        case 5 =>
            // DataModelSeq
            let countBytes = Array<Byte>(4, repeat: 0)
            buffer.read(countBytes)
            let count = Int32.readLittleEndian(countBytes)

            let items = ArrayList<DataModel>()
            for (_ in 0..count) {
                let itemLengthBytes = Array<Byte>(4, repeat: 0)
                buffer.read(itemLengthBytes)
                let itemLength = Int32.readLittleEndian(itemLengthBytes)

                let itemBytes = Array<Byte>(Int64(itemLength), repeat: 0)
                buffer.read(itemBytes)
                let item = deserializeDataModelFromBytes(itemBytes)
                items.add(item)
            }
            DataModelSeq(items)
        case 6 =>
            // DataModelStruct
            let countBytes = Array<Byte>(4, repeat: 0)
            buffer.read(countBytes)
            let count = Int32.readLittleEndian(countBytes)

            let fields = ArrayList<Field>()
            for (_ in 0..count) {
                // Read field name
                let nameLengthBytes = Array<Byte>(4, repeat: 0)
                buffer.read(nameLengthBytes)
                let nameLength = Int32.readLittleEndian(nameLengthBytes)

                let nameBytes = Array<Byte>(Int64(nameLength), repeat: 0)
                buffer.read(nameBytes)
                let name = String.fromUtf8(nameBytes)

                // Read field value
                let valueLengthBytes = Array<Byte>(4, repeat: 0)
                buffer.read(valueLengthBytes)
                let valueLength = Int32.readLittleEndian(valueLengthBytes)

                let valueBytes = Array<Byte>(Int64(valueLength), repeat: 0)
                buffer.read(valueBytes)
                let value = deserializeDataModelFromBytes(valueBytes)

                fields.add(Field(name, value))
            }
            DataModelStruct(fields)
        case _ => throw TCPActorSystemDeserializationException("Invalid DataModel type: " + typeBytes[0].toString() + ".")
    }
}

/**
 * Serializes a TCPActorSystemError enum to the buffer
 */
func serializeTCPActorSystemError(buffer: ByteArrayStream, error: TCPActorSystemError): Unit {
    let errorBytes = Array<Byte>(1, repeat: 0)
    match (error) {
        case UnknownError =>
            errorBytes[0] = 0
            buffer.write(errorBytes)
        case ActorNotFound =>
            errorBytes[0] = 1
            buffer.write(errorBytes)
        case ReceiverNotFound =>
            errorBytes[0] = 2
            buffer.write(errorBytes)
        case DeserializationFailed =>
            errorBytes[0] = 3
            buffer.write(errorBytes)
        case IllegalArgument =>
            errorBytes[0] = 4
            buffer.write(errorBytes)
    }
}

/**
 * Deserializes a TCPActorSystemError enum from the buffer
 */
func deserializeTCPActorSystemError(buffer: ByteArrayStream): TCPActorSystemError {
    let errorBytes = Array<Byte>(1, repeat: 0)
    buffer.read(errorBytes)
    match (errorBytes[0]) {
        case 0 => UnknownError
        case 1 => ActorNotFound
        case 2 => ReceiverNotFound
        case 3 => DeserializationFailed
        case 4 => IllegalArgument
        case _ => throw TCPActorSystemDeserializationException("Invalid TCPActorSystemError kind: " + errorBytes[0].toString() + ".")
    }
}

/**
 * Serializes a ReceiverConfig object to the buffer
 */
func serializeReceiverConfig(buffer: ByteArrayStream, config: ReceiverConfig): Unit {
    // Serialize priority (Int64)
    let priorityBytes = Array<Byte>(8, repeat: 0)
    config.priority.writeLittleEndian(priorityBytes)
    buffer.write(priorityBytes)
}

/**
 * Deserializes a ReceiverConfig object from the buffer
 */
func deserializeReceiverConfig(buffer: ByteArrayStream): ReceiverConfig {
    // Deserialize priority (Int64)
    let priorityBytes = Array<Byte>(8, repeat: 0)
    buffer.read(priorityBytes)
    let priority = Int64.readLittleEndian(priorityBytes)
    ReceiverConfig(priority: priority)
}
