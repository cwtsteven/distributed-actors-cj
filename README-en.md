<div align="center">
<h1>distributed-actors-cj</h1>
</div>

<p align="center">
<img alt="" src="https://img.shields.io/badge/release-v1.0.0-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjc-v0.53.18-brightgreen" style="display: inline-block;" />
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
- **Agent Integration**: Exposing actors as tools under MCP protocol

### Roadmap

- [x] Typed distributed actor proxy
- [ ] Message delivery semantics (at-least-once vs at-most-once)
- [ ] Retry mechanisms for failed message delivery
- [ ] Enhanced exception and error handling
- [ ] Reentrant actors
- [ ] Cluster

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
    └── TCPActorSystem      # Main TCP actor system configuration
```

### APIs description

For a detailed API reference, please refer to [API Documentation](doc-en/apis.md).

## User manual

### Using Git Dependency (Recommended)

Add the following to your `cjpm.toml`:

```toml
[dependencies]
  actors = { git = "https://gitcode.com/Cangjie-TPC/distributed-actors-cj.git", branch = "main", version = "1.0.0" }
```

### Building

```shell
# Build the package and all examples
make
```

### Testing

```shell
# Run all tests
make test
```

Most tests should pass. Known failing tests:
- `testGarbageCollection`
- `testForkJoinGarbageCollection`

These problems are fixed in a newer version of the Cangjie compiler however this library is not supporting that version yet.

### Tutorial

A comprehensive tutorial can be found at [Tutorial](doc-en/tutorial.md).

### Quick examples

For more detailed examples please refers to

- **[Examples](examples/)**: Working examples demonstrating various features
- **[Impresario Demo](https://github.com/Huawei-Edinburgh-Programming-Languages/impresario-demo/)**: Example AI-powered applications demonstrating distributed actors with agent integration on HarmonyOS

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
    tcpHost.export("bank-service", bankService)

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
```

The execution result is as follows:

```shell
Transfer completed
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

    let tcpClient = TCPActorClient("service", "localhost", 8080)
    toolManager.addActorClient(tcpClient)

    let response = agent.chat("Transfer $100 from Alice to Bob")
    println("Assistant: ${response}")
}
```

## Constraints and Limitations

Currently, this project can be correctly compiled and executed only on:

- Cangjie 0.53.18 (Universal Edition)
- DevEco Studio for Windows 5.0.13.200 and DevEco Studio Cangjie Plugin Canary for Windows 5.0.13.200 (HarmonyOS Edition)

If you are using other versions of the Cangjie SDK, you may need to modify the project source code directly for compatibility.

## License

[MIT License](./LICENSE)

## Contributing

Contributions are welcome! Feel free to submit PRs or Issues, and participate in any form of contribution.