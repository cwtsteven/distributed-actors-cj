package distributed_actors_example.host

import std.collection.*
import stdx.log.*
import std.io.*
import std.fs.*
import std.sync.*
import std.time.*

import actors.*
import actors.macros.*
import actors.distributed.*
import actors.tcp_actor_system.*

import stdx.encoding.json.*
import stdx.serialization.serialization.*

import distributed_actors_example.common.*

const PORT: UInt16 = 52165

main() {
    // let logFile = File("tcp-actor-host.log", OpenOption.CreateOrTruncate(false))
    // TCPActorSystem.logger.setOutput(logFile)
    TCPActorSystem.logger.level = LogLevel.DEBUG

    // Create and start the TCP actor host
    let tcpHost = TCPActorHost(addr: "localhost", bindAt: PORT)
    let serverFuture = tcpHost.serve()

    // Export the bank service
    let bankAccount1 = BankAccountImpl("Steven", 0.0)
    tcpHost.publish("Steven", bankAccount1)
    tcpHost.publish("balance-reporter", BalanceReporterImpl())

    // Keep the server running
    serverFuture.get()
}
