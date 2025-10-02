import std.collection.*

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
}

@Actor
public class BankServiceImpl <: BankService {
    @Receiver
    public func transfer(from: String, to: String, amount: Float64): Bool {
        // Transfer logic here
        println("Transferred ${amount} from ${from} to ${to}")
        true
    }
}

const PORT: UInt16 = 52165

main() {
    // Host side
    let tcpHost = TCPActorHost(bindAt: PORT)
    tcpHost.serve() // start the server

    let bankService = BankServiceImpl()
    tcpHost.register("bank-service", bankService)

    // Client side
    let tcpClient = TCPActorClient("client-1", "localhost", PORT)
    let bankProxy = ActorProxy("bank-service", tcpClient)

    let transferFut: DistributedFuture = bankProxy.ask("transfer", [
        "alice".serialize(),
        "bob".serialize(),
        100.0.serialize()
    ])

    transferFut.get()
    println("Transfer completed")
}