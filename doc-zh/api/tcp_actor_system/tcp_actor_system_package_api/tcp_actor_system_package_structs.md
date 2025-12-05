# 结构体

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

功能：关于 TCP actor 客户端的信息，包括客户端 ID、地址和端口。

实现接口：
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

功能：初始化 TCPActorClientInfo。

参数：

- `id: String` - 客户端 ID。
- `addr: String` - 客户端地址。
- `port: UInt16` - 客户端端口。

### func serialize()

```cangjie
public func serialize(): DataModel
```

功能：将 TCPActorClientInfo 对象序列化为 DataModel。

返回值：

- `DataModel` - 序列化后的 DataModel。

### func deserialize()

```cangjie
public static func deserialize(dataModel: DataModel): TCPActorClientInfo
```

功能：将 DataModel 反序列化为 TCPActorClientInfo 对象。

参数：

- `dataModel: DataModel` - 要反序列化的 DataModel。

返回值：

- `TCPActorClientInfo` - 反序列化后的 TCPActorClientInfo 对象。

异常：

- `TCPActorSystemDeserializationException` - 如果反序列化失败则抛出。

### func typeModel()

```cangjie
public static func typeModel(): TypeModel
```

功能：获取 TCPActorClientInfo 的类型模型。

返回值：

- `TypeModel` - TCPActorClientInfo 的类型模型。

