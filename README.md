# Distributed Actors Framework

A comprehensive distributed actors framework for the Cangjie programming language, providing actor-based concurrency and distributed computing capabilities with support for local and remote actor communication.

## Features

- **Actor Programming Model**: Core actor abstractions with message-passing concurrency
- **Distributed Communication**: TCP-based actor communication across network boundaries
- **MCP Integration**: Model Context Protocol support for AI agent integration
- **Macro-based Development**: Compile-time actor and interface generation
- **Priority-based Execution**: Configurable priority queues for actor message processing
- **Serialization Support**: Built-in serialization for distributed actor communication
- **Multiple Implementations**: TCP, dummy, and extensible actor system implementations

## Requirements

- **Cangjie Compiler**: Version 0.53.18 or later
- **CangjieMagic**: For AI agent integration features used in `actors.distributed.mcp` package

## Installation

### Using Git Dependency (Recommended)

Add the following to your `cjpm.toml`:

```toml
[dependencies]
  actors = {
    git = "git@github.com:Huawei-Edinburgh-Programming-Languages/distributed-actors.git",
    branch = "hmos_5.0.5",
    version = "1.0.0"
  }
  ```

## Building

### Prerequisites

1. Follow the instructions on the [Cangjie language homepage](https://cangjie-lang.com) to set up the correct environment
2. Ensure you have the required Cangjie compiler version (0.53.18+)

### Build Commands

```bash
# Build the package and all examples
make

# Run all tests
make test

# Run specific test categories
cjpm test
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
import actors.*
import actors.macros.*
import actors.distributed.*
import actors.tcp_actor_system.*

@ActorInterface[distributed: true, description: "Bank service"]
public interface BankService {
    @Receiver[description: "Transfer money between accounts"]
    public func transfer(from: String, to: String, amount: Float64): Unit
}

@Actor
public class BankServiceImpl <: BankService {
    @Receiver
    public func transfer(from: String, to: String, amount: Float64): Unit {
        // Transfer logic here
        println("Transferred ${amount} from ${from} to ${to}")
    }
}

main() {
    // Host side
    let tcpHost = TCPActorHost(bindAt: 8080)
    let serverFuture = tcpHost.serve()

    let bankService = BankServiceImpl()
    tcpHost.register("bank-service", bankService)

    // Client side
    let tcpClient = TCPActorClient(id: "client-1", addr: "localhost", port: 8080)
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
import actors.distributed.mcp.ActorMCPClient
import actors.tcp_actor_system.*

@agent[model: "deepseek:deepseek-chat"]
class AssistantAgent {
    @prompt("You are a helpful assistant that can interact with distributed services.")
}

public class AgentManager {
    private let agent: AssistantAgent
    private let mcpClient = ActorMCPClient()

    init() {
        agent = AssistantAgent()
        Config.env["DEEPSEEK_API_KEY"] = "your-api-key"
    }

    func addActorClient(client: TCPActorClient): Unit {
        mcpClient.addActorClient(client)
        agent.toolManager.addTools(mcpClient.getTools())
    }

    func chat(userInput: String): String {
        let res = agent.chat(AgentRequest(userInput))
        res.content
    }
}

main() {
    let agentManager = AgentManager()
    let tcpClient = TCPActorClient("service", "localhost", 8080)
    agentManager.addActorClient(tcpClient)

    let response = agentManager.chat("Transfer $100 from Alice to Bob")
    println("Assistant: ${response}")
}
```

## Package Structure

The framework is organized into several packages:

- **`actors`**: Core actor programming model and local actor system
- **`actors.distributed`**: Distributed actor interfaces and metadata
- **`actors.distributed.mcp`**: Model Context Protocol integration
- **`actors.macros`**: Compile-time actor and interface generation
- **`actors.tcp_actor_system`**: TCP-based distributed actor implementation
- **`actors.dummy_actor_system`**: In-memory actor system for testing

## Documentation

- **[Tutorial](doc/tutorial.md)**: Comprehensive guide to using the distributed actors framework
- **[API Documentation](doc/api/en/)**: Complete API reference for all packages
- **[Examples](examples/)**: Working examples demonstrating various features

## Key Concepts

### Actor Model
- **Actors**: Encapsulated units of computation that communicate via message passing
- **Receivers**: Methods that can be called on actors, supporting both ask (synchronous) and tell (fire-and-forget) patterns
- **Futures**: Asynchronous result handling for actor operations

### Distributed Actors
- **Actor Host**: Manages actor registration and handles incoming requests
- **Actor Client**: Provides remote access to actors hosted elsewhere
- **Actor Proxy**: Client-side representation of remote actors
- **Metadata**: Type-safe information about actor interfaces for distributed communication

### MCP Integration
- **Tool Discovery**: Automatic discovery of actor receiver functions as AI agent tools
- **Natural Language Interface**: AI agents can interact with actors using natural language
- **Type Safety**: Ensures proper serialization/deserialization of arguments and return values

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## License

This project is licensed under the terms specified in the repository.

## Roadmap

- [ ] Message delivery semantics (at-least-once vs at-most-once)
- [ ] Retry mechanisms for failed message delivery
- [ ] Move distributed macros to a separate package
- [ ] Enhanced exception and error handling
- [ ] Performance optimizations for large-scale deployments

## Support

For questions, issues, or contributions, please refer to the project repository or documentation.