# Distributed Actors Framework

A comprehensive distributed actors framework for the Cangjie programming language, providing actor-based concurrency and distributed computing capabilities with support for local and remote actor communication.

## Features

- **Actor Programming Model**: Active object abstractions with asynchronous method calls
- **Distributed Actors**: Declarative syntax for defining distributed actor interfaces and implementations
- **TCP Actor System**: Production-ready TCP-based distributed actor system implementation
- **Agent Integration**: Exposing actors as tools under MCP protocol

## Requirements

- **Cangjie Compiler**: Version 0.53.18 (not compatible with version 1.0.0+)
- **CangjieMagic**: For AI agent integration features used in `actors.distributed.mcp` package

## Installation

### Using Git Dependency (Recommended)

Add the following to your `cjpm.toml`:

```toml
[dependencies]
  actors = { git = "git@github.com:Huawei-Edinburgh-Programming-Languages/distributed-actors.git", branch = "main", version = "1.0.0" }
  ```

## Building

### Prerequisites

1. Follow the instructions on the [Cangjie language homepage](https://cangjie-lang.cn/) to set up the correct environment
2. Ensure you have the required Cangjie compiler version (0.53.18)

### Build Commands

```bash
# Build the package and all examples
make

# Run all tests
make test
```

### Test Status

Most tests should pass. Known failing tests:
- `testGarbageCollection`
- `testForkJoinGarbageCollection`

## Quick Start

### Basic Actor Example

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

### Distributed Actor Example

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
```

### AI Agent Integration Example

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

## Package Structure

The framework is organized into a hierarchical package structure:

```
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


## Documentation

- **[Tutorial](doc/tutorial.md)**: Comprehensive guide to using the distributed actors framework
- **[API Documentation](doc/apis.md)**: Complete API reference for all packages
- **[Examples](examples/)**: Working examples demonstrating various features
- **[Impresario Demo](https://github.com/Huawei-Edinburgh-Programming-Languages/impresario-demo/)**: Example AI-powered applications demonstrating distributed actors with agent integration on HarmonyOS

## Key Concepts

### Actor Model
- **Actors**: Encapsulated units of computation that communicate via asynchronous method calls
- **Receivers**: Asynchronous methods that can be called on actors, supporting both ask (synchronous) and tell (fire-and-forget) patterns
- **Futures**: Asynchronous result handling for actor operations

### Distributed Actors
- **Actor Host**: Manages actor registration and handles incoming requests
- **Actor Client**: Provides remote access to actors hosted elsewhere
- **Actor Proxy**: Client-side representation of remote actors

### Agent Integration
- **Tool Generation**: Automatic generation of MCP tools from actor receivers
- **Actor Tool Manager**: Manages multiple actor clients and exposes their receiver functions as MCP tools

## License

// TODO

## Roadmap

- [ ] Typed actor proxy
- [ ] Message delivery semantics (at-least-once vs at-most-once)
- [ ] Retry mechanisms for failed message delivery
- [ ] Move distributed macros to a separate package
- [ ] Enhanced exception and error handling
- [ ] Performance optimizations for large-scale deployments

## Support

For questions, issues, or contributions, please refer to the project repository or documentation.