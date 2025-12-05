package cluster_example.common

import std.collection.*

import actors.*
import actors.macros.*
import actors.distributed.*
import actors.tcp_actor_system.*
import actors.tcp_actor_system.cluster.*

import encoding.json.*
import serialization.serialization.*

@ActorInterface[distributed: true]
public interface BankAccount <: Spawnable<BankAccount> {

    @Receiver
    func deposit(amount: Float64): Bool

    @Receiver
    func withdraw(amount: Float64): Bool

    @Receiver
    func getBalance(): Float64

    static func typeName(): String {
        "BankAccount"
    }

    static func spawnWith(args: Array<SpawnArgument>): Option<BankAccount> {
        if (args.size == 0) {
            return Some(BankAccountImpl())
        }
        if (args.size == 1) {
            return Some(BankAccountImpl((args[0].value as String).getOrThrow()))
        }
        if (args.size == 2) {
            return Some(BankAccountImpl((args[0].value as String).getOrThrow(), (args[1].value as Float64).getOrThrow()))
        }
        None
    }
}

@Actor
public class BankAccountImpl <: BankAccount {
    private let name: String
    private var balance: Float64

    static init() {
        ActorCluster.registerSpawningFunc<BankAccount>(BankAccount.typeName(), BankAccount.spawnWith)
        ActorCluster.registerSpawnParameterType<String>("String")
        ActorCluster.registerSpawnParameterType<Float64>("Float64")
    }

    public init(name: String, initialBalance: Float64) {
        this.name = name
        this.balance = initialBalance
    }

    public init(name: String) {
        this.name = name
        this.balance = 0.0
    }

    public init() {
        this.name = "Unknown"
        this.balance = 0.0
    }

    @Receiver
    public func deposit(amount: Float64): Bool {
        balance += amount
        true
    }

    @Receiver
    public func withdraw(amount: Float64): Bool {
        if (balance < amount) {
            return false
        }
        balance -= amount
        true
    }

    @Receiver
    public func getBalance(): Float64 {
        balance
    }
}