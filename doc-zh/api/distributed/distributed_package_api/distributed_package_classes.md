# 类

## class ActorNotFoundException

```cangjie
public class ActorNotFoundException <: Exception {
  public init(name: String)
}
```

功能：当找不到指定名称的 actor 时抛出。

### init(String)

```cangjie
public init(name: String)
```

功能：创建包含找不到的 Actor 名称信息的 `ActorNotFoundException`。

参数：

- `name: String` — 找不到的 actor 的名称。

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

### func tell()

```cangjie
public func tell(receiverName: String, args: Array<DataModel>, config!: ReceiverConfig = ReceiverConfig.default): Unit
```

功能：以 `Tell` 模式调用远程 actor 的 receiver 函数（即发即忘，不期待返回值）。

参数：

- `receiverName: String` — receiver 函数名称。
- `args: Array<DataModel>` — receiver 的序列化参数。
- `config!: ReceiverConfig` — 调用配置，默认 `ReceiverConfig.default`。

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

## class ActorSystemException

```cangjie
public class ActorSystemException <: Exception {
  public init(msg: String)
}
```

功能：actor 系统相关错误的通用异常。

### init(String)

```cangjie
public init(msg: String)
```

功能：创建带自定义错误信息的 `ActorSystemException`。

参数：

- `msg: String` — 描述 actor 系统错误的消息。

## class DistributedFuture

```cangjie
public class DistributedFuture
```

功能：表示远程 receiver 调用待处理结果的具体类，提供获取与兑现序列化结果的方法。

### func get()

```cangjie
public func get(): DataModel
```

功能：阻塞当前线程直到结果就绪并返回序列化结果。若远程 receiver 抛出异常或错误且可序列化，则本方法抛出相同的异常或错误；否则抛出 [RemoteReceiverException](./distributed_package_classes.md#class-remotereceiverexception)。

返回值：

- `DataModel` — 操作的序列化结果。

### func get(Duration)

```cangjie
public func get(timeout: Duration): Option<DataModel>
```

功能：阻塞当前线程直到超时到期或结果就绪。若结果已准备好则返回结果，否则返回 `None`。若远程 receiver 抛出异常或错误且可序列化，则本方法抛出相同的异常或错误；否则抛出 [RemoteReceiverException](./distributed_package_classes.md#class-remotereceiverexception)。`timeout = 0` 表示无限等待，与调用 `get()` 等效。

参数：

- `timeout: Duration` — 最长等待时间。

返回值：

- `Option<DataModel>` — 超时未就绪返回 `None`，否则返回序列化结果。

### func tryGet()

```cangjie
public func tryGet(): Option<DataModel>
```

功能：若结果已就绪则立刻返回序列化结果，否则返回 `None`。若远程 receiver 抛出异常或错误且可序列化，则本方法抛出相同的异常或错误；否则抛出 [RemoteReceiverException](./distributed_package_classes.md#class-remotereceiverexception)。

返回值：

- `Option<DataModel>` — 未就绪返回 `None`，否则返回序列化结果。

### func fulfill()

```cangjie
public func fulfill(dataModel: DataModel): Bool
```

功能：以序列化结果值完成 Future。

参数：

- `dataModel: DataModel` — 用于完成 Future 的序列化结果。

返回值：

- `Bool` — 成功完成返回 `true`，若已完成返回 `false`。

## class ReceiverNotFoundException

```cangjie
public class ReceiverNotFoundException <: Exception {
  public init(name: String, receiverName: String)
}
```

功能：当在指定的 actor 接口中找不到 receiver 函数时抛出。

### init(String, String)

```cangjie
public init(name: String, receiverName: String)
```

功能：创建包含接口名与找不到的 receiver 名称信息的 `ReceiverNotFoundException`。

参数：

- `name: String` — actor 接口名称。
- `receiverName: String` — 找不到的 receiver 函数名称。

## class RemoteException

```cangjie
public class RemoteException <: Exception {
  public init()
}
```

功能：分布式 actor 通信过程中远程连接失败时抛出。

### init()

```cangjie
public init()
```

功能：创建默认“远程连接失败”消息的 `RemoteException`。

## class RemoteReceiverException

```cangjie
public class RemoteReceiverException <: Exception & Serializable<RemoteReceiverException> {
  public init(e: Exception)
  public init(e: Error)
  public override func serialize(): DataModel
  public static func deserialize(dm: DataModel): RemoteReceiverException
}
```

功能：包装远程 receiver 执行中抛出的不可序列化异常或错误；该异常可序列化以便网络传输。

实现接口：
- `Serializable`

### init(Exception)

```cangjie
public init(e: Exception)
```

功能：从 `Exception` 创建 `RemoteReceiverException`，并捕获其堆栈信息。

参数：

- `e: Exception` — 要包装的异常。

### init(Error)

```cangjie
public init(e: Error)
```

功能：从 `Error` 创建 `RemoteReceiverException`，并捕获其堆栈信息。

参数：

- `e: Error` — 要包装的错误。

### func serialize()

```cangjie
public override func serialize(): DataModel
```

功能：将 `RemoteReceiverException` 序列化以进行网络传输。

返回值：

- `DataModel` — 异常的序列化表示。

### func deserialize()

```cangjie
public static func deserialize(dm: DataModel): RemoteReceiverException
```

功能：从 `DataModel` 反序列化得到 `RemoteReceiverException`。

参数：

- `dm: DataModel` — 异常的序列化数据。

返回值：

- `RemoteReceiverException` — 反序列化得到的异常实例。
