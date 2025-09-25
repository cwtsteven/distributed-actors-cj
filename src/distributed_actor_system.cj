package actors

import std.collection.*
import serialization.serialization.*

/*
* Interface for objects that can be fulfilled with a data model
*/
public interface Fullfillable {
    /*
    * Fulfills the object with a data model
    * @param dataModel - the data model to fulfill the object with
    * @return false if the object was already fulfilled, true otherwise
    * @throws DataModelException - if dataModel cannot be deserialized into the expected type
    */
    func fulfill(dataModel: DataModel): Bool
}

/*
* Interface for objects that can be waited on
*/
public interface Waitable {
    /*
    * Blocks the current thread until the object is ready
    * @return the data model of the object
    * @throws DataModelException - if the data model cannot be deserialized into the expected type
    */
    func wait(): DataModel
}

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
    */
    func dispatchTell(receiverName: String, args: Array<DataModel>, config: ReceiverConfig): Unit

    /*
    * Dispatches an ask to the actor
    * @param receiverName - the name of the receiver
    * @param args - the arguments to the receiver
    * @param config - the configuration of the receiver
    * @return the future of the result
    * @throws ReceiverNotFoundException - if the receiver is not found
    */
    func dispatchAsk(receiverName: String, args: Array<DataModel>, config: ReceiverConfig): Waitable
}

/*
* Proxy for a distributed actor
*/
public class ActorProxy {
    /*
    * Initializes the ActorProxy
    * @param name - the name of the actor
    * @param client - the client to use for remote communication
    */
    public ActorProxy(
        public let name: String,
        public let client: ActorClient
    ) {}

    /*
    * Invokes a receiver function without expecting a return value
    * @param receiverName - the name of the receiver
    * @param args - the arguments to the receiver
    * @param config - the configuration of the receiver
    */
    public func tell(receiverName: String, args: Array<DataModel>, config!: ReceiverConfig = ReceiverConfig.default): Unit {
        client.remoteTell(name, receiverName, args, config)
    }

    /*
    * Invokes a receiver function and returns a future for the result
    * @param receiverName - the name of the receiver
    * @param args - the arguments to the receiver
    * @param config - the configuration of the receiver
    * @return the future of the result
    */
    public func ask<T>(receiverName: String, args: Array<DataModel>, config!: ReceiverConfig = ReceiverConfig.default): ActorFuture<T> where T <: Serializable<T> {
        let fut = DistributedActorFuture<T>()
        client.remoteAsk(name, receiverName, args, config, fut)
        fut
    }
}

/*
* Interface for actor hosts
*/
public interface ActorHost {
    /*
    * Registers an actor
    * @param name - the name of the actor
    * @param a - the actor to register
    * @return true if the actor was successfully registered, false otherwise
    */
    func register(name: String, a: Distributable): Bool

    /*
    * Deregisters an actor
    * @param name - the name of the actor
    * @return true if the actor was successfully deregistered, false otherwise
    */
    func deregister(name: String): Bool
}

/*
* Interface for actor clients
*/
public interface ActorClient {
    /*
    * Finds an actor
    * @param name - the name of the actor
    * @return the actor information if found, None otherwise
    */
    func find(name: String): Option<ActorInfo>

    /*
    * Finds all actors
    * @return the actor information of all actors
    */
    func findAll(): Array<ActorInfo>

    /*
    * Makes a remote call to an actor's receiver function and fulfills the provided future with the result
    * @param name - the name of the actor
    * @param receiverName - the name of the receiver
    * @param args - the arguments to the receiver
    * @param config - the configuration of the receiver
    * @param fut - the future to fulfill with the result
    */
    func remoteAsk(name: String, receiverName: String, args: Array<DataModel>, config: ReceiverConfig, fut: Fullfillable): Unit

    /*
    * Makes a remote call to an actor's receiver function without expecting a return value
    * @param name - the name of the actor
    * @param receiverName - the name of the receiver
    * @param args - the arguments to the receiver
    * @param config - the configuration of the receiver
    */
    func remoteTell(name: String, receiverName: String, args: Array<DataModel>, config: ReceiverConfig): Unit
}

/*
* Future for a distributed actor remote call
*/
public class DistributedActorFuture<T> <: ActorFuture<T> & Fullfillable where T <: Serializable<T> {
    /*
    * Initializes the DistributedActorFuture
    */
    init() {}

    /*
    * Fulfills the future with a result
    * @param dataModel - the data model to fulfill the future with
    * @return false if the future was already fulfilled, true otherwise
    * @throws DataModelException - if dataModel cannot be deserialized into the expected type
    */
    public func fulfill(dataModel: DataModel): Bool {
        if (isReady.load()) {
            return false
        }

        let res: FutureResult<T> = FutureResult<T>.deserialize(dataModel)

        synchronized(mtx) {
            if (isReady.load()) {
                return false
            }
            this.result = res
            isReady.store(true)
            mtx.notifyAll()
            true
        }
    }
}

extend<T> FutureResult<T> <: Serializable<FutureResult<T>> where T <: Serializable<T> {
    /*
    * Serializes the future result
    * @return the serialized future result
    * @throws DataModelException - if the future result cannot be serialized
    */
    public func serialize(): DataModel {
        match (this) {
            case Okay(value) =>
                let fields = ArrayList<Field>()
                fields.append(Field("type", DataModelString("Okay")))
                fields.append(Field("value", value.serialize()))
                DataModelStruct(fields)
            case Exc(exception) =>
                let fields = ArrayList<Field>()
                fields.append(Field("type", DataModelString("Exc")))
                fields.append(Field("message", DataModelString(exception.message)))
                DataModelStruct(fields)
            case Err(error) =>
                let fields = ArrayList<Field>()
                fields.append(Field("type", DataModelString("Err")))
                fields.append(Field("message", DataModelString(error.message)))
                DataModelStruct(fields)
        }
    }

    /*
    * Deserializes the future result
    * @param dataModel - the data model to deserialize the future result from
    * @return the deserialized future result
    * @throws DataModelException - if the future result cannot be deserialized
    */
    public static func deserialize(dataModel: DataModel): FutureResult<T> {
        match (dataModel) {
            case dm: DataModelStruct =>
                let fields = dm.getFields()
                var resultType: String = ""
                var valueData: DataModel = DataModelNull()
                var message: String = ""

                for (field in fields) {
                    match (field.getName()) {
                        case "type" =>
                            match (field.getData()) {
                                case str: DataModelString => resultType = str.getValue()
                                case _ => throw DataModelException("Invalid type field in FutureResult deserialization")
                            }
                        case "value" =>
                            valueData = field.getData()
                        case "message" =>
                            match (field.getData()) {
                                case str: DataModelString => message = str.getValue()
                                case _ => throw DataModelException("Invalid message field in FutureResult deserialization")
                            }
                        case _ => () // ignore unknown fields for forward compatibility
                    }
                }

                match (resultType) {
                    case "Okay" =>
                        let value = T.deserialize(valueData)
                        Okay(value)
                    case "Exc" =>
                        Exc(RemoteReceiverException(message))
                    case "Err" =>
                        Exc(RemoteReceiverException(message))
                    case _ =>
                        throw DataModelException("Invalid FutureResult type: " + resultType)
                }
            case _ =>
                throw DataModelException("Expected DataModelStruct for FutureResult deserialization")
        }
    }
}