package actors.tcp_actor_system.cluster

import std.collection.*

import actors.*
import actors.macros.*
import actors.distributed.*
import actors.tcp_actor_system.*

import encoding.json.*
import serialization.serialization.*

/*
* Worker actor interface
*/
@ActorInterface[distributed: true]
interface WorkerActor {
    /*
    * Spawns an actor on the worker
    * @param typeName - the type name of the actor
    * @param actorName - the name of the actor
    * @param args - the arguments of the actor
    * @return true if the actor spawned successfully, false otherwise
    * @throws ActorSystemException - for any unknown internal errors
    */
    @Receiver[mode: AskOnly]
    func spawnActor(typeName: String, actorName: String, args: Array<SpawnArgument>): Bool

    /*
    * Checks if an actor is alive
    * @param actorName - the name of the actor
    * @return true if the actor is alive, false otherwise
    */
    @Receiver[mode: AskOnly]
    func containsActor(actorName: String): Bool

    /*
    * Removes an actor
    * @param actorName - the name of the actor
    * @return true if the actor was removed, false otherwise
    */
    @Receiver[mode: AskOnly]
    func removeActor(actorName: String): Bool

    /*
    * Starts the worker actor
    * @param name - the name of the worker actor
    * @param bindAt - the port to bind to
    * @return a future handle to the thread
    * @throws SocketException - if the server socket fails to bind
    * @throws ActorSystemException - for any unknown internal errors
    */
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
    private let logger: TCPActorLoggerWrapper

    init(tcpHost: TCPActorHost) {
        this.tcpHost = tcpHost
        this.logger = TCPActorLoggerWrapper("[WorkerActorImpl]")
    }

    /*
    * Spawns an actor on the worker
    * @param typeName - the type name of the actor
    * @param actorName - the name of the actor
    * @param args - the arguments of the actor
    * @return true if the actor spawned successfully, false otherwise
    * @throws ActorSystemException - for any unknown internal errors
    */
    @Receiver[mode: AskOnly]
    public func spawnActor(typeName: String, actorName: String, args: Array<SpawnArgument>): Bool {
        logger.debug("spawning actor ${actorName} with type name ${typeName}.")
        let f = ActorCluster.getSpawningFunc(typeName)
        if (let Some(f) <- f) {
            logger.debug("spawnable function found. args: ${args.size}.")
            let opt = f(args)
            if (let Some(res) <- opt) {
                logger.debug("spawning actor ${actorName} with type name ${typeName} success.")
                actors.put(actorName, res)
                tcpHost.export(actorName, res)
                return true
            }
            logger.debug("spawning actor ${actorName} with type name ${typeName} failed.")
            return false
        }
        logger.debug("spawnable function not found.")
        false
    }

    /*
    * Checks if an actor is alive
    * @param actorName - the name of the actor
    * @return true if the actor is alive, false otherwise
    */
    @Receiver[mode: AskOnly]
    public func containsActor(actorName: String): Bool {
        actors.contains(actorName)
    }

    /*
    * Removes an actor
    * @param actorName - the name of the actor
    * @return true if the actor was removed, false otherwise
    */
    @Receiver[mode: AskOnly]
    public func removeActor(actorName: String): Bool {
        if (!actors.contains(actorName)) {
            return false
        }
        actors.remove(actorName)
        true
    }
}