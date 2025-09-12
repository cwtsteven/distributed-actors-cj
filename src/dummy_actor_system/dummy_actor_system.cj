package actors.dummy_actor_system

import std.collection.concurrent.*
import std.reflect.*
import std.sync.*

import stdx.serialization.serialization.*

import actors.macros.*
import actors.*

let argsTi = TypeInfo.of<Array<DataModel>>()
let anyTi = TypeInfo.of<Any>()

@Actor
public class DummyActorSystem <: ActorSystem {
    private let actorMap = ConcurrentHashMap<String, (Any, TypeInfo)>()
    private let futMap = ConcurrentHashMap<UInt64, (Any, TypeInfo)>()
    private let futId = AtomicUInt64(0)
    private let metadataMap = ConcurrentHashMap<String, Metadata>()

    public func register<T>(name: String, a: T): Bool where T <: Distributable<T> {
        let res = actorMap.addIfAbsent(name, (a, TypeInfo.of<T>()))
        match (res) {
            case Some(_) => false
            case None =>
                metadataMap.addIfAbsent(name, T.getMetadata())
                true
        }
    }

    public func deregister(name: String): Bool {
        match (actorMap.remove(name)) {
            case Some(_) =>
                metadataMap.remove(name)
                true
            case None => false
        }
    }

    public func find(name: String): Option<ActorInfo> {
        match (actorMap.get(name)) {
            case Some(_) => Some((name, metadataMap.get(name).getOrThrow()))
            case None => None
        }
    }

    public func remoteCall<T>(name: String, receiverName: String, args: Array<DataModel>, fut: DistributedActorFuture<T>, config!: ReceiverConfig = ReceiverConfig.default): Unit {
        let _ = config
        let id = futId.fetchAdd(1)
        futMap.add(id, (fut, TypeInfo.of<DistributedActorFuture<T>>()))
        this.handleRemoteCall(name, receiverName, args, Some(id), tell: True)
    }

    public func remoteTell<T>(name: String, receiverName: String, args: Array<DataModel>, config!: ReceiverConfig = ReceiverConfig.default): Unit {
        let _ = config
        this.handleRemoteCall(name, receiverName, args, None, tell: True)
    }

    public func findAll(): Array<ActorInfo> {
        metadataMap.toArray()
    }

    @Receiver[mode: TellOnly]
    func handleResult(id: UInt64, res: Any): Unit {
        match (futMap.remove(id)) {
            case Some((fut, ti)) =>
                let fulfillTi = ti.getInstanceFunction("fulfill", [anyTi])
                fulfillTi.apply(fut, [res])
            case None => ()
        }
    }

    @Receiver[mode: TellOnly]
    func handleRemoteCall(name: String, receiverName: String, args: Array<DataModel>, id: ?UInt64): Unit {
        let (a, ti) = match (actorMap.get(name)) {
            case Some(p) => p
            case None => throw ActorNotFoundException(name)
        }

        let dispatchFunc = ti.getStaticFunction("dispatch", [ti, TypeInfo.of<String>(), argsTi])
        let fut = dispatchFunc.apply(ti, [a, receiverName, args])

        if (id == None) {
            return
        }

        let retTi = TypeInfo.of(a).getInstanceFunctions(receiverName)[0].returnType // there can only be one

        spawn {
            let getTi = retTi.getInstanceFunction("get", [])
            let res = getTi.apply(fut)
            this.handleResult(id.getOrThrow(), res, tell: True)
        }
    }
}