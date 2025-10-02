# Enums

## enum Payload

```Cangjie
enum Payload <: Equatable<Payload> & ToString {
    Ok
    | ErrorCode(TCPActorSystemError)
    | Find(String)
    | FindAll
    | FindResponse(Array<ActorInfo>)
    | Ask(String, String, Array<DataModel>, ReceiverConfig, UInt64)
    | Tell(String, String, Array<DataModel>, ReceiverConfig)
    | Fulfill(UInt64, DataModel)
}
```

Function: Enum representing the message protocol between TCPActorHost and TCPActorClient. This enum defines all possible message types that can be exchanged between the host and client components of the TCP actor system.

### Values

- `Ok` - Indicates a successful operation
- `ErrorCode(TCPActorSystemError)` - Indicates an error with a specific error code
- `Find(String)` - Request to find an actor by name
- `FindAll` - Request to find all registered actors
- `FindResponse(Array<ActorInfo>)` - Response containing actor information
- `Ask(String, String, Array<DataModel>, ReceiverConfig, UInt64)` - Ask request with actor name, receiver name, arguments, config, and future ID
- `Tell(String, String, Array<DataModel>, ReceiverConfig)` - Tell request with actor name, receiver name, arguments, and config
- `Fulfill(UInt64, DataModel)` - Future fulfillment with future ID and result data

### operator ==()

```cangjie
public operator func ==(other: Payload): Bool
```

Function: Compares two Payload instances for equality.

Parameters:

- other: Payload - The other Payload to compare with.

Return Value:

- Bool - Returns `true` if the Payloads are equal, `false` otherwise.

### operator !=()

```cangjie
public operator func !=(other: Payload): Bool
```

Function: Compares two Payload instances for inequality.

Parameters:

- other: Payload - The other Payload to compare with.

Return Value:

- Bool - Returns `true` if the Payloads are not equal, `false` otherwise.

### func toString()

```cangjie
public func toString(): String
```

Function: Converts the Payload to a string representation.

Return Value:

- String - A string representation of the Payload.

## enum TCPActorSystemError

```Cangjie
enum TCPActorSystemError <: ToString & Equatable<TCPActorSystemError> {
    | UnknownError
    | ActorNotFound
    | ReceiverNotFound
}
```

Function: Enum representing the error codes of the TCPActorSystem. This enum defines the various error conditions that can occur during TCP actor system operations.

### Values

- `UnknownError` - Indicates an unknown or unexpected error
- `ActorNotFound` - Indicates that the requested actor was not found
- `ReceiverNotFound` - Indicates that the requested receiver function was not found

### func toString()

```cangjie
public override func toString(): String
```

Function: Converts the TCPActorSystemError to a string representation.

Return Value:

- String - A string representation of the TCPActorSystemError.

### operator ==()

```cangjie
public override operator func ==(other: TCPActorSystemError): Bool
```

Function: Compares two TCPActorSystemError instances for equality.

Parameters:

- other: TCPActorSystemError - The other TCPActorSystemError to compare with.

Return Value:

- Bool - Returns `true` if the TCPActorSystemErrors are equal, `false` otherwise.

### operator !=()

```cangjie
public override operator func !=(other: TCPActorSystemError): Bool
```

Function: Compares two TCPActorSystemError instances for inequality.

Parameters:

- other: TCPActorSystemError - The other TCPActorSystemError to compare with.

Return Value:

- Bool - Returns `true` if the TCPActorSystemErrors are not equal, `false` otherwise.
