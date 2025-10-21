# actors.distributed

## Function Description

The `actors.distributed` package extends the core actor programming model to support distributed systems where actors can communicate across network boundaries. This package provides the infrastructure for remote actor communication, metadata management, and distributed future handling.

Key features include:
- **Distributed Actor Communication**: Abstraction for remote actor communication
- **Distributed Futures**: Asynchronous result handling for remote operations
- **Serialization Support**: Built-in support for data serialization across network boundaries

This package enables building scalable distributed systems where actors can be deployed across multiple nodes while maintaining the same programming model as local actors.

## API List

### Classes

|                 Class Name              |                Function                 |
| --------------------------------- | ---------------------------------- |
| [ActorProxy](./distributed_package_api/distributed_package_classes.md#class-actorproxy) | Proxy class for communicating with remote actors. Provides methods for both ask and tell patterns in distributed systems. |
| [DistributedFuture](./distributed_package_api/distributed_package_classes.md#class-distributedfuture) | Future implementation for distributed actor communication that handles serialized data models and remote result fulfillment. |
| [ActorNotFoundException](./distributed_package_api/distributed_package_classes.md#class-actornotfoundexception) | Exception thrown when an actor with the specified name cannot be found in the distributed actor system. |
| [ReceiverNotFoundException](./distributed_package_api/distributed_package_classes.md#class-receivernotfoundexception) | Exception thrown when a receiver function cannot be found in the specified actor interface. |
| [RemoteException](./distributed_package_api/distributed_package_classes.md#class-remoteexception) | Exception thrown when a remote connection fails during distributed actor communication. |
| [ActorSystemException](./distributed_package_api/distributed_package_classes.md#class-actorsystemexception) | General exception for actor system related errors with a custom message. |
| [RemoteReceiverException](./distributed_package_api/distributed_package_classes.md#class-remotereceiverexception) | Exception that wraps non-serializable exceptions or errors thrown from remote receiver execution. |

### Structs

|                 Struct Name              |                Function                 |
| --------------------------------- | ---------------------------------- |
| [ActorInfo](./distributed_package_api/distributed_package_structs.md#struct-actorinfo) | Information about an actor including its name and metadata. Used by actor systems to provide information about registered actors. |
| [Metadata](./distributed_package_api/distributed_package_structs.md#struct-metadata) | Contains metadata about an actor interface, including receiver information, description, and custom data. |
| [ReceiverInfo](./distributed_package_api/distributed_package_structs.md#struct-receiverinfo) | Information about a specific receiver function, including parameter schemas, return types, and metadata. |
| [ReceiverParameter](./distributed_package_api/distributed_package_structs.md#struct-receiverparameter) | Information about a parameter in a receiver function, including its name, type, and description. |
| [FieldModel](./distributed_package_api/distributed_package_structs.md#struct-fieldmodel) | Information about a field in a struct type, including its name, type, and description. |
| [InvokeInfo](./distributed_package_api/distributed_package_structs.md#struct-invokeinfo) | Information about a remote call invocation, containing all the necessary details to make a remote call to an actor's receiver function. |

### Interfaces

|                 Interface Name              |                Function                 |
| --------------------------------- | ---------------------------------- |
| [Distributable](./distributed_package_api/distributed_package_interfaces.md#interface-distributable) | Interface that distributed actor interfaces must implement to support remote communication. |
| [ActorHost](./distributed_package_api/distributed_package_interfaces.md#interface-actorhost) | Interface for actor host implementations that manage actor registration and deregistration in a distributed actor system. |
| [ActorClient](./distributed_package_api/distributed_package_interfaces.md#interface-actorclient) | Interface for actor client implementations that provide remote access to actors in a distributed actor system. |
| [LocalWaitable](./distributed_package_api/distributed_package_interfaces.md#interface-localwaitable) | Interface for objects that can be waited upon locally and provide serialized results. |

### Enumerations

| Enumeration Name |      Function       |
| ---------------- | ------------------- |
| [ReceiverMode](./distributed_package_api/distributed_package_enums.md#enum-receivermode) | Represents the calling mode for receiver functions (AskOnly, TellOnly, AskAndTell). |
| [TypeModel](./distributed_package_api/distributed_package_enums.md#enum-typemodel) | Represents type information for serialization and metadata generation, supporting primitive types, structs, and lists. |
