# Exceptions

## class ActorClusterException

```cangjie
public class ActorClusterException <: ActorSystemException {
  ActorClusterException(message: String)
}
```

Function: Exception thrown when an actor cluster fails.

### init(String)

```cangjie
ActorClusterException(message: String)
```

Function: Creates an `ActorClusterException` with a custom error message.

Parameters:

- `message: String` - The custom error message describing the cluster error.

## class ActorNotFoundException

```cangjie
public class ActorNotFoundException <: Exception {
  public init(name: String)
}
```

Function: Exception thrown when an actor with the specified name cannot be found.

### init(String)

```cangjie
public init(name: String)
```

Function: Creates an `ActorNotFoundException` with a message indicating the actor name that could not be found.

Parameters:

- `name: String` - The name of the actor that could not be found.

## class ActorSystemException

```cangjie
public class ActorSystemException <: Exception {
  public init(msg: String)
}
```

Function: General exception for actor system related errors with a custom message.

### init(String)

```cangjie
public init(msg: String)
```

Function: Creates an `ActorSystemException` with a custom error message.

Parameters:

- `msg: String` - The custom error message describing the actor system error.

## class DeserializationException

```cangjie
public class DeserializationException <: ActorSystemException {
  DeserializationException(message: String)
}
```

Function: Exception thrown when a deserialization operation fails.

### init(String)

```cangjie
DeserializationException(message: String)
```

Function: Creates a `DeserializationException` with a custom error message.

Parameters:

- `message: String` - The custom error message describing the deserialization error.

## class ReceiverNotFoundException

```cangjie
public class ReceiverNotFoundException <: Exception {
  public init(name: String, receiverName: String)
}
```

Function: Exception thrown when a receiver cannot be found in the specified actor interface.

### init(String, String)

```cangjie
public init(name: String, receiverName: String)
```

Function: Creates a `ReceiverNotFoundException` with a message indicating the receiver that could not be found.

Parameters:

- `name: String` - The name of the actor interface.
- `receiverName: String` - The name of the receiver function that could not be found.

## class RemoteException

```cangjie
public class RemoteException <: Exception {
  public init()
}
```

Function: Exception thrown when a remote connection has failed during distributed actor communication.

### init()

```cangjie
public init()
```

Function: Creates a `RemoteException` with a default message indicating that the remote connection has failed.

## class RemoteReceiverException

```cangjie
public class RemoteReceiverException <: Exception & Serializable<RemoteReceiverException> {
  public init(e: Exception)
  public init(e: Error)
  public override func serialize(): DataModel
  public static func deserialize(dm: DataModel): RemoteReceiverException
}
```

Function: Exception that wraps non-serializable exceptions or errors thrown from remote receiver execution. This exception is serializable and can be transmitted across the network.

Implements:
- `Serializable`

### init(Exception)

```cangjie
public init(e: Exception)
```

Function: Creates a `RemoteReceiverException` from an `Exception`, capturing its stack trace.

Parameters:

- `e: Exception` - The exception to wrap.

### init(Error)

```cangjie
public init(e: Error)
```

Function: Creates a `RemoteReceiverException` from an `Error`, capturing its stack trace.

Parameters:

- `e: Error` - The error to wrap.

### func serialize()

```cangjie
public override func serialize(): DataModel
```

Function: Serializes the RemoteReceiverException for network transmission.

Return Value:

- `DataModel` - The serialized representation of the exception.

### func deserialize()

```cangjie
public static func deserialize(dm: DataModel): RemoteReceiverException
```

Function: Deserializes a RemoteReceiverException from its DataModel representation.

Parameters:

- `dm: DataModel` - The serialized exception data.

Return Value:

- `RemoteReceiverException` - The deserialized exception instance.

Exceptions:

- `DeserializationException` - Thrown if the exception cannot be deserialized.

## class SerializationException

```cangjie
public class SerializationException <: ActorSystemException {
  SerializationException(message: String)
}
```

Function: Exception thrown when a serialization operation fails.

### init(String)

```cangjie
SerializationException(message: String)
```

Function: Creates a `SerializationException` with a custom error message.

Parameters:

- `message: String` - The custom error message describing the serialization error.

## class SerializingFunctionsNotFoundException

```cangjie
public class SerializingFunctionsNotFoundException <: ActorClusterException {
  SerializingFunctionsNotFoundException(message: String)
}
```

Function: Exception thrown when a serializing function is not found.

### init(String)

```cangjie
SerializingFunctionsNotFoundException(message: String)
```

Function: Creates a `SerializingFunctionsNotFoundException` with a custom error message.

Parameters:

- `message: String` - The custom error message describing the error.

