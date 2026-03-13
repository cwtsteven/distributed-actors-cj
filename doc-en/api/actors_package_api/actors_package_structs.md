# Structs

## struct ReceiverConfig

```cangjie
public struct ReceiverConfig <: Equatable<ReceiverConfig> {
  public static let default = ReceiverConfig()
  public init(priority!: Int64 = 5)
}
```

Function: Configuration for receiver calls, including priority.

Implements:
- `Equatable`

### init(Int64)

```cangjie
public init(priority!: Int64 = 5)
```

Function: Creates a `ReceiverConfig` with the specified priority.

Parameters:

- `priority!: Int64` - The priority level for the receiver call, must be between 1 and 10. Defaults to 5.

### static let default

```cangjie
public static let default = ReceiverConfig()
```

Function: A default `ReceiverConfig` instance with default priority.

### prop priority

```cangjie
public let priority: Int64
```

Function: The priority of the receiver call.

Value:

- `Int64` - The configured priority value for this receiver call.

### operator ==()

```cangjie
public override operator func ==(other: ReceiverConfig): Bool
```

Function: Compares two `ReceiverConfig` instances for equality.

Parameters:

- `other: ReceiverConfig` - The other `ReceiverConfig` to compare with.

Return Value:

- `Bool` - Returns `true` if all the values inside the `ReceiverConfig`s are equal, `false` otherwise.

### operator !=()

```cangjie
public override operator func !=(other: ReceiverConfig): Bool
```

Function: Compares two `ReceiverConfig` instances for inequality.

Parameters:

- `other: ReceiverConfig` - The other `ReceiverConfig` to compare with.

Return Value:

- `Bool` - Returns `true` if any of the values inside the `ReceiverConfig`s is not equal, `false` otherwise.

## Constants

### const MAX_PRIORITY

```cangjie
public const MAX_PRIORITY = 10
```

Function: The maximum priority value for receiver calls. Priority values must be between `MIN_PRIORITY` and `MAX_PRIORITY`.

### const MIN_PRIORITY

```cangjie
public const MIN_PRIORITY = 1
```

Function: The minimum priority value for receiver calls. Priority values must be between `MIN_PRIORITY` and `MAX_PRIORITY`.
