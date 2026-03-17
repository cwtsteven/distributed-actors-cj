# Classes

## class ActorProxy

```cangjie
public class ActorProxy <: Serializable<ActorProxy> & TypeSerializable {
  public ActorProxy(
    public let actorName: String,
    public let hostInfo: HostInfo
  )
}
```

Function: Proxy class for communicating with remote actors in a distributed system. The `ActorProxy` allows clients to send messages and make calls to remote actors without directly managing the communication details.

Implements:
- `Serializable`
- `TypeSerializable`

### init(String, HostInfo)

```cangjie
public ActorProxy(
  public let actorName: String,
  public let hostInfo: HostInfo
)
```

Function: Creates an `ActorProxy` for communicating with a specific actor at the given host.

Parameters:

- `actorName: String` - The name of the remote actor to communicate with.
- `hostInfo: HostInfo` - The host information that identifies where the actor is located.

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
- `IllegalArgumentException` - Thrown if the arguments are invalid.
- `ActorSystemException` - Thrown for any system-specific errors.

### func ask()

```cangjie
public func ask(receiverName: String, args: Array<DataModel>, config!: ReceiverConfig = ReceiverConfig.default): DistributedActorFuture<DataModel>
```

Function: Makes a call to a remote actor's receiver and returns a `DistributedActorFuture<DataModel>` representing the pending serialized result (`Ask` mode).

Parameters:

- `receiverName: String` - The name of the receiver to call.
- `args: Array<DataModel>` - Serialized arguments for the receiver.
- `config!: ReceiverConfig` - Configuration for the call, defaults to `ReceiverConfig.default`.

Return Value:

- `DistributedActorFuture<DataModel>` - The pending serialized result of the remote call.

Exceptions:

- `ActorNotFoundException` - Thrown if the actor is not found on the client.
- `ReceiverNotFoundException` - Thrown if the receiver is not found.
- `RemoteException` - Thrown if the remote connection fails.
- `IllegalArgumentException` - Thrown if the arguments are invalid.
- `ActorSystemException` - Thrown for any system-specific errors.

### func serialize()

```cangjie
public func serialize(): DataModel
```

Function: Serializes the actor proxy to a `DataModel` for network transmission.

Return Value:

- `DataModel` - The serialized representation of the actor proxy.

### func deserialize()

```cangjie
public static func deserialize(dataModel: DataModel): ActorProxy
```

Function: Deserializes an actor proxy from its `DataModel` representation.

Parameters:

- `dataModel: DataModel` - The serialized actor proxy data.

Return Value:

- `ActorProxy` - The deserialized actor proxy instance.

Exceptions:

- `DeserializationException` - Thrown if the deserialization fails.

### func typeModel()

```cangjie
public static func typeModel(): TypeModel
```

Function: Gets the type model of the actor proxy, describing its structure for distributed metadata generation.

Return Value:

- `TypeModel` - The type model describing the actor proxy structure.

## class ClientManager

```cangjie
public class ClientManager {
  public static let instance: ClientManager
  public func getClient(hostInfo: HostInfo): Option<ActorClient>
  public func getOrCreateClient(hostInfo: HostInfo): ActorClient
  public func removeClient(hostInfo: HostInfo): Option<ActorClient>
  public func registerHostInfoDeserializer(typeName: String, deserializer: (DataModel) -> HostInfo): Unit
  public func getHostInfoDeserializer(typeName: String): Option<(DataModel) -> HostInfo>
}
```

Function: A singleton class that manages actor clients in the distributed actor system. This class is used to get and register actor clients and their deserializers. The client manager is used for creating actor proxies so as to avoid duplicated connections to the same host.

### static prop instance

```cangjie
public static let instance: ClientManager
```

Function: The singleton instance of the client manager.

### func getClient()

```cangjie
public func getClient(hostInfo: HostInfo): Option<ActorClient>
```

Function: Gets a client for the specified host info if it exists.

Parameters:

- `hostInfo: HostInfo` - The host info of the client.

Return Value:

- `Option<ActorClient>` - Returns the client if found, `None` otherwise.

### func getOrCreateClient()

```cangjie
public func getOrCreateClient(hostInfo: HostInfo): ActorClient
```

Function: Gets a client or creates a new one if it doesn't exist. This method uses double-checked locking to ensure thread-safety when creating new clients.

Parameters:

- `hostInfo: HostInfo` - The host info of the client.

Return Value:

- `ActorClient` - The client for the specified host info.

### func removeClient()

```cangjie
public func removeClient(hostInfo: HostInfo): Option<ActorClient>
```

Function: Removes a client from the manager.

Parameters:

- `hostInfo: HostInfo` - The host info of the client to remove.

Return Value:

- `Option<ActorClient>` - Returns the client if removed, `None` otherwise.

### func registerHostInfoDeserializer()

```cangjie
public func registerHostInfoDeserializer(typeName: String, deserializer: (DataModel) -> HostInfo): Unit
```

Function: Registers a host info deserializer for a given type name.

Parameters:

- `typeName: String` - The type name of the host info.
- `deserializer: (DataModel) -> HostInfo` - The deserializer function to register.

### func getHostInfoDeserializer()

```cangjie
public func getHostInfoDeserializer(typeName: String): Option<(DataModel) -> HostInfo>
```

Function: Gets a host info deserializer for a given type name.

Parameters:

- `typeName: String` - The type name of the host info.

Return Value:

- `Option<(DataModel) -> HostInfo>` - Returns the deserializer if found, `None` otherwise.
