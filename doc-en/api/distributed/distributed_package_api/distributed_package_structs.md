# Structs

## struct ActorInfo

```cangjie
public struct ActorInfo <: ToString {
  public ActorInfo(
    public let name!: String,
    public let metadata!: Metadata
  )
}
```

Function: This struct contains the actor's name and its metadata.

### init(String, Metadata)

```cangjie
public ActorInfo(
  public let name!: String,
  public let metadata!: Metadata
)
```

Function: Creates an `ActorInfo` with the specified name and metadata.

Parameters:

- `name!: String` - The name of the actor.
- `metadata!: Metadata` - The metadata describing the actor interface.

### func toString()

```cangjie
public override func toString(): String
```

Function: Converts the `ActorInfo` to a string representation.

Return Value:

- String - A string representation of the `ActorInfo`.

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

Function: Information about a field in a struct type, including its name, type, and description.

### init(String, String, TypeModel)

```cangjie
public FieldModel(
  public let name!: String,
  public let description!: String,
  public let typeModel!: TypeModel
)
```

Function: Creates a `FieldModel` with the specified details.

Parameters:

- `name!: String` - The name of the field.
- `description!: String` - A description of the field.
- `typeModel!: TypeModel` - The type information for the field.

### func toString()

```cangjie
public override func toString(): String
```

Function: Converts the `FieldModel` to a string representation.

Return Value:

- `String` - A string representation of the `FieldModel`.

### operator ==()

```cangjie
public override operator func ==(other: FieldModel): Bool
```

Function: Compares two `FieldModel` instances for equality.

Parameters:

- `other: FieldModel` - The other `FieldModel` to compare with.

Return Value:

- `Bool` - Returns `true` if the FieldModels are equal, `false` otherwise.

### operator !=()

```cangjie
public override operator func !=(other: FieldModel): Bool
```

Function: Compares two `FieldModel` instances for inequality.

Parameters:

- `other: FieldModel` - The other `FieldModel` to compare with.

Return Value:

- `Bool` - Returns `true` if the `FieldModels` are not equal, `false` otherwise.

## struct InvokeInfo

```cangjie
public struct InvokeInfo {
  public InvokeInfo(
    public let name!: String,
    public let receiverName!: String,
    public let args!: Array<DataModel>,
    public let config!: ReceiverConfig,
    public let fut!: ?DistributedFuture
  )
}
```

Function: Information about a remote call invocation, containing all the necessary details to make a remote call to an actor's receiver function.

### init(String, String, Array<DataModel>, ReceiverConfig, ?DistributedFuture)

```cangjie
public InvokeInfo(
  public let name!: String,
  public let receiverName!: String,
  public let args!: Array<DataModel>,
  public let config!: ReceiverConfig,
  public let fut!: ?DistributedFuture
)
```


Function: Creates an `InvokeInfo` with the specified call details.

Parameters:

- `name!: String` - The name of the target actor.
- `receiverName!: String` - The name of the receiver function to call.
- `args!: Array<DataModel>` - Serialized arguments for the receiver function.
- `config!: ReceiverConfig` - Configuration for the call.
- `fut!: ?DistributedFuture` - Optional future to fulfill with the result.

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

Function: Contains metadata about an actor interface, including receiver information, description, and custom data.

### init(Array<ReceiverInfo>, String, JsonObject)

```cangjie
public Metadata(
  public let receivers!: Array<ReceiverInfo>,
  public let description!: String,
  public let customInfo!: JsonObject
)
```

Function: Creates a `Metadata` instance with the specified receiver information, description, and custom data.

Parameters:

- `receivers!: Array<ReceiverInfo>` - Information about all receiver functions in the actor interface.
- `description!: String` - A human-readable description of the actor interface.
- `customInfo!: JsonObject` - Custom metadata in JSON format.

### func toString()

```cangjie
public override func toString(): String
```

Function: Converts the `Metadata` to a string representation.

Return Value:

- String - A string representation of the `Metadata`.

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

Function: Information about a specific receiver function, including description, custom info, method name, parameter schema, return type model, and the receciver mode (tell or ask).

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

Function: Creates a `ReceiverInfo` instance with the specified function details.

Parameters:

- `description!: String` - A human-readable description of the receiver function.
- `customInfo!: JsonObject` - Custom metadata for the receiver function.
- `methodName!: String` - The name of the receiver function.
- `paramSchema!: Array<ReceiverParameter>` - Schema information for function parameters.
- `retTypeModel!: TypeModel` - Type information for the return value.
- `mode!: ReceiverMode` - The calling mode for the receiver function (tell or ask).

### func toString()

```cangjie
public override func toString(): String
```

Function: Converts the `ReceiverInfo` to a string representation.

Return Value:

- `String` - A string representation of the `ReceiverInfo`.

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

Function: Information about a parameter in a receiver function, including its name, type, and description.

### init(String, TypeModel, String)

```cangjie
public ReceiverParameter(
  public let name!: String,
  public let typeModel!: TypeModel,
  public let description!: String
)
```

Function: Creates a `ReceiverParameter` with the specified details.

Parameters:

- `name!: String` - The name of the parameter.
- `typeModel!: TypeModel` - The type information for the parameter.
- `description!: String` - A description of the parameter.

### func toString()

```cangjie
public override func toString(): String
```

Function: Converts the `ReceiverParameter` to a string representation.

Return Value:

- `String` - A string representation of the `ReceiverParameter`.

## struct SpawnArgument

```cangjie
public struct SpawnArgument <: Serializable<SpawnArgument> & TypeSerializable {
  public let typeName: String
  public let value: Any
}
```

Function: Represents a single argument for spawning distributed actors in the cluster. Each `SpawnArgument` carries both a type name and its value.

### func create\<T>()

```cangjie
public static func create<T>(typeName: String, value: T): SpawnArgument where T <: Serializable<T> & TypeSerializable
```

Function: Creates a new `SpawnArgument` for a value of a serializable and type-serializable type.

Parameters:

- `typeName: String` - The unique type name associated with the argument type.
- `value: T` - The argument value to wrap.

Return Value:

- `SpawnArgument` - The created spawn argument instance.

### func serialize()

```cangjie
public func serialize(): DataModel
```

Function: Serializes the `SpawnArgument` into a `DataModel`.

Return Value:

- `DataModel` - The serialized representation of the `SpawnArgument`.

Exceptions:

- `ActorSystemException` - Thrown when no serialization functions have been registered for the given `typeName`.

### func deserialize()

```cangjie
public static func deserialize(dataModel: DataModel): SpawnArgument
```

Function: Deserializes a `SpawnArgument` from its `DataModel` representation.

Parameters:

- `dataModel: DataModel` - The serialized spawn argument data.

Return Value:

- `SpawnArgument` - The deserialized spawn argument instance.

Exceptions:

- `DataModelException` - Thrown when the structure or fields of the data model are invalid.
- `ActorSystemException` - Thrown when no deserialization functions have been registered for the referenced `typeName`.

### func typeModel()

```cangjie
public static func typeModel(): TypeModel
```

Function: Returns the structural type model of `SpawnArgument` for metadata and schema purposes.

Return Value:

- `TypeModel` - A struct type model describing the `SpawnArgument` fields.
