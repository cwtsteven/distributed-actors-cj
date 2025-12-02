package actors.tcp_actor_system

import std.collection.*

import actors.distributed.*
import serialization.serialization.*

public struct ClientInfo <: Serializable<ClientInfo> & TypeSerializable {
    public ClientInfo(
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

    public static func deserialize(dataModel: DataModel): ClientInfo {
        let structValue = (dataModel as DataModelStruct).getOrThrow()
        ClientInfo(
            (structValue.get("id") as DataModelString).getOrThrow().getValue(),
            (structValue.get("addr") as DataModelString).getOrThrow().getValue(),
            UInt16((structValue.get("port") as DataModelInt).getOrThrow().getValue())
        )
    }

    public static func typeModel(): TypeModel {
        TypeModel.StructType([
            FieldModel(name: "id", description: "Client ID", typeModel: TypeModel.StringType),
            FieldModel(name: "addr", description: "Client Address", typeModel: TypeModel.StringType),
            FieldModel(name: "port", description: "Client Port", typeModel: TypeModel.IntType)
        ])
    }
}