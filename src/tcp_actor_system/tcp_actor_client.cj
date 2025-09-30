package actors.tcp_actor_system

import std.collection.concurrent.*
import std.net.*
import std.sync.*

import serialization.serialization.*

import actors.*
import actors.macros.*
import actors.distributed.*
import std.socket.SocketAddress

type FutMap = ConcurrentHashMap<UInt64, DistributedFuture>

/*
* A class representing a TCP actor client
*/
public class TCPActorClient <: ActorClient {

    public prop id: String { get() { __id } }
    private let __id: String

    private let conn: TCPConnection

    private let nextFutId = AtomicUInt64(0)
    private let futMap = FutMap()

    /*
    * Initializes the TCP actor client
    * @param addr - the address of the TCP actor host
    * @param port - the port of the TCP actor host
    */
    public init(id: String, addr: String, port: UInt16) {
        this.__id = id
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
                TCPActorSystem.logger.error("[TCPActorClient (${conn.localAddress} -- ${conn.remoteAddress})]: Unexpected response.")
                throw ActorSystemException("Unexpected response.")
        }
    }

    public func findAll(): Array<ActorInfo> {
        let resp = conn.sendSync(Payload.FindAll)
        match (resp) {
            case FindResponse(arr) =>
                return arr
            case _ =>
                TCPActorSystem.logger.error("[TCPActorClient (${conn.localAddress} -- ${conn.remoteAddress})]: Unexpected response.")
                throw ActorSystemException("Unexpected response.")
        }
    }

    public func remoteCall(invokeInfo: InvokeInfo): Unit {
        match (invokeInfo.fut) {
            case Some(fut) => remoteAsk(invokeInfo.name, invokeInfo.receiverName, invokeInfo.args, invokeInfo.config, fut)
            case None => remoteTell(invokeInfo.name, invokeInfo.receiverName, invokeInfo.args, invokeInfo.config)
        }
    }

    func remoteAsk(name: String, receiverName: String, args: Array<DataModel>, config: ReceiverConfig, fut: DistributedFuture): Unit {
        TCPActorSystem.logger.debug("[TCPActorClient (${conn.localAddress} -- ${conn.remoteAddress})]: remoteCall(${name}) begins.")

        let futId = nextFutId.fetchAdd(1)
        futMap.put(futId, fut)

        let resp = conn.sendSync(Payload.Ask(name, receiverName, args, config, futId))

        match (resp) {
            case Ok => ()
            case ErrorCode(errorCode) => match (errorCode) {
                case ActorNotFound =>
                    TCPActorSystem.logger.error("[TCPActorClient (${conn.localAddress} -- ${conn.remoteAddress})]: Actor not found.")
                    throw ActorNotFoundException(name)
                case ReceiverNotFound =>
                    TCPActorSystem.logger.error("[TCPActorClient (${conn.localAddress} -- ${conn.remoteAddress})]: Receiver not found.")
                    throw ReceiverNotFoundException(name, receiverName)
                case UnknownError =>
                    TCPActorSystem.logger.error("[TCPActorClient (${conn.localAddress} -- ${conn.remoteAddress})]: Unknown error.")
                    throw ActorSystemException("Unknown error.")
            }
            case _ =>
                TCPActorSystem.logger.error("[TCPActorClient (${conn.localAddress} -- ${conn.remoteAddress})]: Unexpected response.")
                throw ActorSystemException("Unexpected response.")
        }

        TCPActorSystem.logger.debug("[TCPActorClient (${conn.localAddress} -- ${conn.remoteAddress})]: remoteCall(${name}) ends.")
    }

    func remoteTell(name: String, receiverName: String, args: Array<DataModel>, config: ReceiverConfig): Unit {
        TCPActorSystem.logger.debug("[TCPActorClient (${conn.localAddress} -- ${conn.remoteAddress})]: remoteTell(${name}) begins.")

        let resp = conn.sendSync(Payload.Tell(name, receiverName, args, config))

        match (resp) {
            case Ok => ()
            case ErrorCode(errorCode) => match (errorCode) {
                case ActorNotFound =>
                    TCPActorSystem.logger.error("[TCPActorClient (${conn.localAddress} -- ${conn.remoteAddress})]: Actor not found.")
                    throw ActorNotFoundException(name)
                case ReceiverNotFound =>
                    TCPActorSystem.logger.error("[TCPActorClient (${conn.localAddress} -- ${conn.remoteAddress})]: Receiver not found.")
                    throw ReceiverNotFoundException(name, receiverName)
                case UnknownError =>
                    TCPActorSystem.logger.error("[TCPActorClient (${conn.localAddress} -- ${conn.remoteAddress})]: Unknown error.")
                    throw ActorSystemException("Unknown error.")
            }
            case _ =>
                TCPActorSystem.logger.error("[TCPActorClient (${conn.localAddress} -- ${conn.remoteAddress})]: Unexpected response.")
                throw ActorSystemException("Unexpected response.")
        }

        TCPActorSystem.logger.debug("[TCPActorClient (${conn.localAddress} -- ${conn.remoteAddress})]: remoteTell(${name}) ends.")
    }

    func handleEnvelope(e: Envelope, conn: TCPConnection): Unit {
        let (id, msg) = (e.id, e.msg)
        match (msg) {
            case Fulfill(futId, res) =>
                if (let Some(fut) <- futMap.get(futId)) {
                    fut.fulfill(res)
                    return
                }
                TCPActorSystem.logger.error("[TCPActorClient (${conn.localAddress} -- ${conn.remoteAddress})]: No future found for ${futId}.")
                throw ActorSystemException("No future found for ${futId}.")

            case Ok | ErrorCode(_) | FindResponse(_) => conn.messageBoard.put(id, e)

            case _ =>
                TCPActorSystem.logger.error("[TCPActorClient (${conn.localAddress} -- ${conn.remoteAddress})]: Unexpected message ${msg}.")
                throw ActorSystemException("Unexpected message ${msg}.")
        }
    }

    public func close(): Unit {
        conn.close()
    }
}