# 接口

## interface HeadServer

```cangjie
@ActorInterface[distributed: true]
interface HeadServer
```

功能：集群头节点的分布式 actor 接口。头节点负责跟踪工作节点、在工作节点之间调度新建 actor，并按名称解析或销毁 actor。

### func join()

```cangjie
@Receiver[mode: AskOnly]
func join(clientId: String, clientAddr: String, clientPort: UInt16): Bool
```

功能：向头节点注册一个工作节点。

参数：

- `clientId: String` — 工作节点的唯一标识。
- `clientAddr: String` — 头节点访问该工作节点时使用的地址。
- `clientPort: UInt16` — 工作节点暴露 actor 的端口。

返回值：

- `Bool` — 注册成功返回 `true`；若相同 id 的节点已存在返回 `false`。

### func leave()

```cangjie
@Receiver[mode: AskOnly]
func leave(clientId: String): Bool
```

功能：从头节点注销一个工作节点。

参数：

- `clientId: String` — 要移除的工作节点标识。

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

### func killActor()

```cangjie
@Receiver[mode: AskOnly]
func killActor(actorName: String): Bool
```

功能：请求托管给定 actor 的工作节点将其销毁。

参数：

- `actorName: String` — 要销毁的 actor 名称。

返回值：

- `Bool` — 找到对应工作节点且发送销毁请求成功返回 `true`；未找到 actor 或工作节点返回 `false`。

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
static func start(bindAt!: UInt16): Future<Unit>
```

功能：在给定端口启动头节点，通过 `TCPActorHost` 导出并开始处理请求。

参数：

- `bindAt!: UInt16` — 头节点绑定的 TCP 端口。

返回值：

- `Future<Unit>` — 表示头节点异步启动过程的 Future。

### static func connect()

```cangjie
static func connect(headServerAddr!: String, port!: UInt16): Unit
```

功能：连接到已有头节点，并配置全局 `HeadServer` 代理。

参数：

- `headServerAddr!: String` — 头节点地址。
- `port!: UInt16` — 头节点端口。

## interface WorkerActor

```cangjie
@ActorInterface[distributed: true]
interface WorkerActor
```

功能：由 TCP 集群中的工作节点实现的分布式 actor 接口。每个工作节点在本地 `TCPActorHost` 上实际创建、导出并跟踪分布式 actor。

### func spawnActor()

```cangjie
@Receiver[mode: AskOnly]
func spawnActor(typeName: String, actorName: String, args: Array<SpawnArgument>): Bool
```

功能：在本工作节点上创建并导出一个新的分布式 actor。

参数：

- `typeName: String` — 要创建的 actor 注册的 spawnable 类型名。
- `actorName: String` — 用于导出该 actor 的名称。
- `args: Array<SpawnArgument>` — 用于构造 actor 实例的创建参数。

返回值：

- `Bool` — 创建并导出成功返回 `true`；否则返回 `false`。

### func containsActor()

```cangjie
@Receiver[mode: AskOnly]
func containsActor(actorName: String): Bool
```

功能：检查当前工作节点上是否存在给定名称的 actor。

参数：

- `actorName: String` — 要检查的 actor 名称。

返回值：

- `Bool` — 存在返回 `true`，否则返回 `false`。

### func killActor()

```cangjie
@Receiver[mode: AskOnly]
func killActor(actorName: String): Bool
```

功能：从工作节点的内部注册表中移除给定名称的 actor。

参数：

- `actorName: String` — 要移除的 actor 名称。

返回值：

- `Bool` — 若 actor 存在且成功移除返回 `true`，否则返回 `false`。

### static func start()

```cangjie
static func start(name!: String, bindAt!: UInt16): Future<Unit>
```

功能：启动工作节点上的 WorkerActor 实例，通过 `TCPActorHost` 以给定名称导出，并开始处理集群请求。

参数：

- `name!: String` — 导出 WorkerActor 时使用的名称。
- `bindAt!: UInt16` — Worker 节点 `TCPActorHost` 绑定的端口。

返回值：

- `Future<Unit>` — 表示 WorkerActor 异步启动过程的 Future。


