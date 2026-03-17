# 接口

## interface ActorClient

```cangjie
public interface ActorClient
```

功能：为连接到的 `ActorHost` 所 *导出* 的 actor 提供远程访问能力的客户端接口。

### func getActor()

```cangjie
func getActor(name: String): Option<ActorProxy>
```

功能：获取指定名称的 actor 代理。

参数：

- `name: String` — actor 的名称。

返回值：

- `Option<ActorProxy>` — 如果找到 actor 则返回 `Some(ActorProxy)`，否则返回 `None`。

异常：

- `ActorNotFoundException` — 如果在客户端找不到 actor 则抛出。
- `RemoteException` — 如果远程连接失败则抛出。
- `ActorSystemException` — 对于任何系统特定错误则抛出。

### func getHostInfo()

```cangjie
func getHostInfo(): HostInfo
```

功能：获取客户端的主机信息。

返回值：

- `HostInfo` — 标识此客户端连接到的远程主机的主机信息。

### func find()

```cangjie
func find(name: String): Option<ActorInfo>
```

功能：按名称查找 actor 并返回其信息。

参数：

- name: String — 要查找的 actor 名称。

返回值：

- `Option<ActorInfo>` — 找到返回 `Some(ActorInfo)`，否则返回 `None`。

异常：

- `RemoteException` — 如果远程连接失败则抛出。
- `ActorSystemException` — 对于任何系统特定错误则抛出。

### func findAll()

```cangjie
func findAll(): Array<ActorInfo>
```

功能：查找对应 `ActorHost` 中导出的全部 actor。

返回值：

- `Array<ActorInfo>` — 所有已导出 actor 的信息数组。

异常：

- `RemoteException` — 如果远程连接失败则抛出。
- `ActorSystemException` — 对于任何系统特定错误则抛出。

### func containsActor()

```cangjie
func containsActor(name: String): Bool
```

功能：检查服务器是否导出了指定的 actor。

参数：

- `name: String` — actor 的名称。

返回值：

- `Bool` — 如果 actor 已导出则返回 `true`，否则返回 `false`。

异常：

- `RemoteException` — 如果远程连接失败则抛出。
- `ActorSystemException` — 对于任何系统特定错误则抛出。

### func getTypedActor\<T>()

```cangjie
func getTypedActor<T>(name: String): Option<T> where T <: Distributable & Proxyable<T>
```

功能：获取指定名称 actor 的类型化代理。

参数：

- `name: String` — actor 的名称。

返回值：

- `Option<T>` — 找到时返回 `Some(T)`，否则返回 `None`。

异常：

- `RemoteException` — 如果远程连接失败则抛出。
- `ActorSystemException` — 对于任何系统特定错误则抛出。

## interface ActorCluster

```cangjie
public interface ActorCluster
```

功能：用于创建集群系统以在其中创建和发现分布式 actor 的接口。

### func spawnActor\<T>()

```cangjie
static func spawnActor<T>(name: String, args: Array<SpawnArgument>): Option<T> where T <: Distributable & Proxyable<T> & Spawnable<T>
```

功能：以给定名称和参数在集群中创建一个新的分布式 actor 实例。

参数：

- `name: String` — 为新 actor 注册的唯一名称。
- `args: Array<SpawnArgument>` — 用于构造该 actor 的创建参数。

返回值：

- `Option<T>` — 创建成功返回 `Some(T)`；若名称已存在或创建失败返回 `None`。

异常：

- `RemoteException` — 如果与集群的连接失败则抛出。
- `IllegalArgumentException` — 如果参数无效则抛出。

### func getActor\<T>()

```cangjie
static func getActor<T>(name: String): Option<T> where T <: Distributable & Proxyable<T> & Spawnable<T>
```

功能：按名称在集群中查找已存在的分布式 actor，并以类型化实例的形式返回。

参数：

- `name: String` — 要查找的 actor 名称。

返回值：

- `Option<T>` — 找到并能匹配类型时返回 `Some(T)`，否则返回 `None`。

异常：

- `RemoteException` — 如果与集群的连接失败则抛出。
- `IllegalArgumentException` — 如果参数无效则抛出。

### func removeActor()

```cangjie
static func removeActor(name: String): Bool
```

功能：从集群中移除指定名称的 actor。该操作不会立即 *杀死* actor，因为它可能仍在主机机器上被本地引用。

参数：

- `name: String` — 要移除的 actor 名称。

返回值：

- `Bool` — 成功移除返回 `true`，未找到返回 `false`。

### func registerSpawningFunc\<T>()

```cangjie
static func registerSpawningFunc<T>(typeName: String, spawningFunc: (Array<SpawnArgument>) -> Option<T>): Bool where T <: Distributable & Proxyable<T> & Spawnable<T>
```

功能：为给定的 actor 类型名注册创建函数，使集群后续可以按该类型名创建 actor。

参数：

- `typeName: String` — 与该 actor 类型关联的唯一类型名。
- `spawningFunc: (Array<SpawnArgument>) -> Option<T>` — 根据参数列表构造 actor 实例的函数。

返回值：

- `Bool` — 若创建函数已注册返回 `true`，若已存在则返回 `false`。

### func registerSpawnParameterType\<T>()

```cangjie
static func registerSpawnParameterType<T>(typeName: String): Bool where T <: Serializable<T> & TypeSerializable
```

功能：为给定的类型名注册创建函数的参数类型，以便可以安全地传输到集群中的另一个节点。

参数：

- `typeName: String` — 与该参数类型关联的唯一类型名。

返回值：

- `Bool` — 若类型已注册返回 `true`，若已存在则返回 `false`。

### func getSpawningFunc()

```cangjie
static func getSpawningFunc(typeName: String): Option<(Array<SpawnArgument>) -> Option<Distributable>>
```

功能：获取给定类型名的创建函数。

参数：

- `typeName: String` — 要查找创建函数的类型名。

返回值：

- `Option<(Array<SpawnArgument>) -> Option<Distributable>>` — 找到时返回 `Some(f)`，否则返回 `None`。

## interface ActorHost

```cangjie
public interface ActorHost
```

功能：分布式 actor 系统中用于导出与取消导出分布式 actor 的主机接口。

### func export()

```cangjie
func export(name: String, a: Distributable): Bool
```

功能：以指定名称导出一个 actor 实例。

参数：

- `name: String` — 用于注册 actor 的名称。
- `a: Distributable` — 待导出的 actor 实例，需实现 `Distributable`。

返回值：

- `Bool` — 导出成功返回 `true`；若名称已被占用返回 `false`。

异常：

- `ActorSystemException` — 对于任何系统特定错误则抛出。

### func unexport()

```cangjie
func unexport(name: String): Bool
```

功能：取消导出指定名称的 actor。

参数：

- `name: String` — 要取消导出的 actor 名称。

返回值：

- `Bool` — 取消导出成功返回 `true`；未找到返回 `false`。

异常：

- `ActorSystemException` — 对于任何系统特定错误则抛出。

### func getHostInfo()

```cangjie
func getHostInfo(): HostInfo
```

功能：获取主机的主机信息。

返回值：

- `HostInfo` — 标识此主机的主机信息。

## interface HostInfo

```cangjie
public interface HostInfo <: Serializable<HostInfo> & TypeSerializable & Equatable<HostInfo> & Hashable & ToString
```

功能：标识远程 actor 主机的主机信息接口。此接口提供创建客户端和获取序列化类型信息的方法。

实现接口：
- `Serializable`
- `TypeSerializable`
- `Equatable`
- `Hashable`
- `ToString`

### func createClient()

```cangjie
func createClient(): ActorClient
```

功能：创建用于连接到此主机的客户端。

返回值：

- `ActorClient` — 可以连接到此主机的客户端实例。

### func getTypeName()

```cangjie
func getTypeName(): String
```

功能：获取主机信息的类型名称，用于序列化和反序列化。

返回值：

- `String` — 主机信息的类型名称。

### func deserialize()

```cangjie
static func deserialize(dataModel: DataModel): HostInfo
```

功能：将数据模型反序列化为主机信息。这是一个默认实现，不应直接调用。`HostInfo` 的具体实现应重写此方法。

参数：

- `dataModel: DataModel` — 要反序列化的数据模型。

返回值：

- `HostInfo` — 反序列化后的主机信息。

异常：

- `Exception` — 如果调用此默认实现则抛出。

## interface Distributable

```cangjie
public interface Distributable
```

功能：所有分布式 actor 为支持远程通信需实现的共用接口。该接口提供将远程 receiver 调用分发到底层 actor 实例，以及访问元数据所需的方法。

### func getMetadata()

```cangjie
func getMetadata(): Metadata
```

功能：获取 actor 的元数据，包括其所有 receiver 信息、描述与自定义数据。

返回值：

- `Metadata` — 描述 actor 接口的元数据。

### func dispatchTell()

```cangjie
func dispatchTell(receiverName: String, args: Array<DataModel>, config: ReceiverConfig): Unit
```

功能：以 `Tell` 方式向 actor 分发调用，不期待返回值。

参数：

- `receiverName: String` — receiver 函数名称。
- `args: Array<DataModel>` — receiver 的序列化参数。
- `config: ReceiverConfig` — 调用配置。

异常：

- `ReceiverNotFoundException` — 未找到 receiver 函数时抛出。
- `IllegalArgumentException` — 如果参数无效则抛出。

### func dispatchAsk()

```cangjie
func dispatchAsk(receiverName: String, args: Array<DataModel>, config: ReceiverConfig): DistributedActorFuture<DataModel>
```

功能：以 `Ask` 方式向 actor 分发调用，并返回携带序列化结果的 future。

参数：

- `receiverName: String` — receiver 函数名称。
- `args: Array<DataModel>` — receiver 的序列化参数。
- `config: ReceiverConfig` — 调用配置。

返回值：

- `DistributedActorFuture<DataModel>` — 成功值中包含序列化结果载荷的 future。

异常：

- `ReceiverNotFoundException` — 未找到 receiver 函数时抛出。
- `IllegalArgumentException` — 如果参数无效则抛出。

## interface Proxyable<T>

```cangjie
public interface Proxyable<T> where T <: Distributable
```

功能：可被代理为类型化代理的分布式 actor 接口。

### func getProxy()

```cangjie
static func getProxy(proxy: ActorProxy): T
```

功能：从 `ActorProxy` 返回分布式 actor 的类型化代理实例。

参数：

- `proxy: ActorProxy` — 表示远程 actor 的 actor 代理。

返回值：

- `T` — 与接口 receiver 对应的类型化代理，提供与接口声明一致的方法。

## interface Spawnable\<T>

```cangjie
public interface Spawnable<T> where T <: Distributable
```

功能：可在集群中被动态创建的分布式 actor 接口。任何打算在集群中被创建的 actor 接口，都需要实现该接口。

### func typeName()

```cangjie
static func typeName(): String
```

功能：返回用于在集群中注册和查找其构造函数的唯一类型名。

返回值：

- `String` — 该 actor 类型的唯一类型名。

### func spawnWith()

```cangjie
static func spawnWith(args: Array<SpawnArgument>): Option<T>
```

功能：根据给定的参数列表创建一个新的 actor 实例。具体实现负责校验并解码参数，并调用正确的构造函数。

参数：

- `args: Array<SpawnArgument>` — 用于构造 actor 实例的参数列表。

返回值：

- `Option<T>` — 创建成功返回 `Some(T)`，若创建失败（如参数无效）返回 `None`。

异常：

- `IllegalArgumentException` — 如果参数无效则抛出。

## interface TypeSerializable

```cangjie
public interface TypeSerializable
```

功能：用于提供 Cangjie 类型类型模式（`TypeModel`）的接口。

### func typeModel()

```cangjie
static func typeModel(): TypeModel
```

功能：返回描述该类型结构的 `TypeModel`。

返回值：

- `TypeModel` — 用于生成元数据与 Receiver 校验的结构描述。

说明：

- 框架已为整数（`Int8`-`Int64`、`UInt8`-`UInt64`）、浮点数（`Float16`-`Float64`）、`Bool`、`Unit`、`String`、`Array<T>`、`Option<T>`、`ArrayList<T>`、`HashSet<T>` 与 `HashMap<K, V>` 提供默认实现，前提是其中包含的类型满足相应约束。自定义类型应实现该接口以参与分布式元数据生成。
