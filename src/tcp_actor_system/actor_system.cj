package actors.tcp_actor_system

import std.log.*
import std.time.*
import std.io.*

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
                    let l = SimpleLogger()
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

    public func setOutput(output: OutputStream) {
        TCPActorSystem.logger.setOutput(output)
    }

    public func trace(message: String) {
        formatLog(message, TCPActorSystem.logger.trace)
    }

    public func debug(message: String) {
        formatLog(message, TCPActorSystem.logger.debug)
    }

    public func info(message: String) {
        formatLog(message, TCPActorSystem.logger.info)
    }

    public func warn(message: String) {
        formatLog(message, TCPActorSystem.logger.warn)
    }

    public func error(message: String) {
        formatLog(message, TCPActorSystem.logger.error)
    }

    public func log(level: LogLevel, message: String) {
        formatLog(message, { str => TCPActorSystem.logger.log(level, str) })
    }

    func formatLog(message: String, logFunc: (String) -> Unit): Unit {
        let strs = message.split("\n")
        for (str in strs) {
            logFunc(header + " " + str)
        }
    }

    func append(message: String): TCPActorLoggerWrapper {
        TCPActorLoggerWrapper(header + " " + message)
    }
}