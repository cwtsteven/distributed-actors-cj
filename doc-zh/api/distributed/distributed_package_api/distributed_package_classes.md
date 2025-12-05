# 类

## class ActorProxy

```cangjie
public class ActorProxy {
  public ActorProxy(
    public let name: String,
    public let client: ActorClient
  )
}
```

功能：在分布式系统中与远程 actor 通信的代理类。`ActorProxy` 允许客户端在无需管理底层通信细节的情况下向远程 actor 发送消息或发起调用。

### init(String, ActorClient)

```cangjie
public ActorProxy(
  public let name: String,
  public let client: ActorClient
)
```

功能：创建用于与指定 actor client 中某个 actor 通信的 `ActorProxy`。

参数：

- `name: String` — 目标远程 actor 的名称。
- `client: ActorClient` — 连接到远程 actor 的客户端。

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
- `ActorSystemException` — 对于任何系统特定错误则抛出。

### func ask()

```cangjie
public func ask(receiverName: String, args: Array<DataModel>, config!: ReceiverConfig = ReceiverConfig.default): DistributedFuture
```

功能：以 `Ask` 模式调用远程 actor 的 receiver 函数，并返回表示待处理结果的 `DistributedFuture`。

参数：

- `receiverName: String` — receiver 函数名称。
- `args: Array<DataModel>` — receiver 的序列化参数。
- `config!: ReceiverConfig` — 调用配置，默认 `ReceiverConfig.default`。

返回值：

- `DistributedFuture` — 表示远程调用待处理结果的对象。

异常：

- `ActorNotFoundException` — 如果在客户端找不到 actor 则抛出。
- `ReceiverNotFoundException` — 如果找不到 receiver 则抛出。
- `RemoteException` — 如果远程连接失败则抛出。
- `ActorSystemException` — 对于任何系统特定错误则抛出。

## class DistributedFuture

```cangjie
public class DistributedFuture
```

功能：表示远程 receiver 调用待处理结果的具体类，提供获取与兑现序列化结果的方法。

### func get()

```cangjie
public func get(): DataModel
```

功能：阻塞当前线程直到结果就绪并返回序列化结果。

返回值：

- `DataModel` — 操作的序列化结果。

异常：

- `RemoteException` — 如果远程连接失败则抛出。
- `RemoteReceiverException` — 如果结果是远程 receiver 执行时抛出的异常或错误则抛出。
- `ActorSystemException` — 对于任何系统特定错误则抛出。

### func get(Duration)

```cangjie
public func get(timeout: Duration): Option<DataModel>
```

功能：阻塞当前线程直到超时到期或结果就绪。若结果已准备好则返回结果，否则返回 `None`。`timeout = 0` 表示无限等待，与调用 `get()` 等效。

参数：

- `timeout: Duration` — 最长等待时间。

返回值：

- `Option<DataModel>` — 超时未就绪返回 `None`，否则返回序列化结果。

异常：

- `RemoteException` — 如果远程连接失败则抛出。
- `RemoteReceiverException` — 如果结果是远程 receiver 执行时抛出的异常或错误则抛出。
- `ActorSystemException` — 对于任何系统特定错误则抛出。

### func tryGet()

```cangjie
public func tryGet(): Option<DataModel>
```

功能：若结果已就绪则立刻返回序列化结果，否则返回 `None`。

返回值：

- `Option<DataModel>` — 未就绪返回 `None`，否则返回序列化结果。

异常：

- `RemoteException` — 如果远程连接失败则抛出。
- `RemoteReceiverException` — 如果结果是远程 receiver 执行时抛出的异常或错误则抛出。
- `ActorSystemException` — 对于任何系统特定错误则抛出。

### func fulfill()

```cangjie
public func fulfill(dataModel: DataModel): Bool
```

功能：以序列化结果值完成 Future。

参数：

- `dataModel: DataModel` — 用于完成 Future 的序列化结果。

返回值：

- `Bool` — 成功完成返回 `true`，若已完成返回 `false`。

异常：

- `IllegalArgumentException` — 如果序列化结果无法被正确反序列化为有效的 Future 结果则抛出。

### func toActorFuture<T>()

```cangjie
public func toActorFuture<T>(): ActorFuture<T> where T <: Serializable<T>
```

功能：将 DistributedFuture 转换为本地 `ActorFuture`。

类型参数：

- `T` — 期望得到的可序列化类型。

返回值：

- `ActorFuture<T>` — 完成后包含已反序列化结果的 ActorFuture。
