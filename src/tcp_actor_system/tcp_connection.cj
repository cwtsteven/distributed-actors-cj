package actors.tcp_actor_system

import std.binary.*
import std.collection.*
import std.collection.concurrent.*
import std.net.*
import std.io.*
import std.sync.*
import std.time.*

import actors.*
import actors.macros.*
import actors.distributed.*
import stdx.encoding.json.stream.*

/*
* A struct wrapping a payload with an id
*/
struct Envelope <: ToString {
    Envelope(
        let id: UInt64,
        let msg: Payload
    ) {}

    public func toString(): String {
        "Envelope(${id}, ${msg})"
    }
}

type MessageBoard = ConcurrentHashMap<UInt64, Envelope>

/*
* A class representing a thread-safe TCP connection
*/
class TCPConnection <: Hashable {
    private let socket: TcpSocket
    private let writer: TCPWriter
    private let reader: TCPReader
    private let envelopeBuffer: EnvelopeBuffer
    private let envelopeProcessor: EnvelopeProcessor

    private let nextId = AtomicUInt64(0)
    private let messageBoard = MessageBoard()

    let localAddress: SocketAddress
    let remoteAddress: SocketAddress
    private let logger: TCPActorLoggerWrapper

    let isClosed = AtomicBool(false)

    private var closingCallBack: () -> Unit = { => () }

    /*
    * Initializes the TCP connection
    * @param addr - the address of the TCP connection
    * @param port - the port of the TCP connection
    * @throws IllegalArgumentException - if the address or port is invalid
    * @throws SocketException - if the socket connection fails
    * @throws SocketTimeoutException - if the socket connection times out
    */
    init(addr: String, port: UInt16) {
        socket = TcpSocket(addr, port)
        socket.keepAlive = SocketKeepAliveConfig()
        // socket.readTimeout = Duration.second * 5
        socket.connect()

        this.localAddress = socket.localAddress
        this.remoteAddress = socket.remoteAddress
        this.logger = TCPActorLoggerWrapper("[TCPConnection (${localAddress} -- ${remoteAddress})]")

        writer = TCPWriter(socket, logger.append("[Writer]"))
        envelopeProcessor = EnvelopeProcessor(logger.append("[EnvelopeProcessor]"))
        envelopeBuffer = EnvelopeBuffer(envelopeProcessor, logger.append("[EnvelopeBuffer]"))
        reader = TCPReader(socket, envelopeBuffer, logger.append("[Reader]"))
        reader.conn = this
    }

    /*
    * Initializes the TCP connection
    * @param socket - the socket of the TCP connection
    */
    init(socket: TcpSocket) {
        this.socket = socket

        this.localAddress = socket.localAddress
        this.remoteAddress = socket.remoteAddress

        this.logger = TCPActorLoggerWrapper("[TCPConnection (${localAddress} -- ${remoteAddress})]")

        writer = TCPWriter(socket, logger.append("[Writer]"))
        envelopeProcessor = EnvelopeProcessor(logger.append("[EnvelopeProcessor]"))
        envelopeBuffer = EnvelopeBuffer(envelopeProcessor, logger.append("[EnvelopeBuffer]"))
        reader = TCPReader(socket, envelopeBuffer, logger.append("[Reader]"))
        reader.conn = this
    }

    /*
    * Sends a payload synchronously and waits for the response, this method is thread-safe
    * @param msg - the payload to send
    * @param priority - the priority of the envelope
    * @return the response payload
    * @throws TCPActorSystemSerializationException - if the envelope serialization fails
    * @throws TCPActorSystemRemoteException - if the remote connection fails
    * @throws TCPActorSystemRequestTimeoutException - if the request timeout
    */
    func sendSync(msg: Payload, priority!: Int64 = 5): Payload {
        logger.debug("sending a ${msg} synchronously.")

        let id = nextId.fetchAdd(1)
        let envelope = Envelope(id, msg)
        this.send(envelope, priority: priority)

        // TODO: use id as a condition variable for a monitor?
        // TODO: need to think about the case where the message is received after timeout
        let start = DateTime.now()
        while (messageBoard.get(id).isNone()) {
            let timeElapsed = DateTime.now() - start
            if (timeElapsed >= TCPActorSystem.requestTimeout) {
                logger.error("request timeout.")
                throw TCPActorSystemRequestTimeoutException()
            }
            sleep(Duration.millisecond)
        }

        let resp = match (messageBoard.remove(id)) {
            case Some(resp) => resp
            case None =>
                logger.error("No response found for id ${id}.")
                throw TCPActorSystemInternalException("No response found for id ${id}.")
        }

        logger.debug("${resp} received.")

        return resp.msg
    }

    /*
    * Sends an envelope asynchronously, this method is thread-safe
    * @param e - the envelope to send
    * @param priority - the priority of the envelope
    * @throws TCPActorSystemSerializationException - if the envelope serialization fails
    * @throws TCPActorSystemRemoteException - if the remote connection fails
    */
    func send(e: Envelope, priority!: Int64 = 5): Unit {
        let fut = writer.send(e, config: ReceiverConfig(priority: priority))
        try {
            fut.get()
        } catch (e: SocketException) {
            // logger.error("error: ${e.toStringWithStackTrace()}")
            throw TCPActorSystemRemoteException()
        }
    }

    /*
    * Puts an envelope into the message board only if the message with the same id does not exist
    * @param id - the id of the envelope
    * @param e - the envelope to put
    * @return true if the envelope is put successfully, false if message with the same id already exists
    */
    func putMessageBoard(id: UInt64, e: Envelope): Bool {
        messageBoard.addIfAbsent(id, e).isNone()
    }

    /*
    * Starts listening for envelopes
    * @param handleEnvelope - the function to handle a received envelope, this function needs to be thread-safe
    */
    func startListening(handleEnvelope: (Envelope, TCPConnection) -> Unit): Unit {
        logger.debug("start listening.")
        envelopeProcessor.setHandleEnvelope({ e => handleEnvelope(e, this) })
        spawn {
            reader.startListening().get()
            this.close()
        }
    }

    func setClosingCallBack(closingCallBack: () -> Unit): Unit {
        this.closingCallBack = closingCallBack
    }

    /*
    * Closes the TCP connection
    */
    func close(): Unit {
        if (isClosed.compareAndSwap(false, true)) {
            socket.close()
            closingCallBack()
            logger.debug("closed.")
        }
    }

    /*
    * Returns the hash code of the TCP connection
    * @return the hash code of the TCP connection
    */
    public override func hashCode(): Int64 {
        socket.hashCode()
    }
}

// TODO: we could buffer this
/*
* An actor sending envelopes through a TCP socket
*/
@Actor[enableReceiverPriority: true]
private class TCPWriter {
    private let localAddress: SocketAddress
    private let remoteAddress: SocketAddress

    TCPWriter(
        private let socket: TcpSocket,
        private let logger: TCPActorLoggerWrapper
    ) {
        this.localAddress = socket.localAddress
        this.remoteAddress = socket.remoteAddress
    }

    /*
    * Sends an envelope through the TCP socket
    * @param e - the envelope to send
    * @throws TCPActorSystemSerializationException - if the envelope serialization fails
    * @throws SocketException - if the envelope sending fails
    */
    @Receiver[mode: AskOnly]
    func send(e: Envelope): Unit {
        logger.debug("start sending an envelope.")
        let bytes = serializeEnvelope(e)
        // logger.debug("serialized envelope: ${bytes}")
        socket.write(bytes)
        logger.debug("Envelope ${e} sent.")
    }
}

/*
* An actor reading envelopes from a TCP socket
*/
@Actor
private class TCPReader {
    private let localAddress: SocketAddress
    private let remoteAddress: SocketAddress
    private var __conn: ?TCPConnection = None
    mut prop conn: TCPConnection {
        get() { match (__conn) { case Some(c) => c case None => throw TCPActorSystemInternalException("Connection not set") } }
        set(c) { __conn = Some(c) }
    }

    private let buf = Array<Byte>(1024, { _ => 0 })

    TCPReader(
        private let socket: TcpSocket,
        private let envelopeBuffer: EnvelopeBuffer,
        private let logger: TCPActorLoggerWrapper
    ) {
        this.localAddress = socket.localAddress
        this.remoteAddress = socket.remoteAddress
    }

    /*
    * Starts listening for envelopes
    */
    @Receiver[mode: AskOnly]
    func startListening(): Unit {
        while (true) {
            if (conn.isClosed.load()) {
                return
            }

            buf.fill(0u8)
            logger.debug("listening to a Message.")

            let count = try {
                let count = socket.read(buf)
                logger.debug("read ${count} bytes.")
                count
            } catch (e: SocketException) {
                logger.error("error: ${e.toStringWithStackTrace()}")
                conn.close()
                return
            }

            if (count == 0) {
                conn.close()
                return
            }

            if (count > 0) {
                envelopeBuffer.write(buf.clone(), count, tell: True)
            }
        }
    }
}

/*
* An actor buffering envelopes
*/
@Actor
class EnvelopeBuffer {
    private let buffer = ArrayList<Byte>(4096)
    private let envelopeProcessor: EnvelopeProcessor

    private let logger: TCPActorLoggerWrapper

    /*
    * Initializes the envelope buffer
    * @param envelopeProcessor - the envelope processor
    */
    init(envelopeProcessor: EnvelopeProcessor, logger: TCPActorLoggerWrapper) {
        this.envelopeProcessor = envelopeProcessor
        this.logger = logger
    }

    /*
    * Writes an array of bytes to a buffer and sends bytes to a envelope processor
    * when received enough bytes for one envelope
    * @param buf - the array of bytes to write
    * @param count - the number of bytes to write
    */
    @Receiver[mode: TellOnly]
    func write(buf: Array<Byte>, count: Int64): Unit {
        for (b in buf[0..count]) {
            buffer.add(b)
        }
        logger.debug("written ${count} bytes.")
        sendToEnvelopeProcessor()
    }

    /*
    * Sends bytes to the envelope processor
    */
    func sendToEnvelopeProcessor(): Unit {
        while (true) {
            if (buffer.size < 4) {
                break
            }
            let lengthBytes = buffer[0..4].toArray()
            let expectedLength = Int64(Int32.readLittleEndian(lengthBytes))
            logger.debug("buffer size: ${buffer.size}, expected length: ${expectedLength + 4}")
            if (buffer.size >= expectedLength + 4) {
                let dataBytes = buffer[0..expectedLength+4].toArray()
                envelopeProcessor.process(dataBytes, tell: True)
                buffer.remove(0..expectedLength+4)
                continue
            }
            break
        }
    }
}

/*
* An actor processing envelopes
*/
@Actor
class EnvelopeProcessor {
    private var handleEnvelope: (Envelope) -> Unit = { _ => () }

    private let logger: TCPActorLoggerWrapper

    init(logger: TCPActorLoggerWrapper) {
        this.logger = logger
    }

    /*
    * Deserializes an array of bytes to an envelope and calls the handleEnvelope function
    * @param bytes - the array of bytes to process
    * @throws TCPActorSystemDeserializationException - if the envelope deserialization fails
    * @throws TCPActorSystemSerializationException - if the envelope serialization fails
    * @throws TCPActorSystemRemoteException - if the remote connection fails
    * @throws TCPActorSystemInternalException - if an internal error occurs
    */
    @Receiver[mode: TellOnly]
    func process(bytes: Array<Byte>): Unit {
        // TODO: can we spawn threads to handle each envelope?
        logger.debug("process ${bytes.size} bytes.")

        let e: Envelope = try {
            deserializeEnvelope(bytes)
        } catch (e: DeserializationException) {
            logger.error("error processing envelope: ${e.toStringWithStackTrace()}")
            match (tryGetIdFromEnvelopeBytes(bytes)) {
                case Some(id) =>
                    handleEnvelope(Envelope(id, ErrorCode(DeserializationFailed)))
                    throw e
                case None =>
                    throw e
            }
        }

        logger.debug("deserialized envelope: ${e}")

        try {
            handleEnvelope(e)
        } catch (e: TCPActorSystemSerializationException) {
            logger.error("error processing envelope: ${e.toStringWithStackTrace()}")
            match (tryGetIdFromEnvelopeBytes(bytes)) {
                case Some(id) =>
                    handleEnvelope(Envelope(id, ErrorCode(UnknownError)))
                    throw e
                case None =>
                    throw e
            }
        } catch (e: TCPActorSystemRemoteException) {
            logger.error("error processing envelope: ${e.toStringWithStackTrace()}")
            match (tryGetIdFromEnvelopeBytes(bytes)) {
                case Some(id) =>
                    handleEnvelope(Envelope(id, ErrorCode(UnknownError)))
                    throw e
                case None =>
                    throw e
            }
        } catch (e: TCPActorSystemInternalException) {
            logger.error("error processing envelope: ${e.toStringWithStackTrace()}")
            match (tryGetIdFromEnvelopeBytes(bytes)) {
                case Some(id) =>
                    handleEnvelope(Envelope(id, ErrorCode(UnknownError)))
                    throw e
                case None =>
                    throw e
            }
        }

        logger.debug("processed envelope: ${e}")
    }

    /*
    * Sets the handleEnvelope function
    * @param handleEnvelope - the function to handle an envelope
    */
    func setHandleEnvelope(handleEnvelope: (Envelope) -> Unit): Unit {
        this.handleEnvelope = handleEnvelope
    }
}
