# Complete API Reference

This document provides a comprehensive list of all public APIs in the distributed actors framework, organized by package.

## actors Package

### Classes

| Class Name | Description |
|------------|-------------|
| **[ActorFuture\<T>](api/actors_package_api/actors_package_classes.md#class-actorfuture)** | Concrete class representing the pending result of a closure submitted to an Actor |
| **[SequentialDispatcher](api/actors_package_api/actors_package_classes.md#class-sequentialdispatcher)** | Thread-safe dispatcher for sequential task execution |

### Structs

| Struct Name | Description |
|-------------|-------------|
| **[ReceiverConfig](api/actors_package_api/actors_package_structs.md#struct-receiverconfig)** | Configuration for receiver function calls |

### Enums

| Enum Name | Description |
|-----------|-------------|
| **[Tell](api/actors_package_api/actors_package_enums.md#enum-tell)** | Single-valued enum for bypassing ActorFuture mechanism |

## actors.distributed Package

### Classes

| Class Name | Description |
|------------|-------------|
| **[ActorProxy](api/distributed/distributed_package_api/distributed_package_classes.md#class-actorproxy)** | Proxy for communicating with remote actors |
| **[DistributedFuture](api/distributed/distributed_package_api/distributed_package_classes.md#class-distributedfuture)** | Future for distributed actor communication |
| **[ActorNotFoundException](api/distributed/distributed_package_api/distributed_package_classes.md#class-actornotfoundexception)** | Exception for actor not found |
| **[ReceiverNotFoundException](api/distributed/distributed_package_api/distributed_package_classes.md#class-receivernotfoundexception)** | Exception for receiver not found |
| **[RemoteException](api/distributed/distributed_package_api/distributed_package_classes.md#class-remoteexception)** | Exception for remote connection failures |
| **[ActorSystemException](api/distributed/distributed_package_api/distributed_package_classes.md#class-actorsystemexception)** | General actor system exception |
| **[RemoteReceiverException](api/distributed/distributed_package_api/distributed_package_classes.md#class-remotereceiverexception)** | Serializable exception for remote receiver failures |

### Interfaces

| Interface Name | Description |
|----------------|-------------|
| **[Distributable](api/distributed/distributed_package_api/distributed_package_interfaces.md#interface-distributable)** | Interface for distributed actor interfaces |
| **[ActorHost](api/distributed/distributed_package_api/distributed_package_interfaces.md#interface-actorhost)** | Interface for actor host implementations |
| **[ActorClient](api/distributed/distributed_package_api/distributed_package_interfaces.md#interface-actorclient)** | Interface for actor client implementations |
| **[LocalWaitable](api/distributed/distributed_package_api/distributed_package_interfaces.md#interface-localwaitable)** | Interface for locally waitable objects |

### Structs

| Struct Name | Description |
|-------------|-------------|
| **[ActorInfo](api/distributed/distributed_package_api/distributed_package_structs.md#struct-actorinfo)** | Information about an actor |
| **[Metadata](api/distributed/distributed_package_api/distributed_package_structs.md#struct-metadata)** | Metadata about an actor interface |
| **[ReceiverInfo](api/distributed/distributed_package_api/distributed_package_structs.md#struct-receiverinfo)** | Information about a receiver function |
| **[ReceiverParameter](api/distributed/distributed_package_api/distributed_package_structs.md#struct-receiverparameter)** | Information about a receiver parameter |
| **[FieldModel](api/distributed/distributed_package_api/distributed_package_structs.md#struct-fieldmodel)** | Information about a struct field |
| **[InvokeInfo](api/distributed/distributed_package_api/distributed_package_structs.md#struct-invokeinfo)** | Information about a remote call invocation |

### Enums

| Enum Name | Description |
|-----------|-------------|
| **[ReceiverMode](api/distributed/distributed_package_api/distributed_package_enums.md#enum-receivermode)** | Calling mode for receiver functions |
| **[TypeModel](api/distributed/distributed_package_api/distributed_package_enums.md#enum-typemodel)** | Type information for serialization |

## actors.distributed.mcp Package

### Classes

| Class Name | Description |
|------------|-------------|
| **[ActorToolManager](api/distributed/mcp/mcp_package_api/mcp_package_classes.md#class-actortoolmanager)** | Tool manager for distributed actors |
| **[ReceiverTool](api/distributed/mcp/mcp_package_api/mcp_package_classes.md#class-receivertool)** | MCP tool implementation for receiver functions |
| **[ActorMCPException](api/distributed/mcp/mcp_package_api/mcp_package_classes.md#class-actormcpexception)** | Exception for MCP operations |

## actors.dummy_actor_system Package

### Classes

| Class Name | Description |
|------------|-------------|
| **[DummyActorHost](api/dummy_actor_system/dummy_actor_system_package_api/dummy_actor_system_package_classes.md#class-dummyactorhost)** | In-memory actor host implementation |
| **[DummyActorClient](api/dummy_actor_system/dummy_actor_system_package_api/dummy_actor_system_package_classes.md#class-dummyactorclient)** | In-memory actor client implementation |

## actors.tcp_actor_system Package

### Classes

| Class Name | Description |
|------------|-------------|
| **[TCPActorSystem](api/tcp_actor_system/tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorsystem)** | Main TCP actor system class |
| **[TCPActorHost](api/tcp_actor_system/tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorhost)** | TCP-based actor host implementation |
| **[TCPActorClient](api/tcp_actor_system/tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorclient)** | TCP-based actor client implementation |
| **[TCPActorSystemSerializationException](api/tcp_actor_system/tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorsystemserializationexception)** | Serialization exception |
| **[TCPActorSystemDeserializationException](api/tcp_actor_system/tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorsystemdeserializationexception)** | Deserialization exception |

### Enums

| Enum Name | Description |
|-----------|-------------|
| **[Payload](api/tcp_actor_system/tcp_actor_system_package_api/tcp_actor_system_package_enums.md#enum-payload)** | Message protocol between TCP host and client |
| **[TCPActorSystemError](api/tcp_actor_system/tcp_actor_system_package_api/tcp_actor_system_package_enums.md#enum-tcpactorsystemerror)** | Error codes for TCP actor system |

## actors.macros Package

### Macros

| Macro Name | Description |
|------------|-------------|
| **[@ActorInterface](api/macros/macros_package_api/macros_package_macros.md#actorinterface-macro)** | Transform interface into actor interface |
| **[@Actor](api/macros/macros_package_api/macros_package_macros.md#actor-macro)** | Transform class into actor |
| **[@Receiver](api/macros/macros_package_api/macros_package_macros.md#receiver-macro)** | Transform method into receiver function |


