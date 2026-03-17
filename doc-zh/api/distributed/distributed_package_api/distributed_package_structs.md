# 结构体

## struct ActorInfo

```cangjie
public struct ActorInfo <: ToString {
  public ActorInfo(
    public let name!: String,
    public let metadata!: Metadata
  )
}
```

功能：包含 Actor 的名称与其元数据。

### init(String, Metadata)

```cangjie
public ActorInfo(
  public let name!: String,
  public let metadata!: Metadata
:)
```

功能：以给定名称与元数据创建 `ActorInfo`。

参数：

- `name!: String` — Actor 名称。
- `metadata!: Metadata` — 描述该 Actor 接口的元数据。

### func toString()

```cangjie
public override func toString(): String
```

功能：将 `ActorInfo` 转为字符串。

返回值：

- `String` — `ActorInfo`的字符串表示。

## struct FieldModel

```cangjie
public struct FieldModel <: ToString & Equatable<FieldModel> {
  public FieldModel(
    public let name!: String,
    public let description!: String,
    public let typeModel!: TypeModel
  )
}
```

功能：结构体字段信息，包括名称、类型与描述。

### init(String, String, TypeModel)

```cangjie
public FieldModel(
  public let name!: String,
  public let description!: String,
  public let typeModel!: TypeModel
:)
```

功能：创建 `FieldModel`。

参数：

- `name!: String` — 字段名。
- `description!: String` — 字段描述。
- `typeModel!: TypeModel` — 字段类型信息。

### func toString()

```cangjie
public override func toString(): String
```

功能：将 `FieldModel` 转为字符串。

返回值：

- `String` — `FieldModel`的字符串表示。

### operator ==()

```cangjie
public override operator func ==(other: FieldModel): Bool
```

功能：判断两个 `FieldModel` 是否相等。

参数：

- `other: FieldModel` — 另一个字段。

返回值：

- `Bool` — 相等返回 `true`，否则 `false`。

### operator !=()

```cangjie
public override operator func !=(other: FieldModel): Bool
```

功能：判断两个 `FieldModel` 是否不相等。

参数：

- `other: FieldModel` — 另一个字段。

返回值：

- `Bool` — 不相等返回 `true`，否则 `false`。

## struct Metadata

```cangjie
public struct Metadata <: ToString {
  public Metadata(
    public let receivers!: Array<ReceiverInfo>,
    public let description!: String,
    public let customInfo!: JsonObject
  )
}
```

功能：关于 Actor 接口的元数据，包括 Receiver 信息、描述与自定义数据。

### init(Array<ReceiverInfo>, String, JsonObject)

```cangjie
public Metadata(
  public let receivers!: Array<ReceiverInfo>,
  public let description!: String,
  public let customInfo!: JsonObject
:)
```

功能：以给定 Receiver 信息、描述与自定义数据创建 `Metadata`。

参数：

- `receivers!: Array<ReceiverInfo>` — 接口中所有 Receiver 的信息。
- `description!: String` — 接口的人类可读描述。
- `customInfo!: JsonObject` — JSON 格式的自定义元数据。

### func toString()

```cangjie
public override func toString(): String
```

功能：将 `Metadata` 转为字符串。

返回值：

- `String` — `Metadata`的字符串表示。

## struct ReceiverInfo

```cangjie
public struct ReceiverInfo <: ToString {
  public ReceiverInfo(
    public let description!: String,
    public let customInfo!: JsonObject,
    public let methodName!: String,
    public let paramSchema!: Array<ReceiverParameter>,
    public let retTypeModel!: TypeModel,
    public let mode!: ReceiverMode
  )
}
```

功能：某个 Receiver 的信息，包括描述、自定义信息、方法名、参数模式、返回类型与调用模式（Ask/Tell）。

### init(String, JsonObject, String, Array<ReceiverParameter>, TypeModel, ReceiverMode)

```cangjie
public ReceiverInfo(
  public let description!: String,
  public let customInfo!: JsonObject,
  public let methodName!: String,
  public let paramSchema!: Array<ReceiverParameter>,
  public let retTypeModel!: TypeModel,
  public let mode!: ReceiverMode
)
```

功能：以给定信息创建 `ReceiverInfo`。

参数：

- `description!: String` — Receiver 的人类可读描述。
- `customInfo!: JsonObject` — Receiver 的自定义元数据。
- `methodName!: String` — Receiver 方法名。
- `paramSchema!: Array<ReceiverParameter>` — 参数模式信息。
- `retTypeModel!: TypeModel` — 返回值类型信息。
- `mode!: ReceiverMode` — Receiver 的调用模式（Ask/Tell）。

### func toString()

```cangjie
public override func toString(): String
```

功能：将 `ReceiverInfo` 转为字符串。

返回值：

- `String` — `ReceiverInfo` 的字符串表示。

## struct ReceiverParameter

```cangjie
public struct ReceiverParameter <: ToString {
  public ReceiverParameter(
    public let name!: String,
    public let typeModel!: TypeModel,
    public let description!: String
  )
}
```

功能：Receiver 参数信息，包括名称、类型与描述。

### init(String, TypeModel, String)

```cangjie
public ReceiverParameter(
  public let name!: String,
  public let typeModel!: TypeModel,
  public let description!: String
)
```

功能：创建 `ReceiverParameter`。

参数：

- `name!: String` — 参数名。
- `typeModel!: TypeModel` — 参数类型信息。
- `description!: String` — 参数描述。

### func toString()

```cangjie
public override func toString(): String
```

功能：将 `ReceiverParameter` 转为字符串。

返回值：

- `String` —  `ReceiverParameter` 的字符串表示。

## struct SpawnArgument

```cangjie
public struct SpawnArgument <: Serializable<SpawnArgument> & TypeSerializable {
  public let typeName: String
  public let value: Any
}
```

功能：表示在集群中创建分布式 actor 时使用的单个已类型化参数。每个 `SpawnArgument` 同时携带类型名和序列化后的值。


### func create\<T>()

```cangjie
public static func create<T>(typeName: String, value: T): SpawnArgument where T <: Serializable<T> & TypeSerializable
```

功能：为实现了 `Serializable` 和 `TypeSerializable` 的值创建一个新的 `SpawnArgument`。

参数：

- `typeName: String` — 与该参数类型关联的唯一类型名。
- `value: T` — 要包装的参数值。

返回值：

- `SpawnArgument` — 创建出的创建参数实例。

### func serialize()

```cangjie
public func serialize(): DataModel
```

功能：将 `SpawnArgument` 序列化为 `DataModel`。

返回值：

- `DataModel` — `SpawnArgument` 的序列化表示。

异常：

- `ActorSystemException` — 当找不到与给定 `typeName` 对应的序列化函数时抛出。

### func deserialize()

```cangjie
public static func deserialize(dataModel: DataModel): SpawnArgument
```

功能：从 `DataModel` 表示反序列化出一个 `SpawnArgument`。

参数：

- `dataModel: DataModel` — 创建参数的序列化数据。

返回值：

- `SpawnArgument` — 反序列化得到的创建参数实例。

异常：

- `DataModelException` — 当数据模型结构或字段非法时抛出。
- `ActorSystemException` — 当找不到与引用的 `typeName` 对应的反序列化函数时抛出。

### func typeModel()

```cangjie
public static func typeModel(): TypeModel
```

功能：返回 `SpawnArgument` 的结构化类型模式，用于元数据与模式描述。

返回值：

- `TypeModel` — 描述 `SpawnArgument` 字段的结构类型模式。
