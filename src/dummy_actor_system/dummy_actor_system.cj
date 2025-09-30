package actors.dummy_actor_system

import std.collection.*
import std.collection.concurrent.*
import std.sync.*

import actors.*
import actors.macros.*
import actors.distributed.*

import serialization.serialization.*

private let actorMap = ConcurrentHashMap<String, Distributable>()
private let futMap = ConcurrentHashMap<UInt64, DistributedFuture>()
private let futId = AtomicUInt64(0)
private let metadataMap = ConcurrentHashMap<String, ActorInfo>()

/*
* Dummy Actor host
*/
@Actor
public class DummyActorHost <: ActorHost {

    public func register(name: String, a: Distributable): Bool {
        let res = actorMap.putIfAbsent(name, a)
        match (res) {
            case Some(_) => false
            case None =>
                metadataMap.putIfAbsent(name, ActorInfo(name: name, metadata: a.getMetadata()))
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

    @Receiver[mode: TellOnly]
    func handleResult(id: UInt64, res: DataModel): Unit {
        match (futMap.remove(id)) {
            case Some(fut) => fut.fulfill(res); return
            case None => return
        }
    }

    @Receiver[mode: TellOnly]
    func handleRemoteCall(name: String, receiverName: String, args: Array<DataModel>, remoteConfig: ReceiverConfig, id: ?UInt64): Unit {
        try {
            let a = match (actorMap.get(name)) {
                case Some(p) => p
                case None => throw ActorNotFoundException(name)
            }

            let isTell = id == None
            if (isTell) {
                a.dispatchTell(receiverName, args, remoteConfig)
            } else {
                let fut = a.dispatchAsk(receiverName, args, remoteConfig)

                spawn {
                    let res = fut.getResult()
                    this.handleResult(id.getOrThrow(), res, tell: True)
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
            throw e
        }
    }
}

/*
* Dummy Actor client
*/
public class DummyActorClient <: ActorClient {
    public prop id: String { get() { "dummy" } }

    public DummyActorClient(let host: DummyActorHost) {}

    public func find(name: String): Option<ActorInfo> {
        match (actorMap.get(name)) {
            case Some(_) => Some(metadataMap[name])
            case None => None
        }
    }

    public func findAll(): Array<ActorInfo> {
        let list = ArrayList<ActorInfo>()
        let it = actorMap.iterator()
        while (true) {
            match (it.next()) {
                case Some((name, a)) => list.append(ActorInfo(name: name, metadata: a.getMetadata()))
                case None => break
            }
        }
        list.toArray()
    }

    public func remoteCall(invokeInfo: InvokeInfo): Unit {
        match (invokeInfo.fut) {
            case Some(fut) => remoteAsk(invokeInfo.name, invokeInfo.receiverName, invokeInfo.args, invokeInfo.config, fut)
            case None => remoteTell(invokeInfo.name, invokeInfo.receiverName, invokeInfo.args, invokeInfo.config)
        }
    }

    func remoteAsk(name: String, receiverName: String, args: Array<DataModel>, config: ReceiverConfig, fut: DistributedFuture): Unit {
        let _ = config
        let id = futId.fetchAdd(1)
        futMap.put(id, fut)
        host.handleRemoteCall(name, receiverName, args, config, Some(id), tell: True)
    }

    func remoteTell(name: String, receiverName: String, args: Array<DataModel>, config: ReceiverConfig): Unit {
        let _ = config
        host.handleRemoteCall(name, receiverName, args, config, None, tell: True)
    }
}