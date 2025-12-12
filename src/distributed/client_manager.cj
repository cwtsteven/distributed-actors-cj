package actors.distributed

import std.collection.concurrent.*
import std.sync.*

import serialization.serialization.*

/*
* A class that manages the actor clients in the distributed actor system.
* This class is a singleton and is used to get and register actor clients and their deserializers.
* Actor system developers should use this class to get and register actor clients and their deserializers.
* The client manager is used for creating actor proxies so as to not have duplicated connections to the same host.
*/
public class ClientManager {

    private let clients = ConcurrentHashMap<HostInfo, ActorClient>()
    private let hostInfoDeserializer = ConcurrentHashMap<String, (DataModel) -> HostInfo>()
    private let mtx = ReentrantMutex()

    /*
    * The singleton instance of the client manager
    */
    public static let instance: ClientManager = ClientManager()

    private init() {}

    /*
    * Gets a client
    * @param hostInfo - the host info of the client
    * @return the client if found, None otherwise
    */
    public func getClient(hostInfo: HostInfo): Option<ActorClient> {
        clients.get(hostInfo)
    }

    /*
     * Gets a client or creates a new one if it doesn't exist
     * This method uses double-checked locking to ensure thread-safety when creating new clients.
     * @param hostInfo - the host info of the client
     * @return the client
     */
    public func getOrCreateClient(hostInfo: HostInfo): ActorClient {
        match (clients.get(hostInfo)) {
            case Some(client) => client
            case None =>
                synchronized(mtx) {
                    if (let Some(client) <- clients.get(hostInfo)) {
                        return client
                }
                let client = hostInfo.createClient()
                clients.put(hostInfo, client)
                client
            }
        }
    }

    /*
    * Removes a client
    * @param hostInfo - the host info of the client
    * @return the client if removed, None otherwise
    */
    public func removeClient(hostInfo: HostInfo): Option<ActorClient> {
        clients.remove(hostInfo)
    }

    /*
    * Registers a host info deserializer
    * @param typeName - the type name of the host info
    * @param deserializer - the deserializer to register
    */
    public func registerHostInfoDeserializer(typeName: String, deserializer: (DataModel) -> HostInfo): Unit {
        hostInfoDeserializer.put(typeName, deserializer)
    }

    /*
     * Gets a host info deserializer
     * @param typeName - the type name of the host info
     * @return the deserializer if found, None otherwise
     */
    public func getHostInfoDeserializer(typeName: String): Option<(DataModel) -> HostInfo> {
        hostInfoDeserializer.get(typeName)
    }
}