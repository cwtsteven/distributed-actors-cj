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

/*
* A class representing a TCP actor server
*/
public class TCPActorHost <: ActorHost {
    private let localMap = ConcurrentHashMap<String, Distributable>()
    private let connMap = ConcurrentHashMap<Int64, TCPConnection>()
    private let serverSocket: TcpServerSocket
    private let logTag: String
    private var threadHandle: ?Future<Unit> = None

    /*
    * Initializes the server
    * @param bindAt - the port to bind to
    */
    public init(bindAt!: UInt16) {
        serverSocket = TcpServerSocket(bindAt: bindAt)
        logTag = "[TCPActorHost (${serverSocket.localAddress})]"
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

    /*
    * Creates a new thread to serve requests
    * @return A future handle to the thread
    * @throws SocketException - if the server socket fails to bind
    */
    public func serve(): Future<Unit> {
        threadHandle = Some(spawn {
            TCPActorSystem.logger.debug("${logTag}: server starts.")
            serverSocket.bind()
            TCPActorSystem.logger.debug("${logTag}: server bound.")
            while (true) {
                if (Thread.currentThread.hasPendingCancellation) {
                    return
                }

                try {
                    TCPActorSystem.logger.debug("${logTag}: listening to connection.")
                    let clientSocket = serverSocket.accept()
                    TCPActorSystem.logger.debug("${logTag}: client connected.")
                    let conn = TCPConnection(clientSocket)
                    if (let Some(_) <- connMap.putIfAbsent(conn.hashCode(), conn)) {
                        TCPActorSystem.logger.debug("${logTag}: client already exist.")
                        conn.close()
                    } else {
                        TCPActorSystem.logger.debug("${logTag}: client start listening.")
                        conn.startListening(handleEnvelope)
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                    continue
                }
            }
        })
        threadHandle.getOrThrow()
    }

    /*
    * Handles an envelope sent from a connection
    * @param e - the envelope
    * @param conn - the connection
    * @throws ActorSystemException - if the message is unexpected
    */
    func handleEnvelope(e: Envelope, conn: TCPConnection): Unit {
        let (id, msg) = (e.id, e.msg)
        TCPActorSystem.logger.debug("${logTag}: handling a ${msg}.")
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
            case _ =>
                TCPActorSystem.logger.error("${logTag}: unexpected message: ${msg}.")
                throw ActorSystemException("Unexpected message: ${msg}.")
        }

        TCPActorSystem.logger.debug("${logTag}: handled a ${msg}.")
    }

    /*
    * Handles a remote call
    * @param conn - the connection
    * @param id - the id of the envelope
    * @param name - the name of the actor
    * @param methodName - the name of the method
    * @param args - the arguments of the method
    * @param config - the config of the method
    * @param futId - the id of the future
    */
    func handleRemoteCall(conn: TCPConnection, id: UInt64, name: String, methodName: String, args: Array<DataModel>, config: ReceiverConfig, futId: UInt64): Unit {
        let a = if (let Some(a) <- localMap.get(name)) {
            a
        } else {
            conn.send(Envelope(id, ErrorCode(ActorNotFound)))
            return
        }

        TCPActorSystem.logger.debug("${logTag}: try call ${name}.${methodName} with arg size = ${args.size}.")

        try {
            let fut = a.dispatchAsk(methodName, args, config)
            TCPActorSystem.logger.debug("${logTag}: called ${name}.${methodName} with arg size = ${args.size}.")
            conn.send(Envelope(id, Ok))

            TCPActorSystem.logger.debug("${logTag}: spawn a thread to handle the result.")

            spawn {
                TCPActorSystem.logger.debug("${logTag}: wait on local future.")
                let res = fut.wait()
                TCPActorSystem.logger.debug("${logTag}: local future done.")
                conn.send(Envelope(id, Fulfill(futId, res)))
            }
        } catch (_: ReceiverNotFoundException) {
            TCPActorSystem.logger.error("${logTag}: receiver not found for ${name}.${methodName}.")
            conn.send(Envelope(id, ErrorCode(ReceiverNotFound)))
        } catch (_: Exception) {
            TCPActorSystem.logger.error("${logTag}: unknown error for ${name}.${methodName}.")
            conn.send(Envelope(id, ErrorCode(UnknownError)))
        } catch (_: Error) {
            TCPActorSystem.logger.error("${logTag}: unknown error for ${name}.${methodName}.")
            conn.send(Envelope(id, ErrorCode(UnknownError)))
        }
    }

    func handleRemoteTell(conn: TCPConnection, id: UInt64, name: String, methodName: String, args: Array<DataModel>, config: ReceiverConfig): Unit {
        if (localMap.get(name).isNone()) {
            conn.send(Envelope(id, ErrorCode(ActorNotFound)))
            return
        }

        try {
            TCPActorSystem.logger.debug("${logTag}: try call ${name}.${methodName} with arg size = ${args.size}.")
            let a = localMap[name]
            a.dispatchTell(methodName, args, config)
            TCPActorSystem.logger.debug("${logTag}: called ${name}.${methodName} with arg size = ${args.size}.")
            conn.send(Envelope(id, Ok))
        } catch (_: ReceiverNotFoundException) {
            TCPActorSystem.logger.error("${logTag}: receiver not found for ${name}.${methodName}.")
            conn.send(Envelope(id, ErrorCode(ReceiverNotFound)))
        } catch (_: Exception) {
            TCPActorSystem.logger.error("${logTag}: unknown error for ${name}.${methodName}.")
            conn.send(Envelope(id, ErrorCode(UnknownError)))
        } catch (_: Error) {
            TCPActorSystem.logger.error("${logTag}: unknown error for ${name}.${methodName}.")
            conn.send(Envelope(id, ErrorCode(UnknownError)))
        }
    }

    /*
    * Closes the server
    */
    public func close(): Unit {
        for ((_, conn) in connMap) {
            conn.close()
        }
        if (!serverSocket.isClosed()) {
            serverSocket.close()
        }
        match (threadHandle) {
            case Some(t) => t.cancel()
            case None => ()
        }
    }
}