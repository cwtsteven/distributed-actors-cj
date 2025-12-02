package actors.tcp_actor_system

import std.collection.*

import actors.distributed.*
import serialization.serialization.*

public struct TCPActorClientInfo <: Serializable<TCPActorClientInfo> & TypeSerializable {
    public TCPActorClientInfo(
        public let id: String,
        public let addr: String,
        public let port: UInt16
    ) {}

    public func serialize(): DataModel {
        DataModelStruct(ArrayList<Field>([
            Field("id", DataModelString(id)),
            Field("addr", DataModelString(addr)),
            Field("port", DataModelInt(Int64(port)))
        ]))
    }

    public static func deserialize(dataModel: DataModel): TCPActorClientInfo {
        let structValue = match (dataModel) {
            case dm: DataModelStruct => dm
            case _ => throw DataModelException("Expected DataModelStruct for TCPActorClientInfo deserialization.")
        }
        let id = match (structValue.get("id")) {
            case idField: DataModelString => idField.getValue()
            case _ => throw DataModelException("Expected DataModelString for TCPActorClientInfo deserialization.")
        }
        let addr = match (structValue.get("addr")) {
            case addrField: DataModelString => addrField.getValue()
            case _ => throw DataModelException("Expected DataModelString for TCPActorClientInfo deserialization.")
        }
        let port = match (structValue.get("port")) {
            case portField: DataModelInt => UInt16(portField.getValue())
            case _ => throw DataModelException("Expected DataModelInt for TCPActorClientInfo deserialization.")
        }
        TCPActorClientInfo(id, addr, port)
    }

    public static func typeModel(): TypeModel {
        TypeModel.StructType([
            FieldModel(name: "id", description: "Actor Client ID", typeModel: TypeModel.StringType),
            FieldModel(name: "addr", description: "Actor Client Address", typeModel: TypeModel.StringType),
            FieldModel(name: "port", description: "Actor Client Port", typeModel: TypeModel.IntType)
        ])
    }
}