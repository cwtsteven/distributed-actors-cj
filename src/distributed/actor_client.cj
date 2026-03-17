package actors.distributed

import actors.*
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

    func tell(name: String, receiverName: String, args: Array<DataModel>, config: ReceiverConfig): Unit

    func ask(name: String, receiverName: String, args: Array<DataModel>, config: ReceiverConfig): ActorFuture<DataModel>

    /*
    * Gets the host info of the client
    * @return the host info of the client
    */
    func getHostInfo(): HostInfo
}
