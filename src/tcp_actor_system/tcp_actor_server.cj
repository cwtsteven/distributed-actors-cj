package actors.tcp_actor_system

import std.collection.*
import std.collection.concurrent.*
import std.net.*
import std.socket.*
import std.log.*

import actors.*
import actors.macros.*
import encoding.json.stream.*
import serialization.serialization.DataModel

public class TCPActorHost <: ActorHost {
    private let localMap = ConcurrentHashMap<String, Distributable>()
    private let connMap = ConcurrentHashMap<Int64, TCPConnection>()
    private let serverSocket: TcpServerSocket

    public init(bindAt!: UInt16) {
        serverSocket = TcpServerSocket(bindAt: bindAt)
    }

    public func register(name: String, a: Distributable): Bool  {
        if (let Some(_) <- localMap.putIfAbsent(name, a)) {
            false
        } else {
            true
        }
    }

    public func deregister(name: String): Bool {
        match (localMap.remove(name)) {
            case Some(_) => true
            case None => false
        }
    }

    public func serve(): Unit {
        TCPActorSystem.logger.debug("[TCPActorHost]: server starts.")
        serverSocket.bind()
        TCPActorSystem.logger.debug("[TCPActorHost]: server bound.")
        while (true) {
            try {
                TCPActorSystem.logger.debug("[TCPActorHost]: listening to connection.")
                let clientSocket = serverSocket.accept()
                TCPActorSystem.logger.debug("[TCPActorHost]: client connected.")
                let conn = TCPConnection(clientSocket)
                if (let Some(_) <- connMap.putIfAbsent(conn.hashCode(), conn)) {
                    TCPActorSystem.logger.debug("[TCPActorHost]: client already exist.")
                    conn.close()
                } else {
                    TCPActorSystem.logger.debug("[TCPActorHost]: client start listening.")
                    conn.startListening(handleEnvelope)
                }
            } catch (e: Exception) {
                e.printStackTrace()
                continue
            }
        }
    }

    func handleEnvelope(e: Envelope, conn: TCPConnection): Unit {
        let (id, msg) = (e.id, e.msg)
        TCPActorSystem.logger.debug("[TCPActorHost]: handles a ${msg}.")
        match (msg) {
            case Find(name) =>
                match (localMap.get(name)) {
                    case Some(a) => conn.send(Envelope(id, FindResponse([ActorInfo(name, a.getMetadata())])))
                    case None => conn.send(Envelope(id, FindResponse([])))
                }
            case FindAll =>
                let list = ArrayList<ActorInfo>()
                let it = localMap.iterator()
                while (true) {
                    match (it.next()) {
                        case Some((name, a)) => list.append(ActorInfo(name, a.getMetadata()))
                        case None => break
                    }
                }
                conn.send(Envelope(id, FindResponse(list.toArray())))
            case Ask(name, methodName, args, config, futId) =>
                handleRemoteCall(conn, id, name, methodName, args, config, futId)
            case Tell(name, methodName, args, config) =>
                handleRemoteTell(conn, id, name, methodName, args, config)
            case _ => throw Exception()
        }
    }

    func handleRemoteCall(conn: TCPConnection, id: UInt64, name: String, methodName: String, args: Array<DataModel>, config: ReceiverConfig, futId: UInt64): Unit {

        if (localMap.get(name).isNone()) {
            conn.send(Envelope(id, NotOk))
            return
        }

        TCPActorSystem.logger.debug("[TCPActorHost]: try call ${name}.${methodName} with arg size = ${args.size}.")
        let a = localMap[name]
        let fut = a.dispatchAsk(methodName, args, config)
        TCPActorSystem.logger.debug("[TCPActorHost]: called ${name}.${methodName} with arg size = ${args.size}.")
        conn.send(Envelope(id, Ok))

        TCPActorSystem.logger.debug("[TCPActorHost]: spawn a thread to handle the result.")

        spawn {
            TCPActorSystem.logger.debug("[TCPActorHost]: wait on local future.")
            let res = fut.wait()
            TCPActorSystem.logger.debug("[TCPActorHost]: local future done.")
            conn.send(Envelope(id, Fulfill(futId, res)))
        }
    }

    func handleRemoteTell(conn: TCPConnection, id: UInt64, name: String, methodName: String, args: Array<DataModel>, config: ReceiverConfig): Unit {
        if (localMap.get(name).isNone()) {
            conn.send(Envelope(id, NotOk))
            return
        }
        TCPActorSystem.logger.debug("[TCPActorHost]: try call ${name}.${methodName} with arg size = ${args.size}.")
        let a = localMap[name]
        a.dispatchTell(methodName, args, config)
        TCPActorSystem.logger.debug("[TCPActorHost]: called ${name}.${methodName} with arg size = ${args.size}.")
        conn.send(Envelope(id, Ok))
    }


    public func close(): Unit {
        for ((_, c) in connMap) {
            c.close()
        }
        serverSocket.close()
    }
}