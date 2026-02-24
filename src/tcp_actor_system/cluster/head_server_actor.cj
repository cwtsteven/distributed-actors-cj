package actors.tcp_actor_system.cluster

import std.collection.*

import actors.*
import actors.macros.*
import actors.distributed.*
import actors.tcp_actor_system.*

import stdx.encoding.json.*
import stdx.serialization.serialization.*

private var __instance: ?HeadServer = None

const HEAD_SERVER_NAME = "head-server"
const MAX_TRIALS = 10

/*
* Head server interface
*/
@ActorInterface[distributed: true]
public interface HeadServer {
    /*
    * Joins as a worker to the head server
    * @param workerId - the id of the worker
    * @param workerAddr - the address of the worker
    * @param workerPort - the port of the worker
    * @return true if the worker joined successfully, false otherwise
    * @throws ActorNotFoundException - if the worker actor is not found on the specified worker
    * @throws RemoteException - if the remote connection fails
    */
    @Receiver[mode: AskOnly]
    func join(workerId: String, workerAddr: String, workerPort: UInt16): Bool

    /*
    * Leaves from the head server
    * @param workerId - the id of the worker
    * @return true if the worker left successfully, false otherwise
    */
    @Receiver[mode: AskOnly]
    func leave(workerId: String): Bool

    /*
    * Spawns an actor on a worker
    * @param typeName - the type name of the actor
    * @param actorName - the name of the actor
    * @param args - the arguments of the actor
    * @return the host info if the actor spawned successfully, None otherwise
    * @throws ActorNotFoundException - if the worker actor is not found on the specified worker
    * @throws RemoteException - if the remote connection fails
    * @throws ActorSystemException - for any unknown internal errors
    */
    @Receiver[mode: AskOnly]
    func spawnActor(typeName: String, actorName: String, args: Array<SpawnArgument>): Option<ActorProxy>

    /*
    * Gets an actor by name
    * @param actorName - the name of the actor
    * @return the host info if the actor is found, None otherwise
    * @throws ActorNotFoundException - if the actor is not found
    * @throws RemoteException - if the remote connection fails
    * @throws ActorSystemException - for any unknown internal errors
    */
    @Receiver[mode: AskOnly]
    func getActor(actorName: String): Option<ActorProxy>

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
    static func start(headServerAddr!: String, bindAt!: UInt16): Future<Unit> {
        __instance = Some(HeadServerImpl())
        let tcpHost = TCPActorHost(addr: headServerAddr, bindAt: bindAt)
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
        let hostInfo = TCPActorHostInfo(headServerAddr, port)
        let client = ClientManager.instance.getOrCreateClient(hostInfo)
        __instance = Some(HeadServer.getProxy(client.getActor(HEAD_SERVER_NAME).getOrThrow()))
    }
}

@Actor
class HeadServerImpl <: HeadServer {
    private let workerMap = HashMap<String, (TCPActorHostInfo, WorkerActor)>()
    private let workerList = ArrayList<String>() // worker id list
    private let actorMap = HashMap<String, String>() // actor name -> worker id
    private var index = 0
    private let logger: TCPActorLoggerWrapper

    init() {
        this.logger = TCPActorLoggerWrapper("[HeadServerImpl]")
    }

    /*
    * Joins a client to the head server
    * @param workerId - the id of the worker
    * @param workerAddr - the address of the worker
    * @param workerPort - the port of the worker
    * @return true if the worker joined successfully, false otherwise
    * @throws ActorNotFoundException - if the worker actor is not found on the specified worker
    * @throws RemoteException - if the remote connection fails
    */
    @Receiver[mode: AskOnly]
    public func join(workerId: String, workerAddr: String, workerPort: UInt16): Bool {
        logger.debug("joining worker ${workerId}:${workerAddr}:${workerPort} to the head server.")
        if (workerMap.contains(workerId)) {
            logger.debug("worker ${workerId} already joined to the head server.")
            return false
        }
        let hostInfo = TCPActorHostInfo(workerAddr, workerPort)
        let client = ClientManager.instance.getOrCreateClient(hostInfo)
        let workerActor = WorkerActor.getProxy(client.getActor(workerId).getOrThrow())
        workerMap.add(workerId, (hostInfo, workerActor))
        workerList.add(workerId)
        logger.debug("worker ${workerId} joined to the head server.")
        true
    }

    /*
    * Leaves a worker from the head server
    * @param workerId - the id of the worker
    * @return true if the worker left successfully, false otherwise
    */
    @Receiver[mode: AskOnly]
    public func leave(workerId: String): Bool {
        if (!workerList.contains(workerId)) {
            logger.debug("worker ${workerId} not found in the head server.")
            return false
        }
        workerMap.remove(workerId)
        workerList.removeIf{ it => it == workerId }
        logger.debug("worker ${workerId} left from the head server.")
        true
    }

    /*
    * Spawns an actor on a worker
    * @param typeName - the type name of the actor
    * @param actorName - the name of the actor
    * @param args - the arguments of the actor
    * @return the worker info if the actor spawned successfully, None otherwise
    * @throws ActorNotFoundException - if the worker actor is not found on the specified worker
    * @throws RemoteException - if the remote connection fails
    * @throws ActorSystemException - for any unknown internal errors
    */
    @Receiver[mode: AskOnly]
    public func spawnActor(typeName: String, actorName: String, args: Array<SpawnArgument>): Option<ActorProxy> {
        logger.debug("spawning actor ${actorName} with type name ${typeName}.")
        if (workerList.size == 0) {
            logger.debug("no clients found in the head server.")
            return Option<ActorProxy>.None
        }
        logger.debug("workerList size: ${workerList.size}.")

        // simple round robin scheduling
        var trial = 0
        while (trial < MAX_TRIALS) {
            if (index >= workerList.size) {
                index = index % workerList.size
            }
            let workerId = workerList[index]
            logger.debug("spawning actor ${actorName} on worker ${workerId} with type name ${typeName}.")
            match (workerMap.get(workerId)) {
                case Some((info, workerActor)) =>
                    if (workerActor.spawnActor(typeName, actorName, args).get()) {
                        index = (index + 1) % workerList.size
                        actorMap.add(actorName, workerId)
                        logger.debug("spawning actor ${actorName} on worker ${workerId} with type name ${typeName} success.")
                        return Some(ActorProxy(actorName, info))
                    }
                    logger.debug("spawning actor ${actorName} on worker ${workerId} with type name ${typeName} failed.")
                    index = (index + 1) % workerList.size
                case None =>
                    logger.debug("worker ${workerId} not found.")
                    index = (index + 1) % workerList.size
            }
            trial++
        }
        logger.debug("spawning actor ${actorName} with type name ${typeName} failed after ${MAX_TRIALS} trials.")
        Option<ActorProxy>.None
    }

    /*
    * Gets an actor by name
    * @param actorName - the name of the actor
    * @return the worker info if the actor is found, None otherwise
    * @throws ActorNotFoundException - if the actor is not found
    * @throws RemoteException - if the remote connection fails
    * @throws ActorSystemException - for any unknown internal errors
    */
    @Receiver[mode: AskOnly]
    public func getActor(actorName: String): Option<ActorProxy> {
        logger.debug("getting actor ${actorName}.")
        match (actorMap.get(actorName)) {
            case Some(workerId) =>
                match (workerMap.get(workerId)) {
                    case Some((info, workerActor)) =>
                        if (workerActor.containsActor(actorName).get()) {
                            logger.debug("actor ${actorName} found and alive.")
                            return Some(ActorProxy(actorName, info))
                        }
                        logger.debug("actor ${actorName} found but not alive.")
                        Option<ActorProxy>.None
                    case None =>
                        logger.debug("worker ${workerId} not found.")
                        Option<ActorProxy>.None
                }
            case None =>
                logger.debug("actor ${actorName} not found.")
                Option<ActorProxy>.None
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
        match (actorMap.get(actorName)) {
            case Some(workerId) =>
                match (workerMap.get(workerId)) {
                    case Some((_, workerActor)) =>
                        workerActor.removeActor(actorName).get()
                        true
                    case None =>
                        logger.debug("worker ${workerId} not found.")
                        false
                }
            case None =>
                logger.debug("actor ${actorName} not found.")
                false
        }
    }
}
