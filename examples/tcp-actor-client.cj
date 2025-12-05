import std.collection.*
import std.log.*
import std.io.*
import std.fs.*

import actors.*
import actors.distributed.*
import actors.tcp_actor_system.*
import encoding.json.*
import serialization.serialization.*

const PORT: UInt16 = 52165

main() {
    let logFile = File("tcp-actor-client.log", OpenOption.CreateOrTruncate(false))
    TCPActorSystem.logger.setOutput(logFile)
    TCPActorSystem.logger.level = LogLevel.DEBUG

    let tcpClient = TCPActorClient("client-1", "localhost", PORT)

    try {
        let bankProxy = ActorProxy("bank-service", tcpClient)

        let transferFut: DistributedFuture = bankProxy.ask("transfer", [
            "alice".serialize(),
            "bob".serialize(),
            100.0.serialize()
        ])

        transferFut.get()
        println("Transfer completed")

    } catch (e: Exception) {
        e.printStackTrace()
    } finally {
        // Close the client connection
        tcpClient.close()
    }
}