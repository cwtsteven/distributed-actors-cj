package serializable_proxy_example.client

import stdx.log.*

import actors.distributed.*
import actors.tcp_actor_system.*

import serializable_proxy_example.common.*

const PORT: UInt16 = 52165

main() {
    TCPActorSystem.logger.level = LogLevel.DEBUG

    let client = TCPActorClient.create("localhost", PORT)
    let steven = client.getTypedActor<BankAccount>("Steven").getOrThrow()
    steven.deposit(50.0).get()
    println("Steven balance: ${steven.getBalance().get()}")

    let federico = client.getTypedActor<BankAccount>("Federico").getOrThrow()
    steven.transfer(federico, 50.0).get()

    println("Steven balance: ${steven.getBalance().get()}") // 100.0
    println("Federico balance: ${federico.getBalance().get()}") // 50.0
}
