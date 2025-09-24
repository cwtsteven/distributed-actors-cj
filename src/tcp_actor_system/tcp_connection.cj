package actors.tcp_actor_system

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

class TCPConnection <: Hashable {
    private let conn: TcpSocket
    private let writer: TCPWriter
    private let reader: TCPReader

    private let nextId = AtomicUInt64(0)
    let messageBoard = MessageBoard()

    init(addr: String, port: UInt16) {
        conn = TcpSocket(addr, port)
        conn.keepAlive = SocketKeepAliveConfig()
        conn.readTimeout = Duration.second
        conn.connect()

        writer = TCPWriter(conn)
        reader = TCPReader(conn)
    }

    init(conn: TcpSocket) {
        this.conn = conn

        writer = TCPWriter(conn)
        reader = TCPReader(conn)
    }

    func sendSync(msg: Payload): Payload {
        TCPActorSystem.logger.debug("[TCPConnection]: sending a ${msg} synchronously.")

        let id = nextId.fetchAdd(1)
        let envelope = Envelope(id, msg)
        writer.send(envelope, tell: True)

        // TODO: is this the best way?
        while (messageBoard.get(id).isNone()) {
            sleep(Duration.millisecond)
        }

        let resp = messageBoard.remove(id).getOrThrow()

        TCPActorSystem.logger.debug("[TCPConnection]: ${resp} received.")

        return resp.msg
    }

    func send(e: Envelope): Unit {
        writer.send(e, tell: True)
    }

    func startListening(handleEnvelope: (Envelope, TCPConnection) -> Unit): Unit {
        TCPActorSystem.logger.debug("[TCPConnection]: start listening.")

        reader.startListening({ e => handleEnvelope(e, this) }, tell: True)
    }

    func close(): Unit {
        conn.close()
    }

    public func hashCode(): Int64 {
        conn.hashCode()
    }
}

@Actor
private class TCPWriter {
    TCPWriter(private let conn: TcpSocket) {}

    @Receiver[mode: TellOnly]
    func send(e: Envelope): Unit {
        try {
            TCPActorSystem.logger.debug("[TCPWriter]: start sending an envelope.")
            let bytes = serializeEnvelope(e)
            conn.write(bytes)
            TCPActorSystem.logger.debug("[TCPWriter]: Envelope ${e} sent.")
        } catch (e: Exception) {
            e.printStackTrace()
            throw e
        }
    }
}

@Actor
private class TCPReader {
    private let buf = Array<Byte>(1024, item: 0)

    TCPReader(
        private let conn: TcpSocket
    ) {}

    @Receiver[mode: TellOnly]
    func startListening(handleEnvelope: (Envelope) -> Unit): Unit {
        if (conn.isClosed()) {
            return
        }

        try {
            buf.fill(0)
            TCPActorSystem.logger.debug("[TCPReader]: listening to a Message.")
            let count = conn.read(buf)
            TCPActorSystem.logger.debug("[TCPReader]: read ${count} bytes.")
            let e = deserializeEnvelope(buf)
            TCPActorSystem.logger.debug("[TCPReader]: Message ${e} read.")
            handleEnvelope(e)
            this.startListening(handleEnvelope, tell: True)

        } catch (e: SocketTimeoutException) {
            this.startListening(handleEnvelope, tell: True)
        } catch (e: Exception) {
            e.printStackTrace()
            throw e
        }

        return
    }
}