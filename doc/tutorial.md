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


# Local Actors

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

It is also possible for users to restrict the ways in which a receiver can be called by providing the `mode` option
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
    public func transfer(fromAccount: String, toAccount: String, amount: Float64): Bool

    @Receiver
    public func getBalance(accountId: String): Float64

    @Receiver
    public func createAccount(accountId: String, initialBalance: Float64): Bool
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
    public func transfer(fromAccount: String, toAccount: String, amount: Float64): Bool {
        let fromBalance = accounts.get(fromAccount).getOrElse(0.0)
        if (fromBalance < amount) {
            throw InsufficientFundsException(fromAccount)
        }

        let toBalance = accounts.get(toAccount).getOrElse(0.0)
        accounts.put(fromAccount, fromBalance - amount)
        accounts.put(toAccount, toBalance + amount)
        true
    }

    @Receiver
    public func getBalance(accountId: String): Float64 {
        accounts.get(accountId).getOrElse(0.0)
    }

    @Receiver
    public func createAccount(accountId: String, initialBalance: Float64): Bool {
        accounts.put(accountId, initialBalance)
        true
    }
}
```

## ActorHost

To manage distributed actors, you need an actor host and client. The actor host handles actor registration, and the actor client provides remote communication:

```cangjie
// Create an actor host (implementation depends on your distributed setup)
let actorHost: ActorHost

// Create and register the actor
let bankService = BankServiceImpl()
let registered = actorHost.register("bank-service", bankService)
if (!registered) {
    println("Failed to register bank service")
    return
}
```

## Actor Client and Remote Actor Communication

```cangjie
// Create an actor client for remote communication
let actorClient: ActorClient
```

To communicate with remote actors, you use an `ActorProxy`:

```cangjie
// Create a proxy to communicate with the remote actor
let bankProxy = ActorProxy("bank-service", actorClient)

// Call remote methods - these return DistributedFuture objects
let createFut: DistributedFuture = bankProxy.ask("createAccount", [
    "account1".serialize(),
    1000.0.serialize()
])

let transferFut: DistributedFuture = bankProxy.ask("transfer", [
    "account1".serialize(),
    "account2".serialize(),
    500.0.serialize()
])

let balanceFut: DistributedFuture = bankProxy.ask("getBalance", [
    "account1".serialize()
])

// Wait for operations to complete
createFut.get()
transferFut.get()
let balance = Float64.deserialize(balanceFut.get())
println("Account1 balance: ${balance}") // Output: 500.0
```

## Tell Mode for Distributed Actors

You can also use Tell mode for fire-and-forget operations in distributed actors:

```cangjie
// Tell mode - no return value, no synchronization
bankProxy.tell("createAccount", [
    "account3".serialize(),
    2000.0.serialize()
])
```


## Actor Discovery

You can discover and list all registered actors in the corresponding host:

```cangjie
// Find a specific actor
let actorInfo = actorClient.find("bank-service")
match (actorInfo) {
    case Some(info) => {
        println("Found actor: ${info.name}")
        println("Description: ${info.metadata.description}")
    }
    case None => println("Actor not found")
}

// List all actors registered with this host
let allActors = actorClient.findAll()
for (info in allActors) {
    println("Actor: ${info.name} - ${info.metadata.description}")
}
```

## Key Differences from Local Actors

1. **Serialization**: All parameters and return values must be serializable
2. **Network Communication**: Calls go over the network, so they have higher latency
3. **Actor Discovery**: You need to register actors with an actor host and use proxies for communication
4. **No Direct References**: You cannot hold direct references to remote actors

Distributed actors provide a powerful abstraction for building scalable, fault-tolerant distributed systems while maintaining the simplicity and safety guarantees of the actor model.

# Using the TCPActorSystem

The TCPActorSystem provides a production-ready implementation of the distributed actor system using TCP sockets for network communication. This section shows how to set up and use the TCP-based distributed actor system.

## Setting Up TCP Actor Host

To create a TCP actor host that can accept connections from remote clients:

```cangjie
import actors.tcp_actor_system.*

// Create a TCP actor host that listens on port 8080
let tcpHost = TCPActorHost(bindAt: 8080)

// Start the server to accept client connections
let serverFuture = tcpHost.serve()

// Register actors with the host
let bankService = BankServiceImpl()
tcpHost.register("bank-service", bankService)

println("TCP Actor Host is running on port 8080")
```

## Setting Up TCP Actor Client

To create a TCP actor client that connects to a remote TCP actor host:

```cangjie
import actors.tcp_actor_system.*

// Create a TCP actor client that connects to localhost:8080
let tcpClient = TCPActorClient(id: "client-1", addr: "localhost", port: 8080)

// Create a proxy for remote communication
let bankProxy = ActorProxy("bank-service", tcpClient)

// Use the proxy to make remote calls
let createFut: DistributedFuture = bankProxy.ask("createAccount", [
    "alice".serialize(),
    1000.0.serialize()
])

// Wait for the operation to complete
createFut.get()
println("Account created successfully")
```

## Complete TCP Actor System Example

Here's a complete example showing both host and client sides:

### Host Side (Server)

```cangjie
package tcpActorHostDemo

import std.collection.*
import actors.*
import actors.macros.*
import actors.distributed.*
import actors.tcp_actor_system.*

import encoding.json.*
import serialization.serialization.*

@ActorInterface[distributed: true, description: "Bank service for account management"]
public interface BankService {
    @Receiver[description: "Transfer money between accounts"]
    public func transfer(fromAccount: String, toAccount: String, amount: Float64): Bool

    @Receiver[description: "Get account balance"]
    public func getBalance(accountId: String): Float64

    @Receiver[description: "Create a new account"]
    public func createAccount(accountId: String, initialBalance: Float64): Bool
}

@Actor
public class BankServiceImpl <: BankService {
    private let accounts = ConcurrentHashMap<String, Float64>()

    public init() {}

    @Receiver
    public func transfer(fromAccount: String, toAccount: String, amount: Float64): Bool {
        let fromBalance = accounts.get(fromAccount).getOrElse(0.0)
        if (fromBalance < amount) {
            throw InsufficientFundsException(fromAccount)
        }

        let toBalance = accounts.get(toAccount).getOrElse(0.0)
        accounts.put(fromAccount, fromBalance - amount)
        accounts.put(toAccount, toBalance + amount)
        true
    }

    @Receiver
    public func getBalance(accountId: String): Float64 {
        accounts.get(accountId).getOrElse(0.0)
    }

    @Receiver
    public func createAccount(accountId: String, initialBalance: Float64): Bool {
        accounts.put(accountId, initialBalance)
        true
    }
}

public class InsufficientFundsException <: Exception {
    public init(accountId: String) {
        super("Insufficient funds in account: ${accountId}")
    }
}

main() {
    // Create and start the TCP actor host
    let tcpHost = TCPActorHost(bindAt: 8080)
    let serverFuture = tcpHost.serve()

    // Register the bank service
    let bankService = BankServiceImpl()
    tcpHost.register("bank-service", bankService)

    println("TCP Actor Host is running on port 8080")
    println("Press Ctrl+C to stop the server")

    // Keep the server running
    serverFuture.get()
}
```

### Client Side

```cangjie
package tcpActorClientDemo

import std.collection.*
import actors.*
import actors.distributed.*
import actors.tcp_actor_system.*
import encoding.json.*
import serialization.serialization.*

main() {
    // Connect to the TCP actor host
    let tcpClient = TCPActorClient(id: "client-1", addr: "localhost", port: 8080)
    let bankProxy = ActorProxy("bank-service", tcpClient)

    try {
        // Create accounts
        bankProxy.ask("createAccount", ["alice".serialize(), 1000.0.serialize()]).get()
        bankProxy.ask("createAccount", ["bob".serialize(), 500.0.serialize()]).get()

        // Transfer money
        bankProxy.ask("transfer", [
            "alice".serialize(),
            "bob".serialize(),
            300.0.serialize()
        ]).get()

        // Check balances
        let aliceBalance = Float64.deserialize(bankProxy.ask("getBalance", ["alice".serialize()]).get())
        let bobBalance = Float64.deserialize(bankProxy.ask("getBalance", ["bob".serialize()]).get())

        println("Alice balance: ${aliceBalance}") // 700.0
        println("Bob balance: ${bobBalance}")     // 800.0

    } catch (e: RemoteReceiverException) {
        println("Remote operation failed: ${e.message}")
    } catch (e: Exception) {
        println("Unexpected error: ${e.message}")
    } finally {
        // Close the client connection
        tcpClient.close()
    }
}
```


## Actor Discovery with TCP Actor System

You can discover and list all registered actors in the corresponding TCP host:

```cangjie
// Find a specific actor
let actorInfo = tcpClient.find("bank-service")
match (actorInfo) {
    case Some(info) => {
        println("Found actor: ${info.name}")
        println("Description: ${info.metadata.description}")
        println("Receiver count: ${info.metadata.receivers.size}")
    }
    case None => println("Actor not found")
}

// List all actors registered with this TCP host
let allActors = tcpClient.findAll()
for (info in allActors) {
    println("Actor: ${info.name} - ${info.metadata.description}")
}
```

## Tell Mode with TCP Actor System

You can use Tell mode for fire-and-forget operations:

```cangjie
// Tell mode - no return value, no synchronization
bankProxy.tell("createAccount", [
    "charlie".serialize(),
    2000.0.serialize()
])

// The operation is queued but we don't wait for completion
println("Account creation request sent")
```

## Logging Configuration

The TCP actor system provides configurable logging:

```cangjie
import std.log.*

// Configure logging for the TCP actor system
TCPActorSystem.logger = SimpleLogger()

// Or use a custom logger
let customLogger = CustomLogger()
TCPActorSystem.logger = customLogger
```

## Key Features of TCP Actor System

1. **Reliable Communication**: TCP provides reliable, ordered message delivery
2. **Concurrent Connections**: Supports multiple concurrent client connections
3. **Logging**: Built-in logging for debugging and monitoring

## Best Practices

1. **Connection Management**: Always close client connections when done
2. **Resource Cleanup**: Properly shut down the host when the application exits
3. **Logging**: Use appropriate logging levels for production vs development
4. **Serialization**: Ensure all data types used in remote calls are serializable

The TCP actor system provides a robust foundation for building distributed actor applications with reliable network communication.

# Using MCP extension and CangjieMagic

The MCP (Model Context Protocol) extension combined with CangjieMagic provides a powerful way to create AI-powered applications that can interact with distributed actor systems. This section shows how to build intelligent agents that can discover and use actor services through natural language.

## Overview

CangjieMagic is a framework that enables AI agents to interact with external tools and services. When combined with the MCP extension, it allows AI agents to automatically discover and invoke distributed actor receiver functions as tools, creating a seamless bridge between natural language processing and distributed actor systems.

## Setting Up CangjieMagic with MCP

### Dependencies

First, add the required dependencies to your `cjpm.toml`:

```toml
[dependencies]
  [dependencies.actors]
    git = "git@github.com:Huawei-Edinburgh-Programming-Languages/distributed-actors.git"
    branch = "hmos_5.0.5"
    version = "1.0.0"
  [dependencies.magic]
    git = "https://gitcode.com/Cangjie-TPC/CangjieMagic.git"
    tag = "harmony_os_edition"
    version = "1.0.0"
```

### Basic Agent Setup

```cangjie
import magic.prelude.*
import magic.dsl.*
import magic.config.Config
import actors.distributed.mcp.ActorMCPClient
import actors.tcp_actor_system.*

const PROMPT = """
You are an assistant that looks at what tools the MCP server has and dispatches corresponding requests from the user to the correct tool.

Be proactive in asking for any missing details and aim to make the process as smooth and clear as possible.
"""

@agent[
    model: "deepseek:deepseek-chat",
]
class MCPAgent {
    @prompt(PROMPT)
}

public class AgentManager {
    static init() {
        Config.env["DEEPSEEK_API_KEY"] = "your-api-key-here"
    }

    private let agent: MCPAgent
    private let mcpClient = ActorMCPClient()
    private let conversation = Conversation()

    init() {
        agent = MCPAgent()
    }

    func addActorClient(client: TCPActorClient): Unit {
        mcpClient.addActorClient(client)
        agent.toolManager.addTools(mcpClient.getTools())
    }

    func removeActorClient(client: TCPActorClient): Unit {
        mcpClient.removeActorClient(client.id)
        agent.toolManager.clear()
        agent.toolManager.addTools(mcpClient.getTools())
    }

    func chat(userInput: String): String {
        let res = agent.chat(AgentRequest(userInput.trimAscii(), conversation: conversation))
        conversation.addChatRound(res.execution.chatRound)
        res.content
    }
}
```

## Complete Example: AI-Powered Assistant

Here's a complete example showing how to build an AI assistant that can interact with calendar and meeting room services:

### Calendar Service

```cangjie
package demo.services

import std.collection.*
import actors.*
import actors.macros.*
import actors.distributed.*

struct Event <: ToString {
    public Event(
        public let title: String,
        public let date: String,
        public let startTime: String,
        public let endTime: String
    ) {}

    public func toString(): String {
        return "Event(title: ${title}, date: ${date}, startTime: ${startTime}, endTime: ${endTime})"
    }
}

@ActorInterface[
    distributed: true,
    description: "Calendar service for managing events"
]
public interface CalendarService {
    @Receiver[description: "Adds an event to the calendar"]
    func addToCalendar(title: String, date: String, startTime: String, endTime: String): Bool

    @Receiver[description: "Checks if the given time slot is available. Returns true if it is, false otherwise."]
    func isAvailable(date: String, startTime: String, endTime: String): Bool

    @Receiver[description: "Returns all events in the calendar"]
    func getEvents(): String
}

@Actor
public class CalendarImpl <: CalendarService {
    private let events = ArrayList<Event>()

    @Receiver
    public func addToCalendar(title: String, date: String, startTime: String, endTime: String): Bool {
        events.append(Event(title, date, startTime, endTime))
        return true
    }

    @Receiver
    public func isAvailable(date: String, startTime: String, endTime: String): Bool {
        for (evt in events) {
            if (date == evt.date && evt.startTime >= startTime && evt.endTime <= endTime) {
                return false
            }
        }
        return true
    }

    @Receiver
    public func getEvents(): String {
        events.toString()
    }
}
```

### Meeting Room Service

```cangjie
package demo.services

import std.collection.*

struct Booking <: ToString {
    Booking(
        let date: String,
        let startTime: String,
        let endTime: String
    ) {}

    public func toString(): String {
        return "Booking(date: ${date}, startTime: ${startTime}, endTime: ${endTime})"
    }
}

struct Room <: ToString {
    public let name: String
    private let bookings = ArrayList<Booking>()

    public init(name: String) {
        this.name = name
    }

    public func book(date: String, startTime: String, endTime: String): Bool {
        if (isAvailable(date, startTime, endTime)) {
            bookings.append(Booking(date, startTime, endTime))
            return true
        }
        return false
    }

    public func isAvailable(date: String, startTime: String, endTime: String): Bool {
        for (booking in bookings) {
            if (date == booking.date && startTime >= booking.startTime && endTime <= booking.endTime) {
                return false
            }
        }
        return true
    }

    public func toString(): String {
        return "Room(name: ${name}, bookings: ${bookings})"
    }
}

@ActorInterface[
    distributed: true,
    description: "Meeting room booking service"
]
public interface MeetingRoomService {
    @Receiver[description: "Book a meeting room on a given date and time. Returns true if the booking is successful, false otherwise."]
    func book(roomName: String, date: String, startTime: String, endTime: String): Bool

    @Receiver[description: "Check if a meeting room is available on a given date and time. Returns true if the room is available, false otherwise."]
    func isAvailable(roomName: String, date: String, startTime: String, endTime: String): Bool

    @Receiver[description: "Get all available meeting rooms for a given date and time. Returns a list of available meeting rooms."]
    func getAvailableRooms(date: String, startTime: String, endTime: String): String

    @Receiver[description: "Get all bookings. Returns a list of bookings."]
    func getAllBookings(): String
}

@Actor
public class MeetingRoomServiceImpl <: MeetingRoomService {
    private let rooms = HashMap<String, Room>()

    public init() {
        rooms.put("Room 1", Room("Room 1"))
        rooms.put("Room 2", Room("Room 2"))
        rooms.put("Room 3", Room("Room 3"))
    }

    @Receiver
    public func book(roomName: String, date: String, startTime: String, endTime: String): Bool {
        rooms[roomName].book(date, startTime, endTime)
    }

    @Receiver
    public func isAvailable(roomName: String, date: String, startTime: String, endTime: String): Bool {
        rooms[roomName].isAvailable(date, startTime, endTime)
    }

    @Receiver
    public func getAvailableRooms(date: String, startTime: String, endTime: String): String {
        var result = "["
        for ((_, room) in rooms) {
            if (room.isAvailable(date, startTime, endTime)) {
                result += room.name + ","
            }
        }
        result + "]"
    }

    @Receiver
    public func getAllBookings(): String {
        rooms.map({ name, room => room.toString() }).toString()
    }
}
```

### AI Assistant Application

```cangjie
package demo.assistant

import magic.prelude.*
import magic.dsl.*
import magic.config.Config
import actors.distributed.mcp.ActorMCPClient
import actors.tcp_actor_system.*

const PROMPT = """
You are an intelligent assistant that helps users manage their calendar and book meeting rooms.
You have access to calendar and meeting room services through various tools.

When users ask you to:
- Schedule events: Use the calendar service to add events
- Check availability: Check both calendar and meeting room availability
- Book meeting rooms: Use the meeting room service to make bookings
- View schedules: Retrieve and display calendar events and room bookings

Always be helpful, ask for clarification when needed, and provide clear responses.
"""

@agent[model: "deepseek:deepseek-chat"]
class AssistantAgent {
    @prompt(PROMPT)
}

public class AssistantManager {
    static init() {
        Config.env["DEEPSEEK_API_KEY"] = "your-api-key-here"
    }

    private let agent: AssistantAgent
    private let mcpClient = ActorMCPClient()
    private let conversation = Conversation()

    init() {
        agent = AssistantAgent()
    }

    func connectToServices(): Unit {
        // Connect to calendar service
        let calendarClient = TCPActorClient("calendar", "localhost", 52185)
        mcpClient.addActorClient(calendarClient)

        // Connect to meeting room service
        let meetingRoomClient = TCPActorClient("meeting room", "localhost", 52186)
        mcpClient.addActorClient(meetingRoomClient)

        // Add all available tools to the agent
        agent.toolManager.addTools(mcpClient.getTools())
    }

    func chat(userInput: String): String {
        let res = agent.chat(AgentRequest(userInput.trimAscii(), conversation: conversation))
        conversation.addChatRound(res.execution.chatRound)
        res.content
    }
}
```

### Using the AI Assistant

```cangjie
package demo.main

import magic.prelude.*
import magic.dsl.*
import magic.config.Config
import actors.distributed.mcp.ActorMCPClient
import actors.tcp_actor_system.*

main() {
    // Initialize the assistant manager
    let assistantManager = AssistantManager()

    try {
        // Connect to services
        println("Connecting to services...")
        assistantManager.connectToServices()
        println("Services connected!")

        // Example interactions
        let response1 = assistantManager.chat("Schedule a meeting with John tomorrow at 2 PM")
        println("Assistant: ${response1}")

        let response2 = assistantManager.chat("Book Room 1 for a team meeting on Friday")
        println("Assistant: ${response2}")

        let response3 = assistantManager.chat("What meetings do I have today?")
        println("Assistant: ${response3}")

    } catch (e: Exception) {
        println("Error: ${e.message}")
    }
}
```