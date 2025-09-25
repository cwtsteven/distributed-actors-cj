package actors.tcp_actor_system

import std.binary.*
import std.collection.*
import std.collection.concurrent.*
import std.net.*
import std.io.*
import std.socket.*
import std.sync.*
import std.time.*

import actors.*
import actors.macros.*
import encoding.json.stream.*

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
    let messageBoard = MessageBoard()

    /*
    * Initializes the TCP connection
    * @param addr - the address of the TCP connection
    * @param port - the port of the TCP connection
    */
    init(addr: String, port: UInt16) {
        socket = TcpSocket(addr, port)
        socket.keepAlive = SocketKeepAliveConfig()
        // socket.readTimeout = Duration.second * 5
        socket.connect()

        writer = TCPWriter(socket)
        envelopeProcessor = EnvelopeProcessor()
        envelopeBuffer = EnvelopeBuffer(envelopeProcessor)
        reader = TCPReader(socket, envelopeBuffer)
    }

    /*
    * Initializes the TCP connection
    * @param socket - the socket of the TCP connection
    */
    init(socket: TcpSocket) {
        this.socket = socket

        writer = TCPWriter(socket)
        envelopeProcessor = EnvelopeProcessor()
        envelopeBuffer = EnvelopeBuffer(envelopeProcessor)
        reader = TCPReader(socket, envelopeBuffer)
    }

    /*
    * The local address of the TCP connection
    */
    prop localAddress: SocketAddress {
        get() {
            socket.localAddress
        }
    }

    /*
    * The remote address of the TCP connection
    */
    prop remoteAddress: SocketAddress {
        get() {
            socket.remoteAddress
        }
    }

    /*
    * Sends a payload synchronously and waits for the response, this method is thread-safe
    * @param msg - the payload to send
    * @return the response payload
    */
    func sendSync(msg: Payload): Payload {
        TCPActorSystem.logger.debug("[TCPConnection (${socket.localAddress} -- ${socket.remoteAddress})]: sending a ${msg} synchronously.")

        let id = nextId.fetchAdd(1)
        let envelope = Envelope(id, msg)
        writer.send(envelope, tell: True)

        // TODO: is this the best way?
        // TODO: use id as a condition variable for monitor?
        // TODO: yes otherwise this might be blocked forever
        // TODO: there needs to be a timeout, also need to think about the case where the message is not received
        while (messageBoard.get(id).isNone()) {
            sleep(Duration.millisecond)
        }

        let resp = messageBoard.remove(id).getOrThrow()

        TCPActorSystem.logger.debug("[TCPConnection (${socket.localAddress} -- ${socket.remoteAddress})]: ${resp} received.")

        return resp.msg
    }

    /*
    * Sends an envelope asynchronously, this method is thread-safe
    * @param e - the envelope to send
    */
    func send(e: Envelope): Unit {
        writer.send(e, tell: True)
    }

    /*
    * Starts listening for envelopes
    * @param handleEnvelope - the function to handle a received envelope, this method needs to be thread-safe
    */
    func startListening(handleEnvelope: (Envelope, TCPConnection) -> Unit): Unit {
        TCPActorSystem.logger.debug("[TCPConnection (${socket.localAddress} -- ${socket.remoteAddress})]: start listening.")
        envelopeProcessor.setHandleEnvelope({ e => handleEnvelope(e, this) })
        reader.startListening(tell: True)
    }

    /*
    * Closes the TCP connection
    */
    func close(): Unit {
        if (!socket.isClosed()) {
            socket.close()
        }
        TCPActorSystem.logger.debug("[TCPConnection (${socket.localAddress} -- ${socket.remoteAddress})]: closed.")
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
@Actor
private class TCPWriter {
    TCPWriter(private let socket: TcpSocket) {}

    /*
    * Sends an envelope through the TCP socket
    * @param e - the envelope to send
    */
    @Receiver[mode: TellOnly]
    func send(e: Envelope): Unit {
        try {
            TCPActorSystem.logger.debug("[TCPWriter (${socket.localAddress} -- ${socket.remoteAddress})]: start sending an envelope.")
            let bytes = serializeEnvelope(e)
            // TCPActorSystem.logger.debug("[TCPWriter (${socket.localAddress} -- ${socket.remoteAddress})]: serialized envelope: ${bytes}")
            socket.write(bytes)
            TCPActorSystem.logger.debug("[TCPWriter (${socket.localAddress} -- ${socket.remoteAddress})]: Envelope ${e} sent.")
        } catch (e: Exception) {
            TCPActorSystem.logger.error("[TCPWriter (${socket.localAddress} -- ${socket.remoteAddress})]: error: ${e.toStringWithStackTrace()}")
            e.printStackTrace()
            if (!socket.isClosed()) {
                socket.close()
            }
            throw e
        } catch (e: Error) {
            TCPActorSystem.logger.error("[TCPWriter (${socket.localAddress} -- ${socket.remoteAddress})]: error: ${e.toStringWithStackTrace()}")
            e.printStackTrace()
            if (!socket.isClosed()) {
                socket.close()
            }
            throw e
        }
    }
}

/*
* An actor reading envelopes from a TCP socket
*/
@Actor
private class TCPReader {
    private let buf = Array<Byte>(1024, item: 0)

    TCPReader(
        private let socket: TcpSocket,
        private let envelopeBuffer: EnvelopeBuffer
    ) {}

    /*
    * Starts listening for envelopes
    */
    @Receiver[mode: TellOnly]
    func startListening(): Unit {
        while (true) {
            if (socket.isClosed()) {
                return
            }

            try {
                buf.fill(0)
                TCPActorSystem.logger.debug("[TCPReader (${socket.localAddress} -- ${socket.remoteAddress})]: listening to a Message.")
                let count = socket.read(buf)
                TCPActorSystem.logger.debug("[TCPReader (${socket.localAddress} -- ${socket.remoteAddress})]: read ${count} bytes.")
                if (count == 0) {
                    break
                }
                if (count > 0) {
                    envelopeBuffer.write(buf.clone(), count, tell: True)
                }
            } catch (_: SocketTimeoutException) {
                continue
            } catch (e: Exception) {
                if (!socket.isClosed()) {
                    socket.close()
                }
                TCPActorSystem.logger.error("[TCPReader (${socket.localAddress} -- ${socket.remoteAddress})]: error: ${e.toStringWithStackTrace()}")
                e.printStackTrace()
                throw e
            } catch (e: Error) {
                if (!socket.isClosed()) {
                    socket.close()
                }
                TCPActorSystem.logger.error("[TCPReader (${socket.localAddress} -- ${socket.remoteAddress})]: error: ${e.toStringWithStackTrace()}")
                e.printStackTrace()
                throw e
            }
        }
        if (!socket.isClosed()) {
            socket.close()
        }
        TCPActorSystem.logger.debug("[TCPReader (${socket.localAddress} -- ${socket.remoteAddress})]: socket closed.")
    }
}

/*
* An actor buffering envelopes
*/
@Actor
class EnvelopeBuffer {
    private let buffer = ArrayList<Byte>(4096)
    private let envelopeProcessor: EnvelopeProcessor

    /*
    * Initializes the envelope buffer
    * @param envelopeProcessor - the envelope processor
    */
    init(envelopeProcessor: EnvelopeProcessor) {
        this.envelopeProcessor = envelopeProcessor
    }

    /*
    * Writes an array of bytes to a buffer and sends bytes to a envelope processor
    * when received enough bytes for one envelope
    * @param buf - the array of bytes to write
    * @param count - the number of bytes to write
    */
    @Receiver[mode: TellOnly]
    func write(buf: Array<Byte>, count: Int64): Unit {
        try {
            buffer.appendAll(buf[0..count])
            TCPActorSystem.logger.debug("[EnvelopeBuffer]: written ${count} bytes.")
            sendToEnvelopeProcessor()
        } catch (e: Exception) {
            TCPActorSystem.logger.error("[EnvelopeBuffer]: error writing bytes: ${e.toStringWithStackTrace()}")
            e.printStackTrace()
            throw e
        } catch (e: Error) {
            TCPActorSystem.logger.error("[EnvelopeBuffer]: error writing bytes: ${e.toStringWithStackTrace()}")
            e.printStackTrace()
            throw e
        }
    }

    func sendToEnvelopeProcessor(): Unit {
        while (true) {
            if (buffer.size < 4) {
                break
            }
            let lengthBytes = buffer[0..4].toArray()
            let expectedLength = Int64(Int32.readLittleEndian(lengthBytes))
            TCPActorSystem.logger.debug("[EnvelopeBuffer]: buffer size: ${buffer.size}, expected length: ${expectedLength + 4}")
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

    /*
    * Deserializes an array of bytes to an envelope and calls the handleEnvelope function
    * @param bytes - the array of bytes to process
    */
    @Receiver[mode: TellOnly]
    func process(bytes: Array<Byte>): Unit {
        try {
            TCPActorSystem.logger.debug("[EnvelopeProcessor]: process ${bytes.size} bytes.")
            let e = deserializeEnvelope(bytes)
            TCPActorSystem.logger.debug("[EnvelopeProcessor]: deserialized envelope: ${e}")
            handleEnvelope(e)
            TCPActorSystem.logger.debug("[EnvelopeProcessor]: processed envelope: ${e}")
        } catch (e: Exception) {
            TCPActorSystem.logger.error("[EnvelopeProcessor]: error processing envelope: ${e.toStringWithStackTrace()}")
            e.printStackTrace()
            throw e
        } catch (e: Error) {
            TCPActorSystem.logger.error("[EnvelopeProcessor]: error processing envelope: ${e.toStringWithStackTrace()}")
            e.printStackTrace()
            throw e
        }
    }

    /*
    * Sets the handleEnvelope function
    * @param handleEnvelope - the function to handle an envelope
    */
    func setHandleEnvelope(handleEnvelope: (Envelope) -> Unit): Unit {
        this.handleEnvelope = handleEnvelope
    }
}