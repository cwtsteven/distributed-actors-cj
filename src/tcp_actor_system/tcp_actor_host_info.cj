package actors.tcp_actor_system

import std.collection.*

import actors.distributed.*
import stdx.serialization.serialization.*

/*
* Information about a TCP actor host, including the host address and port
*/
public struct TCPActorHostInfo <: HostInfo {

    static init() {
        ClientManager.instance.registerHostInfoDeserializer("TCPActorHostInfo", { dm => TCPActorHostInfo.deserialize(dm) })
    }

    /*
    * Initializes the TCPActorHostInfo
    * @param addr - the host address
    * @param port - the host port
    */
    public TCPActorHostInfo(
        public let addr: String,
        public let port: UInt16
    ) {}

    public func createClient(): ActorClient {
        TCPActorClient(this)
    }

    public func getTypeName(): String {
        "TCPActorHostInfo"
    }

    /*
    * Serializes the TCPActorHostInfo object to a DataModel
    * @return the serialized DataModel
    */
    public func serialize(): DataModel {
        DataModelStruct(ArrayList<Field>([
            Field("addr", DataModelString(addr)),
            Field("port", DataModelInt(Int64(port)))
        ]))
    }

    /*
    * Deserializes a DataModel to a TCPActorHostInfo object
    * @param dataModel - the DataModel to deserialize
    * @return the deserialized TCPActorHostInfo object
    * @throws TCPActorSystemDeserializationException - if the deserialization fails
    */
    public static func deserialize(dataModel: DataModel): HostInfo {
        let structValue = match (dataModel) {
            case dm: DataModelStruct => dm
            case _ => throw TCPActorSystemDeserializationException("Expected DataModelStruct for TCPActorHostInfo deserialization.")
        }
        let addr = match (structValue.get("addr")) {
            case addrField: DataModelString => addrField.getValue()
            case _ => throw TCPActorSystemDeserializationException("Expected DataModelString for TCPActorHostInfo deserialization.")
        }
        let port = match (structValue.get("port")) {
            case portField: DataModelInt => UInt16(portField.getValue())
            case _ => throw TCPActorSystemDeserializationException("Expected DataModelInt for TCPActorHostInfo deserialization.")
        }
        TCPActorHostInfo(addr, port)
    }

    /*
    * Gets the type model of the TCPActorHostInfo
    * @return the type model of the TCPActorHostInfo
    */
    public static func typeModel(): TypeModel {
        TypeModel.StructType([
            FieldModel(name: "addr", description: "Host Address", typeModel: TypeModel.StringType),
            FieldModel(name: "port", description: "Host Port", typeModel: TypeModel.IntType)
        ])
    }

    public override operator func ==(other: HostInfo): Bool {
        match (other) {
            case otherHostInfo: TCPActorHostInfo => addr == otherHostInfo.addr && port == otherHostInfo.port
            case _ => false
        }
    }

    public override operator func !=(other: HostInfo): Bool {
        !(this == other)
    }

    public override func hashCode(): Int64 {
        "TCPActorHostInfo ${addr}:${port}".hashCode()
    }

    public func toString(): String {
        "TCPActorHostInfo ${addr}:${port}"
    }
}