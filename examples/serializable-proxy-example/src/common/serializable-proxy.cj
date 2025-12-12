package serializable_proxy_example.common

import std.collection.*
import std.log.*
import std.io.*
import std.fs.*
import std.sync.*
import std.time.*

import actors.*
import actors.macros.*
import actors.distributed.*
import actors.tcp_actor_system.*

import encoding.json.*
import serialization.serialization.*

@ActorInterface[distributed: true, description: "Bank service"]
public interface BankAccount {
    @Receiver[description: "Deposit money into the account"]
    func deposit(amount: Float64): Bool

    @Receiver[description: "Withdraw money from the account"]
    func withdraw(amount: Float64): Bool

    @Receiver[description: "Get the balance of the account"]
    func getBalance(): Float64

    @Receiver[description: ""]
    func transfer(to: BankAccount, amount: Float64): Bool
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

    @Receiver
    public func transfer(to: BankAccount, amount: Float64): Bool {
        if (amount > balance) {
            return false
        }
        balance -= amount
        (to as BankAccount).getOrThrow().deposit(amount)
        true
    }
}

// // user code
// public interface BankAccount {
//     type Proxy = BankAccountProxy
//     func deposit(amount: Double)
//     func transfer<T>(to: T, amount: Double) where T <: BankAccount
// }

// user code
// public class BankAccountImpl <: BankAccount {
//     var balance: Double = 0.0
//     func deposit(amount: Double) {
//         balance += amount
//     }
//     func transfer<T>(to: T, amount: Double) where T <: BankAccount {
//
//     }
// }

// // generated
// public class BankAccountProxy <: BankAccount {
//     func deposit(amount: Double) {
//         // remote
//     }
//     func transfer(to: BankAccount.Proxy, amount: Double) {
//         // remote
//     }
// }

// extend Proxy

// or
// // my lib
// interface Proxy<T> {}