package actors

import std.collection.concurrent.*
import std.reflect.*
import std.sync.*

import stdx.serialization.serialization.*

import actors.macros.*

let rInfoTi = TypeInfo.of<ReceiverInfo>()
let argsTi = TypeInfo.of<Array<DataModel>>()
let anyTi = TypeInfo.of<Any>()

@Actor
public class DummyActorSystem <: ActorSystem {
    private let actorMap = ConcurrentHashMap<String, (Any, TypeInfo)>()
    private let futMap = ConcurrentHashMap<UInt64, (Any, TypeInfo)>()
    private let futId = AtomicUInt64(0)
    
    public func register<T>(name: String, a: T): Bool where T <: Distributable<T> {
        let res = actorMap.addIfAbsent(name, (a, TypeInfo.of<T>()))
        match (res) {
            case Some(_) => false
            case None => true
        }
    }
    
    public func deregister(name: String): Bool {
        match (actorMap.remove(name)) {
            case Some(_) => true 
            case None => false
        }
    }

    public func find<T>(name: String): Option<T> where T <: Distributable<T> {
        match (actorMap.get(name)) {
            case Some(_) => Some(T.newProxy(name, this)) 
            case None => None
        }
    }   

    public func findAll<T>(): Array<T> where T <: Distributable<T> {
        throw Exception()
    }   
    
    public func findGeneric(name: String): Option<ActorProxy> {
        match (actorMap.get(name)) {
            case Some(_) => Some(ActorProxy(name, this)) 
            case None => None
        }
    }   
    
    public func remoteCall<T>(name: String, info: ReceiverInfo, args: Array<DataModel>, fut: DistributedActorFuture<T>): Unit {
        let id = futId.fetchAdd(1)
        futMap.add(id, (fut, TypeInfo.of<DistributedActorFuture<T>>()))
        this.handleRemoteCall(name, info, args, id)
    }

    public func getAll(): Array<(String, Metadata)> {
        throw Exception()
    }   

    @Receiver 
    func handleResult(id: UInt64, res: Any): Unit {
        match (futMap.remove(id)) {
            case Some((fut, ti)) =>
                let fulfillTi = ti.getInstanceFunction("fulfill", [anyTi])
                fulfillTi.apply(fut, [res])
            case None => ()
        }
    }

    @Receiver
    func handleRemoteCall(name: String, info: ReceiverInfo, args: Array<DataModel>, id: UInt64): Unit {
        let (a, ti) = match (actorMap.get(name)) {
            case Some(p) => p
            case None => throw ActorNotFoundException(name)
        }

        let dispatchFunc = ti.getStaticFunction("dispatch", [ti, rInfoTi, argsTi])
        let fut = dispatchFunc.apply(ti, [a, info, args])
        let retTi = TypeInfo.of(a).getInstanceFunctions(info.methodName)[0].returnType // there can only be one

        spawn {
            let getTi = retTi.getInstanceFunction("get", [])
            let res = getTi.apply(fut)
            this.handleResult(id, res)
        }
    }
}