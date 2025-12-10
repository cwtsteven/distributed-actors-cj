package actors.tcp_actor_system.cluster

import std.collection.concurrent.*

import actors.*
import actors.distributed.*
import actors.tcp_actor_system.*

/*
* TCP Cluster
*/
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

    /*
    * Creates the head server
    * @param headServerAddr - the address of the head server
    * @param headServerPort - the port of the head server
    * @return a future handle to the thread
    * @throws SocketException - if the server socket fails to bind
    * @throws ActorSystemException - for any unknown internal errors
    * @throws TCPClusterException - if the cluster is already initialized
    */
    public static func createHeadServer(headServerAddr!: String, headServerPort!: UInt16): Future<Unit> {
        if (let Some(_) <- __instance) {
            throw TCPClusterException("TCPCluster already initialized.")
        }

        __instance = Some(TCPCluster())
        HeadServer.start(headServerAddr: headServerAddr, bindAt: headServerPort)
    }

    /*
    * Creates the worker
    * @param headServerAddr - the address of the head server
    * @param headServerPort - the port of the head server
    * @param workerId - the id of the worker
    * @param workerAddr - the address of the worker
    * @param workerPort - the port of the worker
    * @return a future handle to the thread
    * @throws SocketException - if the server socket fails to bind
    * @throws ActorSystemException - for any unknown internal errors
    * @throws TCPClusterException - if the cluster is already initialized
    * @throws ActorNotFoundException - if the head server actor is not found
    * @throws RemoteException - if the remote connection fails
    */
    public static func createWorker(headServerAddr!: String, headServerPort!: UInt16, workerId!: String, workerAddr!: String, workerPort!: UInt16): Future<Unit> {
        if (let Some(_) <- __instance) {
            throw TCPClusterException("TCPCluster already initialized.")
        }

        __instance = Some(TCPCluster())
        let fut = WorkerActor.start(name: workerId, addr: workerAddr, bindAt: workerPort)
        HeadServer.connect(headServerAddr: headServerAddr, port: headServerPort)
        HeadServer.instance.join(workerId, workerAddr, workerPort).get()
        fut
    }

    /*
    * Joins a worker to the head server
    * @param headServerAddr - the address of the head server
    * @param headServerPort - the port of the head server
    * @return true if the worker joined successfully, false otherwise
    * @throws SocketException - if the server socket fails to bind
    * @throws ActorSystemException - for any unknown internal errors
    * @throws TCPClusterException - if the cluster is already initialized
    * @throws ActorNotFoundException - if the head server actor is not found
    * @throws RemoteException - if the remote connection fails
    */
    public static func join(headServerAddr!: String, headServerPort!: UInt16): Bool {
        if (let Some(_) <- __instance) {
            return false
        }

        __instance = Some(TCPCluster())
        HeadServer.connect(headServerAddr: headServerAddr, port: headServerPort)
        true
    }

    /*
    * Spawns an actor
    * @param name - the name of the actor
    * @param args - the arguments of the actor
    * @return the proxy of the actor
    * @throws ActorNotFoundException - if the worker actor is not found on the specified client
    * @throws RemoteException - if the remote connection fails
    * @throws TCPClusterException - if the cluster is not initialized
    * @throws ActorSystemException - for any unknown internal errors
    */
    public static func spawnActor<T>(name: String, args: Array<SpawnArgument>): Option<T> where T <: Distributable & Proxyable<T> & Spawnable<T> {
        let p = HeadServer.instance.spawnActor(T.typeName(), name, args).get()
        if (let Some(proxy) <- p) {
            return Some(T.getProxy(proxy))
        }
        None
    }

    /*
    * Gets an actor
    * @param name - the name of the actor
    * @return the proxy of the actor
    * @throws ActorNotFoundException - if the worker actor is not found on the specified client
    * @throws RemoteException - if the remote connection fails
    * @throws TCPClusterException - if the cluster is not initialized
    * @throws ActorSystemException - for any unknown internal errors
    */
    public static func getActor<T>(name: String): Option<T> where T <: Distributable & Proxyable<T> & Spawnable<T> {
        match (HeadServer.instance.getActor(name).get()) {
            case Some(proxy) =>
                return Some(T.getProxy(proxy))
            case None => None
        }
    }

    /*
    * Removes an actor
    * @param name - the name of the actor
    * @return true if the actor was removed, false otherwise
    * @throws ActorNotFoundException - if the worker actor is not found on the specified client
    * @throws RemoteException - if the remote connection fails
    * @throws TCPClusterException - if the cluster is not initialized
    * @throws ActorSystemException - for any unknown internal errors
    */
    public static func removeActor(name: String): Bool {
        HeadServer.instance.removeActor(name).get()
    }
}