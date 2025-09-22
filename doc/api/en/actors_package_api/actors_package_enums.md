# Enums

## enum ControlAction

```Cangjie
public enum ControlAction {
    | Continue
    | Poison(Int64)
    | Stop
}
```

Function: Represents an action to be taken by the actor thread when one of its receivers throws an exception or an error.

### Values

- `Continue` - The actor should keep processing receivers.
- `Poison(Int64)` - A poison pill should be added to the actor's mailbox at the provided priority. 
When a poison pill is removed from the mailbox, the actor stops.
The value must be a valid priority, otherwise an `IllegalArgumentException` will be thrown and the actor
will stop immediately.
- `Stop` - The actor should stop immediately.

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
