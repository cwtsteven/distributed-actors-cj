# Structs

## struct TCPActorClientInfo

```cangjie
public struct TCPActorClientInfo <: Serializable<TCPActorClientInfo> & TypeSerializable {
  public TCPActorClientInfo(
    public let id: String,
    public let addr: String,
    public let port: UInt16
  )
}
```

Function: Information about a TCP actor client, including the client ID, address, and port.

Implements:
- `Serializable`
- `TypeSerializable`

### init(String, String, UInt16)

```cangjie
public TCPActorClientInfo(
  public let id: String,
  public let addr: String,
  public let port: UInt16
)
```

Function: Initializes the TCPActorClientInfo.

Parameters:

- `id: String` - The client ID.
- `addr: String` - The client address.
- `port: UInt16` - The client port.

### func serialize()

```cangjie
public func serialize(): DataModel
```

Function: Serializes the TCPActorClientInfo object to a DataModel.

Return Value:

- `DataModel` - The serialized DataModel.

### func deserialize()

```cangjie
public static func deserialize(dataModel: DataModel): TCPActorClientInfo
```

Function: Deserializes a DataModel to a TCPActorClientInfo object.

Parameters:

- `dataModel: DataModel` - The DataModel to deserialize.

Return Value:

- `TCPActorClientInfo` - The deserialized TCPActorClientInfo object.

Exceptions:

- `TCPActorSystemDeserializationException` - Thrown if the deserialization fails.

### func typeModel()

```cangjie
public static func typeModel(): TypeModel
```

Function: Gets the type model of the TCPActorClientInfo.

Return Value:

- `TypeModel` - The type model of the TCPActorClientInfo.

