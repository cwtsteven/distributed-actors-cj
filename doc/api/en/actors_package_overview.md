# actors

## Function Description

Provides actor programming model in Cangjie with support for both local and distributed actor systems. The package includes macros for defining actors and actor interfaces, along with utilities for actor communication and metadata management.

## API List

### Classes

|                 Class Name              |                Function                 |
| --------------------------------- | ---------------------------------- |
| [ActorFuture\<T>](./actors_package_api/actors_package_classes.md#abstract-class-actorfuture) | Abstract base class for representing the pending result of a closure submitted to an Actor. |
| [LocalActorFuture\<T>](./actors_package_api/actors_package_classes.md#class-localactorfuture) | A concrete implementation of ActorFuture for local actor communication. |
| [DistributedActorFuture\<T>](./actors_package_api/actors_package_classes.md#class-distributedactorfuture) | A specialized ActorFuture for distributed actor communication that supports remote fulfillment. |
| [SequentialDispatcher](./actors_package_api/actors_package_classes.md#class-sequentialdispatcher) | Provides the functionality to queue multiple closures for execution on the same thread. Typically, users do not need to use this type directly.          |
| [ActorProxy](./actors_package_api/actors_package_classes.md#class-actorproxy) | Provides a proxy interface for communicating with remote actors in a distributed system. |
| [ReceiverConfig](./actors_package_api/actors_package_classes.md#class-receiverconfig) | Configuration object for receiver function calls, including priority settings. |
| [Metadata](./actors_package_api/actors_package_classes.md#class-metadata) | Contains metadata about an actor interface, including receiver information and custom data. |
| [ReceiverInfo](./actors_package_api/actors_package_classes.md#class-receiverinfo) | Information about a specific receiver function, including parameter schemas and return types. |
| [ActorNotFoundException](./actors_package_api/actors_package_classes.md#class-actornotfoundexception) | Exception thrown when an actor with the specified name cannot be found in the actor system. |
| [RemoteException](./actors_package_api/actors_package_classes.md#class-remoteexception) | Exception thrown when a remote connection has failed during distributed actor communication. |
| [ActorSystemException](./actors_package_api/actors_package_classes.md#class-actorsystemexception) | General exception for actor system related errors with a custom message. |
| [RemoteReceiverException](./actors_package_api/actors_package_classes.md#class-remotereceiverexception) | Exception that wraps non-serializable exceptions or errors thrown from remote receiver execution. |

### Types

| Type Name | Function |
| --------- | -------- |
| [ActorInfo](./actors_package_api/actors_package_classes.md#type-actorinfo) | Type alias representing information about an actor, containing the actor's name and its metadata. |

### Interfaces

| Interface Name | Function |
| -------------- | -------- |
| [ActorSystem](./actors_package_api/actors_package_interfaces.md#interface-actorsystem) | Interface for actor system implementations that manage actor registration and remote communication. |
| [Distributable](./actors_package_api/actors_package_interfaces.md#interface-distributable) | Interface that distributed actor interfaces must implement to support remote communication. |
| [Fullfillable](./actors_package_api/actors_package_interfaces.md#interface-fullfillable) | Interface for objects that can be fulfilled with a result value. |
| [Supervisable](./actors_package_api/actors_package_interfaces.md#interface-supervisable) | This interface must be implemented by [`@Actor`](../macros/macros_package_api/macros_package_macros.md#actor-macro)-annotated classes. It provides functions for exception and error handling. |
| [Waitable](./actors_package_api/actors_package_interfaces.md#interface-waitable) | Interface for objects that can be waited upon for completion. |

### Enumerations

| Enumeration Name |      Function       |
| ---------------- | ------------------- |
| [Tell](./actors_package_api/actors_package_enums.md#enum-tell) | Single valued enumeration to call a `@Receiver` while bypassing the `ActorFuture` mechanism.|
| [TypeModel](./actors_package_api/actors_package_enums.md#enum-typemodel) | Represents type information for serialization and metadata generation. |
| [ControlAction](./actors_package_api/actors_package_enums.md#enum-controlaction) | Represents an action to be taken by the actor thread when one of its receivers throws an exception or an error. |
