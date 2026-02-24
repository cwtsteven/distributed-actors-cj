package cluster_example.common

import std.convert.*
import stdx.log.*

import actors.*
import actors.distributed.*
import actors.tcp_actor_system.*
import actors.tcp_actor_system.cluster.*

import stdx.encoding.json.*
import stdx.serialization.serialization.*

public func entry() {
    let alice = TCPCluster.spawnActor<BankAccount>("alice", [SpawnArgument.create<String>("String", "alice"), SpawnArgument.create<Float64>("Float64", 100.0)]).getOrThrow()
    let bob = TCPCluster.spawnActor<BankAccount>("bob", [SpawnArgument.create<String>("String", "bob")]).getOrThrow()
    alice.deposit(100.0).get()
    bob.withdraw(50.0).get()
    println("Alice's balance: ${alice.getBalance().get()}")
    println("Bob's balance: ${bob.getBalance().get()}")

    TCPCluster.removeActor("alice")
    TCPCluster.removeActor("bob")

    return 0
}