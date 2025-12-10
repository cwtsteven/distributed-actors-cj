package actors.tcp_actor_system.cluster

import std.collection.*

import actors.*
import actors.macros.*
import actors.distributed.*
import actors.tcp_actor_system.*

import encoding.json.*
import serialization.serialization.*

private var __instance: ?HeadServer = None

const HEAD_SERVER_NAME = "head-server"
const HEAD_SERVER_CLIENT_NAME = "head-server-client"
const MAX_TRIALS = 10

/*
* Head server interface
*/
@ActorInterface[distributed: true]
interface HeadServer {
    /*
    * Joins a client to the head server
    * @param clientId - the id of the client
    * @param clientAddr - the address of the client
    * @param clientPort - the port of the client
    * @return true if the client joined successfully, false otherwise
    * @throws ActorNotFoundException - if the worker actor is not found on the specified client
    * @throws RemoteException - if the remote connection fails
    */
    @Receiver[mode: AskOnly]
    func join(clientId: String, clientAddr: String, clientPort: UInt16): Bool

    /*
    * Leaves a client from the head server
    * @param clientId - the id of the client
    * @return true if the client left successfully, false otherwise
    */
    @Receiver[mode: AskOnly]
    func leave(clientId: String): Bool

    /*
    * Spawns an actor on a client
    * @param typeName - the type name of the actor
    * @param actorName - the name of the actor
    * @param args - the arguments of the actor
    * @return the client info if the actor spawned successfully, None otherwise
    * @throws ActorNotFoundException - if the worker actor is not found on the specified client
    * @throws RemoteException - if the remote connection fails
    * @throws ActorSystemException - for any unknown internal errors
    */
    @Receiver[mode: AskOnly]
    func spawnActor(typeName: String, actorName: String, args: Array<SpawnArgument>): Option<TCPActorClientInfo>

    /*
    * Gets an actor by name
    * @param actorName - the name of the actor
    * @return the client info if the actor is found, None otherwise
    * @throws ActorNotFoundException - if the actor is not found
    * @throws RemoteException - if the remote connection fails
    * @throws ActorSystemException - for any unknown internal errors
    */
    @Receiver[mode: AskOnly]
    func getActor(actorName: String): Option<TCPActorClientInfo>

    /*
    * Removes an actor by name
    * @param actorName - the name of the actor
    * @return true if the actor was removed, false otherwise
    * @throws ActorNotFoundException - if the actor is not found
    * @throws RemoteException - if the remote connection fails
    * @throws ActorSystemException - for any unknown internal errors
    */
    @Receiver[mode: AskOnly]
    func removeActor(actorName: String): Bool

    /*
    * The instance of the head server
    * @return the instance of the head server
    * @throws TCPClusterException - if the head server is not configured
    */
    static prop instance: HeadServer {
        get() {
            match (__instance) {
                case Some(i) => i
                case None => throw TCPClusterException("Head server not configured.")
            }
        }
    }

    /*
    * Starts the head server
    * @param bindAt - the port to bind to
    * @return a future handle to the thread
    * @throws SocketException - if the server socket fails to bind
    * @throws ActorSystemException - for any unknown internal errors
    */
    static func start(bindAt!: UInt16): Future<Unit> {
        __instance = Some(HeadServerImpl())
        let tcpHost = TCPActorHost(bindAt: bindAt)
        tcpHost.export(HEAD_SERVER_NAME, instance)
        tcpHost.serve()
    }

    /*
    * Connects to the head server
    * @param headServerAddr - the address of the head server
    * @param port - the port of the head server
    * @throws SocketException - if the server socket fails to bind
    * @throws ActorNotFoundException - if the head server is not found
    * @throws RemoteException - if the remote connection fails
    * @throws ActorSystemException - for any unknown internal errors
    */
    static func connect(headServerAddr!: String, port!: UInt16): Unit {
        let client = TCPActorClient.create(HEAD_SERVER_CLIENT_NAME, headServerAddr, port)
        __instance = Some(HeadServer.getProxy(HEAD_SERVER_NAME, client))
    }
}

@Actor
class HeadServerImpl <: HeadServer {
    private var clients = HashMap<String, (TCPActorClient, WorkerActor)>()
    private var clientsList = ArrayList<String>() // client id list
    private var actors = HashMap<String, String>() // actor name -> client id
    private var index = 0
    private let logger: TCPActorLoggerWrapper

    init() {
        this.logger = TCPActorLoggerWrapper("[HeadServerImpl]")
    }

    /*
    * Joins a client to the head server
    * @param clientId - the id of the client
    * @param clientAddr - the address of the client
    * @param clientPort - the port of the client
    * @return true if the client joined successfully, false otherwise
    * @throws ActorNotFoundException - if the worker actor is not found on the specified client
    * @throws RemoteException - if the remote connection fails
    */
    @Receiver[mode: AskOnly]
    public func join(clientId: String, clientAddr: String, clientPort: UInt16): Bool {
        logger.debug("joining client ${clientId} to the head server.")
        if (clients.contains(clientId)) {
            logger.debug("client ${clientId} already joined to the head server.")
            return false
        }
        let client = TCPActorClient(clientId, clientAddr, clientPort)
        clients.put(clientId, (client, WorkerActor.getProxy(clientId, client)))
        clientsList.append(clientId)
        logger.debug("client ${clientId} joined to the head server.")
        true
    }

    /*
    * Leaves a client from the head server
    * @param clientId - the id of the client
    * @return true if the client left successfully, false otherwise
    */
    @Receiver[mode: AskOnly]
    public func leave(clientId: String): Bool {
        if (!clients.contains(clientId)) {
            logger.debug("client ${clientId} not found in the head server.")
            return false
        }
        let c = clients.remove(clientId)
        clientsList.removeIf{ it => it == clientId }
        logger.debug("client ${clientId} left from the head server.")
        true
    }

    /*
    * Spawns an actor on a client
    * @param typeName - the type name of the actor
    * @param actorName - the name of the actor
    * @param args - the arguments of the actor
    * @return the client info if the actor spawned successfully, None otherwise
    * @throws ActorNotFoundException - if the worker actor is not found on the specified client
    * @throws RemoteException - if the remote connection fails
    * @throws ActorSystemException - for any unknown internal errors
    */
    @Receiver[mode: AskOnly]
    public func spawnActor(typeName: String, actorName: String, args: Array<SpawnArgument>): Option<TCPActorClientInfo> {
        logger.debug("spawning actor ${actorName} with type name ${typeName}.")
        if (clientsList.size == 0) {
            logger.debug("no clients found in the head server.")
            return None
        }
        logger.debug("clientsList size: ${clientsList.size}.")

        // simple round robin scheduling
        var trial = 0
        while (trial < MAX_TRIALS) {
            if (index >= clientsList.size) {
                index = index % clientsList.size
            }
            let clientId = clientsList[index]
            logger.debug("spawning actor ${actorName} on client ${clientId} with type name ${typeName}.")
            match (clients.get(clientId)) {
                case Some((client, workerActor)) =>
                    if (workerActor.spawnActor(typeName, actorName, args).get()) {
                        index = (index + 1) % clientsList.size
                        actors.put(actorName, clientId)
                        logger.debug("spawning actor ${actorName} on client ${clientId} with type name ${typeName} success.")
                        return Some(TCPActorClientInfo(client.id, client.info.addr, client.info.port))
                    }
                    logger.debug("spawning actor ${actorName} on client ${clientId} with type name ${typeName} failed.")
                    index = (index + 1) % clientsList.size
                case None =>
                    logger.debug("client ${clientId} not found.")
                    index = (index + 1) % clientsList.size
            }
            trial++
        }
        logger.debug("spawning actor ${actorName} with type name ${typeName} failed after ${MAX_TRIALS} trials.")
        None
    }

    /*
    * Gets an actor by name
    * @param actorName - the name of the actor
    * @return the client info if the actor is found, None otherwise
    * @throws ActorNotFoundException - if the actor is not found
    * @throws RemoteException - if the remote connection fails
    * @throws ActorSystemException - for any unknown internal errors
    */
    @Receiver[mode: AskOnly]
    public func getActor(actorName: String): Option<TCPActorClientInfo> {
        logger.debug("getting actor ${actorName}.")
        match (actors.get(actorName)) {
            case Some(clientId) =>
                match (clients.get(clientId)) {
                    case Some((client, workerActor)) =>
                        if (workerActor.containsActor(actorName).get()) {
                            logger.debug("actor ${actorName} found and alive.")
                            return Some(TCPActorClientInfo(client.id, client.info.addr, client.info.port))
                        }
                        logger.debug("actor ${actorName} found but not alive.")
                        None
                    case None =>
                        logger.debug("client ${clientId} not found.")
                        None
                }
            case None =>
                logger.debug("actor ${actorName} not found.")
                None
        }
    }

    /*
    * Removes an actor by name
    * @param actorName - the name of the actor
    * @return true if the actor was removed, false otherwise
    * @throws ActorNotFoundException - if the actor is not found
    * @throws RemoteException - if the remote connection fails
    * @throws ActorSystemException - for any unknown internal errors
    */
    @Receiver[mode: AskOnly]
    public func removeActor(actorName: String): Bool {
        logger.debug("removing actor ${actorName}.")
        match (actors.get(actorName)) {
            case Some(clientId) =>
                match (clients.get(clientId)) {
                    case Some((_, workerActor)) =>
                        workerActor.removeActor(actorName).get()
                        true
                    case None =>
                        logger.debug("client ${clientId} not found.")
                        false
                }
            case None =>
                logger.debug("actor ${actorName} not found.")
                false
        }
    }
}