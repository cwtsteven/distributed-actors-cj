package actors.tcp_actor_system.cluster

import std.collection.*

import actors.*
import actors.macros.*
import actors.distributed.*
import actors.tcp_actor_system.*

import encoding.json.*
import serialization.serialization.*

@ActorInterface[distributed: true]
interface WorkerActor {
    @Receiver[mode: AskOnly]
    func spawnActor(typeName: String, actorName: String, args: Array<SpawnArgument>): Bool

    @Receiver[mode: AskOnly]
    func containsActor(actorName: String): Bool

    @Receiver[mode: AskOnly]
    func killActor(actorName: String): Bool

    static func start(name!: String, bindAt!: UInt16): Future<Unit> {
        let tcpHost = TCPActorHost(bindAt: bindAt)
        let instance = WorkerActorImpl(tcpHost)
        tcpHost.export(name, instance)
        tcpHost.serve()
    }
}

@Actor
class WorkerActorImpl <: WorkerActor {
    private let tcpHost: TCPActorHost

    // keep actors alive
    private var actors = HashMap<String, Distributable>()

    init(tcpHost: TCPActorHost) {
        this.tcpHost = tcpHost
    }

    @Receiver[mode: AskOnly]
    public func spawnActor(typeName: String, actorName: String, args: Array<SpawnArgument>): Bool {
        TCPActorSystem.logger.debug("[WorkerActorImpl]: spawning actor ${actorName} with type name ${typeName}.")
        let f = ActorCluster.getSpawnable(typeName)
        if (let Some(f) <- f) {
            TCPActorSystem.logger.debug("[WorkerActorImpl]: spawnable function found. args: ${args.size}.")
            let opt = f(args)
            if (let Some(res) <- opt) {
                TCPActorSystem.logger.debug("[WorkerActorImpl]: spawning actor ${actorName} with type name ${typeName} success.")
                actors.put(actorName, res)
                tcpHost.export(actorName, res)
                return true
            }
            TCPActorSystem.logger.debug("[WorkerActorImpl]: spawning actor ${actorName} with type name ${typeName} failed.")
            return false
        }
        TCPActorSystem.logger.debug("[WorkerActorImpl]: spawnable function not found.")
        false
    }

    @Receiver[mode: AskOnly]
    public func containsActor(actorName: String): Bool {
        actors.contains(actorName)
    }

    @Receiver[mode: AskOnly]
    public func killActor(actorName: String): Bool {
        if (!actors.contains(actorName)) {
            return false
        }
        actors.remove(actorName)
        true
    }
}