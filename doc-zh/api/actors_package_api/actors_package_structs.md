# 结构体

## struct ReceiverConfig

```cangjie
public struct ReceiverConfig <: Equatable<ReceiverConfig> {
  public static let default = ReceiverConfig()
  public init(priority!: Int64 = 5)
}
```

功能：Receiver 调用的配置，包含优先级等信息。

实现接口：
- `Equatable`

### init(Int64)

```cangjie
public init(priority!: Int64 = 5)
```

功能：创建具有指定优先级的 `ReceiverConfig`。

参数：

- `priority!: Int64` — Receiver 调用的优先级，取值 1 到 10；默认 5。

### static let default

```cangjie
public static let default = ReceiverConfig()
```

功能：使用默认优先级的 `ReceiverConfig` 实例。

### prop priority

```cangjie
public let priority: Int64
```

功能：该 Receiver 调用使用的优先级。

取值：

- `Int64` — 当前 Receiver 调用配置的优先级值。

### operator ==()

```cangjie
public override operator func ==(other: ReceiverConfig): Bool
```

功能：比较两个 `ReceiverConfig` 是否相等。

参数：

- `other: ReceiverConfig` — 待比较的另一个 `ReceiverConfig`。

返回值：

- `Bool` — 若两个 `ReceiverConfig` 的所有字段都相同则返回 `true`，否则返回 `false`。

### operator !=()

```cangjie
public override operator func !=(other: ReceiverConfig): Bool
```

功能：比较两个 `ReceiverConfig` 是否不相等。

参数：

- `other: ReceiverConfig` — 待比较的另一个 `ReceiverConfig`。

返回值：

- `Bool` — 若任一字段不同则返回 `true`，否则返回 `false`。

## 常量

### const MAX_PRIORITY

```cangjie
public const MAX_PRIORITY = 10
```

功能：Receiver 调用的最大优先级值。优先级值必须在 `MIN_PRIORITY` 和 `MAX_PRIORITY` 之间。

### const MIN_PRIORITY

```cangjie
public const MIN_PRIORITY = 1
```

功能：Receiver 调用的最小优先级值。优先级值必须在 `MIN_PRIORITY` 和 `MAX_PRIORITY` 之间。
