package actors

import std.collection.*

import stdx.serialization.serialization.*

public interface Distributable<T> {
    static func newProxy(name: String, actorSystem: ActorSystem): T
    static func getMetadata(): Metadata
}

public class ActorProxy {
    public ActorProxy(
        public let name: String,
        public let actorSystem: ActorSystem
    ) {}

    public func post<T>(info: ReceiverInfo, args: Array<DataModel>): ActorFuture<T> {
        let fut = DistributedActorFuture<T>()
        actorSystem.remoteCall<T>(name, info, args, fut)
        fut
    }
}

public interface ActorSystem {
    func register<T>(name: String, a: T): Bool where T <: Distributable<T>
    func deregister(name: String): Bool
    func find<T>(name: String): Option<T> where T <: Distributable<T>
    func findAll<T>(): Array<T> where T <: Distributable<T>
    func findGeneric(name: String): Option<ActorProxy>
    func remoteCall<T>(name: String, info: ReceiverInfo, args: Array<DataModel>, fut: DistributedActorFuture<T>): Unit

    func getAll(): Array<(String, Metadata)>
}