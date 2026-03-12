# Exceptions

## class ActorClusterException

```cangjie
public class ActorClusterException <: ActorSystemException
```

Function: Exception thrown when an actor cluster fails.

## class ActorNotFoundException

```cangjie
public class ActorNotFoundException <: ActorSystemException {
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
public class ActorSystemException <: Exception
```

Function: General exception for actor system related errors with a custom message.

## class DeserializationException

```cangjie
public class DeserializationException <: ActorSystemException {
  public init(message: String)
}
```

Function: Exception thrown when a deserialization operation fails.

### init(String)

```cangjie
public init(message: String)
```

Function: Creates a `DeserializationException` with a custom error message.

Parameters:

- `message: String` - The custom error message describing the deserialization error.

## class ReceiverNotFoundException

```cangjie
public class ReceiverNotFoundException <: ActorSystemException {
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
public class RemoteException <: ActorSystemException
```

Function: Exception thrown when a remote connection has failed during distributed actor communication.

## class RemoteReceiverException

```cangjie
public class RemoteReceiverException <: ActorSystemException & Serializable<RemoteReceiverException> {
  public override func serialize(): DataModel
  public static func deserialize(dm: DataModel): RemoteReceiverException
}
```

Function: Exception that wraps non-serializable exceptions or errors thrown from remote receiver execution. This exception is serializable and can be transmitted across the network.

Implements:
- `Serializable`

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
public class SerializationException <: ActorSystemException
```

Function: Exception thrown when a serialization operation fails.

## class SerializingFunctionsNotFoundException

```cangjie
public class SerializingFunctionsNotFoundException <: ActorClusterException
```

Function: Exception thrown when a serializing function is not found.
