package actors

import stdx.serialization.serialization.*

public interface Distributable<T> {
    static func newProxy(name: String, actorSystem: ActorSystem): T
    static func getMetadata(): Metadata
    static func dispatch(a: T, receiverName: String, args: Array<DataModel>, config!: ReceiverConfig): Any
}

public class ActorProxy {
    public ActorProxy(
        public let name: String,
        public let actorSystem: ActorSystem
    ) {}

    public func tell<T>(receiverName: String, args: Array<DataModel>, config!: ReceiverConfig = ReceiverConfig.default): Unit {
        actorSystem.remoteTell<T>(name, receiverName, args, config: config)
    }

    public func post<T>(receiverName: String, args: Array<DataModel>, config!: ReceiverConfig = ReceiverConfig.default): ActorFuture<T> {
        let fut = DistributedActorFuture<T>()
        actorSystem.remoteCall<T>(name, receiverName, args, fut, config: config)
        fut
    }

    // public func post<T>(info: ReceiverInfo, args: Array<DataModel>): ActorFuture<T> {
    //     let fut = DistributedActorFuture<T>()
    //     actorSystem.remoteCall<T>(name, info.methodName, args, fut, config: config)
    //     fut
    // }
}

public interface ActorSystem {
    func register<T>(name: String, a: T): Bool where T <: Distributable<T>
    func deregister(name: String): Bool
    func find(name: String): Option<ActorInfo>
    func findAll(): Array<ActorInfo>
    func remoteCall<T>(name: String, receiverName: String, args: Array<DataModel>, fut: DistributedActorFuture<T>, config!: ReceiverConfig): Unit
    func remoteTell<T>(name: String, receiverName: String, args: Array<DataModel>, config!: ReceiverConfig): Unit
}