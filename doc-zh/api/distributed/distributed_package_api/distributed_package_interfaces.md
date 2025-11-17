# 接口

## interface ActorClient

```cangjie
public interface ActorClient
```

功能：为连接到的 `ActorHost` 所 *导出* 的 actor 提供远程访问能力的客户端接口。

### prop id

```cangjie
prop id: String
```

功能：actor client 的唯一标识符。

### func find()

```cangjie
func find(name: String): Option<ActorInfo>
```

功能：按名称查找 actor 并返回其信息。

参数：

- name: String — 要查找的 actor 名称。

返回值：

- `Option<ActorInfo>` — 找到返回 `Some(ActorInfo)`，否则返回 `None`。

### func findAll()

```cangjie
func findAll(): Array<ActorInfo>
```

功能：查找对应 `ActorHost` 中导出的全部 actor。

返回值：

- `Array<ActorInfo>` — 所有已导出 actor 的信息数组。

### func remoteCall()

```cangjie
func remoteCall(invokeInfo: InvokeInfo): Unit
```

功能：根据调用信息对某个 actor 的 receiver 发起远程调用。

参数：

- `invokeInfo: InvokeInfo` — 关于远程调用的全部信息。

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

### func unexport()

```cangjie
func unexport(name: String): Bool
```

功能：取消导出指定名称的 actor。

参数：

- `name: String` — 要取消导出的 actor 名称。

返回值：

- `Bool` — 取消导出成功返回 `true`；未找到返回 `false`。

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

### func dispatchAsk()

```cangjie
func dispatchAsk(receiverName: String, args: Array<DataModel>, config: ReceiverConfig): LocalWaitable
```

功能：以 `Ask` 方式向 actor 分发调用，并返回可等待对象以获取结果。

参数：

- `receiverName: String` — receiver 函数名称。
- `args: Array<DataModel>` — receiver 的序列化参数。
- `config: ReceiverConfig` — 调用配置。

返回值：

- `LocalWaitable` — 可用于获取 receiver 调用待处理结果的可等待对象。

异常：

- `ReceiverNotFoundException` — 未找到 receiver 函数时抛出。

### func getProxy()

```cangjie
static func getProxy(name: String, client: ActorClient): ActorProxy
```

功能：返回该分布式接口对应的代理对象。

参数：

- `name: String` — 在分布式系统中注册的远程 actor 名称。
- `client: ActorClient` — 用于访问远程主机的客户端实例。

返回值：

- `ActorProxy` — 与接口 Receiver 对应的类型化代理，提供与接口声明一致的方法。

## interface LocalWaitable

```cangjie
public interface LocalWaitable
```

功能：所有本地 `ActorFuture<T>` 类型共用的接口，提供以序列化形式（`DataModel`）获取 Future 结果的方法。

### func getResult()

```cangjie
func getResult(): DataModel
```

功能：获取操作的序列化结果。若 receiver 抛出异常或错误，则会以序列化数据模型的形式返回。

返回值：

- `DataModel` — 操作的序列化结果。

### func fromActorFuture<T>()

```cangjie
static func fromActorFuture<T>(obj: Object): LocalWaitable where T <: Serializable<T>
```

功能：从可序列化类型的 `ActorFuture` 创建 `LocalWaitable`。

参数：

- `obj: Object` — 要转换的 `ActorFuture` 对象。

返回值：

- `LocalWaitable` — 提供该 `ActorFuture` 序列化结果的 `LocalWaitable`。


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

- 框架已为整数（`Int8`-`Int64`、`UInt8`-`UInt64`）、浮点数（`Float16`-`Float64`）、`Bool`、`Unit`、`String`、`Array<T>` 与 `Option<T>`（当 `T` 同样实现 `TypeSerializable` 时）提供默认实现。自定义类型应实现该接口以参与分布式元数据生成。