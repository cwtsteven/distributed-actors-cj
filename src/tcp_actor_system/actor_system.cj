package actors.tcp_actor_system

import stdx.log.*
import stdx.logger.SimpleLogger
import std.collection.*
import std.time.*
import std.io.*
import std.env.*

/*
* Stores the configuration of the TCP actor system
*/
public class TCPActorSystem {
    private static var __logger: ?Logger = None
    public static mut prop logger: Logger {
        get() {
            match (__logger) {
                case Some(l) => l
                case None =>
                    let l = SimpleLogger(getStdOut())
                    __logger = Some(l)
                    l
            }
        }
        set(l) {
            __logger = Some(l)
        }
    }

    /*
    * The timeout duration for a request sent in a TCP channel
    */
    public static var requestTimeout: Duration = Duration.second * 10

    /*
    * The interval duration for sending a heartbeat
    */
    public static var heartbeatInterval: Duration = Duration.second * 2
}

/*
* A wrapper for the logger that adds a header to the log messages
*/
class TCPActorLoggerWrapper <: Logger {
    private let header: String

    public mut prop level: LogLevel {
        get() { TCPActorSystem.logger.level }
        set(l) { TCPActorSystem.logger.level = l }
    }

    TCPActorLoggerWrapper(header: String) {
        this.header = header
    }

    public func withAttrs(attrs: Array<Attr>): Logger {
        TCPActorLoggerWrapper(header)
    }

    public func isClosed(): Bool {
        TCPActorSystem.logger.isClosed()
    }

    public func close(): Unit {
        // do nothing
    }

    public func log(record: LogRecord): Unit {
        let strs = record.message.split("\n")
        for (str in strs) {
            TCPActorSystem.logger.log(LogRecord(record.time, record.level, header + " " + str, record.attrs))
        }
    }

    func append(message: String): TCPActorLoggerWrapper {
        TCPActorLoggerWrapper(header + " " + message)
    }
}
