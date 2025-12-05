import std.collection.*
import std.log.*
import std.io.*
import std.fs.*
import std.sync.*
import std.time.*

import actors.*
import actors.macros.*
import actors.distributed.*
import actors.tcp_actor_system.*

import encoding.json.*
import serialization.serialization.*

@ActorInterface[distributed: true, description: "Bank service"]
public interface BankService {
    @Receiver[description: "Transfer money between accounts"]
    func transfer(from: String, to: String, amount: Float64): Bool

    @Receiver
    func neverReturn(): Bool
}

@Actor
public class BankServiceImpl <: BankService {
    @Receiver
    public func transfer(from: String, to: String, amount: Float64): Bool {
        // Transfer logic here
        println("Transferred ${amount} from ${from} to ${to}")
        true
    }

    @Receiver
    public func neverReturn(): Bool {
        while (true) {
            sleep(Duration.second * 1)
        }
        true
    }
}

const PORT: UInt16 = 52165

main() {
    let logFile = File("tcp-actor-host.log", OpenOption.CreateOrTruncate(false))
    TCPActorSystem.logger.setOutput(logFile)
    TCPActorSystem.logger.level = LogLevel.DEBUG

    // Create and start the TCP actor host
    let tcpHost = TCPActorHost(bindAt: PORT)
    let serverFuture = tcpHost.serve()

    // Export the bank service
    let bankService = BankServiceImpl()
    tcpHost.export("bank-service", bankService)

    println("TCP Actor Host is running on port ${PORT}")
    println("Press Ctrl+C to stop the server")

    // Keep the server running
    serverFuture.get()
}