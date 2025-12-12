# actors.distributed

## Function Description

The `actors.distributed` package extends the core actor programming model to support distributed systems where actors can communicate across network boundaries. This package provides the infrastructure for remote actor communication, metadata management, and distributed future handling.

This package enables building scalable distributed systems where actors can be deployed across multiple nodes while maintaining the same programming model as local actors.

## API List

### Classes

|                 Class Name              |                Function                 |
| --------------------------------- | ---------------------------------- |
| [ActorProxy](./distributed_package_api/distributed_package_classes.md#class-actorproxy) | Proxy class for communicating with remote actors. Provides methods for both *ask* and *tell* patterns. |
| [ClientManager](./distributed_package_api/distributed_package_classes.md#class-clientmanager) | Singleton class that manages actor clients in the distributed actor system. Used to get and register actor clients and their deserializers. |
| [DistributedFuture](./distributed_package_api/distributed_package_classes.md#class-distributedfuture) | Concrete class representing the pending result of remote receiver call. Provides methods for obtaining and fulfilling the result. |

### Structs

|                 Struct Name              |                Function                 |
| --------------------------------- | ---------------------------------- |
| [ActorInfo](./distributed_package_api/distributed_package_structs.md#struct-actorinfo) | Information about an actor including its name and metadata. |
| [FieldModel](./distributed_package_api/distributed_package_structs.md#struct-fieldmodel) | Information about a field in a struct type, including its name, type, and description. Part of the whole type model schema. |
| [InvokeInfo](./distributed_package_api/distributed_package_structs.md#struct-invokeinfo) | Information about a remote call invocation, containing all the necessary details to make a remote call to an actor's receiver. |
| [Metadata](./distributed_package_api/distributed_package_structs.md#struct-metadata) | Contains metadata about an actor interface, including receiver information, description, and custom data. |
| [ReceiverInfo](./distributed_package_api/distributed_package_structs.md#struct-receiverinfo) | Information about a specific receiver function, including parameter schemas, return types, and metadata. |
| [ReceiverParameter](./distributed_package_api/distributed_package_structs.md#struct-receiverparameter) | Information about a parameter in a receiver function, including its name, type, and description. |
| [SpawnArgument](./distributed_package_api/distributed_package_structs.md#struct-spawnargument) | Represents a single argument for spawning distributed actors in the cluster. |

### Interfaces

|                 Interface Name              |                Function                 |
| --------------------------------- | ---------------------------------- |
| [ActorClient](./distributed_package_api/distributed_package_interfaces.md#interface-actorclient) | Interface for actor client implementations. Provides methods for *finding* a distributed actor. |
| [ActorCluster](./distributed_package_api/distributed_package_interfaces.md#interface-actorcluster) | Interface for creating a cluster system for spawning and discovering distributed actors. |
| [ActorHost](./distributed_package_api/distributed_package_interfaces.md#interface-actorhost) | Interface for actor host implementations. Provides methods for *exporting* a distributed actor. |
| [HostInfo](./distributed_package_api/distributed_package_interfaces.md#interface-hostinfo) | Interface for host information that identifies a remote actor host. Provides methods to create clients and obtain type information. |
| [Distributable](./distributed_package_api/distributed_package_interfaces.md#interface-distributable) | Interface implemented by all distributed actors, provides methods to dispatch remote calls from client to the underlying actor instance. |
| [LocalWaitable](./distributed_package_api/distributed_package_interfaces.md#interface-localwaitable) | A common interface for all local `ActorFuture<T>` type, provide methods to obtain the result of the Future in its serialized form, i.e. `DataModel`. |
| [Proxyable](./distributed_package_api/distributed_package_interfaces.md#interface-proxyablet) | Interface for distributed actor interfaces that can be proxied to a typed proxy via `getProxy`. |
| [Spawnable](./distributed_package_api/distributed_package_interfaces.md#interface-spawnablet) | Interface for distributed actors that can be spawned dynamically within a cluster. Users are required implement this interface for any actor interfaces that are meant to be spawned in a cluster. |
| [TypeSerializable](./distributed_package_api/distributed_package_interfaces.md#interface-typeserializable) | Interface for types that can describe their type schema for distributed transport by returning a `TypeModel`. |

### Enumerations

| Enumeration Name |      Function       |
| ---------------- | ------------------- |
| [ReceiverMode](./distributed_package_api/distributed_package_enums.md#enum-receivermode) | Calling mode for receiver functions, `Ask` or `Tell`. |
| [TypeModel](./distributed_package_api/distributed_package_enums.md#enum-typemodel) | Type schema for a Cangjie type. Describes the structure of a Cangjie type. |

### Exceptions

| Exception Name                              | Function                                                                                 |
| ------------------------------------------- | ---------------------------------------------------------------------------------------- |
| [ActorClusterException](./distributed_package_api/distributed_package_exceptions.md#class-actorclusterexception) | Thrown when an error occurs in the distributed actor cluster, such as cluster management or coordination failures. |
| [ActorNotFoundException](./distributed_package_api/distributed_package_exceptions.md#class-actornotfoundexception) | Thrown when an actor with the specified name cannot be found in the distributed actor system. |
| [ActorSystemException](./distributed_package_api/distributed_package_exceptions.md#class-actorsystemexception) | General exception for actor system related errors with a custom message. |
| [DeserializationException](./distributed_package_api/distributed_package_exceptions.md#class-deserializationexception) | Thrown when deserialization of a message or object fails. |
| [ReceiverNotFoundException](./distributed_package_api/distributed_package_exceptions.md#class-receivernotfoundexception) | Thrown when a receiver function cannot be found in the specified actor interface. |
| [RemoteException](./distributed_package_api/distributed_package_exceptions.md#class-remoteexception) | Thrown when a remote connection fails during distributed actor communication. |
| [RemoteReceiverException](./distributed_package_api/distributed_package_exceptions.md#class-remotereceiverexception) | Wraps non-serializable exceptions or errors thrown from remote receiver execution. |
| [SerializationException](./distributed_package_api/distributed_package_exceptions.md#class-serializationexception) | Thrown when serialization of a message or object fails. |
| [SerializingFunctionsNotFoundException](./distributed_package_api/distributed_package_exceptions.md#class-serializingfunctionsnotfoundexception) | Thrown when serializing or deserializing functions for a type cannot be found in the distributed actor system. |
