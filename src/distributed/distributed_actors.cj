package actors.distributed

import std.collection.*
import std.sync.*
import std.time.*

import actors.*
import serialization.serialization.*

/*
* Interface for actors that can be distributed
*/
public interface Distributable {

    /*
    * Gets the metadata of the actor
    * @return the metadata of the actor
    */
    func getMetadata(): Metadata

    /*
    * Dispatches a tell to the actor
    * @param receiverName - the name of the receiver
    * @param args - the arguments to the receiver
    * @param config - the configuration of the receiver
    * @throws ReceiverNotFoundException - if the receiver is not found
    * @throws IllegalArgumentException - if the arguments are invalid
    */
    func dispatchTell(receiverName: String, args: Array<DataModel>, config: ReceiverConfig): Unit

    /*
    * Dispatches an ask to the actor
    * @param receiverName - the name of the receiver
    * @param args - the arguments to the receiver
    * @param config - the configuration of the receiver
    * @return the future of the result
    * @throws ReceiverNotFoundException - if the receiver is not found
    * @throws IllegalArgumentException - if the arguments are invalid
    */
    func dispatchAsk(receiverName: String, args: Array<DataModel>, config: ReceiverConfig): LocalWaitable
}

/*
* Interface for actors that can create a typed proxy
*/
public interface Proxyable<T> where T <: Distributable {
    /*
    * Gets a typed-proxy for the actor
    * @param proxy - the actor proxy
    * @return a typed-proxy for the actor
    */
    static func getProxy(proxy: ActorProxy): T
}

/*
* Proxy for a distributed actor
*/
public class ActorProxy <: Serializable<ActorProxy> & TypeSerializable {

    public ActorProxy(
        public let actorName: String,
        public let hostInfo: HostInfo
    ) {}

    /*
    * Invokes a receiver function without expecting a return value
    * @param receiverName - the name of the receiver
    * @param args - the arguments to the receiver in serialized form
    * @param config - the configuration of the receiver call
    * @throws ActorNotFoundException - if the actor is not found on the client
    * @throws ReceiverNotFoundException - if the receiver is not found
    * @throws RemoteException - if the remote connection fails
    * @throws IllegalArgumentException - if the arguments are invalid
    * @throws ActorSystemException - for any system-specific errors
    */
    public func tell(receiverName: String, args: Array<DataModel>, config!: ReceiverConfig = ReceiverConfig.default): Unit {
        ClientManager.instance.getOrCreateClient(hostInfo).remoteCall(InvokeInfo(name: actorName, receiverName: receiverName, args: args, config: config, fut: None))
    }

    /*
    * Invokes a receiver function and returns a future for the result
    * @param receiverName - the name of the receiver
    * @param args - the arguments to the receiver in serialized form
    * @param config - the configuration of the receiver
    * @throws ActorNotFoundException - if the actor is not found on the client
    * @throws ReceiverNotFoundException - if the receiver is not found
    * @throws RemoteException - if the remote connection fails
    * @throws IllegalArgumentException - if the arguments are invalid
    * @throws ActorSystemException - for any system-specific errors
    */
    public func ask(receiverName: String, args: Array<DataModel>, config!: ReceiverConfig = ReceiverConfig.default): DistributedFuture {
        let fut = DistributedFuture()
        ClientManager.instance.getOrCreateClient(hostInfo).remoteCall(InvokeInfo(name: actorName, receiverName: receiverName, args: args, config: config, fut: Some(fut)))
        fut
    }

    /*
    * Serializes the actor proxy
    * @return the serialized actor proxy
    */
    public func serialize(): DataModel {
        DataModelStruct(ArrayList([
            Field("actorName", DataModelString(actorName)),
            Field("hostInfoTypeName", DataModelString(hostInfo.getTypeName())),
            Field("hostInfo", hostInfo.serialize())
        ]))
    }

    /*
    * Deserializes the actor proxy
    * @param dataModel - the data model to deserialize
    * @return the deserialized actor proxy
    * @throws DeserializationException - if the deserialization fails
    */
    public static func deserialize(dataModel: DataModel): ActorProxy {
        let structValue = match (dataModel) {
            case dm: DataModelStruct => dm
            case _ => throw DeserializationException("Expected DataModelStruct for ActorProxy deserialization.")
        }
        let actorName = match (structValue.get("actorName")) {
            case nameField: DataModelString => nameField.getValue()
            case _ => throw DeserializationException("Expected DataModelString for ActorProxy deserialization.")
        }
        let hostInfoTypeName = match (structValue.get("hostInfoTypeName")) {
            case typeNameField: DataModelString => typeNameField.getValue()
            case _ => throw DeserializationException("Expected DataModelString for ActorProxy deserialization.")
        }
        let hostInfoDeserializer = match (ClientManager.instance.getHostInfoDeserializer(hostInfoTypeName)) {
            case Some(deserializer) => deserializer
            case None => throw DeserializationException("Host info deserializer not found for type name ${hostInfoTypeName}.")
        }
        let hostInfo: HostInfo = hostInfoDeserializer(match (structValue.get("hostInfo")) {
            case hostInfoField: DataModel => hostInfoField
            case _ => throw DeserializationException("Expected DataModel for ActorProxy deserialization.")
        })
        ClientManager.instance.getOrCreateClient(hostInfo)
        ActorProxy(actorName, hostInfo)
    }

    /*
    * Gets the type model of the actor proxy
    * @return the type model of the actor proxy
    */
    public static func typeModel(): TypeModel {
        TypeModel.StructType([
            FieldModel(name: "actorName", description: "Actor Name", typeModel: TypeModel.StringType),
            FieldModel(name: "hostInfoTypeName", description: "Host Info Type Name", typeModel: TypeModel.StringType),
            FieldModel(name: "hostInfo", description: "Host Info", typeModel: TypeModel.UnitType)
        ])
    }
}

// public abstract class Proxy<T> {}