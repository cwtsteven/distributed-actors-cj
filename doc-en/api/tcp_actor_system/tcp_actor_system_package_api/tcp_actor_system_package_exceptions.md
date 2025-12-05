# Exceptions

## class TCPActorSystemDeserializationException

```cangjie
public class TCPActorSystemDeserializationException <: ActorSystemException {
  TCPActorSystemDeserializationException(message: String)
}
```

Function: Exception thrown when a deserialization operation fails in the TCP actor system.

### init(String)

```cangjie
TCPActorSystemDeserializationException(message: String)
```

Function: Creates a TCPActorSystemDeserializationException with a custom error message.

Parameters:

- `message: String` - The custom error message describing the deserialization error.

## class TCPActorSystemInternalException

```cangjie
public class TCPActorSystemInternalException <: ActorSystemException {
  TCPActorSystemInternalException(message: String)
}
```

Function: Exception thrown when an internal error occurs in the TCP actor system.

### init(String)

```cangjie
TCPActorSystemInternalException(message: String)
```

Function: Creates a TCPActorSystemInternalException with a custom error message.

Parameters:

- `message: String` - The custom error message describing the internal error.

## class TCPActorSystemRemoteException

```cangjie
public class TCPActorSystemRemoteException <: RemoteException {
  TCPActorSystemRemoteException(message: String)
  TCPActorSystemRemoteException()
}
```

Function: Exception thrown when a remote connection fails in the TCP actor system.

### init(String)

```cangjie
TCPActorSystemRemoteException(message: String)
```

Function: Creates a TCPActorSystemRemoteException with a custom error message.

Parameters:

- `message: String` - The custom error message describing the remote connection error.

### init()

```cangjie
TCPActorSystemRemoteException()
```

Function: Creates a TCPActorSystemRemoteException with a default error message.

## class TCPActorSystemRequestTimeoutException

```cangjie
public class TCPActorSystemRequestTimeoutException <: RemoteException {
  TCPActorSystemRequestTimeoutException(message: String)
  TCPActorSystemRequestTimeoutException()
}
```

Function: Exception thrown when a request timeout occurs in the TCP actor system.

### init(String)

```cangjie
TCPActorSystemRequestTimeoutException(message: String)
```

Function: Creates a TCPActorSystemRequestTimeoutException with a custom error message.

Parameters:

- `message: String` - The custom error message describing the timeout error.

### init()

```cangjie
TCPActorSystemRequestTimeoutException()
```

Function: Creates a TCPActorSystemRequestTimeoutException with a default error message indicating that the request has timed out.

## class TCPActorSystemSerializationException

```cangjie
public class TCPActorSystemSerializationException <: ActorSystemException {
  TCPActorSystemSerializationException(message: String)
}
```

Function: Exception thrown when a serialization operation fails in the TCP actor system.

### init(String)

```cangjie
TCPActorSystemSerializationException(message: String)
```

Function: Creates a TCPActorSystemSerializationException with a custom error message.

Parameters:

- `message: String` - The custom error message describing the serialization error.

