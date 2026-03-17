package actors.tcp_actor_system

import std.collection.concurrent.*
import std.net.*
import std.sync.*
import std.time.*

import stdx.serialization.serialization.*

import actors.*
import actors.macros.*
import actors.distributed.*

class PendingRemoteResult {
    private var result: FutureResult<DataModel> = unsafe { zeroValue<FutureResult<DataModel>>() }
    private let isReady = AtomicBool(false)
    private let mtx = Mutex()
    private let cond: Condition

    init() {
        synchronized(mtx) {
            cond = mtx.condition()
        }
    }

    func get(): DataModel {
        if (isReady.load()) {
            return result.getOrThrow()
        }
        synchronized(mtx) {
            while (!isReady.load()) {
                cond.wait()
            }
            result.getOrThrow()
        }
    }

    func fulfill(dataModel: DataModel): Bool {
        setResult(deserializePendingResult(dataModel))
    }

    func exn(exception: Exception): Bool {
        setResult(Exc(exception))
    }

    private func setResult(result: FutureResult<DataModel>): Bool {
        synchronized(mtx) {
            if (isReady.load()) {
                return false
            }
            this.result = result
            isReady.store(true)
            cond.notifyAll()
            true
        }
    }

    private func deserializePendingResult(dataModel: DataModel): FutureResult<DataModel> {
        match (dataModel) {
            case dm: DataModelStruct =>
                let fields = dm.getFields()
                var resultType: String = ""
                var valueData: DataModel = DataModelNull()
                var message: String = ""

                for (field in fields) {
                    match (field.getName()) {
                        case "type" =>
                            match (field.getData()) {
                                case str: DataModelString => resultType = str.getValue()
                                case _ => throw IllegalArgumentException("Invalid type field in FutureResult deserialization.")
                            }
                        case "value" =>
                            valueData = field.getData()
                        case "message" =>
                            match (field.getData()) {
                                case str: DataModelString => message = str.getValue()
                                case _ => throw IllegalArgumentException("Invalid message field in FutureResult deserialization.")
                            }
                        case _ => ()
                    }
                }

                match (resultType) {
                    case "Okay" => Okay(valueData)
                    case "Exc" => Exc(RemoteReceiverException(message))
                    case "Err" => Exc(RemoteReceiverException(message))
                    case _ => throw IllegalArgumentException("Invalid FutureResult type: ${resultType}.")
                }
            case _ =>
                throw IllegalArgumentException("Expected DataModelStruct for FutureResult deserialization.")
        }
    }
}

type FutMap = ConcurrentHashMap<UInt64, PendingRemoteResult>

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
    * Gets a typed actor proxy by name.
    * This is the preferred public API when users work with distributed actor interfaces.
    * @param name - the exported actor name
    * @return the typed proxy if found, None otherwise
    */
    public func getTypedActor<T>(name: String): Option<T> where T <: Distributable & Proxyable<T> {
        match (this.getActor(name)) {
            case Some(proxy) => Some(T.getProxy(proxy.actorName, proxy.hostInfo))
            case None => None
        }
    }

    /*
    * Gets a typed actor proxy by name or throws if the actor is not found.
    * @param name - the exported actor name
    * @return the typed proxy
    * @throws ActorNotFoundException - if the actor is not found
    */
    public func requireTypedActor<T>(name: String): T where T <: Distributable & Proxyable<T> {
        match (this.getTypedActor<T>(name)) {
            case Some(actor) => actor
            case None => throw ActorNotFoundException(name)
        }
    }

    public func ask(name: String, receiverName: String, args: Array<DataModel>, config: ReceiverConfig): ActorFuture<DataModel> {
        if (isClosed.load()) {
            throw TCPActorSystemRemoteException("[Client to ${hostInfo}] Connection to ${conn.remoteAddress} has been lost.")
        }
        let fut = PendingRemoteResult()
        remoteAsk(name, receiverName, args, config, fut)
        let actorFuture = ActorFuture<DataModel>({ => fut.get() })
        spawn { actorFuture.execute() }
        actorFuture
    }

    func remoteAsk(name: String, receiverName: String, args: Array<DataModel>, config: ReceiverConfig, fut: PendingRemoteResult): Unit {
        logger.debug("remoteCall(${name}) begins.")

        let futId = nextFutId.fetchAdd(1)
        futMap.add(futId, fut)

        let resp = conn.sendSync(Payload.Ask(name, receiverName, args, config, futId))
        handleResponse(resp, name, receiverName)

        logger.debug("remoteCall(${name}) ends.")
    }

    public func tell(name: String, receiverName: String, args: Array<DataModel>, config: ReceiverConfig): Unit {
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
        ClientManager.instance.removeClient(hostInfo)
    }

    /*
    * Gets the host info of the client
    * @return the host info of the client
    */
    public func getHostInfo(): HostInfo {
        hostInfo
    }
}
