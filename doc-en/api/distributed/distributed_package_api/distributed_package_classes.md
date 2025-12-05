# Classes

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

Function: Creates an `ActorProxy` for communicating with a specific actor in the given actor client.

Parameters:

- `name: String` - The name of the remote actor to communicate with.
- `client: ActorClient` - The actor client that connects to the remote actor.

Exceptions:

- `ActorNotFoundException` - Thrown if the actor is not found on the client.
- `RemoteException` - Thrown if the remote connection fails.
- `ActorSystemException` - Thrown for any system-specific errors.

### func tell()

```cangjie
public func tell(receiverName: String, args: Array<DataModel>, config!: ReceiverConfig = ReceiverConfig.default): Unit
```

Function: Calling a remote actor's receiver without expecting a return value (`Tell` mode).

Parameters:

- `receiverName: String` - The name of the receiver to call.
- `args: Array<DataModel>` - Serialized arguments for the receiver.
- `config!: ReceiverConfig` - Configuration for the call, defaults to `ReceiverConfig.default`.

Exceptions:

- `ActorNotFoundException` - Thrown if the actor is not found on the client.
- `ReceiverNotFoundException` - Thrown if the receiver is not found.
- `RemoteException` - Thrown if the remote connection fails.
- `ActorSystemException` - Thrown for any system-specific errors.

### func ask()

```cangjie
public func ask(receiverName: String, args: Array<DataModel>, config!: ReceiverConfig = ReceiverConfig.default): DistributedFuture
```

Function: Makes a call to a remote actor's receiver and returns a [DistributedFuture](distributed_package_classes.md#class-distributedfuture) representing the pending result (`Ask` mode).

Parameters:

- `receiverName: String` - The name of the receiver to call.
- `args: Array<DataModel>` - Serialized arguments for the receiver.
- `config!: ReceiverConfig` - Configuration for the call, defaults to `ReceiverConfig.default`.

Return Value:

- [DistributedFuture](distributed_package_classes.md#class-distributedfuture) - The pending result of the remote call.

Exceptions:

- `ActorNotFoundException` - Thrown if the actor is not found on the client.
- `ReceiverNotFoundException` - Thrown if the receiver is not found.
- `RemoteException` - Thrown if the remote connection fails.
- `ActorSystemException` - Thrown for any system-specific errors.

## class DistributedFuture

```cangjie
public class DistributedFuture
```

Function: Represents the pending result of remote receiver call. Provides methods for obtaining and fulfilling the serialized result.

### func get()

```cangjie
public func get(): DataModel
```

Function: Blocks the current thread until the result is ready and returns the serialized result.

Return Value:

- `DataModel` - The serialized result of the operation.

Exceptions:

- `RemoteException` - Thrown if the remote connection fails.
- `RemoteReceiverException` - Thrown if the result is an exception or error thrown from the remote receiver execution.
- `ActorSystemException` - Thrown for any system-specific errors.

### func get(Duration)

```cangjie
public func get(timeout: Duration): Option<DataModel>
```

Function: Blocks the current thread until the result is ready with a timeout and returns the result.

Parameters:

- `timeout: Duration` - The timeout duration.

Return Value:

- `Option<DataModel>` - Returns the result if it is ready within the timeout, `None` otherwise.

Exceptions:

- `RemoteException` - Thrown if the remote connection fails.
- `RemoteReceiverException` - Thrown if the result is an exception or error thrown from the remote receiver execution.
- `ActorSystemException` - Thrown for any system-specific errors.

### func tryGet()

```cangjie
public func tryGet(): Option<DataModel>
```

Function: Tries to get the result.

Return Value:

- `Option<DataModel>` - Returns the result if it is ready, `None` otherwise.

Exceptions:

- `RemoteException` - Thrown if the remote connection fails.
- `RemoteReceiverException` - Thrown if the result is an exception or error thrown from the remote receiver execution.
- `ActorSystemException` - Thrown for any system-specific errors.

### func fulfill()

```cangjie
public func fulfill(dataModel: DataModel): Bool
```

Function: Fulfills the future with a serialized result value.

Parameters:

- `dataModel: DataModel` - The serialized result value to fulfill the future with.

Return Value:

- `Bool` - Returns `true` if the future was successfully fulfilled, `false` if it was already fulfilled.

Exceptions:

- `IllegalArgumentException` - Thrown if the serialized result cannot be deserialized into a valid future result.

### func toActorFuture\<T>()

```cangjie
public func toActorFuture<T>(): ActorFuture<T> where T <: Serializable<T>
```

Function: Converts the distributed future into a local `ActorFuture`.

Type Parameters:

- `T` - The concrete serializable type expected from the remote call.

Return Value:

- `ActorFuture<T>` - A local future that will complete with the deserialized value.

Exceptions:

- `DataModelException` - Thrown when the type of the result of the DistributedFuture does not match with `T`.
