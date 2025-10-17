# Complete API Reference

This document provides a comprehensive list of all public APIs in the distributed actors framework, organized by package.

## actors Package

### Classes

| Class Name | Description |
|------------|-------------|
| **[ActorFuture<T>](api/en/actors_package_api/actors_package_classes.md#class-actorfuture)** | Concrete class representing the pending result of a closure submitted to an Actor |
| **[SequentialDispatcher](api/en/actors_package_api/actors_package_classes.md#class-sequentialdispatcher)** | Thread-safe dispatcher for sequential task execution |

### Structs

| Struct Name | Description |
|-------------|-------------|
| **[ReceiverConfig](api/en/actors_package_api/actors_package_structs.md#struct-receiverconfig)** | Configuration for receiver function calls |

### Enums

| Enum Name | Description |
|-----------|-------------|
| **[Tell](api/en/actors_package_api/actors_package_enums.md#enum-tell)** | Single-valued enum for bypassing ActorFuture mechanism |

## actors.distributed Package

### Classes

| Class Name | Description |
|------------|-------------|
| **[ActorProxy](api/en/distributed/distributed_package_api/distributed_package_classes.md#class-actorproxy)** | Proxy for communicating with remote actors |
| **[DistributedFuture](api/en/distributed/distributed_package_api/distributed_package_classes.md#class-distributedfuture)** | Future for distributed actor communication |
| **[ActorNotFoundException](api/en/distributed/distributed_package_api/distributed_package_classes.md#class-actornotfoundexception)** | Exception for actor not found |
| **[ReceiverNotFoundException](api/en/distributed/distributed_package_api/distributed_package_classes.md#class-receivernotfoundexception)** | Exception for receiver not found |
| **[RemoteException](api/en/distributed/distributed_package_api/distributed_package_classes.md#class-remoteexception)** | Exception for remote connection failures |
| **[ActorSystemException](api/en/distributed/distributed_package_api/distributed_package_classes.md#class-actorsystemexception)** | General actor system exception |
| **[RemoteReceiverException](api/en/distributed/distributed_package_api/distributed_package_classes.md#class-remotereceiverexception)** | Serializable exception for remote receiver failures |

### Interfaces

| Interface Name | Description |
|----------------|-------------|
| **[Distributable](api/en/distributed/distributed_package_api/distributed_package_interfaces.md#interface-distributable)** | Interface for distributed actor interfaces |
| **[ActorHost](api/en/distributed/distributed_package_api/distributed_package_interfaces.md#interface-actorhost)** | Interface for actor host implementations |
| **[ActorClient](api/en/distributed/distributed_package_api/distributed_package_interfaces.md#interface-actorclient)** | Interface for actor client implementations |
| **[LocalWaitable](api/en/distributed/distributed_package_api/distributed_package_interfaces.md#interface-localwaitable)** | Interface for locally waitable objects |

### Structs

| Struct Name | Description |
|-------------|-------------|
| **[ActorInfo](api/en/distributed/distributed_package_api/distributed_package_structs.md#struct-actorinfo)** | Information about an actor |
| **[Metadata](api/en/distributed/distributed_package_api/distributed_package_structs.md#struct-metadata)** | Metadata about an actor interface |
| **[ReceiverInfo](api/en/distributed/distributed_package_api/distributed_package_structs.md#struct-receiverinfo)** | Information about a receiver function |
| **[ReceiverParameter](api/en/distributed/distributed_package_api/distributed_package_structs.md#struct-receiverparameter)** | Information about a receiver parameter |
| **[FieldModel](api/en/distributed/distributed_package_api/distributed_package_structs.md#struct-fieldmodel)** | Information about a struct field |
| **[InvokeInfo](api/en/distributed/distributed_package_api/distributed_package_structs.md#struct-invokeinfo)** | Information about a remote call invocation |

### Enums

| Enum Name | Description |
|-----------|-------------|
| **[ReceiverMode](api/en/distributed/distributed_package_api/distributed_package_enums.md#enum-receivermode)** | Calling mode for receiver functions |
| **[TypeModel](api/en/distributed/distributed_package_api/distributed_package_enums.md#enum-typemodel)** | Type information for serialization |

## actors.distributed.mcp Package

### Classes

| Class Name | Description |
|------------|-------------|
| **[ActorToolManager](api/en/distributed/mcp/mcp_package_api/mcp_package_classes.md#class-actortoolmanager)** | Tool manager for distributed actors |
| **[ReceiverTool](api/en/distributed/mcp/mcp_package_api/mcp_package_classes.md#class-receivertool)** | MCP tool implementation for receiver functions |
| **[ActorMCPException](api/en/distributed/mcp/mcp_package_api/mcp_package_classes.md#class-actormcpexception)** | Exception for MCP operations |

## actors.dummy_actor_system Package

### Classes

| Class Name | Description |
|------------|-------------|
| **[DummyActorHost](api/en/dummy_actor_system/dummy_actor_system_package_api/dummy_actor_system_package_classes.md#class-dummyactorhost)** | In-memory actor host implementation |
| **[DummyActorClient](api/en/dummy_actor_system/dummy_actor_system_package_api/dummy_actor_system_package_classes.md#class-dummyactorclient)** | In-memory actor client implementation |

## actors.tcp_actor_system Package

### Classes

| Class Name | Description |
|------------|-------------|
| **[TCPActorSystem](api/en/tcp_actor_system/tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorsystem)** | Main TCP actor system class |
| **[TCPActorHost](api/en/tcp_actor_system/tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorhost)** | TCP-based actor host implementation |
| **[TCPActorClient](api/en/tcp_actor_system/tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorclient)** | TCP-based actor client implementation |
| **[TCPActorSystemSerializationException](api/en/tcp_actor_system/tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorsystemserializationexception)** | Serialization exception |
| **[TCPActorSystemDeserializationException](api/en/tcp_actor_system/tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorsystemdeserializationexception)** | Deserialization exception |

### Enums

| Enum Name | Description |
|-----------|-------------|
| **[Payload](api/en/tcp_actor_system/tcp_actor_system_package_api/tcp_actor_system_package_enums.md#enum-payload)** | Message protocol between TCP host and client |
| **[TCPActorSystemError](api/en/tcp_actor_system/tcp_actor_system_package_api/tcp_actor_system_package_enums.md#enum-tcpactorsystemerror)** | Error codes for TCP actor system |

## actors.macros Package

### Macros

| Macro Name | Description |
|------------|-------------|
| **[@ActorInterface](api/en/macros/macros_package_api/macros_package_macros.md#actorinterface-macro)** | Transform interface into actor interface |
| **[@Actor](api/en/macros/macros_package_api/macros_package_macros.md#actor-macro)** | Transform class into actor |
| **[@Receiver](api/en/macros/macros_package_api/macros_package_macros.md#receiver-macro)** | Transform method into receiver function |


