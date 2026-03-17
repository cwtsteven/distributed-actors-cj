package actors.tcp_actor_system

import std.collection.*
import std.collection.concurrent.*
import std.net.*
import stdx.log.*

import actors.*
import actors.macros.*
import actors.distributed.*
import stdx.encoding.json.stream.*
import stdx.serialization.serialization.*

/*
* A class representing a TCP actor host
*/
public class TCPActorHost <: ActorHost {
    private let hostInfo: TCPActorHostInfo
    private let localMap = ConcurrentHashMap<String, Distributable>()
    private let connMap = ConcurrentHashMap<Int64, TCPConnection>()
    private let serverSocket: TcpServerSocket
    private var threadHandle: ?Future<Unit> = None
    private let logger: TCPActorLoggerWrapper

    /*
    * Initializes the server
    * @param bindAt - the port to bind to
    */
    public init(addr!: String, bindAt!: UInt16) {
        hostInfo = TCPActorHostInfo(addr, bindAt)
        serverSocket = TcpServerSocket(bindAt: bindAt)
        logger = TCPActorLoggerWrapper("[TCPActorHost (${serverSocket.localAddress})]")
    }

    /*
     * Exports an actor
     * @param name - the name of the actor
     * @param a - the actor to export
     * @return Some(ActorProxy) if the actor was exported successfully, None if the name is already taken
     */
    public func export(name: String, a: Distributable): Option<ActorProxy> {
        if (let Some(_) <- localMap.addIfAbsent(name, a)) {
            None
        } else {
            Some(ActorProxy(name, hostInfo))
        }
    }

    /*
    * Exports an actor and returns whether the export succeeded.
    * This is the preferred public API when the raw ActorProxy is not needed.
    * @param name - the name of the actor to export
    * @param a - the actor to export
    * @return true if the actor was exported successfully, false otherwise
    */
    public func publish(name: String, a: Distributable): Bool {
        match (export(name, a)) {
            case Some(_) => true
            case None => false
        }
    }

    /*
    * Unexports an actor
    * @param name - the name of the actor
    * @return true if the actor was unexported successfully, false otherwise
    */
    public func unexport(name: String): Bool {
        match (localMap.remove(name)) {
            case Some(_) => true
            case None => false
        }
    }

    /*
    * Starts the server
    * @return A future handle to the thread
    * @throws SocketException - if the server socket fails to bind
    */
    public func serve(): Future<Unit> {
        logger.debug("server starts to bind.")
        serverSocket.bind()
        logger.debug("server bound.")
        logger.debug("server starts to accept connections.")

        threadHandle = Some(spawn {
            while (true) {
                if (Thread.currentThread.hasPendingCancellation) {
                    logger.debug("server thread is cancelled.")
                    return
                }

                let clientSocket = try {
                    logger.debug("listening to connection...")
                    let clientSocket = serverSocket.accept()
                    logger.debug("client connected.")
                    clientSocket
                } catch (e: SocketException) {
                    logger.error("error accepting client: ${e.message}")
                    continue
                }

                let conn = TCPConnection(clientSocket)
                if (let Some(_) <- connMap.addIfAbsent(conn.hashCode(), conn)) {
                    logger.debug("client already exist.")
                    conn.close()
                } else {
                    conn.setClosingCallBack({ => connMap.remove(conn.hashCode()) })
                    conn.startListening(handleEnvelope)
                }
            }
        })
        threadHandle.getOrThrow()
    }

    /*
    * Handles an envelope sent from a connection
    * @param e - the envelope
    * @param conn - the connection
    * @throws TCPActorSystemSerializationException - if the envelope serialization fails
    * @throws TCPActorSystemRemoteException - if the remote connection fails
    * @throws TCPActorSystemInternalException - for any internal errors
    */
    func handleEnvelope(e: Envelope, conn: TCPConnection): Unit {
        let (id, msg) = (e.id, e.msg)
        logger.debug("handling a ${msg}.")
        match (msg) {
            case Find(name) =>
                match (localMap.get(name)) {
                    case Some(a) => conn.send(Envelope(id, FindResponse([ActorInfo(name: name, metadata: a.getMetadata())])))
                    case None => conn.send(Envelope(id, FindResponse([])))
                }
            case FindAll =>
                let list = ArrayList<ActorInfo>()
                let it = localMap.iterator()
                while (true) {
                    match (it.next()) {
                        case Some((name, a)) => list.add(ActorInfo(name: name, metadata: a.getMetadata()))
                        case None => break
                    }
                }
                conn.send(Envelope(id, FindResponse(list.toArray())))
            case ContainsActor(name) =>
                conn.send(Envelope(id, ContainsActorResponse(localMap.contains(name))))
            case Ask(name, methodName, args, config, futId) =>
                handleRemoteCall(conn, id, name, methodName, args, config, futId)
            case Tell(name, methodName, args, config) =>
                handleRemoteTell(conn, id, name, methodName, args, config)
            case Heartbeat =>
                conn.send(Envelope(id, Ok))
            case _ =>
                logger.error("unexpected message: ${msg}.")
                throw TCPActorSystemInternalException("Unexpected message: ${msg}.")
        }

        logger.debug("handled a ${msg}.")
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
    * @throws TCPActorSystemSerializationException - if the envelope serialization fails
    * @throws TCPActorSystemRemoteException - if the remote connection fails
    */
    func handleRemoteCall(conn: TCPConnection, id: UInt64, name: String, methodName: String, args: Array<DataModel>, config: ReceiverConfig, futId: UInt64): Unit {
        let a = if (let Some(a) <- localMap.get(name)) {
            a
        } else {
            conn.send(Envelope(id, ErrorCode(ActorNotFound)))
            return
        }

        logger.debug("try call ${name}.${methodName} with arg size = ${args.size}.")

        let fut = try {
            a.dispatchAsk(methodName, args, config)
        } catch (e: ReceiverNotFoundException) {
            logger.error("receiver not found for ${name}.${methodName}: ${e.toString()}")
            conn.send(Envelope(id, ErrorCode(ReceiverNotFound)))
            return
        } catch (e: IllegalArgumentException) {
            logger.error("illegal argument exception for ${name}.${methodName}: ${e.toString()}")
            conn.send(Envelope(id, ErrorCode(IllegalArgument)))
            return
        }

        logger.debug("called ${name}.${methodName} with arg size = ${args.size}.")
        conn.send(Envelope(id, Ok))

        logger.debug("spawn a thread to handle the result.")

        spawn {
            logger.debug("wait on local future.")
            let res = fut.get()
            logger.debug("local future done.")
            conn.send(Envelope(id, Fulfill(futId, res)))
        }
    }

    /*
    * Handles a remote tell
    * @param conn - the connection
    * @param id - the id of the envelope
    * @param name - the name of the actor
    * @param methodName - the name of the method
    * @param args - the arguments of the method
    * @param config - the config of the method
    * @throws TCPActorSystemSerializationException - if the envelope serialization fails
    * @throws TCPActorSystemRemoteException - if the remote connection fails
    */
    func handleRemoteTell(conn: TCPConnection, id: UInt64, name: String, methodName: String, args: Array<DataModel>, config: ReceiverConfig): Unit {
        let a = if (let Some(a) <- localMap.get(name)) {
            a
        } else {
            conn.send(Envelope(id, ErrorCode(ActorNotFound)))
            return
        }

        logger.debug("try call ${name}.${methodName} with arg size = ${args.size}.")
        try {
            a.dispatchTell(methodName, args, config)
        } catch (e: ReceiverNotFoundException) {
            logger.error("receiver not found for ${name}.${methodName}: ${e.toString()}")
            conn.send(Envelope(id, ErrorCode(ReceiverNotFound)))
            return
        } catch (e: IllegalArgumentException) {
            logger.error("illegal argument exception for ${name}.${methodName}: ${e.toString()}")
            conn.send(Envelope(id, ErrorCode(IllegalArgument)))
            return
        }

        logger.debug("called ${name}.${methodName} with arg size = ${args.size}.")
        conn.send(Envelope(id, Ok))
    }

    /*
    * Closes the TCP actor host
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

    /*
    * Gets the host info of the host
    * @return the host info of the host
    */
    public func getHostInfo(): HostInfo {
        hostInfo
    }
}
