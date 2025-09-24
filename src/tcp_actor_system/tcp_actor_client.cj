package actors.tcp_actor_system

import std.collection.concurrent.*
import std.net.*
import std.sync.*

import serialization.serialization.*

import actors.*
import actors.macros.*
import std.socket.SocketAddress

type FutMap = ConcurrentHashMap<UInt64, Fullfillable>

public class TCPActorClient <: ActorClient {

    private let conn: TCPConnection

    private let proxyMap = ConcurrentHashMap<String, Unit>()
    private let nextFutId = AtomicUInt64(0)
    private let futMap = FutMap()

    public init(addr: String, port: UInt16) {
        this.conn = TCPConnection(addr, port)
        this.conn.startListening(handleEnvelope)
    }

    public func find(name: String): Option<ActorInfo> {
        let resp = conn.sendSync(Payload.Find(name))
        match (resp) {
            case FindResponse(arr) =>
                if (arr.size == 0) { return None }
                return arr[0]
            case _ =>
                TCPActorSystem.logger.debug("[TCPActorClient]: Unexpected response.")
                throw ActorSystemException("Unexpected response.")
        }
    }

    public func findAll(): Array<ActorInfo> {
        let resp = conn.sendSync(Payload.FindAll)
        match (resp) {
            case FindResponse(arr) =>
                return arr
            case _ =>
                TCPActorSystem.logger.debug("[TCPActorClient]: Unexpected response.")
                throw ActorSystemException("Unexpected response.")
        }
    }

    public func remoteCall(name: String, receiverName: String, args: Array<DataModel>, config: ReceiverConfig, fut: Fullfillable): Unit {
        TCPActorSystem.logger.debug("[TCPActorClient]: remoteCall(${name}) begins.")

        let futId = nextFutId.fetchAdd(1)
        futMap.put(futId, fut)

        let resp = conn.sendSync(Payload.Ask(name, receiverName, args, config, futId))

        if (resp != Ok) {
            TCPActorSystem.logger.debug("[TCPActorClient]: Unexpected response.")
            throw ActorSystemException("Unexpected response.")
        }
        TCPActorSystem.logger.debug("[TCPActorClient]: remoteCall(${name}) ends.")
    }

    public func remoteTell(name: String, receiverName: String, args: Array<DataModel>, config: ReceiverConfig): Unit {
        TCPActorSystem.logger.debug("[TCPActorClient]: remoteTell(${name}) begins.")

        let resp = conn.sendSync(Payload.Tell(name, receiverName, args, config))

        if (resp != Ok) {
            throw ActorSystemException("Unexpected response.")
        }
        TCPActorSystem.logger.debug("[TCPActorClient]: remoteTell(${name}) ends.")
    }

    func handleEnvelope(e: Envelope, conn: TCPConnection): Unit {
        let (id, msg) = (e.id, e.msg)
        match (msg) {
            case Fulfill(futId, res) =>
                if (let Some(fut) <- futMap.get(futId)) {
                    fut.fulfill(res)
                    return
                }
                throw Exception("No future")

            case Ok | NotOk => conn.messageBoard.put(id, e)

            case _ => throw Exception()
        }
    }

    public func close(): Unit {
        conn.close()
    }
}