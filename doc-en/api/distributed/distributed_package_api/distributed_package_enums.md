# Enums

## enum ReceiverMode

```cangjie
public enum ReceiverMode <: ToString & Equatable<ReceiverMode> {
    | AskOnly
    | TellOnly
    | AskAndTell
}
```

Function: Represents the calling mode for receivers. This enum determines which mode a receiver can be called, *ask* only, *tell* only or both.

Implements:
- `ToString`
- `Equatable`

### Values

- `AskOnly` - The receiver can only be called using the ask mode (expecting a return value).
- `TellOnly` - The receiver can only be called using the tell mode (fire-and-forget).
- `AskAndTell` - The receiver can be called using both ask and tell patterns.

### func toString()

```cangjie
public override func toString(): String
```

Function: Converts the `ReceiverMode` to a string representation.

Return Value:

- `String` - A string representation of the `ReceiverMode`.

### operator ==()

```cangjie
public override operator func ==(other: ReceiverMode): Bool
```

Function: Compares two `ReceiverMode` instances for equality.

Parameters:

- `other: ReceiverMode` - The other `ReceiverMode` to compare with.

Return Value:

- `Bool` - Returns `true` if the `ReceiverMode`s are equal, `false` otherwise.

### operator !=()

```cangjie
public override operator func !=(other: ReceiverMode): Bool
```

Function: Compares two `ReceiverMode` instances for inequality.

Parameters:

- `other: ReceiverMode` - The other `ReceiverMode` to compare with.

Return Value:

- `Bool` - Returns `true` if the `ReceiverMode`s are not equal, `false` otherwise.

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

Function: Represents type schema of a Cangjie type, describing its structure. This enum is used to describe the types of parameters and return values in receiver functions for distributed actor communication.

### Values

- `IntType` - Represents integer types
- `FloatType` - Represents floating point types
- `BoolType` - Represents boolean types
- `StringType` - Represents string types
- `UnitType` - Represents unit/void types
- `StructType(Array<FieldModel>)` - Represents struct types with field information
- `ListType(TypeModel)` - Represents list/array types with element type information

### func toString()

```cangjie
public override func toString(): String
```

Function: Converts the `TypeModel` to a string representation.

Return Value:

- `String` - A string representation of the `TypeModel`.

### operator ==()

```cangjie
public override operator func ==(other: TypeModel): Bool
```

Function: Compares two `TypeModel` instances for equality.

Parameters:

- `other: TypeModel` - The other `TypeModel` to compare with.

Return Value:

- `Bool` - Returns `true` if the `TypeModel`s are equal, `false` otherwise.

### operator !=()

```cangjie
public override operator func !=(other: TypeModel): Bool
```

Function: Compares two `TypeModel` instances for inequality.

Parameters:

- `other: TypeModel` - The other `TypeModel` to compare with.

Return Value:

- `Bool` - Returns `true` if the `TypeModel`s are not equal, `false` otherwise.
