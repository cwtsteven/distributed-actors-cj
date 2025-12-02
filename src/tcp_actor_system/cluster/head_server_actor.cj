package actors.tcp_actor_system.cluster

import std.collection.*

import actors.*
import actors.macros.*
import actors.distributed.*
import actors.tcp_actor_system.*

import encoding.json.*
import serialization.serialization.*

private var __instance: ?HeadServer = None

@ActorInterface[distributed: true]
interface HeadServer {
    @Receiver[mode: AskOnly]
    func join(clientId: String, clientAddr: String, clientPort: UInt16): Bool

    @Receiver[mode: AskOnly]
    func leave(clientId: String): Bool

    @Receiver[mode: AskOnly]
    func spawnActor(typeName: String, actorName: String, args: Array<SpawnArgument>): Option<ClientInfo>

    static prop instance: HeadServer {
        get() {
            match (__instance) {
                case Some(i) => i
                case None => throw IllegalStateException("Head server not configured.")
            }
        }
    }

    static func start(bindAt!: UInt16): Future<Unit> {
        __instance = Some(HeadServerImpl())
        let tcpHost = TCPActorHost(bindAt: bindAt)
        tcpHost.export("head-server", instance)
        tcpHost.serve()
    }

    static func connect(headServerAddr!: String, port!: UInt16): Unit {
        let client = TCPActorClient("head-server-client", headServerAddr, port)
        __instance = Some(HeadServer.getProxy("head-server", client))
    }
}

@Actor
class HeadServerImpl <: HeadServer {

    private var clients = HashMap<String, (TCPActorClient, WorkerActor)>()
    private var clientsList = ArrayList<String>()
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
    public func spawnActor(typeName: String, actorName: String, args: Array<SpawnArgument>): Option<ClientInfo> {
        TCPActorSystem.logger.debug("[HeadServerImpl]: spawning actor ${actorName} with type name ${typeName}")
        if (clientsList.size == 0) {
            return None
        }
        TCPActorSystem.logger.debug("[HeadServerImpl]: clientsList size: ${clientsList.size}")
        while (true) {
            if (index >= clientsList.size) {
                index = index % clientsList.size
            }
            let clientId = clientsList[index]
            TCPActorSystem.logger.debug("[HeadServerImpl]: spawning actor ${actorName} on client ${clientId} with type name ${typeName}")
            match (clients.get(clientId)) {
                case Some((client, workerActor)) =>
                    if (workerActor.spawnActor(typeName, actorName, args).get()) {
                        index = (index + 1) % clientsList.size
                        TCPActorSystem.logger.debug("[HeadServerImpl]: spawning actor ${actorName} on client ${clientId} with type name ${typeName} success")
                        return Some(ClientInfo(client.id, client.info.addr, client.info.port))
                    }
                    TCPActorSystem.logger.debug("[HeadServerImpl]: spawning actor ${actorName} on client ${clientId} with type name ${typeName} failed")
                    index = (index + 1) % clientsList.size
                case None =>
                    TCPActorSystem.logger.debug("[HeadServerImpl]: client ${clientId} not found")
                    index = (index + 1) % clientsList.size
            }
        }
        None
    }
}