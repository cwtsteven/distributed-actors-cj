# Complete API Reference

This document provides a comprehensive list of all public APIs in the distributed actors framework, organized by package.

## actors Package

### Classes

| Class Name | Description |
|------------|-------------|
| [ActorFuture\<T>](./actors_package_api/actors_package_classes.md#class-actorfuture) | Concrete class for representing the pending result of a closure submitted to an Actor. Provides methods for blocking and non-blocking result retrieval with timeout support. |
| [SequentialDispatcher](./actors_package_api/actors_package_classes.md#class-sequentialdispatcher) | A dispatcher that queues and executes closures sequentially on a dedicated thread, and provides methods for submitting closures. Supports priority-based scheduling and is typically used internally by the actor system. |

### Structs

| Struct Name | Description |
|-------------|-------------|
| [ReceiverConfig](./actors_package_api/actors_package_structs.md#struct-receiverconfig) | Configuration for receiver calls, including priority settings (1-10 scale). |

### Enums

| Enum Name | Description |
|-----------|-------------|
| [Tell](./actors_package_api/actors_package_enums.md#enum-tell) | Single-valued enumeration that enables fire-and-forget messaging by bypassing the `ActorFuture` mechanism. Use `tell: True` as a named argument when calling receivers. |

## actors.distributed Package

### Classes

| Class Name | Description |
|------------|-------------|
| [ActorProxy](./distributed_package_api/distributed_package_classes.md#class-actorproxy) | Proxy class for communicating with remote actors. Provides methods for both *ask* and *tell* patterns. |
| [DistributedFuture](./distributed_package_api/distributed_package_classes.md#class-distributedfuture) | Concrete class representing the pending result of remote receiver call. Provides methods for obtaining and fulfilling the result. |
| [ActorNotFoundException](./distributed_package_api/distributed_package_classes.md#class-actornotfoundexception) | Exception thrown when an actor with the specified name cannot be found in the distributed actor system. |
| [ReceiverNotFoundException](./distributed_package_api/distributed_package_classes.md#class-receivernotfoundexception) | Exception thrown when a receiver function cannot be found in the specified actor interface. |
| [RemoteException](./distributed_package_api/distributed_package_classes.md#class-remoteexception) | Exception thrown when a remote connection fails during distributed actor communication. |
| [ActorSystemException](./distributed_package_api/distributed_package_classes.md#class-actorsystemexception) | General exception for actor system related errors with a custom message. |
| [RemoteReceiverException](./distributed_package_api/distributed_package_classes.md#class-remotereceiverexception) | Exception that wraps non-serializable exceptions or errors thrown from remote receiver execution. |

### Interfaces

| Interface Name | Description |
|----------------|-------------|
| [Distributable](./distributed_package_api/distributed_package_interfaces.md#interface-distributable) | Interface implemented by all distributed actors, provides methods to dispatch remote calls from client to the underlying actor instance. |
| [ActorHost](./distributed_package_api/distributed_package_interfaces.md#interface-actorhost) | Interface for actor host implementations. Provides methods for *exporting* a distributed actor. |
| [ActorClient](./distributed_package_api/distributed_package_interfaces.md#interface-actorclient) | Interface for actor client implementations. Provides methods for *finding* a distributed actor. |
| [LocalWaitable](./distributed_package_api/distributed_package_interfaces.md#interface-localwaitable) | A common interface for all local `ActorFuture<T>` type, provide methods to obtain the result of the Future in its serialized form, i.e. `DataModel`. |

### Structs

| Struct Name | Description |
|-------------|-------------|
| [ActorInfo](./distributed_package_api/distributed_package_structs.md#struct-actorinfo) | Information about an actor including its name and metadata. |
| [Metadata](./distributed_package_api/distributed_package_structs.md#struct-metadata) | Contains metadata about an actor interface, including receiver information, description, and custom data. |
| [ReceiverInfo](./distributed_package_api/distributed_package_structs.md#struct-receiverinfo) | Information about a specific receiver function, including parameter schemas, return types, and metadata. |
| [ReceiverParameter](./distributed_package_api/distributed_package_structs.md#struct-receiverparameter) | Information about a parameter in a receiver function, including its name, type, and description. |
| [FieldModel](./distributed_package_api/distributed_package_structs.md#struct-fieldmodel) | Information about a field in a struct type, including its name, type, and description. Part of the whole type model schema. |
| [InvokeInfo](./distributed_package_api/distributed_package_structs.md#struct-invokeinfo) | Information about a remote call invocation, containing all the necessary details to make a remote call to an actor's receiver. |

### Enums

| Enum Name | Description |
|-----------|-------------|
| [ReceiverMode](./distributed_package_api/distributed_package_enums.md#enum-receivermode) | Calling mode for receiver functions, `Ask` or `Tell`. |
| [TypeModel](./distributed_package_api/distributed_package_enums.md#enum-typemodel) | Type schema for a Cangjie type. Describes the structure of a Cangjie type. |

## actors.distributed.mcp Package

### Classes

| Class Name | Description |
|------------|-------------|
| [ActorToolManager](./mcp_package_api/mcp_package_classes.md#class-actortoolmanager) | Tool manager implementation that manages multiple actor clients and exposes their receiver functions as MCP tools. |
| [ReceiverTool](./mcp_package_api/mcp_package_classes.md#class-receivertool) | MCP tool implementation that wraps actor receiver functions, enabling them to be called as MCP tools. |
| [ActorMCPException](./mcp_package_api/mcp_package_classes.md#class-actormcpexception) | Exception thrown when MCP-related operations fail, such as tool not found or invalid arguments. |

## actors.tcp_actor_system Package

### Classes

| Class Name | Description |
|------------|-------------|
| [TCPActorHost](./tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorhost) | TCP-based actor host implementation providing methods to *export* distributed actors. |
| [TCPActorClient](./tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorclient) | TCP-based actor client implementation providing methods to *find* distributed actors. |
| [TCPActorSystemSerializationException](./tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorsystemserializationexception) | Exception thrown when a serialization operation fails in the TCP actor system. |
| [TCPActorSystemDeserializationException](./tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorsystemdeserializationexception) | Exception thrown when a deserialization operation fails in the TCP actor system. |

### Enums

| Enum Name | Description |
|-----------|-------------|
| [Payload](./tcp_actor_system_package_api/tcp_actor_system_package_enums.md#enum-payload) | Message protocol between TCPActorHost and TCPActorClient, including various message types for actor communication. |
| [TCPActorSystemError](./tcp_actor_system_package_api/tcp_actor_system_package_enums.md#enum-tcpactorsystemerror) | Enum representing the error codes of the TCPActorSystem, including common error conditions. |

## actors.macros Package

### Macros

| Macro Name | Description |
|------------|-------------|
| [@Actor](./macros_package_api/macros_package_macros.md#actor-macro)     | Transform a class into an actor. |
| [@ActorInterface](./macros_package_api/macros_package_macros.md#actorinterface-macro)     | Transform an interface into an actor interface. |
| [@Receiver](./macros_package_api/macros_package_macros.md#receiver-macro)     | Transform a method into a receiver. |


