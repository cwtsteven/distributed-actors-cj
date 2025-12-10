package actors.distributed

import serialization.serialization.*

/*
* Interface for actor clients
*/
public interface ActorClient <: Serializable<ActorClient> {
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
    * Checks if an actor is exported from the respective server
    * @param name - the name of the actor
    * @return true if the actor is exported, false otherwise
    * @throws RemoteException - if the remote connection fails
    * @throws ActorSystemException - for any system-specific errors
    */
    func containsActor(name: String): Bool

    /*
    * Makes a remote call to an actor's receiver function and fulfills the provided future with the result
    * @param invokeInfo - the information about the invoke
    * @throws ActorNotFoundException - if the actor is not found on the client
    * @throws ReceiverNotFoundException - if the receiver is not found
    * @throws RemoteException - if the remote connection fails
    * @throws IllegalArgumentException - if the arguments are invalid
    * @throws ActorSystemException - for any system-specific errors
    */
    func remoteCall(invokeInfo: InvokeInfo): Unit

    func getTypeName(): String

    static func deserialize(dataModel: DataModel): ActorClient {
        // TODO
        throw DeserializationException("Expected ActorClient deserialization.")
    }
}
