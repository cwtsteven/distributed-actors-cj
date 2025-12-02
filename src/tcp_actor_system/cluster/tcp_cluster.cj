package actors.tcp_actor_system.cluster

import std.collection.concurrent.*

import actors.*
import actors.distributed.*
import actors.tcp_actor_system.*

public class TCPCluster <: ActorCluster {

    public static var instance: TCPCluster = unsafe { zeroValue<TCPCluster>() }

    init() {}

    public static func createHeadServer(headServerAddr!: String, headServerPort!: UInt16): Future<Unit> {
        instance = TCPCluster()
        HeadServer.start(bindAt: headServerPort)
    }

    public static func createWorker(headServerAddr!: String, headServerPort!: UInt16, selfId!: String, selfAddr!: String, selfPort!: UInt16): Future<Unit> {
        instance = TCPCluster()
        let fut = WorkerActor.start(name: selfId, bindAt: selfPort)
        HeadServer.connect(headServerAddr: headServerAddr, port: headServerPort)
        HeadServer.instance.join(selfId, selfAddr, selfPort).get()
        fut
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
}