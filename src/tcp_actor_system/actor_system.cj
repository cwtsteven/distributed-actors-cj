package actors.tcp_actor_system

import std.collection.concurrent.*
import std.net.*
import std.sync.*

import encoding.json.*
import serialization.serialization.*

import actors.*
import actors.macros.*

//
//
//public class ImpresarioActorSystem <: ActorSystem {
//    let port: UInt16
//    let server: TCPActorHost
//    let client: ClientManager
//
//    public init(bindAt!: UInt16) {
//        port = bindAt
//        server = TCPActorHost(bindAt: port)
//        client = ClientManager()
//    }
//
//    public func register(name: String, a: Distributable): Bool {
//        if (server.export(name, a)) {
//            return true
//        }
//        false
//    }
//
//    public func deregister(name: String): Bool {
//        if (server.remove(name)) {
//            registry.deregister(name)
//            return true
//        }
//        false
//    }
//
//    public func find(name: String): Option<ActorInfo> {
//
//    }
//
//    public func findAll(): Array<ActorInfo> {
//
//    }
//
//    public func remoteCall(name: String, receiverName: String, args: Array<DataModel>, config: ReceiverConfig, fut: Fullfillable): Unit {
//        client.remoteCall(name, receiverName, args, config, fut)
//    }
//
//    public func remoteTell(name: String, receiverName: String, args: Array<DataModel>, config: ReceiverConfig): Unit {
//        client.remoteTell(name, receiverName, args, config)
//    }
//}