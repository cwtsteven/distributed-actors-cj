# 接口

## interface HeadServer

```cangjie
@ActorInterface[distributed: true]
public interface HeadServer
```

功能：集群头节点的分布式 actor 接口。头节点负责跟踪工作节点、在工作节点之间调度新建 actor，并按名称解析或销毁 actor。

### func join()

```cangjie
@Receiver[mode: AskOnly]
func join(workerId: String, workerAddr: String, workerPort: UInt16): Bool
```

功能：向头节点注册一个工作节点。

参数：

- `workerId: String` — 工作节点的唯一标识。
- `workerAddr: String` — 头节点访问该工作节点时使用的地址。
- `workerPort: UInt16` — 工作节点暴露 actor 的端口。

返回值：

- `Bool` — 注册成功返回 `true`；若相同 id 的节点已存在返回 `false`。

异常：

- `ActorNotFoundException` — 如果指定工作节点上的 worker actor 不存在则抛出。
- `RemoteException` — 如果远程连接失败则抛出。

### func leave()

```cangjie
@Receiver[mode: AskOnly]
func leave(workerId: String): Bool
```

功能：从头节点注销一个工作节点。

参数：

- `workerId: String` — 要移除的工作节点标识。

返回值：

- `Bool` — 移除成功返回 `true`；未找到该节点返回 `false`。

### func spawnActor()

```cangjie
@Receiver[mode: AskOnly]
func spawnActor(typeName: String, actorName: String, args: Array<SpawnArgument>): Option<ActorProxy>
```

功能：按照简单的轮询（round-robin）策略，在已注册的工作节点上创建分布式 actor。

参数：

- `typeName: String` — 要创建的 actor 注册的 spawnable 类型名。
- `actorName: String` — 为该 actor 注册的唯一名称。
- `args: Array<SpawnArgument>` — 用于构造 actor 实例的创建参数。

返回值：

- `Option<ActorProxy>` — 成功时返回 `Some(ActorProxy)`，包含托管该 actor 的工作节点代理；若无可用工作节点或多次尝试均失败，则返回 `None`。

异常：

- `ActorNotFoundException` — 如果指定工作节点上的 worker actor 不存在则抛出。
- `RemoteException` — 如果远程连接失败则抛出。
- `ActorSystemException` — 对于任何未知的内部错误则抛出。

### func getActor()

```cangjie
@Receiver[mode: AskOnly]
func getActor(actorName: String): Option<ActorProxy>
```

功能：解析给定名称的 actor 当前所在的工作节点。

参数：

- `actorName: String` — 要解析的 actor 名称。

返回值：

- `Option<ActorProxy>` — 若 actor 存在且在某个工作节点上仍然存活，则返回 `Some(ActorProxy)`，否则返回 `None`。

异常：

- `ActorNotFoundException` — 如果 actor 不存在则抛出。
- `RemoteException` — 如果远程连接失败则抛出。
- `ActorSystemException` — 对于任何未知的内部错误则抛出。

### func removeActor()

```cangjie
@Receiver[mode: AskOnly]
func removeActor(actorName: String): Bool
```

功能：请求托管给定 actor 的工作节点将其移除。

参数：

- `actorName: String` — 要移除的 actor 名称。

返回值：

- `Bool` — 找到对应工作节点且发送移除请求成功返回 `true`；未找到 actor 或工作节点返回 `false`。

异常：

- `ActorNotFoundException` — 如果 actor 不存在则抛出。
- `RemoteException` — 如果远程连接失败则抛出。
- `ActorSystemException` — 对于任何未知的内部错误则抛出。

### static prop instance

```cangjie
static prop instance: HeadServer
```

功能：返回指向头节点的分布式代理单例。

返回值：

- `HeadServer` — 头节点的分布式代理。

异常：

- `TCPClusterException` — 当头节点尚未配置时抛出。

### static func start()

```cangjie
static func start(headServerAddr!: String, bindAt!: UInt16): Future<Unit>
```

功能：在给定端口启动头节点，通过 `TCPActorHost` 导出并开始处理请求。

参数：

- `headServerAddr!: String` — 头节点用于对外导出的地址。
- `bindAt!: UInt16` — 头节点绑定的 TCP 端口。

返回值：

- `Future<Unit>` — 表示头节点异步启动过程的 Future。

异常：

- `SocketException` — 如果服务器套接字绑定失败则抛出。
- `ActorSystemException` — 对于任何未知的内部错误则抛出。

### static func connect()

```cangjie
static func connect(headServerAddr!: String, port!: UInt16): Unit
```

功能：连接到已有头节点，并配置全局 `HeadServer` 代理。

参数：

- `headServerAddr!: String` — 头节点地址。
- `port!: UInt16` — 头节点端口。

异常：

- `SocketException` — 如果连接过程在套接字层失败则抛出。
- `ActorNotFoundException` — 如果找不到头节点 actor 则抛出。
- `RemoteException` — 如果远程连接失败则抛出。
- `ActorSystemException` — 对于任何未知的内部错误则抛出。
