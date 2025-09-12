# Enums

## enum Tell

```Cangjie
public enum Tell {
    True
}
```
Function: Single valued enumeration to call a `@Receiver` while bypassing the `ActorFuture` mechanism. `tell: True` should be passed to the `@Receiver` as a named argument.

## enum TypeModel

```Cangjie
public enum TypeModel <: ToString {
    IntType
    | FloatType
    | BoolType
    | StringType
    | UnitType
}
```

Function: Represents type information for serialization and metadata generation. This enum is used to describe the types of parameters and return values in receiver functions for distributed actor communication.

### Values

- `IntType` - Represents integer types
- `FloatType` - Represents floating point types
- `BoolType` - Represents boolean types
- `StringType` - Represents string types
- `UnitType` - Represents unit/void types
