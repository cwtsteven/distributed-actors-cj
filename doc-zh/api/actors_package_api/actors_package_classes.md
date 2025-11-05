# 类

## `class ActorFuture<T>`

```cangjie
public class ActorFuture<T>
```

功能：表示提交给 Actor 的闭包的待处理结果。提供线程安全的阻塞与非阻塞结果获取方法，并支持超时。

### func get()

```cangjie
public func get(): T
```

功能：阻塞当前线程直到闭包执行完成；若闭包抛出异常或错误，本方法将抛出相同的异常或错误。

返回值：

- `T` — 对应闭包计算得到的结果。

### func get(Duration)

```cangjie
public func get(timeout: Duration): Option<T>
```

功能：阻塞当前线程直到超时到期或结果就绪。若结果已准备好则返回结果，否则返回 `None`。若产生异常或错误，本方法会传播相同的异常或错误。`timeout = 0` 表示无限等待。

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

## class SequentialDispatcher

```cangjie
public class SequentialDispatcher {
  public init(enableReceiverPriority!: Bool = false)
}
```

功能：一个 `SequentialDispatcher` 实例代表 Cangjie 系统中的一个线程。用户可以向该实例提交闭包，这些闭包将被排队并在该线程上执行。

通常无需直接使用该类，推荐通过 [@Actor](../macros/macros_package_api/macros_package_macros.md#actor-宏) 宏。

### init(Bool)

```cangjie
public init(enableReceiverPriority!: Bool = false)
```

功能：创建 `SequentialDispatcher` 并启动对应线程以处理用户提交的闭包。

参数：

- `enableReceiverPriority!: Bool` — 若为 `true`，启用优先级特性，使高优先级闭包先执行；默认为 `false`。

### func post<T>(() -> T, ReceiverConfig)

```cangjie
public func post<T>(f: () -> T, config!: ReceiverConfig = ReceiverConfig.default): ActorFuture<T>
```

功能：向调度器提交闭包，闭包将在调度器线程上排队并执行。返回 [ActorFuture<T>](actors_package_classes.md#class-actorfuture) 作为待处理结果。若构造时启用了 `enableReceiverPriority`，高优先级闭包将被优先执行；否则 `priority` 值无效。

参数：

- `f: () -> T` — 提交给 Actor 的闭包。
- `config!: ReceiverConfig` — 提交任务的配置，默认为 `ReceiverConfig.default`。

返回值：

- [ActorFuture<T>](actors_package_classes.md#class-actorfuture) — 用于获取闭包计算结果。

### func tell(() -> Unit, ReceiverConfig)

```cangjie
public func tell(f: () -> Unit, config!: ReceiverConfig = ReceiverConfig.default): Unit
```

功能：以 Tell 模式提交闭包（不关心返回值）。

参数：

- `f: () -> Unit` — 提交给 Actor 的闭包。
- `config!: ReceiverConfig` — 提交任务的配置，默认为 `ReceiverConfig.default`。
