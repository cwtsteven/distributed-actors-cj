# Classes

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

Function: Creates an `ActorNotFoundException` with a message indicating the actor name that could not be found.

Parameters:

- `name: String` - The name of the actor that could not be found.

## class ActorProxy

```cangjie
public class ActorProxy {
  public ActorProxy(
    public let name: String,
    public let client: ActorClient
  )
}
```

Function: Proxy class for communicating with remote actors in a distributed system. The `ActorProxy` allows clients to send messages and make calls to remote actors without directly managing the communication details.

### init(String, ActorClient)

```cangjie
public ActorProxy(
  public let name: String,
  public let client: ActorClient
)
```

Function: Creates an `ActorProxy` for communicating with a specific actor in the given actor system.

Parameters:

- `name: String` - The name of the remote actor to communicate with.
- `client: ActorClient` - The actor client that manages the remote actor.

### func tell()

```cangjie
public func tell(receiverName: String, args: Array<DataModel>, config!: ReceiverConfig = ReceiverConfig.default): Unit
```

Function: Sends a message to a remote actor's receiver function without expecting a return value (Tell mode).

Parameters:

- `receiverName: String` - The name of the receiver function to call.
- `args: Array<DataModel>` - Serialized arguments for the receiver function.
- `config!: ReceiverConfig` - Configuration for the call, defaults to `ReceiverConfig.default`.

### func ask()

```cangjie
public func ask(receiverName: String, args: Array<DataModel>, config!: ReceiverConfig = ReceiverConfig.default): DistributedFuture
```

Function: Makes a call to a remote actor's receiver function and returns a future for the result (Ask mode).

Parameters:

- `receiverName: String` - The name of the receiver function to call.
- `args: Array<DataModel>` - Serialized arguments for the receiver function.
- `config!: ReceiverConfig` - Configuration for the call, defaults to `ReceiverConfig.default`.

Return Value:

- `DistributedFuture` - A future that will contain the serialized result of the remote call.

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

Function: Creates an `ActorSystemException` with a custom error message.

Parameters:

- `msg: String` - The custom error message describing the actor system error.

## class DistributedFuture

```cangjie
public class DistributedFuture
```

Function: A future implementation for distributed actor communication that handles serialized data models. This class is used internally by distributed actor systems to manage remote operation results.

### func get()

```cangjie
public func get(): DataModel
```

Function: Blocks the current thread until the result is ready and returns the serialized result.

Return Value:

- `DataModel` - The serialized result of the operation.

### func get(Duration)

```cangjie
public func get(timeout: Duration): Option<DataModel>
```

Function: Blocks the current thread until either the specified timeout has expired or the result is ready.

Parameters:

- `timeout: Duration` - The maximum time to wait.

Return Value:

- `Option<DataModel>` - Returns `None` if the result is not ready within the specified timeout, otherwise returns the serialized result.

### func tryGet()

```cangjie
public func tryGet(): Option<DataModel>
```

Function: If the result is ready, it immediately returns the serialized result; otherwise, it returns `None`.

Return Value:

- `Option<DataModel>` - If the result is not yet ready, it returns `None`; otherwise, it returns the serialized result.

### func fulfill()

```cangjie
public func fulfill(dataModel: DataModel): Bool
```

Function: Fulfills the future with a serialized result value.

Parameters:

- `dataModel: DataModel` - The serialized result value to fulfill the future with.

Return Value:

- `Bool` - Returns `true` if the future was successfully fulfilled, `false` if it was already fulfilled.

## class ReceiverNotFoundException

```cangjie
public class ReceiverNotFoundException <: Exception {
  public init(name: String, receiverName: String)
}
```

Function: Exception thrown when a receiver function cannot be found in the specified actor interface.

### init(String, String)

```cangjie
public init(name: String, receiverName: String)
```

Function: Creates a `ReceiverNotFoundException` with a message indicating the actor interface and receiver that could not be found.

Parameters:

- `name: String` - The name of the actor interface.
- `receiverName: String` - The name of the receiver function that could not be found.

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

Function: Creates a `RemoteException` with a default message indicating that the remote connection has failed.

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

Function: Creates a `RemoteReceiverException` from an `Exception`, capturing its stack trace.

Parameters:

- `e: Exception` - The exception to wrap.

### init(Error)

```cangjie
public init(e: Error)
```

Function: Creates a `RemoteReceiverException` from an `Error`, capturing its stack trace.

Parameters:

- `e: Error` - The error to wrap.

### func serialize()

```cangjie
public override func serialize(): DataModel
```

Function: Serializes the RemoteReceiverException for network transmission.

Return Value:

- `DataModel` - The serialized representation of the exception.

### func deserialize()

```cangjie
public static func deserialize(dm: DataModel): RemoteReceiverException
```

Function: Deserializes a RemoteReceiverException from its DataModel representation.

Parameters:

- `dm: DataModel` - The serialized exception data.

Return Value:

- `RemoteReceiverException` - The deserialized exception instance.
