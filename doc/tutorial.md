# Actor Model Overview

The Actor model is a concurrency programming model designed to simplify the handling of concurrent tasks.

In this model, an *actor* is the basic unit of concurrency with the following characteristics:

- Each actor has its own independent execution thread.
- Each actor has its own member variables.
- These variables can only be accessed and modified by the actor's own thread.
- An actor includes a special kind of member function called *receivers*. When a receiver is called, the call will be added to a queue and executed in order on the actor's thread.
- Once there are no references pointing to the actor and all receivers have been executed, the actor can be reclaimed by the system.

> **Note:**
> The third characteristic of the Actor model has not yet been enforced by the language, so the member variables of an *actor* do not yet provide full concurrency safety. In the future, a new type system may address this issue, ensuring the concurrency safety of member variables.

The Actor model is primarily used for concurrent access and modification of the same object in multi-threaded environments. For example, a bank account object may be accessed simultaneously by multiple threads for operations like deposits or withdrawals, potentially leading to data races without proper synchronization.

```cangjie
public class Account {
    public Account(
        private let name: String,
        private var balance: Float64
    ) {}

    public func deposit(amount: Float64): Unit {
        balance += amount
    }

    public func withdraw(amount: Float64): Unit {
        if (balance < amount) {
            throw BalanceNotEnoughException(name)
        }
        balance -= amount
    }

    public func getBalance(): Float64 {
        balance
    }
}
```

Simultaneous access and modification of the object in a multi-threaded environment can lead to data races:

```cangjie
let account = Account("Steven", 0.0)
spawn {
    account.deposit(1000.0)
}
spawn {
    account.withdraw(2000.0)
}
```

Correctly using the Actor model can make concurrent programming simpler and more efficient.


# Actor Declaration

Using the bank account example above, to avoid thread safety issues, we can design an *actor* specifically for handling account operations using the Actor model.

First, we can annotate the `Account` class with the [@Actor](./macros/macros_package_api/macros_package_macros.md#actor-macro) macro to mark it as an actor. Then, we use the [@Receiver](./macros/macros_package_api/macros_package_macros.md#receiver-macro) macro to mark the deposit, withdraw, and getBalance functions:


```cangjie
@Actor
public class Account {
    public Account(
        private let name: String,
        private var balance: Float64
    ) {}

    @Receiver
    public func deposit(amount: Float64): Unit {
        balance += amount
    }

    @Receiver
    public func withdraw(amount: Float64): Unit {
        if (balance < amount) {
            throw BalanceNotEnoughException(name)
        }
        balance -= amount
    }

    @Receiver
    public func getBalance(): Float64 {
        balance
    }
}
```

For the rules and limitations of the [@Actor](./macros/macros_package_api/macros_package_macros.md#actor-macro) and [@Receiver](./macros/macros_package_api/macros_package_macros.md#receiver-macro) macros, please refer to the corresponding documentation.

We can create an instance of the `Account` class by calling its constructor, for example:

```cangjie
let stevenAccount: Account = Account("Steven", 0.0)
```

When creating an `Account` instance, the system will also automatically create an associated execution thread for that instance.

## Receivers

Unlike regular functions, the invocation of a receiver is asynchronous and it returns an [ActorFuture<T>](./actors_package_api/actors_package_classes.md#class-actorfuture) object. This object allows you to wait for the completion of the receiver and obtain the result, where `T` is the return type of the receiver. For example, calling `getBalance` will return an [ActorFuture<Float64>](./actors_package_api/actors_package_classes.md#class-actorfuture) object:

```cangjie
let fut: ActorFuture<Float64> = stevenAccount.getBalance()
```

When a receiver is called, the call is added to a queue and executed sequentially on the actor's dedicated thread.

Subsequently, we can block the current thread by calling the `get` function of the [ActorFuture<T>](./actors_package_api/actors_package_classes.md#class-actorfuture) object, which will wait until the `steven.getBalance()` receiver completes and returns a value of type `T`.

```cangjie
let stevenBalance: Float64 = fut.get()
```

The value of `stevenBalance` will depend on the value of the `balance` member variable at the time `steven.getBalance()` is executed.

In a multi-threaded environment, although receivers may be called concurrently, they are executed sequentially within the same actor instance, preventing any interleaved execution. Therefore, we can think of them as atomic functions of this actor, which helps avoid data races.

```cangjie
let account = Account("Steven", 0.0)
spawn {
    account.deposit(1000.0)
}
spawn {
    account.withdraw(2000.0)
}
```

> **Note:**
> Currently, the member variables of an actor do not provide full concurrency safety. For example, in the following case, the public member variables can still be accessed and modified directly from outside:
> ```cangjie
> @Actor
> public class MyActor {
>     public var x: Int64 = 0
> }
>
> let myActor = MyActor()
> spawn {
>     myActor.x = 2
> }
> spawn {
>     myActor.x = 3
> }
> ```
>
> In the future, a new type system could address this issue, ensuring the concurrency safety of member variables.

## Execution Order of Receivers

When calling two receivers on the same actor within the same thread, these functions will be executed in the order they were called. For example:

```cangjie
func foo() {
    let account = Account("Federico", 0.0)
    account.deposit(1000.0)
    account.withdraw(500.0)
    let fut = account.getBalance()
    println(fut.get())
}
```

In the absence of other threads, this code will always output the following, ensuring that `account.withdraw(500.0)` will not execute before `account.deposit(1000.0)`:

```text
500.0
```

However, when different threads call receivers of the same actor, the execution order is not guaranteed. For example:

```cangjie
let account = Account("Steven", 0.0)
spawn {
    account.deposit(1000.0)
}
spawn {
    account.withdraw(500.0)
}
```

The following execution orders are possible:

```text
account.deposit(1000.0)
account.withdraw(500.0)
```

```text
account.withdraw(500.0)
account.deposit(1000.0)
```

## Exceptions Thrown by Receivers

Any uncaught exceptions or errors thrown by a receiver will propagate to the corresponding [ActorFuture\<T>](./actors_package_api/actors_package_classes.md#class-actorfuture) object, similar to how `spawn` handles them.

Continuing with the `Account` example, if the `balance` in the `withdraw(amount)` function is insufficient, it will throw a `BalanceNotEnoughException`:

```cangjie
@Receiver
public func withdraw(amount: Float64): Unit {
    if (balance < amount) {
        throw BalanceNotEnoughException(name)
    }
    balance -= amount
}
```

The thrown exception will be passed to the corresponding [ActorFuture](./actors_package_api/actors_package_classes.md#class-actorfuture) object, and when its `get` function is called, the same exception will be thrown:

```cangjie
let account = Account("Hamid", 0.0)
let fut: ActorFuture<Unit> = account.withdraw(500.0)
try {
    let res = fut.get()
} catch (e: BalanceNotEnoughException) {
    println("fut.get() throws BalanceNotEnoughException")
    println()
    e.printStackTrace()
}
```

Since `account.withdraw(500.0)` threw a `BalanceNotEnoughException`, calling `fut.get()` will also throw the same exception. The output will be as follows:

```text
fut.get() throws BalanceNotEnoughException

An exception has occurred:
Exception: Balance for account Hamid is not enough.
         at default.BalanceNotEnoughException::init(std.core::String)(/home/.../main.cj:6)
         at default.Account::withdraw::lambda.0()(/home/.../main.cj:25)
         at actors.ActorFuture<...>::execute()(stdx/actors/actor_future.cj:90)
         at actors.SequentialDispatcher::startActorLoop::lambda.0()(stdx/actors/actors.cj:46)
```

When a receiver throws an exception, the actor's dedicated thread will proceed to execute the next receiver call in the queue:

```cangjie
let account = Account("Hamid", 0.0)
let fut: ActorFuture<Unit> = account.withdraw(500.0)
let fut2: ActorFuture<Float64> = account.getBalance()
try {
    let res = fut.get()
} catch (e: BalanceNotEnoughException) {
    println("fut.get() throws BalanceNotEnoughException")
    println()
    e.printStackTrace()
    println()
}
let res = fut2.get()
println("Balance = ${res}")
```

After `account.withdraw(500.0)` is executed and throws an exception within the actor's thread, the thread will continue to execute `account.getBalance()`. The output will be as follows:

```text
fut.get() throws BalanceNotEnoughException

An exception has occurred:
Exception: Balance for account Hamid is not enough.
         at default.BalanceNotEnoughException::init(std.core::String)(/home/.../main.cj:6)
         at default.Account::withdraw::lambda.0()(/home/.../main.cj:25)
         at actors.ActorFuture<...>::execute()(stdx/actors/actor_future.cj:90)
         at actors.SequentialDispatcher::startActorLoop::lambda.0()(stdx/actors/actors.cj:46)

Balance = 0.0
```

## Lifecycle of an actor

An actor can be garbage collected when there are no references pointing to it, and there are no pending receiver calls to be executed:

```cangjie
func test(): Unit {
    let account = Account("Ziming", 0.0)
    let fut = account.deposit(5.0)
    println(fut.get())
}

func bar() {
    test()
    // account could be reclaimed
}
```

After the `test()` function returns, since there are no remaining references to the account and no pending receivers (because we awaited the result of `account.deposit(5.0)` inside `test()`), the actor referenced by account and its dedicated execution thread will be reclaimed by the system.


## Priority between Receivers

Users can specify a priority for receivers, allowing higher-priority receivers to be executed before lower-priority ones.

First, users need to enable receiver priority by adding the `[enableReceiverPriority: true]` annotation to the class. For example:

```cangjie
@Actor[enableReceiverPriority: true]
public class Account {
    public Account(
        private let name: String,
        private var balance: Float64
    ) {}
}
```

If `enableReceiverPriority` is set to `false` or if the `@Actor` macro does not include this option, it means that receiver priorities are not enabled.

Next, we can assign a default priority level to each receiver. Currently, we provide 10 priority levels, represented by integers from 1 to 10. The higher the number, the higher the priority. If the priority option is not set, the default value is 5:

```cangjie
@Actor[enableReceiverPriority: true]
public class Account {
    ...

    @Receiver[priority: 10]
    public func deposit(amount: Float64): Unit {
        balance += amount
    }

    @Receiver[priority: 1]
    public func withdraw(amount: Float64): Unit {
        if (balance < amount) {
            throw BalanceNotEnoughException(name)
        }
        balance -= amount
    }

    @Receiver
    public func getBalance(): Float64 {
        balance
    }
}
```

By increasing the priority of `deposit` and lowering the priority of `withdraw`, when there are many `deposit` and `withdraw` calls simultaneously, `deposit` will be prioritized, reducing the chances of `withdraw` throwing a `BalanceNotEnoughException`.

Additionally, when calling a receiver, one can override its priority by passing an extra named parameter, *priority*, at the end of the argument list:

```cangjie
func foo(account: Account) {
    account.getBalance()
    account.withdraw(100.0, priority: 10)
}
```

The call to `account.withdraw(100.0, priority: 10)` may be executed before `account.getBalance()`.

## Deadlock

Finally, please note that calling `fut.get()` within an actor's receiver may result in a deadlock. For example:

```cangjie
@Actor
class MyActor {
    @Receiver
    func foo(): Int64 {
        let fut = this.bar()
        // this will deadlock
        fut.get()
    }

    @Receiver
    func bar(): Int64 {
        42
    }
}
```

Calling `this.bar()` will add the receiver to the end of the queue. However, blocking within a receiver causes the actor's thread to block, so `bar()` will never be executed. As a result, calling `fut.get()` inside `foo()` will block indefinitely.

## Calling Receivers in Tell mode

As discussed previously, receivers return an `ActorFuture` that allows the caller to wait for the receiver call to return and
to obtain the returned value. We say that these calls are in "Ask" mode, given that the caller expects the actor to reply in the form of a completed `ActorFuture`.
However, in some scenarios, the caller may not need to synchronize with the actor nor need the result of the receiver.
In this context, one
might want to avoid the overhead introduced by creating an `ActorFuture`, and call the receiver in "Tell" mode.
Calling a receiver in "Tell" mode does not create any `ActorFuture`, returns `Unit`, and requires an additional parameter named
`tell` that only accepts the value `Tell.True`:

```cangjie
func foo(account: Account) {
    let _: Unit = account.withdraw(100.0, priority: 10, tell: True)
}
```

It is also possible to for users to restrict the ways in which a receiver can be called by providing the `mode` option
to the `@Receiver` macro:

```cangjie
@Actor
public class Account {
    ...

    @Receiver[mode: TellOnly]
    public func deposit(amount: Float64): Unit {
        balance += amount
    }

    @Receiver[mode: AskAndTell]
    public func withdraw(amount: Float64): Unit {
        if (balance < amount) {
            throw BalanceNotEnoughException(name)
        }
        balance -= amount
    }

    @Receiver[mode: AskOnly]
    public func getBalance(): Float64 {
        balance
    }
}
```

In the above example,

- The function `getBalance` can only be called in "Ask" mode.
- The function `deposit(Float64)` can only be called in "Tell" mode.
- The function `withdraw(Float64)` can be called both in "Ask" and "Tell" modes.

Note that the sequential guarantees that apply to receiver calls in "Ask" mode also apply to receiver calls in "Tell" mode.

## Complete example

<!-- compile -->

```cangjie
package actorDemo

import std.collection.ArrayList

import actors.*
import actors.macros.*

@Actor[enableReceiverPriority: true]
public class Account {
    public Account(
        private let name: String,
        private var balance: Float64
    ) {}

    @Receiver[priority: 10]
    public func deposit(amount: Float64): Unit {
        balance += amount
    }

    @Receiver[priority: 1]
    public func withdraw(amount: Float64): Unit {
        if (balance < amount) {
            throw BalanceNotEnoughException(name)
        }
        balance -= amount
    }

    @Receiver
    public func getBalance(): Float64 {
        balance
    }
}

public class BalanceNotEnoughException <: Exception {
    public init(name: String) {
        super("Balance for account ${name} is not enough.")
    }
}

main() {
    let account = Account("Steven", 0.0)
    let futs = ArrayList<Future<Unit>>()
    for (_ in 0..100) {
        let fut1 = spawn {
            for (_ in 0..10) {
                account.deposit(1000.0)
            }
        }
        let fut2 = spawn {
            for (_ in 0..10) {
                account.withdraw(1000.0)
            }
        }
        futs.add(fut1)
        futs.add(fut2)
    }
    for (f in futs) {
        f.get()
    }
    println("Balance: ${account.getBalance().get()}")
}
```


# Distributed Actors

The actor model can be extended to work across multiple machines in a distributed system. In Cangjie, distributed actors allow you to create actors that can communicate with each other even when they're running on different nodes in a network.

## Actor Interfaces

To create distributed actors, you first need to define an *actor interface* using the [@ActorInterface](./macros/macros_package_api/macros_package_macros.md#actorinterface-macro) macro. This interface defines the contract that distributed actors must implement.

```cangjie
@ActorInterface[distributed: true]
public interface BankService {
    @Receiver
    public func transfer(fromAccount: String, toAccount: String, amount: Float64): Unit

    @Receiver
    public func getBalance(accountId: String): Float64

    @Receiver
    public func createAccount(accountId: String, initialBalance: Float64): Unit
}
```

The `distributed: true` option indicates that this is a distributed actor interface, which means it can be used for remote communication across the network.

## Implementing Distributed Actors

Once you have an actor interface, you can implement it using the [@Actor](./macros/macros_package_api/macros_package_macros.md#actor-macro) macro:

```cangjie
@Actor
public class BankServiceImpl <: BankService {
    private let accounts = ConcurrentHashMap<String, Float64>()

    public init() {}

    @Receiver
    public func transfer(fromAccount: String, toAccount: String, amount: Float64): Unit {
        let fromBalance = accounts.get(fromAccount).getOrElse(0.0)
        if (fromBalance < amount) {
            throw InsufficientFundsException(fromAccount)
        }

        let toBalance = accounts.get(toAccount).getOrElse(0.0)
        accounts.put(fromAccount, fromBalance - amount)
        accounts.put(toAccount, toBalance + amount)
    }

    @Receiver
    public func getBalance(accountId: String): Float64 {
        accounts.get(accountId).getOrElse(0.0)
    }

    @Receiver
    public func createAccount(accountId: String, initialBalance: Float64): Unit {
        accounts.put(accountId, initialBalance)
    }
}
```

## Actor System

To manage distributed actors, you need an actor system. The actor system handles actor registration, discovery, and remote communication:

```cangjie
import actors.*

// Create an actor system (implementation depends on your distributed setup)
let actorSystem: ActorSystem = createDistributedActorSystem()

// Create and register the actor
let bankService = BankServiceImpl()
let registered = actorSystem.register("bank-service", bankService)
if (!registered) {
    println("Failed to register bank service")
    return
}
```

## Remote Actor Communication

To communicate with remote actors, you use an `ActorProxy`:

```cangjie
// Create a proxy to communicate with the remote actor
let bankProxy = ActorProxy("bank-service", actorSystem)

// Call remote methods - these return ActorFuture objects
let createFut = bankProxy.post<Unit>("createAccount", [
    "account1".serialize(),
    1000.0.serialize()
])

let transferFut = bankProxy.post<Unit>("transfer", [
    "account1".serialize(),
    "account2".serialize(),
    500.0.serialize()
])

let balanceFut = bankProxy.post<Float64>("getBalance", [
    "account1".serialize()
])

// Wait for operations to complete
createFut.get()
transferFut.get()
let balance = balanceFut.get()
println("Account1 balance: ${balance}") // Output: 500.0
```

## Tell Mode for Distributed Actors

You can also use Tell mode for fire-and-forget operations in distributed actors:

```cangjie
// Tell mode - no return value, no synchronization
bankProxy.postMessage("createAccount", [
    "account3".serialize(),
    2000.0.serialize()
])
```

## Error Handling in Distributed Actors

Exceptions thrown by remote actors are wrapped in `RemoteReceiverException` and can be handled normally:

```cangjie
try {
    let fut = bankProxy.post<Unit>("transfer", [
        "account1".serialize(),
        "account2".serialize(),
        10000.0.serialize() // This will cause insufficient funds
    ])
    fut.get()
} catch (e: RemoteReceiverException) {
    println("Remote operation failed: ${e.message}")
} catch (e: Exception) {
    println("Unexpected error: ${e.message}")
}
```

## Actor Discovery

You can discover and list all registered actors in the system:

```cangjie
// Find a specific actor
let actorInfo = actorSystem.find("bank-service")
match (actorInfo) {
    case Some(info) => {
        let (name, metadata) = info
        println("Found actor: ${name}")
        println("Description: ${metadata.description}")
    }
    case None => println("Actor not found")
}

// List all actors
let allActors = actorSystem.findAll()
for ((name, metadata) in allActors) {
    println("Actor: ${name} - ${metadata.description}")
}
```

## Complete Distributed Example

```cangjie
package distributedBankDemo

import std.collection.*
import actors.*
import actors.macros.*

@ActorInterface[distributed: true]
public interface BankService {
    @Receiver
    public func transfer(fromAccount: String, toAccount: String, amount: Float64): Unit

    @Receiver
    public func getBalance(accountId: String): Float64

    @Receiver
    public func createAccount(accountId: String, initialBalance: Float64): Unit
}

@Actor
public class BankServiceImpl <: BankService {
    private let accounts = ConcurrentHashMap<String, Float64>()

    public init() {}

    @Receiver
    public func transfer(fromAccount: String, toAccount: String, amount: Float64): Unit {
        let fromBalance = accounts.get(fromAccount).getOrElse(0.0)
        if (fromBalance < amount) {
            throw InsufficientFundsException(fromAccount)
        }

        let toBalance = accounts.get(toAccount).getOrElse(0.0)
        accounts.put(fromAccount, fromBalance - amount)
        accounts.put(toAccount, toBalance + amount)
    }

    @Receiver
    public func getBalance(accountId: String): Float64 {
        accounts.get(accountId).getOrElse(0.0)
    }

    @Receiver
    public func createAccount(accountId: String, initialBalance: Float64): Unit {
        accounts.put(accountId, initialBalance)
    }
}

public class InsufficientFundsException <: Exception {
    public init(accountId: String) {
        super("Insufficient funds in account: ${accountId}")
    }
}

main() {
    // In a real distributed system, this would be provided by your infrastructure
    let actorSystem: ActorSystem = createDistributedActorSystem()

    // Register the bank service
    let bankService = BankServiceImpl()
    actorSystem.register("bank-service", bankService)

    // Create a proxy for remote communication
    let bankProxy = ActorProxy("bank-service", actorSystem)

    // Perform banking operations
    bankProxy.post<Unit>("createAccount", ["alice".serialize(), 1000.0.serialize()]).get()
    bankProxy.post<Unit>("createAccount", ["bob".serialize(), 500.0.serialize()]).get()

    // Transfer money
    bankProxy.post<Unit>("transfer", [
        "alice".serialize(),
        "bob".serialize(),
        300.0.serialize()
    ]).get()

    // Check balances
    let aliceBalance = bankProxy.post<Float64>("getBalance", ["alice".serialize()]).get()
    let bobBalance = bankProxy.post<Float64>("getBalance", ["bob".serialize()]).get()

    println("Alice balance: ${aliceBalance}") // 700.0
    println("Bob balance: ${bobBalance}")     // 800.0
}
```

## Key Differences from Local Actors

1. **Serialization**: All parameters and return values must be serializable
2. **Network Communication**: Calls go over the network, so they have higher latency
3. **Error Handling**: Exceptions are wrapped in `RemoteReceiverException`
4. **Actor Discovery**: You need to register actors with an actor system and use proxies for communication
5. **No Direct References**: You cannot hold direct references to remote actors

Distributed actors provide a powerful abstraction for building scalable, fault-tolerant distributed systems while maintaining the simplicity and safety guarantees of the actor model.

