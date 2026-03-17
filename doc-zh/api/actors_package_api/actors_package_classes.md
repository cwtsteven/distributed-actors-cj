# 类

## class DistributedActorFuture\<T>

```cangjie
public open class DistributedActorFuture<T>
```

功能：分布式 actor 调用使用的基础 future 类型。它提供阻塞/非阻塞结果获取、惰性结果映射以及传输转换能力。与本地 `ActorFuture` 不同，该类型可能暴露远程传输或 actor 系统错误。

## class ActorFuture\<T>

```cangjie
public class ActorFuture<T>
```

功能：表示提交给本地 Actor 的闭包的待处理结果。`ActorFuture<T>` 继承 `DistributedActorFuture<T>` 的全部获取和转换 API，并增加本地任务执行语义。

### func get()

```cangjie
public func get(): T
```

功能：阻塞当前线程直到闭包执行完成；若闭包抛出异常或错误，本方法将抛出相同的异常或错误。

返回值：

- `T` — 对应闭包的执行结果。

### func get(Duration)

```cangjie
public func get(timeout: Duration): Option<T>
```

功能：阻塞当前线程直到超时到期或结果就绪。若结果已准备好则返回结果，否则返回 `None`。若产生异常或错误，本方法会抛出相同的异常或错误。`timeout = 0` 表示无限等待，与调用 `get()` 等效。

参数：

- `timeout: Duration` — 最长等待时间。

返回值：

- `Option<T>` — 在超时时间内未就绪返回 `None`，否则返回结果值。

### func tryGet()

```cangjie
public func tryGet(): Option<T>
```

功能：若结果已就绪则立刻返回，否则返回 `None`。若结果为异常或错误，本方法将抛出相同的异常或错误。

返回值：

- `Option<T>` — 未就绪返回 `None`，否则返回结果值。

### func map\<U>()

```cangjie
public func map<U>(transform: (T) -> U): DistributedActorFuture<U>
```

功能：创建一个派生 future，在不生成新任务的前提下变换成功结果。异常与错误会被原样透传。

参数：

- `transform: (T) -> U` — 将成功值映射为新值的函数。

返回值：

- `DistributedActorFuture<U>` — 惰性解析的派生 future。

### func toDataModel()

```cangjie
public func toDataModel(): DistributedActorFuture<DataModel>
```

功能：将可序列化 future 转换为以 `DataModel` 表示成功结果的传输 future。

返回值：

- `DistributedActorFuture<DataModel>` — 携带序列化结果载荷的派生分布式 future。

### static func fromDataModel()

```cangjie
public static func fromDataModel(actorFuture: DistributedActorFuture<DataModel>): DistributedActorFuture<T>
```

功能：将序列化数据的传输 future 转换回类型化 future。

参数：

- `actorFuture: DistributedActorFuture<DataModel>` — 序列化后的远程结果。

返回值：

- `DistributedActorFuture<T>` — 按需反序列化成功载荷的类型化分布式 future。

## class SequentialDispatcher

```cangjie
public class SequentialDispatcher {
  public init(enableReceiverPriority!: Bool = false)
}
```

功能：在专用线程上按顺序排队并执行闭包的调度器，并提供提交闭包的方法；支持基于优先级的调度。

通常无需直接使用该类，推荐通过 [@Actor](../macros/macros_package_api/macros_package_macros.md#actor-宏) 宏。

### init(Bool)

```cangjie
public init(enableReceiverPriority!: Bool = false)
```

功能：创建 `SequentialDispatcher` 并启动线程以执行提交给它的闭包。

参数：

- `enableReceiverPriority!: Bool` — 若为 `true`，启用优先级特性，使高优先级闭包先执行；默认为 `false`。

### func post<T>(() -> T, ReceiverConfig)

```cangjie
public func post<T>(f: () -> T, config!: ReceiverConfig = ReceiverConfig.default): ActorFuture<T>
```

功能：向调度器提交闭包，闭包将在调度器线程上排队并执行。返回 [ActorFuture\<T>](actors_package_classes.md#class-actorfuture) 作为待处理结果。若构造时启用了 `enableReceiverPriority`，高优先级闭包将被优先执行；否则 [ReceiverConfig](./actors_package_structs.md#struct-receiverconfig) 中的 `priority` 值无效。

参数：

- `f: () -> T` — 提交给调度器的闭包。
- `config!: ReceiverConfig` — 提交任务的配置，默认为 `ReceiverConfig.default`。

返回值：

- [ActorFuture\<T>](actors_package_classes.md#class-actorfuture) — 提供用于获取该闭包结果的待处理对象。

异常：

- `IllegalArgumentException` — 如果优先级超出范围则抛出。

### func tell(() -> Unit, ReceiverConfig)

```cangjie
public func tell(f: () -> Unit, config!: ReceiverConfig = ReceiverConfig.default): Unit
```

功能：以 `Tell` 模式（即发即忘）提交闭包，不关心返回值。

参数：

- `f: () -> Unit` — 提交给调度器的闭包。
- `config!: ReceiverConfig` — 提交任务的配置，默认为 `ReceiverConfig.default`。

异常：

- `IllegalArgumentException` — 如果优先级超出范围则抛出。
