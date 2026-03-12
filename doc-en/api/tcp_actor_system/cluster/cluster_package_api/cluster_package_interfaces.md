# Interfaces

## interface HeadServer

```cangjie
@ActorInterface[distributed: true]
public interface HeadServer
```

Function: Distributed actor interface for the cluster head server. The head server tracks worker nodes and coordinates actor placement, lookup, and removal across the cluster.

### func join()

```cangjie
@Receiver[mode: AskOnly]
func join(workerId: String, workerAddr: String, workerPort: UInt16): Bool
```

Function: Registers a worker node with the head server.

Parameters:

- `workerId: String` - The unique identifier of the worker node.
- `workerAddr: String` - The address the head server should use to reach the worker node.
- `workerPort: UInt16` - The port where the worker node exposes actors.

Return Value:

- `Bool` - Returns `true` if the worker joined successfully, `false` if a worker with the same id is already registered.

Exceptions:

- `ActorNotFoundException` - Thrown if the worker actor cannot be found on the specified worker node.
- `RemoteException` - Thrown if the remote connection fails.

### func leave()

```cangjie
@Receiver[mode: AskOnly]
func leave(workerId: String): Bool
```

Function: Unregisters a worker node from the head server.

Parameters:

- `workerId: String` - The worker node identifier to remove.

Return Value:

- `Bool` - Returns `true` if the worker was removed, `false` if it was not registered.

### func spawnActor()

```cangjie
@Receiver[mode: AskOnly]
func spawnActor(typeName: String, actorName: String, args: Array<SpawnArgument>): Option<ActorProxy>
```

Function: Creates a distributed actor on one of the registered worker nodes using a round-robin placement strategy.

Parameters:

- `typeName: String` - The registered spawnable type name of the actor to create.
- `actorName: String` - The unique name to register the actor under.
- `args: Array<SpawnArgument>` - The spawn arguments used to construct the actor instance.

Return Value:

- `Option<ActorProxy>` - Returns `Some(ActorProxy)` for the created actor when successful, or `None` when no worker is available or creation fails after retries.

Exceptions:

- `ActorNotFoundException` - Thrown if the worker actor cannot be found on the selected worker node.
- `RemoteException` - Thrown if the remote connection fails.
- `ActorSystemException` - Thrown for unknown internal actor-system errors.

### func getActor()

```cangjie
@Receiver[mode: AskOnly]
func getActor(actorName: String): Option<ActorProxy>
```

Function: Resolves the worker node currently hosting the actor with the given name.

Parameters:

- `actorName: String` - The name of the actor to resolve.

Return Value:

- `Option<ActorProxy>` - Returns `Some(ActorProxy)` if the actor exists and is still alive on a worker node, otherwise `None`.

Exceptions:

- `ActorNotFoundException` - Thrown if the actor cannot be found.
- `RemoteException` - Thrown if the remote connection fails.
- `ActorSystemException` - Thrown for unknown internal actor-system errors.

### func removeActor()

```cangjie
@Receiver[mode: AskOnly]
func removeActor(actorName: String): Bool
```

Function: Requests the worker node hosting the actor to remove it.

Parameters:

- `actorName: String` - The name of the actor to remove.

Return Value:

- `Bool` - Returns `true` if removal succeeded, `false` if the actor or worker node could not be found.

Exceptions:

- `ActorNotFoundException` - Thrown if the actor cannot be found.
- `RemoteException` - Thrown if the remote connection fails.
- `ActorSystemException` - Thrown for unknown internal actor-system errors.

### static prop instance

```cangjie
static prop instance: HeadServer
```

Function: Returns the global distributed proxy for the head server.

Return Value:

- `HeadServer` - The configured head-server proxy instance.

Exceptions:

- `TCPClusterException` - Thrown if the head server has not been configured yet.

### static func start()

```cangjie
static func start(headServerAddr!: String, bindAt!: UInt16): Future<Unit>
```

Function: Starts the head server at the given address and port, exports it via `TCPActorHost`, and begins serving cluster requests.

Parameters:

- `headServerAddr!: String` - The address the head server should advertise to peers.
- `bindAt!: UInt16` - The TCP port to bind the head server to.

Return Value:

- `Future<Unit>` - A future representing the asynchronous server loop.

Exceptions:

- `SocketException` - Thrown if the server socket fails to bind.
- `ActorSystemException` - Thrown for unknown internal actor-system errors.

### static func connect()

```cangjie
static func connect(headServerAddr!: String, port!: UInt16): Unit
```

Function: Connects to an existing head server and configures the global `HeadServer` proxy.

Parameters:

- `headServerAddr!: String` - The address of the head server.
- `port!: UInt16` - The port of the head server.

Exceptions:

- `SocketException` - Thrown if the connection setup fails at the socket layer.
- `ActorNotFoundException` - Thrown if the head-server actor cannot be found.
- `RemoteException` - Thrown if the remote connection fails.
- `ActorSystemException` - Thrown for unknown internal actor-system errors.
