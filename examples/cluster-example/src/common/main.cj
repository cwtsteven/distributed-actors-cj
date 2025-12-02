package cluster_example.common

import std.convert.*
import std.log.*

import actors.*
import actors.distributed.*
import actors.tcp_actor_system.*
import actors.tcp_actor_system.cluster.*

import encoding.json.*
import serialization.serialization.*

public func entry() {
    let test = TCPCluster.spawnActor<BankAccount>("test", []).getOrThrow()
    // let alice = TCPCluster.spawnActor<BankAccount>("alice", [SpawnArgument.create<String>("String", "alice"), SpawnArgument.create<Float64>("Float64", 100.0)]).getOrThrow()
    // let bob = TCPCluster.spawnActor<BankAccount>("bob", [SpawnArgument.create<String>("String", "bob")]).getOrThrow()
    // alice.deposit(100.0).get()
    // bob.withdraw(50.0).get()
    // println("Alice's balance: ${alice.getBalance().get()}")
    // println("Bob's balance: ${bob.getBalance().get()}")
}