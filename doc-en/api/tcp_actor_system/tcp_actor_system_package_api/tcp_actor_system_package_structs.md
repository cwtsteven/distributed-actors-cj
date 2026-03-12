# Structs

## struct TCPActorHostInfo

```cangjie
public struct TCPActorHostInfo <: HostInfo {
  public TCPActorHostInfo(
    public let addr: String,
    public let port: UInt16
  )
}
```

Function: Information about a TCP actor host, including the host address and port. This struct implements `HostInfo` and is used to identify and connect to TCP actor hosts.

Implements:
- `HostInfo`
- `Serializable`
- `TypeSerializable`
- `Equatable`
- `Hashable`
- `ToString`

### init(String, UInt16)

```cangjie
public TCPActorHostInfo(
  public let addr: String,
  public let port: UInt16
)
```

Function: Initializes the TCPActorHostInfo.

Parameters:

- `addr: String` - The host address.
- `port: UInt16` - The host port.

### func createClient()

```cangjie
public func createClient(): ActorClient
```

Function: Creates a client for connecting to this TCP actor host.

Return Value:

- `ActorClient` - A TCP actor client instance.

### func getTypeName()

```cangjie
public func getTypeName(): String
```

Function: Gets the type name of the host info.

Return Value:

- `String` - Returns "TCPActorHostInfo".

### func serialize()

```cangjie
public func serialize(): DataModel
```

Function: Serializes the TCPActorHostInfo object to a DataModel.

Return Value:

- `DataModel` - The serialized DataModel.

### func deserialize()

```cangjie
public static func deserialize(dataModel: DataModel): HostInfo
```

Function: Deserializes a DataModel to a TCPActorHostInfo object.

Parameters:

- `dataModel: DataModel` - The DataModel to deserialize.

Return Value:

- `HostInfo` - The deserialized TCPActorHostInfo object.

Exceptions:

- `TCPActorSystemDeserializationException` - Thrown if the deserialization fails.

### func typeModel()

```cangjie
public static func typeModel(): TypeModel
```

Function: Gets the type model of the TCPActorHostInfo.

Return Value:

- `TypeModel` - The type model of the TCPActorHostInfo.

### operator ==()

```cangjie
public override operator func ==(other: HostInfo): Bool
```

Function: Compares this `TCPActorHostInfo` with another `HostInfo`.

Parameters:

- `other: HostInfo` - The other host info value to compare with.

Return Value:

- `Bool` - Returns `true` when the other value is also a `TCPActorHostInfo` with the same address and port.

### operator !=()

```cangjie
public override operator func !=(other: HostInfo): Bool
```

Function: Compares this `TCPActorHostInfo` with another `HostInfo` for inequality.

Parameters:

- `other: HostInfo` - The other host info value to compare with.

Return Value:

- `Bool` - Returns `true` when the two host info values are not equal.

### func hashCode()

```cangjie
public override func hashCode(): Int64
```

Function: Returns the hash code of the TCP actor host info.

Return Value:

- `Int64` - The hash code derived from the host address and port.

### func toString()

```cangjie
public func toString(): String
```

Function: Converts the TCP actor host info to a string representation.

Return Value:

- `String` - A string in the form `TCPActorHostInfo addr:port`.
