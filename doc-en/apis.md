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

### Constants

| Constant Name | Description |
|---------------|-------------|
| [MAX_PRIORITY](./actors_package_api/actors_package_structs.md#const-max_priority) | The maximum priority value for receiver calls (10). |
| [MIN_PRIORITY](./actors_package_api/actors_package_structs.md#const-min_priority) | The minimum priority value for receiver calls (1). |

## actors.distributed Package

### Classes

| Class Name | Description |
|------------|-------------|
| [ActorProxy](./distributed_package_api/distributed_package_classes.md#class-actorproxy) | Proxy class for communicating with remote actors. Provides methods for both *ask* and *tell* patterns. |
| [ClientManager](./distributed_package_api/distributed_package_classes.md#class-clientmanager) | Singleton class that manages actor clients in the distributed actor system. Used to get and register actor clients and their deserializers. |
| [DistributedFuture](./distributed_package_api/distributed_package_classes.md#class-distributedfuture) | Concrete class representing the pending result of remote receiver call. Provides methods for obtaining and fulfilling the result. |

### Structs

| Struct Name | Description |
|-------------|-------------|
| [ActorInfo](./distributed_package_api/distributed_package_structs.md#struct-actorinfo) | Information about an actor including its name and metadata. |
| [FieldModel](./distributed_package_api/distributed_package_structs.md#struct-fieldmodel) | Information about a field in a struct type, including its name, type, and description. Part of the whole type model schema. |
| [InvokeInfo](./distributed_package_api/distributed_package_structs.md#struct-invokeinfo) | Information about a remote call invocation, containing all the necessary details to make a remote call to an actor's receiver. |
| [Metadata](./distributed_package_api/distributed_package_structs.md#struct-metadata) | Contains metadata about an actor interface, including receiver information, description, and custom data. |
| [ReceiverInfo](./distributed_package_api/distributed_package_structs.md#struct-receiverinfo) | Information about a specific receiver function, including parameter schemas, return types, and metadata. |
| [ReceiverParameter](./distributed_package_api/distributed_package_structs.md#struct-receiverparameter) | Information about a parameter in a receiver function, including its name, type, and description. |
| [SpawnArgument](./distributed_package_api/distributed_package_structs.md#struct-spawnargument) | Represents a single argument for spawning distributed actors in the cluster. |

### Interfaces

| Interface Name | Description |
|----------------|-------------|
| [ActorClient](./distributed_package_api/distributed_package_interfaces.md#interface-actorclient) | Interface for actor client implementations. Provides methods for *finding* a distributed actor. |
| [ActorCluster](./distributed_package_api/distributed_package_interfaces.md#interface-actorcluster) | Interface for creating a cluster system for spawning and discovering distributed actors. |
| [ActorHost](./distributed_package_api/distributed_package_interfaces.md#interface-actorhost) | Interface for actor host implementations. Provides methods for *exporting* a distributed actor. |
| [HostInfo](./distributed_package_api/distributed_package_interfaces.md#interface-hostinfo) | Interface for host information that identifies a remote actor host. Provides methods to create clients and obtain type information. |
| [Distributable](./distributed_package_api/distributed_package_interfaces.md#interface-distributable) | Interface implemented by all distributed actors, provides methods to dispatch remote calls from client to the underlying actor instance. |
| [LocalWaitable](./distributed_package_api/distributed_package_interfaces.md#interface-localwaitable) | A common interface for all local `ActorFuture<T>` type, provide methods to obtain the result of the Future in its serialized form, i.e. `DataModel`. |
| [Proxyable](./distributed_package_api/distributed_package_interfaces.md#interface-proxyablet) | Interface for distributed actor interfaces that can be proxied to a typed proxy via `getProxy`. |
| [Spawnable](./distributed_package_api/distributed_package_interfaces.md#interface-spawnablet) | Interface for distributed actors that can be spawned dynamically within a cluster. Users are required implement this interface for any actor interfaces that are meant to be spawned in a cluster. |
| [TypeSerializable](./distributed_package_api/distributed_package_interfaces.md#interface-typeserializable) | Interface for types that can describe their type schema for distributed transport by returning a `TypeModel`. |

### Enums

| Enum Name | Description |
|-----------|-------------|
| [ReceiverMode](./distributed_package_api/distributed_package_enums.md#enum-receivermode) | Calling mode for receiver functions, `Ask` or `Tell`. |
| [TypeModel](./distributed_package_api/distributed_package_enums.md#enum-typemodel) | Type schema for a Cangjie type. Describes the structure of a Cangjie type. |

### Exceptions

| Exception Name | Description |
|----------------|-------------|
| [ActorClusterException](./distributed_package_api/distributed_package_exceptions.md#class-actorclusterexception) | Thrown when an error occurs in the distributed actor cluster, such as cluster management or coordination failures. |
| [ActorNotFoundException](./distributed_package_api/distributed_package_exceptions.md#class-actornotfoundexception) | Thrown when an actor with the specified name cannot be found in the distributed actor system. |
| [ActorSystemException](./distributed_package_api/distributed_package_exceptions.md#class-actorsystemexception) | General exception for actor system related errors with a custom message. |
| [DeserializationException](./distributed_package_api/distributed_package_exceptions.md#class-deserializationexception) | Thrown when deserialization of a message or object fails. |
| [ReceiverNotFoundException](./distributed_package_api/distributed_package_exceptions.md#class-receivernotfoundexception) | Thrown when a receiver function cannot be found in the specified actor interface. |
| [RemoteException](./distributed_package_api/distributed_package_exceptions.md#class-remoteexception) | Thrown when a remote connection fails during distributed actor communication. |
| [RemoteReceiverException](./distributed_package_api/distributed_package_exceptions.md#class-remotereceiverexception) | Wraps non-serializable exceptions or errors thrown from remote receiver execution. |
| [SerializationException](./distributed_package_api/distributed_package_exceptions.md#class-serializationexception) | Thrown when serialization of a message or object fails. |
| [SerializingFunctionsNotFoundException](./distributed_package_api/distributed_package_exceptions.md#class-serializingfunctionsnotfoundexception) | Thrown when serializing or deserializing functions for a type cannot be found in the distributed actor system. |

## actors.distributed.mcp Package

### Classes

| Class Name | Description |
|------------|-------------|
| [ActorToolManager](./mcp_package_api/mcp_package_classes.md#class-actortoolmanager) | Tool manager implementation that manages multiple actor clients and exposes their receiver functions as MCP tools. |
| [ReceiverTool](./mcp_package_api/mcp_package_classes.md#class-receivertool) | MCP tool implementation that wraps actor receiver functions, enabling them to be called as MCP tools. |

### Exceptions

| Exception Name | Description |
|----------------|-------------|
| [ActorMCPException](./mcp_package_api/mcp_package_classes.md#class-actormcpexception) | Exception thrown when MCP-related operations fail, such as tool not found or invalid arguments. |

## actors.tcp_actor_system Package

### Classes

| Class Name | Description |
|------------|-------------|
| [TCPActorClient](./tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorclient) | TCP-based actor client implementation providing methods to *find* distributed actors. |
| [TCPActorHost](./tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorhost) | TCP-based actor host implementation providing methods to *export* distributed actors. |
| [TCPActorSystem](./tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorsystem) | Main system class that provides logging configuration for the TCP actor system. |

### Exceptions

| Exception Name | Description |
|----------------|-------------|
| [TCPActorSystemDeserializationException](./tcp_actor_system_package_api/tcp_actor_system_package_exceptions.md#class-tcpactorsystemdeserializationexception) | Exception thrown when a deserialization operation fails in the TCP actor system. |
| [TCPActorSystemInternalException](./tcp_actor_system_package_api/tcp_actor_system_package_exceptions.md#class-tcpactorsysteminternalexception) | Exception thrown when an internal error occurs in the TCP actor system. |
| [TCPActorSystemRemoteException](./tcp_actor_system_package_api/tcp_actor_system_package_exceptions.md#class-tcpactorsystemremoteexception) | Exception thrown when a remote connection fails in the TCP actor system. |
| [TCPActorSystemRequestTimeoutException](./tcp_actor_system_package_api/tcp_actor_system_package_exceptions.md#class-tcpactorsystemrequesttimeoutexception) | Exception thrown when a request timeout occurs in the TCP actor system. |
| [TCPActorSystemSerializationException](./tcp_actor_system_package_api/tcp_actor_system_package_exceptions.md#class-tcpactorsystemserializationexception) | Exception thrown when a serialization operation fails in the TCP actor system. |

### Structs

| Struct Name | Description |
|-------------|-------------|
| [TCPActorHostInfo](./tcp_actor_system_package_api/tcp_actor_system_package_structs.md#struct-tcpactorhostinfo) | Information about a TCP actor host, including the host address and port. |

## actors.tcp_actor_system.cluster Package

### Classes

| Class Name | Description |
|------------|-------------|
| [TCPCluster](./cluster/cluster_package_api/cluster_package_classes.md#class-tcpcluster) | TCP-based implementation of `ActorCluster` consist of a head-server and multiple worker nodes. Provides functionalities to spawn and lookup distributed actors within the cluster. |

### Exceptions

| Exception Name | Description |
|----------------|-------------|
| [TCPClusterException](./cluster/cluster_package_api/cluster_package_exceptions.md#class-tcpclusterexception) | Exception thrown when a cluster operation fails. |

## actors.macros Package

### Macros

| Macro Name | Description |
|------------|-------------|
| [@Actor](./macros_package_api/macros_package_macros.md#actor-macro)     | Transform a class into an actor. |
| [@ActorInterface](./macros_package_api/macros_package_macros.md#actorinterface-macro)     | Transform an interface into an actor interface. |
| [@Receiver](./macros_package_api/macros_package_macros.md#receiver-macro)     | Transform a method into a receiver. |

