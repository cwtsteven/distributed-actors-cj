# Interfaces

## interface ActorClient

```cangjie
public interface ActorClient
```

Function: Interface for actor client implementations that provide remote access to actors in a distributed actor system.

### prop id

```cangjie
prop id: String
```

Function: The unique identifier of the actor client.

### func find()

```cangjie
func find(name: String): Option<ActorInfo>
```

Function: Finds an actor by name and returns its information.

Parameters:

- name: String - The name of the actor to find.

Return Value:

- `Option<ActorInfo>` - Returns `Some(ActorInfo)` if the actor is found, `None` otherwise.

### func findAll()

```cangjie
func findAll(): Array<ActorInfo>
```

Function: Finds all actors registered in the distributed actor system.

Return Value:

- `Array<ActorInfo>` - An array containing information about all registered actors.

### func remoteCall()

```cangjie
func remoteCall(invokeInfo: InvokeInfo): Unit
```

Function: Makes a remote call to an actor's receiver function and fulfills the provided future with the result.

Parameters:

- `invokeInfo: InvokeInfo` - The information about the remote call invocation.

## interface ActorHost

```cangjie
public interface ActorHost
```

Function: Interface for actor host implementations that manage actor registration and deregistration in a distributed actor system.

### func register()

```cangjie
func register(name: String, a: Distributable): Bool
```

Function: Registers an actor instance with the actor system under the specified name.

Parameters:

- `name: String` - The name to register the actor under.
- `a: Distributable` - The actor instance to register, must implement `Distributable`.

Return Value:

- `Bool` - Returns `true` if the actor was successfully registered, `false` if the name is already taken.

### func deregister()

```cangjie
func deregister(name: String): Bool
```

Function: Removes an actor from the actor system.

Parameters:

- `name: String` - The name of the actor to deregister.

Return Value:

- `Bool` - Returns `true` if the actor was successfully deregistered, `false` if the actor was not found.

## interface Distributable

```cangjie
public interface Distributable
```

Function: Interface that distributed actor interfaces must implement to support remote communication. This interface provides the necessary methods for remote method invocation and metadata access.

### func getMetadata()

```cangjie
func getMetadata(): Metadata
```

Function: Gets the metadata of the actor, including information about its receiver functions, description, and custom data.

Return Value:

- `Metadata` - The metadata describing the actor interface.

### func dispatchTell()

```cangjie
func dispatchTell(receiverName: String, args: Array<DataModel>, config: ReceiverConfig): Unit
```

Function: Dispatches a `tell` operation to the actor without expecting a return value.

Parameters:

- `receiverName: String` - The name of the receiver function to call.
- `args: Array<DataModel>` - Serialized arguments for the receiver function.
- `config: ReceiverConfig` - Configuration for the call.

Exceptions:

- `ReceiverNotFoundException` - If the receiver function is not found.

### func dispatchAsk()

```cangjie
func dispatchAsk(receiverName: String, args: Array<DataModel>, config: ReceiverConfig): LocalWaitable
```

Function: Dispatches an `ask` operation to the actor and returns a waitable for the result.

Parameters:

- `receiverName: String` - The name of the receiver function to call.
- `args: Array<DataModel>` - Serialized arguments for the receiver function.
- `config: ReceiverConfig` - Configuration for the call.

Return Value:

- `LocalWaitable` - A waitable object that can be used to retrieve the result.

Exceptions:

- `ReceiverNotFoundException` - If the receiver function is not found.

## interface LocalWaitable

```cangjie
public interface LocalWaitable
```

Function: Interface for objects that can be waited upon locally and provide serialized results.

### func getResult()

```cangjie
func getResult(): DataModel
```

Function: Gets the serialized result of the operation.

Return Value:

- `DataModel` - The serialized result.

### func fromActorFuture<T>()

```cangjie
static func fromActorFuture<T>(obj: Object): LocalWaitable where T <: Serializable<T>
```

Function: Creates a LocalWaitable from an ActorFuture for serializable types.

Parameters:

- `obj: Object` - The ActorFuture object to convert.

Return Value:

- `LocalWaitable` - A `LocalWaitable` that provides the serialized result of the ActorFuture.

## interface TypeSerializable

```cangjie
public interface TypeSerializable
```

Function: Marker interface for types that can describe their type schema for distributed transport by returning a `TypeModel`.

### func typeModel()

```cangjie
static func typeModel(): TypeModel
```

Function: Provides the static `TypeModel` describing how the type is serialized. Implementations must keep the returned model in sync with their encoded representation.

Return Value:

- `TypeModel` - The structural description of the type for metadata generation and receiver validation.

Notes:

- Built-in conformances cover integers (`Int8`-`Int64`, `UInt8`-`UInt64`), floats (`Float16`-`Float64`), `Bool`, `Unit`, `String`, `Array<T>` and `Option<T>` whenever `T` is also `TypeSerializable`. Custom types should implement this interface to participate in distributed metadata generation.
