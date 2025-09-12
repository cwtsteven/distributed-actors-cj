package actors

import stdx.serialization.serialization.*

public interface Distributable<T> {
    // static func newProxy(name: String, actorSystem: ActorSystem): T
    static func getMetadata(): Metadata
    static func dispatch(a: T, receiverName: String, args: Array<DataModel>, config: ReceiverConfig, isTell: Bool): Any
}

public class ActorProxy {
    public ActorProxy(
        public let name: String,
        public let actorSystem: ActorSystem
    ) {}

    public func tell<T>(receiverName: String, args: Array<DataModel>, config!: ReceiverConfig = ReceiverConfig.default): Unit {
        actorSystem.remoteTell<T>(name, receiverName, args, config)
    }

    public func post<T>(receiverName: String, args: Array<DataModel>, config!: ReceiverConfig = ReceiverConfig.default): ActorFuture<T> {
        let fut = DistributedActorFuture<T>()
        actorSystem.remoteCall<T>(name, receiverName, args, config, fut)
        fut
    }
}

public interface ActorSystem {
    func register<T>(name: String, a: T): Bool where T <: Distributable<T>
    func deregister(name: String): Bool
    func find(name: String): Option<ActorInfo>
    func findAll(): Array<ActorInfo>
    func remoteCall<T>(name: String, receiverName: String, args: Array<DataModel>, config: ReceiverConfig, fut: DistributedActorFuture<T>): Unit
    func remoteTell<T>(name: String, receiverName: String, args: Array<DataModel>, config: ReceiverConfig): Unit
}