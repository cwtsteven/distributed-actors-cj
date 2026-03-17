# 类

## class ActorProxy

```cangjie
public class ActorProxy <: Serializable<ActorProxy> & TypeSerializable {
  public ActorProxy(
    public let actorName: String,
    public let hostInfo: HostInfo
  )
}
```

功能：在分布式系统中与远程 actor 通信的代理类。`ActorProxy` 允许客户端在无需管理底层通信细节的情况下向远程 actor 发送消息或发起调用。

实现接口：
- `Serializable`
- `TypeSerializable`

### init(String, HostInfo)

```cangjie
public ActorProxy(
  public let actorName: String,
  public let hostInfo: HostInfo
)
```

功能：创建用于与指定主机上的某个 actor 通信的 `ActorProxy`。

参数：

- `actorName: String` — 要通信的远程 actor 的名称。
- `hostInfo: HostInfo` — 标识 actor 所在位置的主机信息。

异常：

- `ActorNotFoundException` — 如果在客户端找不到 actor 则抛出。
- `RemoteException` — 如果远程连接失败则抛出。
- `ActorSystemException` — 对于任何系统特定错误则抛出。

### func tell()

```cangjie
public func tell(receiverName: String, args: Array<DataModel>, config!: ReceiverConfig = ReceiverConfig.default): Unit
```

功能：以 `Tell` 模式调用远程 actor 的 receiver 函数（即发即忘，不期待返回值）。

参数：

- `receiverName: String` — receiver 函数名称。
- `args: Array<DataModel>` — receiver 的序列化参数。
- `config!: ReceiverConfig` — 调用配置，默认 `ReceiverConfig.default`。

异常：

- `ActorNotFoundException` — 如果在客户端找不到 actor 则抛出。
- `ReceiverNotFoundException` — 如果找不到 receiver 则抛出。
- `RemoteException` — 如果远程连接失败则抛出。
- `IllegalArgumentException` — 如果参数无效则抛出。
- `ActorSystemException` — 对于任何系统特定错误则抛出。

### func ask()

```cangjie
public func ask(receiverName: String, args: Array<DataModel>, config!: ReceiverConfig = ReceiverConfig.default): DistributedActorFuture<DataModel>
```

功能：以 `Ask` 模式调用远程 actor 的 receiver 函数，并返回表示待处理序列化结果的 `DistributedActorFuture<DataModel>`。

参数：

- `receiverName: String` — receiver 函数名称。
- `args: Array<DataModel>` — receiver 的序列化参数。
- `config!: ReceiverConfig` — 调用配置，默认 `ReceiverConfig.default`。

返回值：

- `DistributedActorFuture<DataModel>` — 表示远程调用待处理序列化结果的对象。

异常：

- `ActorNotFoundException` — 如果在客户端找不到 actor 则抛出。
- `ReceiverNotFoundException` — 如果找不到 receiver 则抛出。
- `RemoteException` — 如果远程连接失败则抛出。
- `IllegalArgumentException` — 如果参数无效则抛出。
- `ActorSystemException` — 对于任何系统特定错误则抛出。

### func serialize()

```cangjie
public func serialize(): DataModel
```

功能：将 actor 代理序列化为 `DataModel` 以便网络传输。

返回值：

- `DataModel` — actor 代理的序列化表示。

### func deserialize()

```cangjie
public static func deserialize(dataModel: DataModel): ActorProxy
```

功能：从 `DataModel` 反序列化 actor 代理。

参数：

- `dataModel: DataModel` — 要反序列化的 `DataModel`。

返回值：

- `ActorProxy` — 反序列化后的 actor 代理。

异常：

- `DeserializationException` — 如果反序列化失败则抛出。

### func typeModel()

```cangjie
public static func typeModel(): TypeModel
```

功能：获取 actor 代理的类型模型。

返回值：

- `TypeModel` — actor 代理的类型模型。

## class ClientManager

```cangjie
public class ClientManager {
  public static prop instance: ClientManager
}
```

功能：管理分布式 actor 系统中 actor client 的单例类。用于获取和注册 actor client 及其反序列化器。

### static prop instance

```cangjie
public static prop instance: ClientManager
```

功能：返回 `ClientManager` 的单例实例。

返回值：

- `ClientManager` — ClientManager 的单例实例。

### func getClient()

```cangjie
public func getClient(hostInfo: HostInfo): Option<ActorClient>
```

功能：获取与给定主机信息关联的 actor client。

参数：

- `hostInfo: HostInfo` — 要查找的主机信息。

返回值：

- `Option<ActorClient>` — 如果找到 client 则返回 `Some(ActorClient)`，否则返回 `None`。

### func getOrCreateClient()

```cangjie
public func getOrCreateClient(hostInfo: HostInfo): ActorClient
```

功能：获取与给定主机信息关联的 actor client，如果不存在则创建一个新的。使用双重检查锁定确保线程安全。

参数：

- `hostInfo: HostInfo` — 要查找或创建的主机信息。

返回值：

- `ActorClient` — 与主机信息关联的 actor client。

异常：

- `ActorSystemException` — 如果创建 client 失败则抛出。

### func removeClient()

```cangjie
public func removeClient(hostInfo: HostInfo): Unit
```

功能：移除与给定主机信息关联的 actor client。

参数：

- `hostInfo: HostInfo` — 要移除的主机信息。

### func registerHostInfoDeserializer()

```cangjie
public func registerHostInfoDeserializer(typeName: String, deserializer: (DataModel) -> HostInfo): Unit
```

功能：注册主机信息反序列化器。

参数：

- `typeName: String` — 主机信息类型名称。
- `deserializer: (DataModel) -> HostInfo` — 反序列化函数。

### func getHostInfoDeserializer()

```cangjie
public func getHostInfoDeserializer(typeName: String): Option<(DataModel) -> HostInfo>
```

功能：获取主机信息反序列化器。

参数：

- `typeName: String` — 主机信息类型名称。

返回值：

- `Option<(DataModel) -> HostInfo>` — 如果找到反序列化器则返回 `Some(deserializer)`，否则返回 `None`。
