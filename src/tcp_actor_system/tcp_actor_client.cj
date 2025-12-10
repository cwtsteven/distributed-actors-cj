package actors.tcp_actor_system

import std.collection.concurrent.*
import std.net.*
import std.sync.*
import std.time.*

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

    public static func create(addr: String, port: UInt16): TCPActorClient {
        (ClientManager.instance.getOrCreateClient(TCPActorHostInfo(addr, port)) as TCPActorClient).getOrThrow()
    }

    /*
    * The information about the TCP actor client
    */
    public let hostInfo: TCPActorHostInfo

    private let conn: TCPConnection
    private let nextFutId = AtomicUInt64(0)
    private let futMap = FutMap()
    private let timer: Timer
    private var isClosed: AtomicBool = AtomicBool(false)
    private let logger: TCPActorLoggerWrapper

    /*
    * Creates a new TCP actor client and connects to the specified TCP actor host
    * @param hostInfo - the host info of the TCP actor host
    * @throws IllegalArgumentException - if the address or port is invalid
    * @throws SocketException - if the socket connection fails
    * @throws SocketTimeoutException - if the socket connection times out
    */
    init(hostInfo: TCPActorHostInfo) {
        this.hostInfo = hostInfo
        this.conn = TCPConnection(hostInfo.addr, hostInfo.port)

        this.logger = TCPActorLoggerWrapper("[TCPActorClient (${conn.localAddress} -- ${conn.remoteAddress})]")

        this.timer = Timer(TCPActorSystem.heartbeatInterval)
        this.timer.setCallback(sendHeartbeat)
        this.timer.start()
        this.conn.startListening(handleEnvelope)
    }

    /*
    * Sends a heartbeat message to the TCP actor host.
    * If the connection is lost, the client will be closed and all futures will be fulfilled with a TCPActorSystemRemoteException.
    */
    func sendHeartbeat(): Unit {
        if (isClosed.load()) {
            return
        }

        try {
            // TODO: check OK
            conn.sendSync(Payload.Heartbeat, priority: MAX_PRIORITY)
            return
        } catch (e: TCPActorSystemRemoteException) {
            logger.error("error: ${e.toStringWithStackTrace()}")
            logger.error("connection to ${conn.remoteAddress} has been lost.")
        }

        this.close()
        this.timer.stop()

        // TODO: is there a better way to do this?
        sleep(Duration.second)

        let iter = futMap.iterator()
        while (let Some((futId, fut)) <- iter.next()) {
            fut.exn(TCPActorSystemRemoteException("[Client to ${hostInfo}] Connection to ${conn.remoteAddress} has been lost."))
        }
    }

    /*
    * Finds an actor by name
    * @param name - the name of the actor to find
    * @return the actor info if found, None otherwise
    * @throws TCPActorSystemRemoteException - if the connection is lost
    * @throws TCPActorSystemRequestTimeoutException - if the TCP request has timed out
    * @throws TCPActorSystemSerializationException - if the envelope serialization fails
    * @throws TCPActorSystemDeserializationException - if the response envelope deserialization fails
    * @throws TCPActorSystemInternalException - for any internal errors
    */
    public func find(name: String): Option<ActorInfo> {
        if (isClosed.load()) {
            throw TCPActorSystemRemoteException("[Client to ${hostInfo}] Connection to ${conn.remoteAddress} has been lost.")
        }
        let resp = conn.sendSync(Payload.Find(name))
        match (resp) {
            case FindResponse(arr) =>
                if (arr.size == 0) { return None }
                return arr[0]
            case ErrorCode(errorCode) => match (errorCode) {
                case DeserializationFailed =>
                    logger.error("Deserialization failed.")
                    throw TCPActorSystemDeserializationException("Deserialization failed.")
                case _ =>
                    logger.error("Unexpected response.")
                    throw TCPActorSystemInternalException("Unexpected response.")
            }
            case _ =>
                logger.error("Unexpected response.")
                throw TCPActorSystemInternalException("Unexpected response.")
        }
    }

    /*
    * Finds all actors
    * @return the actor infos if found, None otherwise
    * @throws TCPActorSystemRemoteException - if the connection is lost
    * @throws TCPActorSystemRequestTimeoutException - if the request has timed out
    * @throws TCPActorSystemSerializationException - if the envelope serialization fails
    * @throws TCPActorSystemDeserializationException - if the response envelope deserialization fails
    * @throws TCPActorSystemInternalException - for any internal errors
    */
    public func findAll(): Array<ActorInfo> {
        if (isClosed.load()) {
            throw TCPActorSystemRemoteException("[Client to ${hostInfo}] Connection to ${conn.remoteAddress} has been lost.")
        }
        let resp = conn.sendSync(Payload.FindAll)
        match (resp) {
            case FindResponse(arr) =>
                return arr
            case ErrorCode(errorCode) => match (errorCode) {
                case DeserializationFailed =>
                    logger.error("Deserialization failed.")
                    throw TCPActorSystemDeserializationException("Deserialization failed.")
                case _ =>
                    logger.error("Unexpected response.")
                    throw TCPActorSystemInternalException("Unexpected response.")
            }
            case _ =>
                logger.error("Unexpected response.")
                throw TCPActorSystemInternalException("Unexpected response.")
        }
    }

    /*
    * Checks if an actor is exported from the respective server
    * @param name - the name of the actor
    * @return true if the actor is exported, false otherwise
    * @throws TCPActorSystemRemoteException - if the connection is lost
    * @throws TCPActorSystemRequestTimeoutException - if the request has timed out
    * @throws TCPActorSystemSerializationException - if the envelope serialization fails
    * @throws TCPActorSystemDeserializationException - if the response envelope deserialization fails
    * @throws TCPActorSystemInternalException - for any internal errors
    */
    public func containsActor(name: String): Bool {
        if (isClosed.load()) {
            throw TCPActorSystemRemoteException("[Client to ${hostInfo}] Connection to ${conn.remoteAddress} has been lost.")
        }
        let resp = conn.sendSync(Payload.ContainsActor(name))
        match (resp) {
            case ContainsActorResponse(b) => b
            case _ =>
                logger.error("Unexpected response.")
                throw TCPActorSystemInternalException("Unexpected response.")
        }
    }

    /*
    * Gets an actor
    * @param name - the name of the actor
    * @return the actor proxy if found, None otherwise
    * @throws TCPActorSystemRemoteException - if the connection is lost
    * @throws TCPActorSystemRequestTimeoutException - if the request has timed out
    * @throws TCPActorSystemSerializationException - if the envelope serialization fails
    * @throws TCPActorSystemDeserializationException - if the response envelope deserialization fails
    * @throws TCPActorSystemInternalException - for any internal errors
    */
    public func getActor(name: String): Option<ActorProxy> {
        if (isClosed.load()) {
            throw TCPActorSystemRemoteException("[Client to ${hostInfo}] Connection to ${conn.remoteAddress} has been lost.")
        }
        match (this.find(name)) {
            case Some(_) => Some(ActorProxy(name, hostInfo))
            case None => None
        }
    }

    /*
    * Makes a remote call to an actor's receiver
    * @param invokeInfo - the invoke info
    * @throws ActorNotFoundException - if the actor is not found
    * @throws ReceiverNotFoundException - if the receiver is not found
    * @throws IllegalArgumentException - if the arguments are invalid
    * @throws TCPActorSystemRemoteException - if the connection is lost
    * @throws TCPActorSystemRequestTimeoutException - if the request has timed out
    * @throws TCPActorSystemSerializationException - if the envelope serialization fails
    * @throws TCPActorSystemDeserializationException - if the response envelope deserialization fails
    * @throws TCPActorSystemInternalException - for any internal errors
    */
    public func remoteCall(invokeInfo: InvokeInfo): Unit {
        if (isClosed.load()) {
            throw TCPActorSystemRemoteException("[Client to ${hostInfo}] Connection to ${conn.remoteAddress} has been lost.")
        }
        match (invokeInfo.fut) {
            case Some(fut) => remoteAsk(invokeInfo.name, invokeInfo.receiverName, invokeInfo.args, invokeInfo.config, fut)
            case None => remoteTell(invokeInfo.name, invokeInfo.receiverName, invokeInfo.args, invokeInfo.config)
        }
    }

    /*
    * Makes a remote ask to an actor's receiver
    * @param name - the name of the actor
    * @param receiverName - the name of the receiver
    * @param args - the arguments of the method
    * @param config - the config of the method
    * @param fut - the future to fulfill
    * @throws ActorNotFoundException - if the actor is not found
    * @throws ReceiverNotFoundException - if the receiver is not found
    * @throws IllegalArgumentException - if the arguments are invalid
    * @throws TCPActorSystemRemoteException - if the connection is lost
    * @throws TCPActorSystemRequestTimeoutException - if the request has timed out
    * @throws TCPActorSystemSerializationException - if the envelope serialization fails
    * @throws TCPActorSystemDeserializationException - if the response envelope deserialization fails
    * @throws TCPActorSystemInternalException - for any internal errors
    */
    func remoteAsk(name: String, receiverName: String, args: Array<DataModel>, config: ReceiverConfig, fut: DistributedFuture): Unit {
        logger.debug("remoteCall(${name}) begins.")

        let futId = nextFutId.fetchAdd(1)
        futMap.put(futId, fut)

        let resp = conn.sendSync(Payload.Ask(name, receiverName, args, config, futId))
        handleResponse(resp, name, receiverName)

        logger.debug("remoteCall(${name}) ends.")
    }

    /*
    * Makes a remote tell to an actor's receiver
    * @param name - the name of the actor
    * @param receiverName - the name of the receiver
    * @param args - the arguments of the method
    * @param config - the config of the method
    * @throws ActorNotFoundException - if the actor is not found
    * @throws ReceiverNotFoundException - if the receiver is not found
    * @throws IllegalArgumentException - if the arguments are invalid
    * @throws TCPActorSystemRemoteException - if the connection is lost
    * @throws TCPActorSystemRequestTimeoutException - if the request has timed out
    * @throws TCPActorSystemSerializationException - if the envelope serialization fails
    * @throws TCPActorSystemDeserializationException - if the response envelope deserialization fails
    * @throws TCPActorSystemInternalException - for any internal errors
    */
    func remoteTell(name: String, receiverName: String, args: Array<DataModel>, config: ReceiverConfig): Unit {
        logger.debug("remoteTell(${name}) begins.")

        let resp = conn.sendSync(Payload.Tell(name, receiverName, args, config))
        handleResponse(resp, name, receiverName)

        logger.debug("remoteTell(${name}) ends.")
    }

    func handleResponse(resp: Payload, name: String, receiverName: String): Unit {
        match (resp) {
            case Ok => ()
            case ErrorCode(errorCode) => match (errorCode) {
                case ActorNotFound =>
                    logger.error("Actor not found.")
                    throw ActorNotFoundException(name)
                case ReceiverNotFound =>
                    logger.error("Receiver not found.")
                    throw ReceiverNotFoundException(name, receiverName)
                case DeserializationFailed =>
                    logger.error("Deserialization failed.")
                    throw TCPActorSystemDeserializationException("Deserialization failed.")
                case IllegalArgument =>
                    logger.error("Illegal argument.")
                    throw IllegalArgumentException("Illegal argument.")
                case UnknownError =>
                    logger.error("Unknown error.")
                    throw TCPActorSystemInternalException("Unknown error.")
            }
            case _ =>
                logger.error("Unexpected response.")
                throw TCPActorSystemInternalException("Unexpected response.")
        }
    }

    /*
    * Handles an envelope
    * @param e - the envelope
    * @param conn - the connection
    * @throws TCPActorSystemInternalException - for any internal errors
    */
    func handleEnvelope(e: Envelope, conn: TCPConnection): Unit {
        let (id, msg) = (e.id, e.msg)
        match (msg) {
            case Fulfill(futId, res) =>
                if (let Some(fut) <- futMap.remove(futId)) {
                    try {
                        fut.fulfill(res)
                    } catch (e: IllegalArgumentException) {
                        logger.error("Invalid future result for ${futId}: ${e.toStringWithStackTrace()}")
                        fut.exn(TCPActorSystemInternalException("Invalid future result for ${futId}."))
                    }
                    return
                }
                logger.error("No future found for ${futId}.")
                throw TCPActorSystemInternalException("No future found for ${futId}.")

            case Ok | ErrorCode(_) | FindResponse(_) | ContainsActorResponse(_) => conn.putMessageBoard(id, e)

            case _ =>
                logger.error("Unexpected message ${msg}.")
                throw TCPActorSystemInternalException("Unexpected message ${msg}.")
        }
    }

    /*
    * Closes the TCP actor client, can be called multiple times safely
    */
    public func close(): Unit {
        if (isClosed.compareAndSwap(true, true)) {
            return
        }
        conn.close()
    }

    public func getHostInfo(): HostInfo {
        hostInfo
    }
}