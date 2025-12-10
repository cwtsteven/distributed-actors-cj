package actors.distributed

import std.collection.concurrent.*

import serialization.serialization.*

/*
* A class that manages the clients
*/
public class ClientManager {
    /*
    * The map of the clients
    */
    private let clients = ConcurrentHashMap<String, ActorClient>()
    private let clientDeserializer = ConcurrentHashMap<String, (DataModel) -> ActorClient>()

    private init() {}

    public static let instance: ClientManager = ClientManager()

    public func getClient(name: String): Option<ActorClient> {
        clients.get(name)
    }

    public func registerClient(name: String, client: ActorClient): Unit {
        clients.putIfAbsent(name, client)
    }

    public func removeClient(name: String): Option<ActorClient> {
        clients.remove(name)
    }

    public func registerClientDeserializer(typeName: String, deserializer: (DataModel) -> ActorClient): Unit {
        clientDeserializer.put(typeName, deserializer)
    }

    public func getClientDeserializer(typeName: String): Option<(DataModel) -> ActorClient> {
        clientDeserializer.get(typeName)
    }
}