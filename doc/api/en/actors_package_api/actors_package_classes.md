# Classes

## abstract class ActorFuture

```cangjie
public abstract class ActorFuture<T> {}
```

Function: Abstract base class representing the pending result of a closure submitted to an Actor.


### func get()

```cangjie
public func get(): T
```

Function: Blocks the current thread until the closure completes. If the closure throws an exception or error, this method will throw the same exception or error.


Return Value:

- T - The computed result of the corresponding closure.

### func get(Duration)

```cangjie
public func get(timeout: Duration): Option<T>
```

Function: Blocks the current thread until either the specified timeout has expired or the result is ready. If the result is already prepared, it will return the result; otherwise, it will return `None`. If an exception or error is thrown, this method will propagate the same exception or error. If the timeout is set to zero, it means there is no time limit.

Parameters:

- timeout: Duration - The maximum time to wait.

Return Value:

- Option\<T> - Returns `None` if the result is not ready within the specified timeout, otherwise returns the result value.

### func tryGet()

```cangjie
public func tryGet(): Option<T>
```

Function: If the result is ready, it immediately returns the result; otherwise, it returns `None`. If the result is an exception or error, this method will throw the same exception or error.

Return Value:

- Option\<T> - If the result is not yet ready, it returns `None`; otherwise, it returns the result value.

## class LocalActorFuture

```cangjie
public class LocalActorFuture<T> <: ActorFuture<T>
```

Function: A concrete implementation of ActorFuture for local actor communication. This class is used internally by the actor system to manage the execution of closures on the actor thread.

### init(() -> T)

```cangjie
init(task: () -> T)
```

Function: Creates a LocalActorFuture with the specified task to execute.

Parameters:

- task: () -> T - The closure to execute on the actor thread.

### func execute()

```cangjie
func execute(): Unit
```

Function: Executes the stored closure and fulfills the future with the result. This method is called internally by the actor system when the task is ready to be executed.

## class DistributedActorFuture

```cangjie
public class DistributedActorFuture<T> <: ActorFuture<T> & Fullfillable where T <: Serializable<T>
```

Function: A specialized ActorFuture for distributed actor communication that supports remote fulfillment. This class extends ActorFuture and implements Fullfillable to allow remote actors to fulfill the future with results.

### func fulfill()

```cangjie
public func fulfill(value: Any): Bool
```

Function: Fulfills the future with a result value. This method is typically called by the distributed actor system when a remote operation completes.

Parameters:

- value: Any - The result value to fulfill the future with.

Return Value:

- Bool - Returns `true` if the future was successfully fulfilled, `false` if it was already fulfilled.

## class ActorProxy

```cangjie
public class ActorProxy {
  public init(name: String, actorSystem: ActorSystem)
}
```

Function: Provides a proxy interface for communicating with remote actors in a distributed system. The ActorProxy allows clients to send messages and make calls to remote actors without directly managing the communication details.

### init(String, ActorSystem)

```cangjie
public init(name: String, actorSystem: ActorSystem)
```

Function: Creates an ActorProxy for communicating with a specific actor in the given actor system.

Parameters:

- name: String - The name of the remote actor to communicate with.
- actorSystem: ActorSystem - The actor system that manages the remote actor.

### func postMessage()

```cangjie
public func postMessage(receiverName: String, args: Array<DataModel>, config!: ReceiverConfig = ReceiverConfig.default): Unit
```

Function: Sends a message to a remote actor's receiver function without expecting a return value (Tell mode).

Parameters:

- receiverName: String - The name of the receiver function to call.
- args: Array<DataModel> - Serialized arguments for the receiver function.
- config!: ReceiverConfig - Configuration for the call, defaults to ReceiverConfig.default.

### func post<T>()

```cangjie
public func post<T>(receiverName: String, args: Array<DataModel>, config!: ReceiverConfig = ReceiverConfig.default): ActorFuture<T> where T <: Serializable<T>
```

Function: Makes a call to a remote actor's receiver function and returns a future for the result (Ask mode).

Parameters:

- receiverName: String - The name of the receiver function to call.
- args: Array<DataModel> - Serialized arguments for the receiver function.
- config!: ReceiverConfig - Configuration for the call, defaults to ReceiverConfig.default.

Return Value:

- ActorFuture<T> - A future that will contain the result of the remote call.

## class ReceiverConfig

```cangjie
public class ReceiverConfig {
  public static let default = ReceiverConfig()
  public init(priority!: Int64 = 5)
}
```

Function: Configuration object for receiver function calls, including priority settings and other call parameters.

### init(Int64)

```cangjie
public init(priority!: Int64 = 5)
```

Function: Creates a ReceiverConfig with the specified priority.

Parameters:

- priority!: Int64 - The priority level for the receiver call, must be between 1 and 10. Defaults to 5.

### static let default

```cangjie
public static let default = ReceiverConfig()
```

Function: A default ReceiverConfig instance with standard priority settings.

## class Metadata

```cangjie
public struct Metadata <: ToString {
  public init(receivers: Array<ReceiverInfo>, description: String, customInfo: JsonValue)
}
```

Function: Contains metadata about an actor interface, including receiver information, description, and custom data. This is used by distributed actor systems to understand the capabilities of remote actors.

### init(Array<ReceiverInfo>, String, JsonValue)

```cangjie
public init(receivers: Array<ReceiverInfo>, description: String, customInfo: JsonValue)
```

Function: Creates a Metadata instance with the specified receiver information, description, and custom data.

Parameters:

- receivers: Array<ReceiverInfo> - Information about all receiver functions in the actor interface.
- description: String - A human-readable description of the actor interface.
- customInfo: JsonValue - Custom metadata in JSON format.

## class ReceiverInfo

```cangjie
public struct ReceiverInfo <: ToString & Equatable<ReceiverInfo> {
  public init(description: String, customInfo: JsonValue, methodName: String, paramSchema: Array<(String, TypeModel)>, retTypeModel: TypeModel)
}
```

Function: Information about a specific receiver function, including parameter schemas, return types, and metadata.

### init(String, JsonValue, String, Array<(String, TypeModel)>, TypeModel)

```cangjie
public init(description: String, customInfo: JsonValue, methodName: String, paramSchema: Array<(String, TypeModel)>, retTypeModel: TypeModel)
```

Function: Creates a ReceiverInfo instance with the specified function details.

Parameters:

- description: String - A human-readable description of the receiver function.
- customInfo: JsonValue - Custom metadata for the receiver function.
- methodName: String - The name of the receiver function.
- paramSchema: Array<(String, TypeModel)> - Schema information for function parameters.
- retTypeModel: TypeModel - Type information for the return value.

## class SequentialDispatcher

```cangjie
public class SequentialDispatcher {
  public init(enableReceiverPriorty!: Bool)
}
```

Function: A `SequentialDispatcher` instance represents a thread in the Cangjie system. Users can submit closures to a `SequentialDispatcher` instance, and these closures will be queued and executed on that thread.

Typically, users do not need to use this class directly. Instead, they should use the [@Actor](../macros/macros_package_api/macros_package_macros.md#actor-macro) macro.

### init(Bool)

```cangjie
public init(enableReceiverPriorty!: Bool)
```

Function: Creates a `SequentialDispatcher` instance and starts a thread for the `SequentialDispatcher` to handle the closures submitted by the user.


Parameters:

- enableReceiverPriorty!: Bool - When set to `true`, it enables the priority feature, allowing closures with higher priority to be executed first.

### func post\<T>(() -> T, Int64)

```cangjie
public func post<T>(task: () -> T, priority!: Int64 = 5): ActorFuture<T>
```

Function: Submits a closure to the dispatcher, which will be queued and executed on the dispatcher thread. This method returns an [ActorFuture\<T>](actors_package_classes.md#class-actorfuture), representing the pending result of the closure. If the dispatcher was created with `enableReceiverPriority` set to true, closures with higher priority will be executed first. If `enableReceiverPriority` is set to false, the `priority` value will have no effect.

Parameters:

- task: () -> T - The closure submitted to the actor.
- priority!: Int64 - The priority of the submitted task, where 1 <= priority <= 10, with a default value of 5.


Return Value:

- [ActorFuture\<T>](actors_package_classes.md#class-actorfuture) - This object can be used to obtain the computed result of the closure.

Exceptions:

- IllegalArgumentException - This exception will be thrown if the priority parameter is less than 1 or greater than 10.

## class ActorNotFoundException

```cangjie
public class ActorNotFoundException <: Exception {
  public init(name: String)
}
```

Function: Exception thrown when an actor with the specified name cannot be found in the actor system.

### init(String)

```cangjie
public init(name: String)
```

Function: Creates an ActorNotFoundException with a message indicating the actor name that could not be found.

Parameters:

- name: String - The name of the actor that could not be found.

## class RemoteException

```cangjie
public class RemoteException <: Exception {
  public init()
}
```

Function: Exception thrown when a remote connection has failed during distributed actor communication.

### init()

```cangjie
public init()
```

Function: Creates a RemoteException with a default message indicating that the remote connection has failed.

## class ActorSystemException

```cangjie
public class ActorSystemException <: Exception {
  public init(msg: String)
}
```

Function: General exception for actor system related errors with a custom message.

### init(String)

```cangjie
public init(msg: String)
```

Function: Creates an ActorSystemException with a custom error message.

Parameters:

- msg: String - The custom error message describing the actor system error.

## class RemoteReceiverException

```cangjie
public class RemoteReceiverException <: Exception & Serializable<RemoteReceiverException> {
  public init(e: Exception)
  public init(e: Error)
  public override func serialize(): DataModel
  public static func deserialize(dm: DataModel): RemoteReceiverException
}
```

Function: Exception that wraps non-serializable exceptions or errors thrown from remote receiver execution. This exception is serializable and can be transmitted across the network.

### init(Exception)

```cangjie
public init(e: Exception)
```

Function: Creates a RemoteReceiverException from an Exception, capturing its stack trace.

Parameters:

- e: Exception - The exception to wrap.

### init(Error)

```cangjie
public init(e: Error)
```

Function: Creates a RemoteReceiverException from an Error, capturing its stack trace.

Parameters:

- e: Error - The error to wrap.

### func serialize()

```cangjie
public override func serialize(): DataModel
```

Function: Serializes the RemoteReceiverException for network transmission.

Return Value:

- DataModel - The serialized representation of the exception.

### func deserialize()

```cangjie
public static func deserialize(dm: DataModel): RemoteReceiverException
```

Function: Deserializes a RemoteReceiverException from its DataModel representation.

Parameters:

- dm: DataModel - The serialized exception data.

Return Value:

- RemoteReceiverException - The deserialized exception instance.

## type ActorInfo

```cangjie
public type ActorInfo = (String, Metadata)
```

Function: Type alias representing information about an actor, containing the actor's name and its metadata. This type is used by actor systems to provide information about registered actors.

### Components

- String - The name of the actor
- Metadata - The metadata describing the actor interface, including receiver information and custom data
