<div align="center">
<h1>distributed-actors-cj</h1>
</div>

<p align="center">
<img alt="" src="https://img.shields.io/badge/release-v0.2.0-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjc-v1.0.5-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjcov-0.0%25-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/state-孵化/毕业-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/domain-OHOS/Cloud-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/points- ？/100-brightgreen" style="display: inline-block;" />
</p>

## Description

A distributed actor framework designed for the Cangjie programming language, providing actor-based concurrency and distributed computing capabilities, supporting both local and remote communication, and enabling integration with AI agents by exposing actors as tools under the MCP protocol.

## Features

- **Actor Programming Model**: Active object abstractions with asynchronous method calls
- **Distributed Actors**: Declarative syntax for defining distributed actor interfaces and implementations
- **TCP Actor System**: TCP-based distributed actor system implementation
- **TCP Cluster**: Cluster-based distributed actor system supporting multi-node deployment and automatic actor placement
- **Agent Integration**: Exposing actors as tools under MCP protocol

### Roadmap

- [x] Typed distributed actor proxy
- [x] Serializable proxy
- [ ] Short-cut receiver calls for co-located actors
- [ ] Message delivery semantics (at-least-once vs at-most-once)
- [ ] Retry mechanisms for failed message delivery
- [ ] Enhanced exception and error handling
- [ ] Reentrant actors
- [x] Cluster

## Project structure

### Source files directory

```shell
actors                   # Core actor programming model and local actor system
├── ActorFuture          # Asynchronous result handling
├── SequentialDispatcher # Thread-safe task execution
│
├── actors.distributed      # Distributed actor interfaces and metadata
│   ├── ActorHost           # Actor registration interface
│   ├── ActorClient         # Remote actor access interface
│   ├── ActorProxy          # Client-side proxy for remote actors
│   ├── DistributedFuture   # Distributed operation results
│   ├── ActorCluster
│   │
│   └── actors.distributed.mcp  # Model Context Protocol integration
│       ├── ActorMCPClient      # MCP client for AI agent integration
│       └── ReceiverTool        # MCP tool wrapper for actor receivers
│
├── actors.macros          # Compile-time actor and interface generation
│   ├── @Actor             # Transform classes into actors
│   ├── @ActorInterface    # Transform interfaces into actor interfaces
│   └── @Receiver          # Transform methods into receiver functions
│
├── actors.tcp_actor_system # TCP-based distributed actor implementation
    ├── TCPActorHost        # TCP-based actor host
    ├── TCPActorClient      # TCP-based actor client
    ├── TCPActorSystem      # Main TCP actor system configuration
    │
    └── actors.tcp_actor_system.cluster  # Cluster-based distributed actor system
        └── TCPCluster                   # Cluster manager (head server and worker nodes)
```

### APIs description

For a detailed API reference, please refer to [API Documentation](doc-en/apis.md).

## User manual

### Using Git Dependency (Recommended)

Add the following to your `cjpm.toml`:

```toml
[dependencies]
  actors = { git = "https://gitcode.com/Cangjie-TPC/distributed-actors-cj.git", branch = "main", version = "0.2.0" }
```

### Building

Before building the package, make sure you have done:
1. set up cangjie compiler, e.g. `source /path-to-cangjie-compiler/envsetup.sh`
2. set up the path to stdx, e.g. `export CANGJIE_STDX_PATH=/path-to-stdx-lib/dynamic/stdx`

```shell
# Build the package
make
```

```shell
# Build all examples
make example
```

### Testing

```shell
# Run all tests
make test
```

### Tutorial

A comprehensive tutorial can be found at [Tutorial](doc-en/tutorial.md).

### Quick examples

For more detailed examples please refers to

- **[Examples](examples/)**: Working examples demonstrating various features

#### Local Actor

```cangjie
import actors.*
import actors.macros.*

@Actor
public class Counter {
    private var value: Int64 = 0

    @Receiver
    public func increment(): Int64 {
        value += 1
        return value
    }

    @Receiver
    public func getValue(): Int64 {
        return value
    }
}

main() {
    let counter = Counter()
    let future = counter.increment()
    println("Counter value: ${future.get()}")
}
```

The execution result is as follows:

```shell
1
```

#### Distributed Actor

```cangjie
import std.collection.*

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

const PORT: UInt16 = 52165

main() {
    // Host side
    let tcpHost = TCPActorHost(addr: "localhost", bindAt: PORT)
    let serverFuture = tcpHost.serve() // start the server

    let bankAccount = BankAccountImpl("Steven", 0.0)
    tcpHost.export("Steven", bankAccount)

    // Client side
    let tcpClient = TCPActorClient.create("localhost", PORT)
    let proxy = tcpClient.getActor("Steven").getOrThrow()

    // Using untyped proxy
    proxy.ask("deposit", [100.0.serialize()]).get()
    let res = Float64.deserialize(proxy.ask("getBalance", []).get())
    println("Steven balance: ${res}") // 100.0

    // Using typed proxy
    let steven = BankAccount.getProxy(proxy)
    steven.deposit(100.0).get()
    let res2 = steven.getBalance().get()
    println("Steven balance: ${res2}") // 200.0
}
```

The execution result is as follows:

```shell
Steven balance: 100.0
Steven balance: 200.0
```

### AI Agent Integration

```cangjie
import magic.prelude.*
import magic.dsl.*
import magic.config.Config

import actors.distributed.mcp.*
import actors.tcp_actor_system.*

@agent[model: "deepseek:deepseek-chat"]
class AssistantAgent {
    @prompt("You are a helpful assistant that can interact with distributed services.")

    init(toolManager!: ToolManager) {
        __TOOL_MANAGER__ = Some(toolManager)
    }
}

main() {
    let toolManager = ActorToolManager()
    let agent = AssistantAgent(toolManager: toolManager)

    let tcpClient = TCPActorClient.create("localhost", 8080)
    toolManager.addActorClient(tcpClient)

    let response = agent.chat("Transfer $100 from Alice to Bob")
    println("Assistant: ${response}")
}
```

## Constraints and Limitations

Currently, this project can be correctly compiled and executed only on:

- Cangjie 1.0.5 (Universal Edition)

If you are using other versions of the Cangjie SDK, you may need to modify the project source code directly for compatibility.

## License

[MIT License](./LICENSE)

## Contributing

Contributions are welcome! Feel free to submit PRs or Issues, and participate in any form of contribution.