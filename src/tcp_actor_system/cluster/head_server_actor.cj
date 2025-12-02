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

@ActorInterface[distributed: true]
interface HeadServer {
    @Receiver[mode: AskOnly]
    func join(clientId: String, clientAddr: String, clientPort: UInt16): Bool

    @Receiver[mode: AskOnly]
    func leave(clientId: String): Bool

    @Receiver[mode: AskOnly]
    func spawnActor(typeName: String, actorName: String, args: Array<SpawnArgument>): Option<TCPActorClientInfo>

    @Receiver[mode: AskOnly]
    func killActor(actorName: String): Bool

    static prop instance: HeadServer {
        get() {
            match (__instance) {
                case Some(i) => i
                case None => throw TCPClusterException("Head server not configured.")
            }
        }
    }

    static func start(bindAt!: UInt16): Future<Unit> {
        __instance = Some(HeadServerImpl())
        let tcpHost = TCPActorHost(bindAt: bindAt)
        tcpHost.export(HEAD_SERVER_NAME, instance)
        tcpHost.serve()
    }

    static func connect(headServerAddr!: String, port!: UInt16): Unit {
        let client = TCPActorClient(HEAD_SERVER_CLIENT_NAME, headServerAddr, port)
        __instance = Some(HeadServer.getProxy(HEAD_SERVER_NAME, client))
    }
}

@Actor
class HeadServerImpl <: HeadServer {

    private var clients = HashMap<String, (TCPActorClient, WorkerActor)>()
    private var clientsList = ArrayList<String>() // client id list
    private var actors = HashMap<String, String>() // actor name -> client id
    private var index = 0

    @Receiver[mode: AskOnly]
    public func join(clientId: String, clientAddr: String, clientPort: UInt16): Bool {
        if (clients.contains(clientId)) {
            return false
        }
        let client = TCPActorClient(clientId, clientAddr, clientPort)
        clients.put(clientId, (client, WorkerActor.getProxy(clientId, client)))
        clientsList.append(clientId)
        true
    }

    @Receiver[mode: AskOnly]
    public func leave(clientId: String): Bool {
        if (!clients.contains(clientId)) {
            return false
        }
        let c = clients.remove(clientId)
        clientsList.removeIf{ it => it == clientId }
        true
    }

    @Receiver[mode: AskOnly]
    public func spawnActor(typeName: String, actorName: String, args: Array<SpawnArgument>): Option<TCPActorClientInfo> {
        TCPActorSystem.logger.debug("[HeadServerImpl]: spawning actor ${actorName} with type name ${typeName}")
        if (clientsList.size == 0) {
            return None
        }
        TCPActorSystem.logger.debug("[HeadServerImpl]: clientsList size: ${clientsList.size}")

        // simple round robin scheduling
        var trial = 0
        while (trial < MAX_TRIALS) {
            if (index >= clientsList.size) {
                index = index % clientsList.size
            }
            let clientId = clientsList[index]
            TCPActorSystem.logger.debug("[HeadServerImpl]: spawning actor ${actorName} on client ${clientId} with type name ${typeName}")
            match (clients.get(clientId)) {
                case Some((client, workerActor)) =>
                    if (workerActor.spawnActor(typeName, actorName, args).get()) {
                        index = (index + 1) % clientsList.size
                        actors.put(actorName, clientId)
                        TCPActorSystem.logger.debug("[HeadServerImpl]: spawning actor ${actorName} on client ${clientId} with type name ${typeName} success")
                        return Some(TCPActorClientInfo(client.id, client.info.addr, client.info.port))
                    }
                    TCPActorSystem.logger.debug("[HeadServerImpl]: spawning actor ${actorName} on client ${clientId} with type name ${typeName} failed")
                    index = (index + 1) % clientsList.size
                case None =>
                    TCPActorSystem.logger.debug("[HeadServerImpl]: client ${clientId} not found")
                    index = (index + 1) % clientsList.size
            }
            trial++
        }
        TCPActorSystem.logger.debug("[HeadServerImpl]: spawning actor ${actorName} with type name ${typeName} failed after ${MAX_TRIALS} trials")
        None
    }

    @Receiver[mode: AskOnly]
    public func killActor(actorName: String): Bool {
        match (actors.get(actorName)) {
            case Some(clientId) =>
                match (clients.get(clientId)) {
                    case Some((_, workerActor)) =>
                        workerActor.killActor(actorName).get()
                        true
                    case None => false
                }
            case None => false
        }
        false
    }
}