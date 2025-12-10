# 结构体

## struct TCPActorHostInfo

```cangjie
public struct TCPActorHostInfo <: HostInfo {
  public TCPActorHostInfo(
    public let addr: String,
    public let port: UInt16
  )
}
```

功能：关于 TCP actor 主机的信息，包括主机地址和端口。此结构体实现 `HostInfo`，用于标识和连接到 TCP actor 主机。

实现接口：
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

功能：初始化 TCPActorHostInfo。

参数：

- `addr: String` - 主机地址。
- `port: UInt16` - 主机端口。

### func createClient()

```cangjie
public func createClient(): ActorClient
```

功能：创建用于连接到此 TCP actor 主机的客户端。

返回值：

- `ActorClient` - TCP actor 客户端实例。

### func getTypeName()

```cangjie
public func getTypeName(): String
```

功能：获取主机信息的类型名称。

返回值：

- `String` - 返回 "TCPActorHostInfo"。

### func serialize()

```cangjie
public func serialize(): DataModel
```

功能：将 TCPActorHostInfo 对象序列化为 DataModel。

返回值：

- `DataModel` - 序列化后的 DataModel。

### func deserialize()

```cangjie
public static func deserialize(dataModel: DataModel): HostInfo
```

功能：将 DataModel 反序列化为 TCPActorHostInfo 对象。

参数：

- `dataModel: DataModel` - 要反序列化的 DataModel。

返回值：

- `HostInfo` - 反序列化后的 TCPActorHostInfo 对象。

异常：

- `TCPActorSystemDeserializationException` - 如果反序列化失败则抛出。

### func typeModel()

```cangjie
public static func typeModel(): TypeModel
```

功能：获取 TCPActorHostInfo 的类型模型。

返回值：

- `TypeModel` - TCPActorHostInfo 的类型模型。

### operator ==()

```cangjie
public override operator func ==(other: TCPActorHostInfo): Bool
```

功能：比较两个 TCPActorHostInfo 实例是否相等。

参数：

- `other: TCPActorHostInfo` - 要比较的另一个 TCPActorHostInfo。

返回值：

- `Bool` - 如果两个实例的地址和端口都相同则返回 `true`，否则返回 `false`。

### operator !=()

```cangjie
public override operator func !=(other: TCPActorHostInfo): Bool
```

功能：比较两个 TCPActorHostInfo 实例是否不相等。

参数：

- `other: TCPActorHostInfo` - 要比较的另一个 TCPActorHostInfo。

返回值：

- `Bool` - 如果两个实例的地址或端口不同则返回 `true`，否则返回 `false`。

### func hashCode()

```cangjie
public override func hashCode(): Int64
```

功能：获取 TCPActorHostInfo 的哈希码。

返回值：

- `Int64` - TCPActorHostInfo 的哈希码。

### func toString()

```cangjie
public override func toString(): String
```

功能：将 TCPActorHostInfo 转换为字符串表示。

返回值：

- `String` - TCPActorHostInfo 的字符串表示。

