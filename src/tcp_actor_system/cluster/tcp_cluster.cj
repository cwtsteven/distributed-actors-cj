package actors.tcp_actor_system.cluster

import std.collection.concurrent.*

import actors.*
import actors.distributed.*
import actors.tcp_actor_system.*

public class TCPCluster <: ActorCluster {

    private static var __instance: ?TCPCluster = None
    public static prop instance: TCPCluster {
        get() {
            match (__instance) {
                case Some(i) => i
                case None => throw TCPClusterException("TCPCluster not initialized.")
            }
        }
    }

    init() {}

    public static func createHeadServer(headServerAddr!: String, headServerPort!: UInt16): Future<Unit> {
        if (let Some(_) <- __instance) {
            throw TCPClusterException("TCPCluster already initialized.")
        }

        __instance = Some(TCPCluster())
        HeadServer.start(bindAt: headServerPort)
    }

    public static func createWorker(headServerAddr!: String, headServerPort!: UInt16, selfId!: String, selfAddr!: String, selfPort!: UInt16): Future<Unit> {
        if (let Some(_) <- __instance) {
            throw TCPClusterException("TCPCluster already initialized.")
        }

        __instance = Some(TCPCluster())
        let fut = WorkerActor.start(name: selfId, bindAt: selfPort)
        HeadServer.connect(headServerAddr: headServerAddr, port: headServerPort)
        HeadServer.instance.join(selfId, selfAddr, selfPort).get()
        fut
    }

    public static func join(headServerAddr!: String, headServerPort!: UInt16): Bool {
        if (let Some(_) <- __instance) {
            return false
        }

        __instance = Some(TCPCluster())
        HeadServer.connect(headServerAddr: headServerAddr, port: headServerPort)
        true
    }

    public static func spawnActor<T>(name: String, args: Array<SpawnArgument>): Option<T> where T <: Distributable & Proxyable<T> & Spawnable<T> {
        let info = HeadServer.instance.spawnActor(T.typeName(), name, args).get()
        if (let Some(info) <- info) {
            // TODO: duplicated client?
            let proxy = T.getProxy(name, TCPActorClient(info.id, info.addr, info.port))
            return Some(proxy)
        }
        None
    }

    public static func getActor<T>(name: String): Option<T> where T <: Distributable & Proxyable<T> & Spawnable<T> {
        match (HeadServer.instance.getActor(name).get()) {
            case Some(info) =>
                let proxy = T.getProxy(name, TCPActorClient(info.id, info.addr, info.port))
                return Some(proxy)
            case None => None
        }
    }

    public static func killActor(name: String): Bool {
        HeadServer.instance.killActor(name).get()
    }
}