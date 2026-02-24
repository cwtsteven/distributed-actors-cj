package actors.distributed

import stdx.serialization.serialization.*

/*
* Interface for actor hosts
*/
public interface ActorHost {
    /*
     * Exports an actor
     * @param name - the name of the actor
     * @param a - the actor to export
     * @return Some(ActorProxy) if the actor was successfully exported, None if the name is already taken
     * @throws ActorSystemException - for any system-specific errors
     */
    func export(name: String, a: Distributable): Option<ActorProxy>

    /*
    * Un-exports an actor
    * @param name - the name of the actor
    * @return true if the actor was successfully un-exported, false otherwise
    * @throws ActorSystemException - for any system-specific errors
    */
    func unexport(name: String): Bool

    /*
    * Gets the host info of the host
    * @return the host info of the host
    */
    func getHostInfo(): HostInfo
}

/*
* Interface for host info
*/
public interface HostInfo <: Serializable<HostInfo> & TypeSerializable & Equatable<HostInfo> & Hashable & ToString {

    /*
    * Creates a client for the host
    * @return the client for the host
    */
    func createClient(): ActorClient

    /*
    * Gets the type name of the host info
    * @return the type name of the host info
    */
    func getTypeName(): String

    /*
     * Deserializes a data model to a host info
     * This is a default implementation that should not be called directly.
     * Concrete implementations of HostInfo should override this method.
     * @param dataModel - the data model to deserialize
     * @return the deserialized host info
     * @throws Exception - if this default implementation is called
     */
    static func deserialize(dataModel: DataModel): HostInfo {
        throw Exception("This shouldn't be called.")
    }
}