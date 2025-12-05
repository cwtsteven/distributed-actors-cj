package actors.tcp_actor_system

import std.collection.*

import actors.distributed.*
import serialization.serialization.*

/*
* Information about a TCP actor client, including the client ID, address, and port
*/
public struct TCPActorClientInfo <: Serializable<TCPActorClientInfo> & TypeSerializable {
    /*
    * Initializes the TCPActorClientInfo
    * @param id - the client ID
    * @param addr - the client address
    * @param port - the client port
    */
    public TCPActorClientInfo(
        public let id: String,
        public let addr: String,
        public let port: UInt16
    ) {}

    /*
    * Serializes the TCPActorClientInfo object to a DataModel
    * @return the serialized DataModel
    */
    public func serialize(): DataModel {
        DataModelStruct(ArrayList<Field>([
            Field("id", DataModelString(id)),
            Field("addr", DataModelString(addr)),
            Field("port", DataModelInt(Int64(port)))
        ]))
    }

    /*
    * Deserializes a DataModel to a TCPActorClientInfo object
    * @param dataModel - the DataModel to deserialize
    * @return the deserialized TCPActorClientInfo object
    * @throws TCPActorSystemDeserializationException - if the deserialization fails
    */
    public static func deserialize(dataModel: DataModel): TCPActorClientInfo {
        let structValue = match (dataModel) {
            case dm: DataModelStruct => dm
            case _ => throw TCPActorSystemDeserializationException("Expected DataModelStruct for TCPActorClientInfo deserialization.")
        }
        let id = match (structValue.get("id")) {
            case idField: DataModelString => idField.getValue()
            case _ => throw TCPActorSystemDeserializationException("Expected DataModelString for TCPActorClientInfo deserialization.")
        }
        let addr = match (structValue.get("addr")) {
            case addrField: DataModelString => addrField.getValue()
            case _ => throw TCPActorSystemDeserializationException("Expected DataModelString for TCPActorClientInfo deserialization.")
        }
        let port = match (structValue.get("port")) {
            case portField: DataModelInt => UInt16(portField.getValue())
            case _ => throw TCPActorSystemDeserializationException("Expected DataModelInt for TCPActorClientInfo deserialization.")
        }
        TCPActorClientInfo(id, addr, port)
    }

    /*
    * Gets the type model of the TCPActorClientInfo
    * @return the type model of the TCPActorClientInfo
    */
    public static func typeModel(): TypeModel {
        TypeModel.StructType([
            FieldModel(name: "id", description: "Actor Client ID", typeModel: TypeModel.StringType),
            FieldModel(name: "addr", description: "Actor Client Address", typeModel: TypeModel.StringType),
            FieldModel(name: "port", description: "Actor Client Port", typeModel: TypeModel.IntType)
        ])
    }
}