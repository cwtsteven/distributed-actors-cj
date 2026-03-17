# Classes

## class TCPActorClient

```cangjie
public class TCPActorClient <: ActorClient {
  public static func create(addr: String, port: UInt16): TCPActorClient
  public let hostInfo: TCPActorHostInfo
}
```

Function: TCP-based implementation of ActorClient that provides remote access to actors over TCP connections. This class connects to a TCP actor host and enables communication with remote actors.

### static func create()

```cangjie
public static func create(addr: String, port: UInt16): TCPActorClient
```

Function: Creates a TCP actor client to connect to the specified host and port. This method uses the `ClientManager` to ensure that only one client exists per host.

Parameters:

- `addr: String` - The address of the TCP actor host to connect to.
- `port: UInt16` - The port of the TCP actor host to connect to.

Return Value:

- `TCPActorClient` - A TCP actor client instance connected to the specified host.

Exceptions:

- `IllegalArgumentException` - Thrown if the address or port is invalid.
- `SocketException` - Thrown if the socket connection fails.
- `SocketTimeoutException` - Thrown if the socket connection times out.

### prop hostInfo

```cangjie
public let hostInfo: TCPActorHostInfo
```

Function: The host information about the TCP actor host this client connects to.

### func find()

```cangjie
public func find(name: String): Option<ActorInfo>
```

Function: Finds an actor by name and returns its information.

Parameters:

- `name: String` - The name of the actor to find.

Return Value:

- `Option<ActorInfo>` - Returns `Some(ActorInfo)` if the actor is found, `None` otherwise.

Exceptions:

- `TCPActorSystemRemoteException` - Thrown if the connection is lost.
- `TCPActorSystemRequestTimeoutException` - Thrown if the TCP request has timed out.
- `TCPActorSystemSerializationException` - Thrown if the envelope serialization fails.
- `TCPActorSystemDeserializationException` - Thrown if the response envelope deserialization fails.
- `TCPActorSystemInternalException` - Thrown for any internal errors.

### func findAll()

```cangjie
public func findAll(): Array<ActorInfo>
```

Function: Finds all actors registered in the TCP actor host.

Return Value:

- `Array<ActorInfo>` - An array containing information about all registered actors.

Exceptions:

- `TCPActorSystemRemoteException` - Thrown if the connection is lost.
- `TCPActorSystemRequestTimeoutException` - Thrown if the request has timed out.
- `TCPActorSystemSerializationException` - Thrown if the envelope serialization fails.
- `TCPActorSystemDeserializationException` - Thrown if the response envelope deserialization fails.
- `TCPActorSystemInternalException` - Thrown for any internal errors.

### func containsActor()

```cangjie
public func containsActor(name: String): Bool
```

Function: Checks if an actor is exported from the respective server.

Parameters:

- `name: String` - The name of the actor.

Return Value:

- `Bool` - Returns `true` if the actor is exported, `false` otherwise.

Exceptions:

- `TCPActorSystemRemoteException` - Thrown if the connection is lost.
- `TCPActorSystemRequestTimeoutException` - Thrown if the request has timed out.
- `TCPActorSystemSerializationException` - Thrown if the envelope serialization fails.
- `TCPActorSystemDeserializationException` - Thrown if the response envelope deserialization fails.
- `TCPActorSystemInternalException` - Thrown for any internal errors.

### func getActor()

```cangjie
public func getActor(name: String): Option<ActorProxy>
```

Function: Gets an actor proxy for the specified actor name.

Parameters:

- `name: String` - The name of the actor.

Return Value:

- `Option<ActorProxy>` - Returns `Some(ActorProxy)` if the actor is found, `None` otherwise.

Exceptions:

- `ActorNotFoundException` - Thrown if the actor is not found on the client.
- `TCPActorSystemRemoteException` - Thrown if the connection is lost.
- `TCPActorSystemRequestTimeoutException` - Thrown if the TCP request has timed out.
- `TCPActorSystemSerializationException` - Thrown if the envelope serialization fails.
- `TCPActorSystemDeserializationException` - Thrown if the response envelope deserialization fails.
- `TCPActorSystemInternalException` - Thrown for any internal errors.

### func getTypedActor\<T>()

```cangjie
public func getTypedActor<T>(name: String): Option<T> where T <: Distributable & Proxyable<T>
```

Function: Gets a typed actor proxy by name.

Parameters:

- `name: String` - The exported actor name.

Return Value:

- `Option<T>` - Returns `Some(T)` if the actor is found, `None` otherwise.

### func getHostInfo()

```cangjie
public func getHostInfo(): HostInfo
```

Function: Gets the host info of the client.

Return Value:

- `HostInfo` - The host info that identifies the remote host this client connects to.

### func close()

```cangjie
public func close(): Unit
```

Function: Closes the TCP actor client connection. Can be called multiple times safely.

## class TCPActorHost

```cangjie
public class TCPActorHost <: ActorHost {
  public init(addr!: String, bindAt!: UInt16)
}
```

Function: TCP-based implementation of ActorHost that manages actor registration and handles remote calls over TCP connections. This class provides a server that accepts client connections and manages actor communication over the network.

### init(String, UInt16)

```cangjie
public init(addr!: String, bindAt!: UInt16)
```

Function: Initializes the TCP actor host to bind to the specified address and port.

Parameters:

- `addr!: String` - The address to bind the server to.
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

### func getHostInfo()

```cangjie
public func getHostInfo(): HostInfo
```

Function: Gets the host info of the host.

Return Value:

- `HostInfo` - The host info that identifies this host.

### func close()

```cangjie
public func close(): Unit
```

Function: Closes the TCP actor host by closing all client connections and the server socket.

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

### static var requestTimeout

```cangjie
public static var requestTimeout: Duration
```

Function: The timeout duration for a request sent in a TCP channel.

Default Value:

- `Duration.second * 10` - Default timeout of 10 seconds.

### static var heartbeatInterval

```cangjie
public static var heartbeatInterval: Duration
```

Function: The interval duration for sending a heartbeat.

Default Value:

- `Duration.second * 2` - Default heartbeat interval of 2 seconds.
