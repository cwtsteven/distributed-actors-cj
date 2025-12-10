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
    * @param name - the name of the actor
    * @param client - the client to use for remote communication
    * @return a typed-proxy for the actor
    * @throws ActorNotFoundException - if the actor is not found on the client
    * @throws RemoteException - if the remote connection fails
    * @throws ActorSystemException - for any system-specific errors
    */
    static func getProxy(name: String, client: ActorClient): T
}

/*
* Proxy for a distributed actor
*/
public class ActorProxy <: Serializable<ActorProxy> & TypeSerializable {
    /*
    * Checks if the actor is found on the client and creates a new ActorProxy
    * @param name - the name of the actor
    * @param client - the client to use for remote communication
    * @throws ActorNotFoundException - if the actor is not found on the client
    * @throws RemoteException - if the remote connection fails
    * @throws ActorSystemException - for any system-specific errors
    */
    public ActorProxy(
        public let name: String,
        public let client: ActorClient
    ) {
        if (!client.containsActor(name)) {
            throw ActorNotFoundException(name)
        }
    }

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
        client.remoteCall(InvokeInfo(name: name, receiverName: receiverName, args: args, config: config, fut: None))
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
        client.remoteCall(InvokeInfo(name: name, receiverName: receiverName, args: args, config: config, fut: Some(fut)))
        fut
    }

    public func serialize(): DataModel {
        DataModelStruct(ArrayList([
            Field("name", DataModelString(name)),
            Field("clientId", DataModelString(client.id)),
            Field("typeName", DataModelString(client.getTypeName())),
            Field("client", client.serialize())
        ]))
    }

    public static func deserialize(dataModel: DataModel): ActorProxy {
        let structValue = match (dataModel) {
            case dm: DataModelStruct => dm
            case _ => throw DeserializationException("Expected DataModelStruct for ActorProxy deserialization.")
        }
        let name = match (structValue.get("name")) {
            case nameField: DataModelString => nameField.getValue()
            case _ => throw DeserializationException("Expected DataModelString for ActorProxy deserialization.")
        }
        let clientId = match (structValue.get("clientId")) {
            case clientIdField: DataModelString => clientIdField.getValue()
            case _ => throw DeserializationException("Expected DataModelString for ActorProxy deserialization.")
        }
        if (let Some(client) <- ClientManager.instance.getClient(clientId)) {
            return ActorProxy(name, client)
        }
        let typeName = match (structValue.get("typeName")) {
            case typeNameField: DataModelString => typeNameField.getValue()
            case _ => throw DeserializationException("Expected DataModelString for ActorProxy deserialization.")
        }
        if (let Some(deserializer) <- ClientManager.instance.getClientDeserializer(typeName)) {
            let client = deserializer(structValue.get("client"))
            return ActorProxy(name, client)
        }
        // TODO
        throw DeserializationException("Expected DataModel for ActorProxy deserialization.")
    }

    public static func typeModel(): TypeModel {
        TypeModel.StructType([
            FieldModel(name: "name", description: "Name", typeModel: TypeModel.StringType),
            FieldModel(name: "clientId", description: "Client ID", typeModel: TypeModel.StringType),
            FieldModel(name: "typeName", description: "Type Name", typeModel: TypeModel.StringType),
            FieldModel(name: "client", description: "Client", typeModel: TypeModel.UnitType)
        ])
    }
}
