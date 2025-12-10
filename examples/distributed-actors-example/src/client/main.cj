package distributed_actors_example.client

import std.collection.*
import std.log.*
import std.io.*
import std.fs.*

import actors.*
import actors.distributed.*
import actors.tcp_actor_system.*
import encoding.json.*
import serialization.serialization.*

import distributed_actors_example.common.*

const PORT: UInt16 = 52165

main() {
    // let logFile = File("tcp-actor-client.log", OpenOption.CreateOrTruncate(false))
    // TCPActorSystem.logger.setOutput(logFile)
    TCPActorSystem.logger.level = LogLevel.DEBUG

    let tcpClient = TCPActorClient.create("client-1", "localhost", PORT)

    let proxy = ActorProxy("Steven", tcpClient)
    proxy.ask("deposit", [100.0.serialize()]).get()
    let res = Float64.deserialize(proxy.ask("getBalance", []).get())
    println("Steven balance: ${res}") // 100.0

    let steven = BankAccount.getProxy("Steven", tcpClient)
    steven.deposit(100.0).get()
    let res2 = steven.getBalance().get()
    println("Steven balance: ${res2}") // 200.0
}