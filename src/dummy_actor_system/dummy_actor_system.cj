package actors.dummy_actor_system

import std.collection.concurrent.*
import std.sync.*

import serialization.serialization.*

import actors.macros.*
import actors.*

@Actor
public class DummyActorSystem <: ActorSystem {
    private let actorMap = ConcurrentHashMap<String, Distributable>()
    private let futMap = ConcurrentHashMap<UInt64, Fullfillable>()
    private let futId = AtomicUInt64(0)
    private let metadataMap = ConcurrentHashMap<String, Metadata>()

    public func register(name: String, a: Distributable): Bool {
        let res = actorMap.putIfAbsent(name, a)
        match (res) {
            case Some(_) => false
            case None =>
                metadataMap.putIfAbsent(name, a.getMetadata())
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

    public func remoteCall(name: String, receiverName: String, args: Array<DataModel>, config: ReceiverConfig, fut: Fullfillable): Unit {
        let _ = config
        let id = futId.fetchAdd(1)
        futMap.put(id, fut)
        this.handleRemoteCall(name, receiverName, args, config, Some(id), tell: True)
    }

    public func remoteTell(name: String, receiverName: String, args: Array<DataModel>, config: ReceiverConfig): Unit {
        let _ = config
        this.handleRemoteCall(name, receiverName, args, config, None, tell: True)
    }

    public func findAll(): Array<ActorInfo> {
        metadataMap.toArray()
    }

    @Receiver[mode: TellOnly]
    func handleResult(id: UInt64, res: Any): Unit {
        match (futMap.remove(id)) {
            case Some(fut) => fut.fulfill(res); return
            case None => return
        }
    }

    @Receiver[mode: TellOnly]
    func handleRemoteCall(name: String, receiverName: String, args: Array<DataModel>, remoteConfig: ReceiverConfig, id: ?UInt64): Unit {
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
                let res = fut.wait()
                this.handleResult(id.getOrThrow(), res, tell: True)
            }
        }
    }
}