package actors.distributed

import stdx.serialization.serialization.*

/*
* Interface for actor clients
*/
public interface ActorClient {
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
    * Gets an actor
    * @param name - the name of the actor
    * @return the actor proxy
    * @throws ActorNotFoundException - if the actor is not found on the client
    * @throws RemoteException - if the remote connection fails
    * @throws ActorSystemException - for any system-specific errors
    */
    func getActor(name: String): Option<ActorProxy>

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

    /*
    * Gets the host info of the client
    * @return the host info of the client
    */
    func getHostInfo(): HostInfo
}