# 接口

## interface ActorClient

```cangjie
public interface ActorClient
```

功能：分布式 Actor 系统中，向远程 Actor 提供访问能力的客户端接口。

### prop id

```cangjie
prop id: String
```

功能：客户端唯一标识。

### func find()

```cangjie
func find(name: String): Option<ActorInfo>
```

功能：按名称查找 Actor 并返回其信息。

参数：

- name: String — 要查找的 Actor 名称。

返回值：

- `Option<ActorInfo>` — 找到返回 `Some(ActorInfo)`，否则返回 `None`。

### func findAll()

```cangjie
func findAll(): Array<ActorInfo>
```

功能：查找分布式系统中注册的全部 Actor。

返回值：

- `Array<ActorInfo>` — 所有已注册 Actor 的信息数组。

### func remoteCall()

```cangjie
func remoteCall(invokeInfo: InvokeInfo): Unit
```

功能：调用 Actor 的 Receiver，并将结果填充到提供的 Future 中。

参数：

- `invokeInfo: InvokeInfo` — 远程调用所需信息。

## interface ActorHost

```cangjie
public interface ActorHost
```

功能：分布式 Actor 系统中管理 Actor 注册与注销的主机接口。

### func register()

```cangjie
func register(name: String, a: Distributable): Bool
```

功能：以指定名称在系统中注册 Actor 实例。

参数：

- `name: String` — 注册名。
- `a: Distributable` — 待注册的 Actor，需实现 `Distributable`。

返回值：

- `Bool` — 成功返回 `true`；若名称已被占用返回 `false`。

### func deregister()

```cangjie
func deregister(name: String): Bool
```

功能：从系统移除指定 Actor。

参数：

- `name: String` — 要移除的 Actor 名称。

返回值：

- `Bool` — 成功返回 `true`；未找到返回 `false`。

## interface Distributable

```cangjie
public interface Distributable
```

功能：分布式 Actor 接口需实现的接口，提供远程调用与元数据访问所需方法。

### func getMetadata()

```cangjie
func getMetadata(): Metadata
```

功能：获取 Actor 的元数据，包括 Receiver 信息、描述与自定义数据。

返回值：

- `Metadata` — 描述 Actor 接口的元数据。

### func dispatchTell()

```cangjie
func dispatchTell(receiverName: String, args: Array<DataModel>, config: ReceiverConfig): Unit
```

功能：以 Tell 方式分发调用，不期待返回值。

参数：

- `receiverName: String` — Receiver 名称。
- `args: Array<DataModel>` — Receiver 的序列化参数。
- `config: ReceiverConfig` — 调用配置。

异常：

- `ReceiverNotFoundException` — 未找到 Receiver 时抛出。

### func dispatchAsk()

```cangjie
func dispatchAsk(receiverName: String, args: Array<DataModel>, config: ReceiverConfig): LocalWaitable
```

功能：以 Ask 方式分发调用，并返回可等待的对象以获取结果。

参数：

- `receiverName: String` — Receiver 名称。
- `args: Array<DataModel>` — Receiver 的序列化参数。
- `config: ReceiverConfig` — 调用配置。

返回值：

- `LocalWaitable` — 可用于获取结果的 waitable 对象。

异常：

- `ReceiverNotFoundException` — 未找到 Receiver 时抛出。

## interface LocalWaitable

```cangjie
public interface LocalWaitable
```

功能：可在本地等待并提供序列化结果的对象接口。

### func getResult()

```cangjie
func getResult(): DataModel
```

功能：获取操作的序列化结果。

返回值：

- `DataModel` — 序列化结果。

### func fromActorFuture<T>()

```cangjie
static func fromActorFuture<T>(obj: Object): LocalWaitable where T <: Serializable<T>
```

功能：从 ActorFuture（可序列化类型）创建 `LocalWaitable`。

参数：

- `obj: Object` — 要转换的 ActorFuture 对象。

返回值：

- `LocalWaitable` — 提供该 ActorFuture 序列化结果的 `LocalWaitable`。

## interface TypeSerializable

```cangjie
public interface TypeSerializable
```

功能：用于声明可在分布式环境中序列化的类型的标记接口，类型通过返回 `TypeModel` 描述自身的类型结构。

### func typeModel()

```cangjie
static func typeModel(): TypeModel
```

功能：返回该类型的静态 `TypeModel` 描述。实现应保持返回的模型与真实编码格式一致。

返回值：

- `TypeModel` — 用于生成元数据与 Receiver 校验的结构描述。

说明：

- 框架已为整数（`Int8`-`Int64`、`UInt8`-`UInt64`）、浮点数（`Float16`-`Float64`）、`Bool`、`Unit`、`String`、`Array<T>` 与 `Option<T>`（当 `T` 同样实现 `TypeSerializable` 时）提供默认实现。自定义类型需实现该接口以参与分布式元数据生成。
