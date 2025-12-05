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
    */
    static func getProxy(name: String, client: ActorClient): T
}

/*
* Proxy for a distributed actor
*/
public open class ActorProxy {
    /*
    * Initializes the ActorProxy
    * @param name - the name of the actor
    * @param client - the client to use for remote communication
    * @throws ActorNotFoundException - if the actor is not found on the client
    * @throws RemoteException - if the remote connection fails
    */
    public ActorProxy(
        public let name: String,
        public let client: ActorClient
    ) {
        match (client.find(name)) {
            case Some(_) => ()
            case None =>
                throw ActorNotFoundException(name)
        }
    }

    /*
    * Invokes a receiver function without expecting a return value
    * @param receiverName - the name of the receiver
    * @param args - the arguments to the receiver
    * @param config - the configuration of the receiver
    * @throws ActorNotFoundException - if the receiver is not found
    * @throws ReceiverNotFoundException - if the receiver is not found
    * @throws RemoteException - if the remote connection fails
    * @throws ActorSystemException - for any system-specific errors
    */
    public func tell(receiverName: String, args: Array<DataModel>, config!: ReceiverConfig = ReceiverConfig.default): Unit {
        client.remoteCall(InvokeInfo(name: name, receiverName: receiverName, args: args, config: config, fut: None))
    }

    /*
    * Invokes a receiver function and returns a future for the result
    * @param receiverName - the name of the receiver
    * @param args - the arguments to the receiver
    * @param config - the configuration of the receiver
    * @throws ActorNotFoundException - if the actor is not found
    * @throws ReceiverNotFoundException - if the receiver is not found
    * @throws RemoteException - if the remote connection fails
    * @throws ActorSystemException - for any system-specific errors
    */
    public func ask(receiverName: String, args: Array<DataModel>, config!: ReceiverConfig = ReceiverConfig.default): DistributedFuture {
        let fut = DistributedFuture()
        client.remoteCall(InvokeInfo(name: name, receiverName: receiverName, args: args, config: config, fut: Some(fut)))
        fut
    }
}

/*
* Interface for actor hosts
*/
public interface ActorHost {
    /*
    * Exports an actor
    * @param name - the name of the actor
    * @param a - the actor to export
    * @return true if the actor was successfully exported, false otherwise
    * @throws ActorSystemException - for any system-specific errors
    */
    func export(name: String, a: Distributable): Bool

    /*
    * Un-exports an actor
    * @param name - the name of the actor
    * @return true if the actor was successfully un-exported, false otherwise
    * @throws ActorSystemException - for any system-specific errors
    */
    func unexport(name: String): Bool
}

/*
* Interface for actor clients
*/
public interface ActorClient {
    /*
    * A unique identifier of the actor client
    */
    prop id: String

    /*
    * Finds an actor
    * @param name - the name of the actor
    * @return the actor information if found, None otherwise
    * @throws RemoteException - if the remote connection fails
    * @throws ActorSystemException - for any system-specific errors
    */
    func find(name: String): Option<ActorInfo>

    /*
    * Finds all actors
    * @return the actor information of all actors
    * @throws RemoteException - if the remote connection fails
    * @throws ActorSystemException - for any system-specific errors
    */
    func findAll(): Array<ActorInfo>

    /*
    * Makes a remote call to an actor's receiver function and fulfills the provided future with the result
    * @param invokeInfo - the information about the invoke
    * @throws ActorNotFoundException - if the actor is not found
    * @throws ReceiverNotFoundException - if the receiver is not found
    * @throws RemoteException - if the remote connection fails
    * @throws SerializationException - if the serialization fails
    * @throws ActorSystemException - for any system-specific errors
    */
    func remoteCall(invokeInfo: InvokeInfo): Unit
}
