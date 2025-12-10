package serializable_proxy_example.client

import std.log.*

import actors.tcp_actor_system.*

import serializable_proxy_example.common.*

const PORT: UInt16 = 52165

main() {
    TCPActorSystem.logger.level = LogLevel.DEBUG

    let client = TCPActorClient.create("client-1", "localhost", PORT)
    let steven = BankAccount.getProxy("Steven", client)
    steven.deposit(50.0).get()
    println("Steven balance: ${steven.getBalance().get()}")

    let federico = BankAccount.getProxy("Federico", client)
    steven.transfer(federico, 50.0).get()

    println("Steven balance: ${steven.getBalance().get()}") // 100.0
    println("Federico balance: ${federico.getBalance().get()}") // 50.0
}