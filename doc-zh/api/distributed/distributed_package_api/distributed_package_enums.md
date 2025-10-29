# 枚举

## enum ReceiverMode

```cangjie
public enum ReceiverMode <: ToString & Equatable<ReceiverMode> {
    | AskOnly
    | TellOnly
    | AskAndTell
}
```

功能：表示 Receiver 函数的调用模式，决定在分布式系统中 Receiver 可被如何调用。

### 取值

- `AskOnly` — 仅允许以 Ask 模式调用（期待返回值）
- `TellOnly` — 仅允许以 Tell 模式调用（即发即忘）
- `AskAndTell` — 既可 Ask 也可 Tell

### func toString()

```cangjie
public override func toString(): String
```

功能：将 `ReceiverMode` 转为字符串。

返回值：

- `String` — `ReceiverMode` 的字符串表示。

### operator ==()

```cangjie
public override operator func ==(other: ReceiverMode): Bool
```

功能：比较两个 `ReceiverMode` 是否相等。

参数：

- `other: ReceiverMode` — 另一个待比较的值。

返回值：

- `Bool` — 相等返回 `true`，否则 `false`。

### operator !=()

```cangjie
public override operator func !=(other: ReceiverMode): Bool
```

功能：比较两个 `ReceiverMode` 是否不相等。

参数：

- `other: ReceiverMode` — 另一个待比较的值。

返回值：

- `Bool` — 不相等返回 `true`，否则 `false`。

## enum TypeModel

```cangjie
public enum TypeModel <: ToString & Equatable<TypeModel> {
    | IntType
    | FloatType
    | BoolType
    | StringType
    | UnitType
    | StructType(Array<FieldModel>)
    | ListType(TypeModel)
}
```

功能：用于序列化与元数据生成的类型信息。描述分布式 Actor 通信中 Receiver 参数与返回值的类型。

### 取值

- `IntType` — 整型
- `FloatType` — 浮点型
- `BoolType` — 布尔型
- `StringType` — 字符串
- `UnitType` — 单元/void 类型
- `StructType(Array<FieldModel>)` — 结构体类型及其字段信息
- `ListType(TypeModel)` — 列表/数组类型及其元素类型

### func toString()

```cangjie
public override func toString(): String
```

功能：将 `TypeModel` 转为字符串。

返回值：

- `String` — `TypeModel` 的字符串表示。

### operator ==()

```cangjie
public override operator func ==(other: TypeModel): Bool
```

功能：比较两个 `TypeModel` 是否相等。

参数：

- `other: TypeModel` — 另一个待比较的值。

返回值：

- `Bool` — 相等返回 `true`，否则 `false`。

### operator !=()

```cangjie
public override operator func !=(other: TypeModel): Bool
```

功能：比较两个 `TypeModel` 是否不相等。

参数：

- `other: TypeModel` — 另一个待比较的值。

返回值：

- `Bool` — 不相等返回 `true`，否则 `false`。
