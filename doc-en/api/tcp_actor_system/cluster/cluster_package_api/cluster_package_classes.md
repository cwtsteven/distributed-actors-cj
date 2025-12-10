# Classes

## class TCPCluster

```cangjie
public class TCPCluster <: ActorCluster
```

Function: TCP-based implementation of `ActorCluster` consist of a head-server and multiple worker nodes. Provides functionalities to spawn and lookup distributed actors within the cluster.

### static prop instance

```cangjie
public static prop instance: TCPCluster
```

Function: Returns the singleton instance of the `TCPCluster`. Accessing this property before the cluster is initialized will throw a `TCPClusterException`.

Return Value:

- `TCPCluster` - The current TCP-based cluster instance.

Exceptions:

- `TCPClusterException` - Thrown when the cluster has not been initialized yet.

### static func createHeadServer()

```cangjie
public static func createHeadServer(headServerAddr!: String, headServerPort!: UInt16): Future<Unit>
```

Function: Creates and starts a new TCP-based cluster head server bound at the given port and initializes the global `TCPCluster` instance.

Parameters:

- `headServerAddr!: String` - The head server address.
- `headServerPort!: UInt16` - The TCP port where the head server will listen for worker nodes.

Return Value:

- `Future<Unit>` - A future representing the asynchronous startup of the head server.

Exceptions:

- `SocketException` - Thrown if the server socket fails to bind.
- `ActorSystemException` - Thrown for any unknown internal errors.
- `TCPClusterException` - Thrown if the cluster has already been initialized.

### static func createWorker()

```cangjie
public static func createWorker(headServerAddr!: String, headServerPort!: UInt16, workerId!: String, workerAddr!: String, workerPort!: UInt16): Future<Unit>
```

Function: Starts a worker node, connects it to the head server, and initializes the global `TCPCluster` instance.

Parameters:

- `headServerAddr!: String` - The address of the head server to connect to.
- `headServerPort!: UInt16` - The port of the head server to connect to.
- `workerId!: String` - The unique identifier of this worker node.
- `workerAddr!: String` - The address where this worker node can be reached by the head server.
- `workerPort!: UInt16` - The port where this worker node exposes actors via `TCPActorHost`.

Return Value:

- `Future<Unit>` - A future representing the asynchronous startup of the worker.

Exceptions:

- `SocketException` - Thrown if the server socket fails to bind.
- `ActorSystemException` - Thrown for any unknown internal errors.
- `TCPClusterException` - Thrown if the cluster has already been initialized.
- `ActorNotFoundException` - Thrown if the head server actor is not found.
- `RemoteException` - Thrown if the remote connection fails.

### static func join()

```cangjie
public static func join(headServerAddr!: String, headServerPort!: UInt16): Bool
```

Function: Joins an existing TCP-based cluster as a client-only participant by connecting to the head server. This means that the head server will not spawn any actors onto this node.

Parameters:

- `headServerAddr!: String` - The address of the head server to connect to.
- `headServerPort!: UInt16` - The port of the head server to connect to.

Return Value:

- `Bool` - Returns `true` if the cluster was successfully joined, `false` if the cluster was already initialized.

Exceptions:

- `SocketException` - Thrown if the server socket fails to bind.
- `ActorSystemException` - Thrown for any unknown internal errors.
- `TCPClusterException` - Thrown if the cluster has already been initialized.
- `ActorNotFoundException` - Thrown if the head server actor is not found.
- `RemoteException` - Thrown if the remote connection fails.

### static func spawnActor\<T>()

```cangjie
public static func spawnActor<T>(name: String, args: Array<SpawnArgument>): Option<T> where T <: Distributable & Proxyable<T> & Spawnable<T>
```

Function: Spawns a distributed actor in the TCP cluster by delegating to the remote head server, then returns a typed proxy to the spawned actor.

Parameters:

- `name: String` - The unique name to register the new actor under.
- `args: Array<SpawnArgument>` - The arguments used to construct the actor instance.

Return Value:

- `Option<T>` - Returns `Some(T)` with a typed proxy to the created actor when successful, or `None` if spawning fails.

Exceptions:

- `ActorNotFoundException` - Thrown if the worker actor is not found on the specified client.
- `RemoteException` - Thrown if the remote connection fails.
- `TCPClusterException` - Thrown if the cluster is not initialized.
- `ActorSystemException` - Thrown for any unknown internal errors.

### static func getActor\<T>()

```cangjie
public static func getActor<T>(name: String): Option<T> where T <: Distributable & Proxyable<T> & Spawnable<T>
```

Function: Looks up an existing distributed actor in the TCP cluster by name and returns a typed proxy to it.

Parameters:

- `name: String` - The name of the actor to look up.

Return Value:

- `Option<T>` - Returns `Some(T)` with a typed proxy when the actor is found, or `None` otherwise.

Exceptions:

- `ActorNotFoundException` - Thrown if the worker actor is not found on the specified client.
- `RemoteException` - Thrown if the remote connection fails.
- `TCPClusterException` - Thrown if the cluster is not initialized.
- `ActorSystemException` - Thrown for any unknown internal errors.

### static func removeActor()

```cangjie
public static func removeActor(name: String): Bool
```

Function: Removes an actor from the cluster.

Parameters:

- `name: String` - The name of the actor to remove.

Return Value:

- `Bool` - Returns `true` if the actor was removed, `false` otherwise.

Exceptions:

- `ActorNotFoundException` - Thrown if the worker actor is not found on the specified client.
- `RemoteException` - Thrown if the remote connection fails.
- `TCPClusterException` - Thrown if the cluster is not initialized.
- `ActorSystemException` - Thrown for any unknown internal errors.


