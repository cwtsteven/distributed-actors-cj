# Interfaces

## interface ActorClient

```cangjie
public interface ActorClient
```

Function: Interface that provide remote access to actors *exported* by the connected `ActorHost`.

### prop id

```cangjie
prop id: String
```

Function: A unique identifier of the actor client.

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

Function: Finds all actors exported in the corresponding `ActorHost`.

Return Value:

- `Array<ActorInfo>` - An array containing information about all exported actors.

### func remoteCall()

```cangjie
func remoteCall(invokeInfo: InvokeInfo): Unit
```

Function: Makes a remote call to an actor's receiver according to the invocation info.

Parameters:

- `invokeInfo: InvokeInfo` - The information about the remote call invocation.

## interface ActorHost

```cangjie
public interface ActorHost
```

Function: Interface that exports and un-exports distributed actors.

### func export()

```cangjie
func export(name: String, a: Distributable): Bool
```

Function: Exports an actor instance with a specified name.

Parameters:

- `name: String` - The name to export the actor.
- `a: Distributable` - The actor instance to export.

Return Value:

- `Bool` - Returns `true` if the actor was successfully exported, `false` if the name is already taken.

### func unexport()

```cangjie
func unexport(name: String): Bool
```

Function: Un-export an actor.

Parameters:

- `name: String` - The name of the actor to un-export.

Return Value:

- `Bool` - Returns `true` if the actor was successfully un-exported, `false` if the actor was not found.

## interface Distributable

```cangjie
public interface Distributable
```

Function: A common interface for **all** distributed actors. This interface provides the necessary methods for dispatching remote receiver invocation to the underlying actor instance and metadata access.

### func getMetadata()

```cangjie
func getMetadata(): Metadata
```

Function: Gets the metadata of the actor, including information about its receivers, description, and custom data.

Return Value:

- `Metadata` - The metadata describing the actor interface.

### func dispatchTell()

```cangjie
func dispatchTell(receiverName: String, args: Array<DataModel>, config: ReceiverConfig): Unit
```

Function: Dispatches a `tell` operation to the actor without expecting a return value.

Parameters:

- `receiverName: String` - The name of the receiver function to call.
- `args: Array<DataModel>` - Serialized arguments for the receiver.
- `config: ReceiverConfig` - Configuration for the call.

Exceptions:

- `ReceiverNotFoundException` - Thrown if the receiver function is not found.

### func dispatchAsk()

```cangjie
func dispatchAsk(receiverName: String, args: Array<DataModel>, config: ReceiverConfig): LocalWaitable
```

Function: Dispatches an `ask` operation to the actor and returns a *waitable* object for the result.

Parameters:

- `receiverName: String` - The name of the receiver function to call.
- `args: Array<DataModel>` - Serialized arguments for the receiver function.
- `config: ReceiverConfig` - Configuration for the call.

Return Value:

- [LocalWaitable](./distributed_package_interfaces.md#interface-localwaitable) - A *waitable* object that can be used to retrieve the pending result of a receiver call.

Exceptions:

- `ReceiverNotFoundException` - Thrown if the receiver function is not found.

## interface Proxyable\<T>

```cangjie
public interface Proxyable<T> where T <: Distributable
```

Function: Interface for actors that can be proxied to a typed proxy.

### func getProxy()

```cangjie
static func getProxy(name: String, client: ActorClient): T
```

Function: Returns a typed proxy instance for the distributed actor that implements this interface.

Parameters:

- `name: String` - The remote actor name registered with the distributed system.
- `client: ActorClient` - The client instance used to reach the remote host.

Return Value:

- `T` - The typed proxy that exposes methods mirroring the receivers declared on the interface.

## interface LocalWaitable

```cangjie
public interface LocalWaitable
```

Function: A common interface for all local `ActorFuture<T>` type, provide methods to obtain the result of the Future in its serialized form, i.e. `DataModel`.

### func getResult()

```cangjie
func getResult(): DataModel
```

Function: Gets the serialized result of the operation. If the receiver throws an exception or an error, they will be returned as serialized data model.

Return Value:

- `DataModel` - The serialized result.

### func fromActorFuture<T>()

```cangjie
static func fromActorFuture<T>(obj: Object): LocalWaitable where T <: Serializable<T>
```

Function: Creates a LocalWaitable from an `ActorFuture` for serializable types.

Parameters:

- `obj: Object` - The ActorFuture object to convert.

Return Value:

- `LocalWaitable` - A `LocalWaitable` that provides the serialized result of the ActorFuture.

## interface TypeSerializable

```cangjie
public interface TypeSerializable
```

Function: Interface for providing the type model schema of a Cangjie type.

### func typeModel()

```cangjie
static func typeModel(): TypeModel
```

Function: Returns the `TypeModel` describing the structure of the type.

Return Value:

- `TypeModel` - The structural description of the type

Notes:

- Built-in conformances cover integers (`Int8`-`Int64`, `UInt8`-`UInt64`), floats (`Float16`-`Float64`), `Bool`, `Unit`, `String`, `Array<T>` and `Option<T>` whenever `T` is also `TypeSerializable`. Custom types should implement this interface to participate in distributed metadata generation.