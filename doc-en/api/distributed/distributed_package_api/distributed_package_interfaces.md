# Interfaces

## interface ActorClient

```cangjie
public interface ActorClient
```

Function: Interface that provide remote access to actors *exported* by the connected `ActorHost`.

### func find()

```cangjie
func find(name: String): Option<ActorInfo>
```

Function: Finds an actor by name and returns its information.

Parameters:

- name: String - The name of the actor to find.

Return Value:

- `Option<ActorInfo>` - Returns `Some(ActorInfo)` if the actor is found, `None` otherwise.

Exceptions:

- `RemoteException` - Thrown if the remote connection fails.
- `ActorSystemException` - Thrown for any system-specific errors.

### func findAll()

```cangjie
func findAll(): Array<ActorInfo>
```

Function: Finds all actors exported in the corresponding `ActorHost`.

Return Value:

- `Array<ActorInfo>` - An array containing information about all exported actors.

Exceptions:

- `RemoteException` - Thrown if the remote connection fails.
- `ActorSystemException` - Thrown for any system-specific errors.

### func containsActor()

```cangjie
func containsActor(name: String): Bool
```

Function: Checks if an actor is exported from the respective server.

Parameters:

- `name: String` - The name of the actor.

Return Value:

- `Bool` - Returns `true` if the actor is exported, `false` otherwise.

Exceptions:

- `RemoteException` - Thrown if the remote connection fails.
- `ActorSystemException` - Thrown for any system-specific errors.

### func getActor()

```cangjie
func getActor(name: String): Option<ActorProxy>
```

Function: Gets an actor proxy for the specified actor name.

Parameters:

- `name: String` - The name of the actor.

Return Value:

- `Option<ActorProxy>` - Returns `Some(ActorProxy)` if the actor is found, `None` otherwise.

Exceptions:

- `ActorNotFoundException` - Thrown if the actor is not found on the client.
- `RemoteException` - Thrown if the remote connection fails.
- `ActorSystemException` - Thrown for any system-specific errors.

### func remoteCall()

```cangjie
func remoteCall(invokeInfo: InvokeInfo): Unit
```

Function: Makes a remote call to an actor's receiver according to the invocation info.

Parameters:

- `invokeInfo: InvokeInfo` - The information about the remote call invocation.

Exceptions:

- `ActorNotFoundException` - Thrown if the actor is not found on the client.
- `ReceiverNotFoundException` - Thrown if the receiver is not found.
- `RemoteException` - Thrown if the remote connection fails.
- `IllegalArgumentException` - Thrown if the arguments are invalid.
- `ActorSystemException` - Thrown for any system-specific errors.

### func getHostInfo()

```cangjie
func getHostInfo(): HostInfo
```

Function: Gets the host info of the client.

Return Value:

- `HostInfo` - The host info that identifies the remote host this client connects to.

## interface ActorCluster

```cangjie
public interface ActorCluster
```

Function: Interface for creating a cluster system for spawning and discovering distributed actors.

### func spawnActor\<T>()

```cangjie
static func spawnActor<T>(name: String, args: Array<SpawnArgument>): Option<T> where T <: Distributable & Proxyable<T> & Spawnable<T>
```

Function: Spawns a new distributed actor instance in the cluster with the given name and arguments.

Parameters:

- `name: String` - A unique name to register the new actor under.
- `args: Array<SpawnArgument>` - The typed spawn arguments used to construct the actor.

Return Value:

- `Option<T>` - Returns `Some(T)` with the created actor when successful, or `None` if an actor with the same name already exists or the spawn fails.

Exceptions:

- `RemoteException` - Thrown if the connection to the cluster fails.
- `IllegalArgumentException` - Thrown if the arguments are invalid.

### func getActor\<T>()

```cangjie
static func getActor<T>(name: String): Option<T> where T <: Distributable & Proxyable<T> & Spawnable<T>
```

Function: Looks up an existing distributed actor in the cluster by name and returns it as a typed instance.

Parameters:

- `name: String` - The name of the actor to look up.

Return Value:

- `Option<T>` - Returns `Some(T)` if an actor with the given name exists and matches the requested type, `None` otherwise.

### func removeActor()

```cangjie
static func removeActor(name: String): Bool
```

Function: Removes the actor with the given name from the cluster. This does not immediately *kill* the actor as it might still be referenced in the host machine locally.

Parameters:

- `name: String` - The name of the actor to remove.

Return Value:

- `Bool` - Returns `true` if an actor with the given name was removed, `false` if no such actor exists.

### func registerSpawningFunc\<T>()

```cangjie
static func registerSpawningFunc<T>(typeName: String, spawningFunc: (Array<SpawnArgument>) -> Option<T>): Bool where T <: Distributable & Proxyable<T> & Spawnable<T>
```

Function: Registers a spawning function for a given actor type name so that the cluster can later spawn actors of that type.

Parameters:

- `typeName: String` - The unique type name associated with the actor type.
- `spawningFunc: (Array<SpawnArgument>) -> Option<T>` - The function that constructs an actor instance from a list of arguments.

Return Value:

- `Bool` - Returns `true` if the spawning function was registered, `false` if it was already registered.

### func registerSpawnParameterType\<T>()

```cangjie
static func registerSpawnParameterType<T>(typeName: String): Bool where T <: Serializable<T> & TypeSerializable
```

Function: Registers the parameter type of a spawning function with a given type name so that it can be safely transferred to another node in the cluster.

Parameters:

- `typeName: String` - The unique type name associated with the argument type.

Return Value:

- `Bool` - Returns `true` if the type was registered, `false` if it was already registered.

### func getSpawningFunc()

```cangjie
static func getSpawningFunc(typeName: String): Option<(Array<SpawnArgument>) -> Option<Distributable>>
```

Function: Gets a spawning function for a given type name.

Parameters:

- `typeName: String` - The type name whose spawn function should be retrieved.

Return Value:

- `Option<(Array<SpawnArgument>) -> Option<Distributable>>` - Returns `Some(f)` with the spawn function if found, `None` otherwise.

## interface ActorHost

```cangjie
public interface ActorHost
```

Function: Interface that exports and un-exports distributed actors.

### func export()

```cangjie
func export(name: String, a: Distributable): Option<ActorProxy>
```

Function: Exports an actor instance with a specified name.

Parameters:

- `name: String` - The name to export the actor.
- `a: Distributable` - The actor instance to export.

Return Value:

- `Option<ActorProxy>` - Returns `Some(ActorProxy)` if the actor was successfully exported, `None` if the name is already taken.

Exceptions:

- `ActorSystemException` - Thrown for any system-specific errors.

### func unexport()

```cangjie
func unexport(name: String): Bool
```

Function: Un-export an actor.

Parameters:

- `name: String` - The name of the actor to un-export.

Return Value:

- `Bool` - Returns `true` if the actor was successfully un-exported, `false` if the actor was not found.

Exceptions:

- `ActorSystemException` - Thrown for any system-specific errors.

### func getHostInfo()

```cangjie
func getHostInfo(): HostInfo
```

Function: Gets the host info of the host.

Return Value:

- `HostInfo` - The host info that identifies this host.

## interface HostInfo

```cangjie
public interface HostInfo <: Serializable<HostInfo> & TypeSerializable & Equatable<HostInfo> & Hashable & ToString
```

Function: Interface for host information that identifies a remote actor host. This interface provides methods to create clients and obtain type information for serialization.

Implements:
- `Serializable`
- `TypeSerializable`
- `Equatable`
- `Hashable`
- `ToString`

### func createClient()

```cangjie
func createClient(): ActorClient
```

Function: Creates a client for connecting to this host.

Return Value:

- `ActorClient` - A client instance that can connect to this host.

### func getTypeName()

```cangjie
func getTypeName(): String
```

Function: Gets the type name of the host info, used for serialization and deserialization.

Return Value:

- `String` - The type name of the host info.

### func deserialize()

```cangjie
static func deserialize(dataModel: DataModel): HostInfo
```

Function: Deserializes a data model to a host info. This is a default implementation that should not be called directly. Concrete implementations of `HostInfo` should override this method.

Parameters:

- `dataModel: DataModel` - The data model to deserialize.

Return Value:

- `HostInfo` - The deserialized host info.

Exceptions:

- `Exception` - Thrown if this default implementation is called.

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
static func getProxy(proxy: ActorProxy): T
```

Function: Returns a typed proxy instance for the distributed actor from an `ActorProxy`.

Parameters:

- `proxy: ActorProxy` - The actor proxy representing the remote actor.

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

Exceptions:

- `SerializationException` - Thrown if the result cannot be serialized.

### func fromActorFuture\<T>()

```cangjie
static func fromActorFuture<T>(obj: Object): LocalWaitable where T <: Serializable<T>
```

Function: Creates a LocalWaitable from an `ActorFuture` for serializable types.

Parameters:

- `obj: Object` - The ActorFuture object to convert.

Return Value:

- `LocalWaitable` - A `LocalWaitable` that provides the serialized result of the ActorFuture.

## interface Spawnable\<T>

```cangjie
public interface Spawnable<T> where T <: Distributable
```

Function: Interface for distributed actors that can be spawned dynamically within a cluster. Users are required implement this interface for any actor interfaces that are meant to be spawned in a cluster.

### func typeName()

```cangjie
static func typeName(): String
```

Function: Returns the unique type name used by the cluster to register and look up its constructors.

Return Value:

- `String` - The unique type name for this actor type.

### func spawnWith()

```cangjie
static func spawnWith(args: Array<SpawnArgument>): Option<T>
```

Function: Creates a new actor instance from a list of arguments. Implementations are responsible for validating and decoding arguments, and calling the correct constructor.

Parameters:

- `args: Array<SpawnArgument>` - The arguments used to construct the actor instance.

Return Value:

- `Option<T>` - Returns `Some(T)` when the actor is successfully created, `None` when creation fails (for example due to invalid arguments).

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