# Classes

## class TCPActorSystem

```cangjie
public class TCPActorSystem
```

Function: Main system class that provides logging configuration for the TCP actor system. This class manages the global logger instance used throughout the TCP actor system for debugging and monitoring purposes.

### static mut prop logger

```cangjie
public static mut prop logger: Logger
```

Function: A mutable property representing the logger of the TCPActorSystem. This property provides access to the global logger instance used by all TCP actor system components.

Return Value:

- `Logger` - The logger instance used by the TCP actor system.

## class TCPActorHost

```cangjie
public class TCPActorHost <: ActorHost {
  public init(bindAt!: UInt16)
}
```

Function: TCP-based implementation of ActorHost that manages actor registration and handles remote calls over TCP connections. This class provides a server that accepts client connections and manages actor communication over the network.

### init(UInt16)

```cangjie
public init(bindAt!: UInt16)
```

Function: Initializes the TCP actor host to bind to the specified port.

Parameters:

- `bindAt!: UInt16` - The port to bind the server to.

### func export()

```cangjie
public func export(name: String, a: Distributable): Bool
```

Function: Exports an actor instance under the specified name.

Parameters:

- `name: String` - The name to export the actor under.
- `a: Distributable` - The actor instance to export.

Return Value:

- `Bool` - Returns `true` if the actor was successfully exported, `false` if the name is already taken.

### func unexport()

```cangjie
public func unexport(name: String): Bool
```

Function: Unexport an actor from the TCP actor host.

Parameters:

- `name: String` - The name of the actor to unexport.

Return Value:

- `Bool` - Returns `true` if the actor was successfully un-exported, `false` if the actor was not found.

### func serve()

```cangjie
public func serve(): Future<Unit>
```

Function: Creates a new thread to serve requests and starts accepting client connections.

Return Value:

- `Future<Unit>` - A future handle to the server thread.

Exceptions:

- `SocketException` - Thrown if the server socket fails to bind.

### func close()

```cangjie
public func close(): Unit
```

Function: Closes the TCP actor host by closing all client connections and the server socket.

## class TCPActorClient

```cangjie
public class TCPActorClient <: ActorClient {
  public init(id: String, addr: String, port: UInt16)
}
```

Function: TCP-based implementation of ActorClient that provides remote access to actors over TCP connections. This class connects to a TCP actor host and enables communication with remote actors.

### init(String, String, UInt16)

```cangjie
public init(id: String, addr: String, port: UInt16)
```

Function: Initializes the TCP actor client to connect to the specified host and port.

Parameters:

- `id: String` - The unique identifier for this client.
- `addr: String` - The address of the TCP actor host to connect to.
- `port: UInt16` - The port of the TCP actor host to connect to.

### prop id

```cangjie
public prop id: String
```

Function: The unique identifier of the TCP actor client.

### func find()

```cangjie
public func find(name: String): Option<ActorInfo>
```

Function: Finds an actor by name and returns its information.

Parameters:

- `name: String` - The name of the actor to find.

Return Value:

- `Option<ActorInfo>` - Returns `Some(ActorInfo)` if the actor is found, `None` otherwise.

### func findAll()

```cangjie
public func findAll(): Array<ActorInfo>
```

Function: Finds all actors registered in the TCP actor host.

Return Value:

- `Array<ActorInfo>` - An array containing information about all registered actors.

### func remoteCall()

```cangjie
public func remoteCall(invokeInfo: InvokeInfo): Unit
```

Function: Makes a remote call to an actor's receiver.

Parameters:

- `invokeInfo: InvokeInfo` - The information about the remote call invocation.

### func close()

```cangjie
public func close(): Unit
```

Function: Closes the TCP actor client connection.

## class TCPActorSystemSerializationException

```cangjie
public class TCPActorSystemSerializationException <: Exception {
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

## class TCPActorSystemDeserializationException

```cangjie
public class TCPActorSystemDeserializationException <: Exception {
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
