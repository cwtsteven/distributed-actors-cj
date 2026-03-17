package distributed_actors_example.client

import std.collection.*
import stdx.log.*
import std.io.*
import std.fs.*

import actors.*
import actors.distributed.*
import actors.tcp_actor_system.*
import stdx.encoding.json.*
import stdx.serialization.serialization.*

import distributed_actors_example.common.*

const PORT: UInt16 = 52165

main() {
    // let logFile = File("tcp-actor-client.log", OpenOption.CreateOrTruncate(false))
    // TCPActorSystem.logger.setOutput(logFile)
    TCPActorSystem.logger.level = LogLevel.DEBUG

    let tcpClient = TCPActorClient.create("localhost", PORT)
    let steven = tcpClient.getTypedActor<BankAccount>("Steven").getOrThrow()
    steven.deposit(100.0).get()
    let res = steven.getBalance().get()
    println("Steven balance: ${res}") // 100.0

    let reporter = tcpClient.getTypedActor<BalanceReporter>("balance-reporter").getOrThrow()
    let snapshot = reporter.recordSnapshot("Steven", res).get()
    println("Latest snapshot: ${snapshot}")
    println("Stored snapshot: ${reporter.latestSnapshot().get()}")
}
