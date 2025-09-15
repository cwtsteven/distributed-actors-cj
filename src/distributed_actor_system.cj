package actors

import stdx.serialization.serialization.*

public interface Fullfillable {
    func fulfill(value: Any): Bool
}

public interface Distributable {
    static func getMetadata(): Metadata

    func dispatchTell(receiverName: String, args: Array<DataModel>, config: ReceiverConfig): Unit
    func dispatchAsk(receiverName: String, args: Array<DataModel>, config: ReceiverConfig): Waitable
}

public class ActorProxy {
    public ActorProxy(
        public let name: String,
        public let actorSystem: ActorSystem
    ) {}

    public func postMessage(receiverName: String, args: Array<DataModel>, config!: ReceiverConfig = ReceiverConfig.default): Unit {
        actorSystem.remoteTell(name, receiverName, args, config)
    }

    public func post<T>(receiverName: String, args: Array<DataModel>, config!: ReceiverConfig = ReceiverConfig.default): ActorFuture<T> where T <: Serializable<T> {
        let fut = DistributedActorFuture<T>()
        actorSystem.remoteCall(name, receiverName, args, config, fut)
        fut
    }
}

public interface ActorSystem {
    func register<T>(name: String, a: T): Bool where T <: Distributable
    func deregister(name: String): Bool
    func find(name: String): Option<ActorInfo>
    func findAll(): Array<ActorInfo>
    func remoteCall(name: String, receiverName: String, args: Array<DataModel>, config: ReceiverConfig, fut: Fullfillable): Unit
    func remoteTell(name: String, receiverName: String, args: Array<DataModel>, config: ReceiverConfig): Unit
}

public class DistributedActorFuture<T> <: ActorFuture<T> & Fullfillable where T <: Serializable<T> {
    init() {}

    public func fulfill(value: Any): Bool {
        if (isReady.load()) {
            return false
        }

        let res: FutureResult<T> = match (value) {
            case v: T => Okay(v)
            case e: Exception => Exc(e)
            case e: Error => Err(e)
            case _ =>
                throw IllegalArgumentException("TODO")
        }

        synchronized(mtx) {
            if (isReady.load()) {
                return false
            }
            this.result = res
            isReady.store(true)
            cond.notifyAll()
            true
        }
    }
}

protected enum FutureResult<T> {
    Okay(T)
    | Exc(Exception)
    | Err(Error)

    func getOrThrow(): T {
        match (this) {
            case Okay(res) => return res
            case Exc(e) => throw e
            case Err(e) => throw e
        }
    }
}