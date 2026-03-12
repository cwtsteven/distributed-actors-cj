package distributed_actors_example.common

import std.collection.*
import stdx.log.*
import std.io.*
import std.fs.*
import std.sync.*
import std.time.*

import actors.*
import actors.macros.*
import actors.distributed.*
import actors.tcp_actor_system.*

import stdx.encoding.json.*
import stdx.serialization.serialization.*

@ActorInterface[distributed: true, description: "Bank service"]
public interface BankAccount {
    @Receiver[description: "Deposit money into the account"]
    func deposit(amount: Float64): Bool

    @Receiver[description: "Withdraw money from the account"]
    func withdraw(amount: Float64): Bool

    @Receiver[description: "Get the balance of the account"]
    func getBalance(): Float64
}

@ActorInterface[distributed: true, enableReceiverPriority: true, description: "Balance reporter service"]
public interface BalanceReporter {
    @Receiver[priority: 10, description: "Store a balance snapshot"]
    func recordSnapshot(owner: String, balance: Float64): String

    @Receiver[priority: 1, description: "Get the latest balance snapshot"]
    func latestSnapshot(): String
}

@Actor
public class BankAccountImpl <: BankAccount {
    private let name: String
    private var balance: Float64

    public init(name: String, balance: Float64) {
        this.name = name
        this.balance = balance
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

@Actor[enableReceiverPriority: true]
public class BalanceReporterImpl <: BalanceReporter {
    private var latest: String = "No snapshots yet"

    @Receiver[priority: 10]
    public func recordSnapshot(owner: String, balance: Float64): String {
        latest = "${owner}: ${balance}"
        latest
    }

    @Receiver[priority: 1]
    public func latestSnapshot(): String {
        latest
    }
}
