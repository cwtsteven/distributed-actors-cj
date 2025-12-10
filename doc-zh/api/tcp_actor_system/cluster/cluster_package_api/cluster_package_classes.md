# 类

## class TCPCluster

```cangjie
public class TCPCluster <: ActorCluster
```

功能：基于 TCP 的 `ActorCluster` 实现，由头节点与多个工作节点组成。提供在集群内创建与查找分布式 actor 的功能。

### static prop instance

```cangjie
public static prop instance: TCPCluster
```

功能：返回 `TCPCluster` 的单例实例。若在集群尚未初始化之前访问该属性，会抛出 `TCPClusterException`。

返回值：

- `TCPCluster` — 当前基于 TCP 的集群实例。

异常：

- `TCPClusterException` — 当集群尚未初始化时抛出。

### static func createHeadServer()

```cangjie
public static func createHeadServer(headServerAddr!: String, headServerPort!: UInt16): Future<Unit>
```

功能：创建并启动新的 TCP 集群头节点，绑定到给定端口并初始化全局 `TCPCluster` 实例。

参数：

- `headServerAddr!: String` — 头节点地址。
- `headServerPort!: UInt16` — 头节点监听工作节点的 TCP 端口。

返回值：

- `Future<Unit>` — 表示头节点异步启动过程的 Future。

异常：

- `SocketException` — 如果服务器套接字绑定失败则抛出。
- `ActorSystemException` — 对于任何未知的内部错误则抛出。
- `TCPClusterException` — 当集群已被初始化时抛出。

### static func createWorker()

```cangjie
public static func createWorker(headServerAddr!: String, headServerPort!: UInt16, workerId!: String, workerAddr!: String, workerPort!: UInt16): Future<Unit>
```

功能：启动一个工作节点，连接到头节点，并初始化全局 `TCPCluster` 实例。

参数：

- `headServerAddr!: String` — 要连接的头节点地址。
- `headServerPort!: UInt16` — 要连接的头节点端口。
- `workerId!: String` — 当前工作节点的唯一标识。
- `workerAddr!: String` — 头节点访问当前工作节点时使用的地址。
- `workerPort!: UInt16` — 当前工作节点通过 `TCPActorHost` 暴露 actor 的端口。

返回值：

- `Future<Unit>` — 表示工作节点异步启动过程的 Future。

异常：

- `SocketException` — 如果服务器套接字绑定失败则抛出。
- `ActorSystemException` — 对于任何未知的内部错误则抛出。
- `TCPClusterException` — 当集群已被初始化时抛出。
- `ActorNotFoundException` — 如果找不到头服务器 actor 则抛出。
- `RemoteException` — 如果远程连接失败则抛出。

### static func join()

```cangjie
public static func join(headServerAddr!: String, headServerPort!: UInt16): Bool
```

功能：以仅客户端参与者的身份连接到已有的 TCP 集群并完成初始化。这意味着头节点不会在该节点上创建任何 actor。

参数：

- `headServerAddr!: String` — 头节点地址。
- `headServerPort!: UInt16` — 头节点端口。

返回值：

- `Bool` — 连接并加入成功返回 `true`；若集群已初始化则返回 `false`。

异常：

- `SocketException` — 如果服务器套接字绑定失败则抛出。
- `ActorSystemException` — 对于任何未知的内部错误则抛出。
- `TCPClusterException` — 当集群已被初始化时抛出。
- `ActorNotFoundException` — 如果找不到头服务器 actor 则抛出。
- `RemoteException` — 如果远程连接失败则抛出。

### static func spawnActor\<T>()

```cangjie
public static func spawnActor<T>(name: String, args: Array<SpawnArgument>): Option<T> where T <: Distributable & Proxyable<T> & Spawnable<T>
```

功能：通过远程调用头节点在 TCP 集群中创建分布式 actor，并返回该 actor 的类型化代理。

参数：

- `name: String` — 为新 actor 注册的唯一名称。
- `args: Array<SpawnArgument>` — 用于构造 actor 实例的创建参数。

返回值：

- `Option<T>` — 创建成功时返回 `Some(T)`（类型化代理），否则返回 `None`。

异常：

- `ActorNotFoundException` — 如果在指定客户端找不到工作 actor 则抛出。
- `RemoteException` — 如果远程连接失败则抛出。
- `TCPClusterException` — 如果集群未初始化则抛出。
- `ActorSystemException` — 对于任何未知的内部错误则抛出。

### static func getActor\<T>()

```cangjie
public static func getActor<T>(name: String): Option<T> where T <: Distributable & Proxyable<T> & Spawnable<T>
```

功能：在 TCP 集群中按名称查找已存在的分布式 actor，并返回其类型化代理。

参数：

- `name: String` — 要查找的 actor 名称。

返回值：

- `Option<T>` — 找到时返回 `Some(T)`（类型化代理），否则返回 `None`。

异常：

- `ActorNotFoundException` — 如果在指定客户端找不到工作 actor 则抛出。
- `RemoteException` — 如果远程连接失败则抛出。
- `TCPClusterException` — 如果集群未初始化则抛出。
- `ActorSystemException` — 对于任何未知的内部错误则抛出。

### static func removeActor()

```cangjie
public static func removeActor(name: String): Bool
```

功能：从集群中移除 actor。

参数：

- `name: String` — 要移除的 actor 名称。

返回值：

- `Bool` — 成功移除返回 `true`；未找到或移除失败返回 `false`。


