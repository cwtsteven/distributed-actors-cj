# 结构体

## struct ReceiverConfig

```cangjie
public struct ReceiverConfig <: Equatable<ReceiverConfig> {
  public static let default = ReceiverConfig()
  public init(priority!: Int64 = 5)
}
```

功能：Receiver 函数调用的配置，包含优先级与其他调用参数。

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

功能：使用标准优先级设置的默认 `ReceiverConfig` 实例。

### operator ==()

```cangjie
public override operator func ==(other: ReceiverConfig): Bool
```

功能：判断两个 `ReceiverConfig` 是否相等。

参数：

- `other: ReceiverConfig` — 待比较的另一个配置。

返回值：

- `Bool` — 相等返回 `true`，否则 `false`。

### operator !=()

```cangjie
public override operator func !=(other: ReceiverConfig): Bool
```

功能：判断两个 `ReceiverConfig` 是否不相等。

参数：

- `other: ReceiverConfig` — 待比较的另一个配置。

返回值：

- `Bool` — 不相等返回 `true`，否则 `false`。
