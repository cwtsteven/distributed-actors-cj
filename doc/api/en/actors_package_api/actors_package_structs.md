# Structs

## struct ReceiverConfig

```cangjie
public struct ReceiverConfig <: Equatable<ReceiverConfig> {
  public static let default = ReceiverConfig()
  public init(priority!: Int64 = 5)
}
```

Function: Configuration struct for receiver function calls, including priority settings and other call parameters.

### init(Int64)

```cangjie
public init(priority!: Int64 = 5)
```

Function: Creates a ReceiverConfig with the specified priority.

Parameters:

- priority!: Int64 - The priority level for the receiver call, must be between 1 and 10. Defaults to 5.

### static let default

```cangjie
public static let default = ReceiverConfig()
```

Function: A default ReceiverConfig instance with standard priority settings.

### operator ==()

```cangjie
public override operator func ==(other: ReceiverConfig): Bool
```

Function: Compares two ReceiverConfig instances for equality.

Parameters:

- other: ReceiverConfig - The other ReceiverConfig to compare with.

Return Value:

- Bool - Returns `true` if the ReceiverConfigs are equal, `false` otherwise.

### operator !=()

```cangjie
public override operator func !=(other: ReceiverConfig): Bool
```

Function: Compares two ReceiverConfig instances for inequality.

Parameters:

- other: ReceiverConfig - The other ReceiverConfig to compare with.

Return Value:

- Bool - Returns `true` if the ReceiverConfigs are not equal, `false` otherwise.
