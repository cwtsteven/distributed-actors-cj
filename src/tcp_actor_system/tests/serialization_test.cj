package actors.tcp_actor_system.tests

import std.binary.*
import std.unittest.*
import std.unittest.testmacro.*
import std.collection.*
import std.time.*
import std.sync.*

import actors.*
import actors.macros.*
import actors.tcp_actor_system.*
import serialization.serialization.*
import encoding.json.*

@Test
public class SerializationTest {

    @TestCase
    func testEnvelopeSerializationRoundTrip() {
        // Test serializing and deserializing an envelope
        let originalEnvelope = Envelope(12345, Payload.Find("testActor"))

        // Serialize the envelope
        let serializedBytes = serializeEnvelope(originalEnvelope)
        @Expect(serializedBytes.size > 4, true)  // Should have at least 4 bytes for length prefix + data

        // Verify the length prefix is correctly encoded
        let lengthBytes = Array<Byte>(4, item: 0)
        lengthBytes[0..4] = serializedBytes[0..4]
        let encodedLength = Int32.readLittleEndian(lengthBytes)
        @Expect(Int64(encodedLength + 4), serializedBytes.size)  // Total size should be length + 4

        // Deserialize the envelope
        let deserializedEnvelope = deserializeEnvelope(serializedBytes)

        // Verify the deserialized envelope matches the original
        @Expect(deserializedEnvelope.id, originalEnvelope.id)

        // Verify the payload matches
        match(deserializedEnvelope.msg) {
            case Find(name) => @Expect(name, "testActor")
            case _ => @Expect(false, true)  // This should never be reached
        }
    }

    @TestCase
    func testEnvelopeSerializationWithDifferentPayloads() {
        // Test with Ok payload
        let envelope1 = Envelope(1, Payload.Ok)
        let serialized1 = serializeEnvelope(envelope1)
        let deserialized1 = deserializeEnvelope(serialized1)
        @Expect(deserialized1.id, 1)
        match(deserialized1.msg) {
            case Ok => @Expect(true, true)
            case _ => @Expect(false, true)  // This should never be reached
        }

        // Test with ErrorCode payload
        let envelope2 = Envelope(2, Payload.ErrorCode(TCPActorSystemError.ActorNotFound))
        let serialized2 = serializeEnvelope(envelope2)
        let deserialized2 = deserializeEnvelope(serialized2)
        @Expect(deserialized2.id, 2)
        match(deserialized2.msg) {
            case ErrorCode(errorCode) =>
                match(errorCode) {
                    case ActorNotFound => @Expect(true, true)
                    case _ => @Expect(false, true)  // This should never be reached
                }
            case _ => @Expect(false, true)  // This should never be reached
        }

        // Test with FindAll payload
        let envelope3 = Envelope(3, Payload.FindAll)
        let serialized3 = serializeEnvelope(envelope3)
        let deserialized3 = deserializeEnvelope(serialized3)
        @Expect(deserialized3.id, 3)
        match(deserialized3.msg) {
            case FindAll => @Expect(true, true)
            case _ => @Expect(false, true)  // This should never be reached
        }

        // Test with Find payload
        let envelope4 = Envelope(4, Payload.Find("testActor"))
        let serialized4 = serializeEnvelope(envelope4)
        let deserialized4 = deserializeEnvelope(serialized4)
        @Expect(deserialized4.id, 4)
        match(deserialized4.msg) {
            case Find(name) => @Expect(name, "testActor")
            case _ => @Expect(false, true)  // This should never be reached
        }

        // Test with Ask payload
        let args = ArrayList<DataModel>()
        args.append(DataModelString("test"))
        args.append(DataModelInt(42))
        let config = ReceiverConfig(priority: 5)
        let askPayload = Payload.Ask("testActor", "testMethod", args.toArray(), config, 123)
        let envelope5 = Envelope(5, askPayload)
        let serialized5 = serializeEnvelope(envelope5)
        let deserialized5 = deserializeEnvelope(serialized5)
        @Expect(deserialized5.id, 5)
        match(deserialized5.msg) {
            case Ask(name, methodName, args, config, futId) =>
                @Expect(name, "testActor")
                @Expect(methodName, "testMethod")
                @Expect(futId, 123)
                @Expect(config.priority, 5)
                @Expect(args.size, 2)
            case _ => @Expect(false, true)  // This should never be reached
        }

        // Test with Tell payload
        let tellArgs = ArrayList<DataModel>()
        tellArgs.append(DataModelBool(true))
        let tellConfig = ReceiverConfig(priority: 3)
        let tellPayload = Payload.Tell("testActor", "testMethod", tellArgs.toArray(), tellConfig)
        let envelope6 = Envelope(6, tellPayload)
        let serialized6 = serializeEnvelope(envelope6)
        let deserialized6 = deserializeEnvelope(serialized6)
        @Expect(deserialized6.id, 6)
        match(deserialized6.msg) {
            case Tell(name, methodName, args, config) =>
                @Expect(name, "testActor")
                @Expect(methodName, "testMethod")
                @Expect(config.priority, 3)
                @Expect(args.size, 1)
            case _ => @Expect(false, true)  // This should never be reached
        }

        // Test with Fulfill payload
        let result = DataModelString("success")
        let fulfillPayload = Payload.Fulfill(456, result)
        let envelope7 = Envelope(7, fulfillPayload)
        let serialized7 = serializeEnvelope(envelope7)
        let deserialized7 = deserializeEnvelope(serialized7)
        @Expect(deserialized7.id, 7)
        match(deserialized7.msg) {
            case Fulfill(futId, res) =>
                @Expect(futId, 456)
                @Expect(true, true)  // Result creation successful
            case _ => @Expect(false, true)  // This should never be reached
        }
    }

    @TestCase
    func testEnvelopeSerializationLengthPrefix() {
        // Test that length prefix is correctly encoded for different payload sizes
        let smallEnvelope = Envelope(1, Payload.Ok)
        let largeEnvelope = Envelope(2, Payload.Find("aVeryLongActorNameThatShouldResultInALargerSerializedSize"))

        let smallBytes = serializeEnvelope(smallEnvelope)
        let largeBytes = serializeEnvelope(largeEnvelope)

        // Both should have length prefix
        @Expect(smallBytes.size >= 4, true)
        @Expect(largeBytes.size >= 4, true)

        // Large envelope should be bigger than small envelope
        @Expect(largeBytes.size > smallBytes.size, true)

        // Verify length prefixes are different
        let smallLengthBytes = Array<Byte>(4, item: 0)
        smallLengthBytes[0..4] = smallBytes[0..4]
        let smallLength = Int32.readLittleEndian(smallLengthBytes)

        let largeLengthBytes = Array<Byte>(4, item: 0)
        largeLengthBytes[0..4] = largeBytes[0..4]
        let largeLength = Int32.readLittleEndian(largeLengthBytes)

        @Expect(largeLength > smallLength, true)
    }

    @TestCase
    func testEnvelopeDeserializationErrorHandling() {
        // Test deserialization with invalid data
        let emptyBytes = Array<Byte>(0, item: 0)
        let tooShortBytes = Array<Byte>(2, item: 0)
        let invalidLengthBytes = Array<Byte>(8, item: 0)
        // Set invalid length (larger than actual data)
        invalidLengthBytes[0] = 100
        invalidLengthBytes[1] = 0
        invalidLengthBytes[2] = 0
        invalidLengthBytes[3] = 0

        // Test empty data
        try {
            deserializeEnvelope(emptyBytes)
            @Expect(false, true)  // Should have thrown an exception
        } catch (e: Exception) {
            @Expect(e.message.contains("too short"), true)
        }

        // Test too short data
        try {
            deserializeEnvelope(tooShortBytes)
            @Expect(false, true)  // Should have thrown an exception
        } catch (e: Exception) {
            @Expect(e.message.contains("too short"), true)
        }

        // Test length mismatch
        try {
            deserializeEnvelope(invalidLengthBytes)
            @Expect(false, true)  // Should have thrown an exception
        } catch (e: Exception) {
            @Expect(e.message.contains("length mismatch"), true)
        }
    }

    @TestCase
    func testEnvelopeSerializationConsistency() {
        // Test that multiple serializations of the same envelope produce consistent results
        let envelope = Envelope(999, Payload.Ask("test", "method", Array<DataModel>(0, item: DataModelNull()), ReceiverConfig(priority: 1), 123))

        let serialized1 = serializeEnvelope(envelope)
        let serialized2 = serializeEnvelope(envelope)

        // Should produce identical results
        @Expect(serialized1.size, serialized2.size)

        for (i in 0..serialized1.size) {
            @Expect(serialized1[i], serialized2[i])
        }

        // Both should deserialize to the same envelope
        let deserialized1 = deserializeEnvelope(serialized1)
        let deserialized2 = deserializeEnvelope(serialized2)

        @Expect(deserialized1.id, deserialized2.id)
        @Expect(deserialized1.id, 999)
    }
}