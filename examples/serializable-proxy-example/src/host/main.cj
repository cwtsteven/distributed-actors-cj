package serializable_proxy_example.host

import stdx.log.*

import actors.tcp_actor_system.*

import serializable_proxy_example.common.*

const PORT: UInt16 = 52165

main() {
    TCPActorSystem.logger.level = LogLevel.DEBUG

    // Create and start the TCP actor host
    let tcpHost = TCPActorHost(addr: "localhost", bindAt: PORT)

    // Export the bank account
    let bankAccount1 = BankAccountImpl("Steven", 100.0)
    let bankAccount2 = BankAccountImpl("Federico", 0.0)
    tcpHost.publish("Steven", bankAccount1)
    tcpHost.publish("Federico", bankAccount2)

    tcpHost.serve().get()
}
