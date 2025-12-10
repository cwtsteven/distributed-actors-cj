# 类

## class TCPActorSystem

```cangjie
public class TCPActorSystem
```

功能：提供 TCP actor 系统日志配置的主类。管理整个 TCP actor 系统用于调试与监控的全局日志器实例。

### static mut prop logger

```cangjie
public static mut prop logger: Logger
```

功能：可变的全局日志器属性，供 TCP actor 系统各组件使用。

返回值：

- `Logger` — TCP Actor 系统使用的日志器实例。

### static var requestTimeout

```cangjie
public static var requestTimeout: Duration
```

功能：TCP 通道中请求的超时时间。

默认值：

- `Duration.second * 10` - 默认超时时间为 10 秒。

### static var heartbeatInterval

```cangjie
public static var heartbeatInterval: Duration
```

功能：发送心跳的间隔时间。

默认值：

- `Duration.second * 2` - 默认心跳间隔为 2 秒。

## class TCPActorClient

```cangjie
public class TCPActorClient <: ActorClient {
  public static func create(addr: String, port: UInt16): TCPActorClient
}
```

功能：基于 TCP 的 `ActorClient` 实现，通过 TCP 连接为远程 actor 提供访问能力。该类连接到 TCP actor 主机并启用与远程 actor 的通信。

### static func create()

```cangjie
public static func create(addr: String, port: UInt16): TCPActorClient
```

功能：创建一个连接到指定主机与端口的 TCP actor 客户端。

参数：

- `addr: String` — 目标主机地址。
- `port: UInt16` — 目标主机端口。

返回值：

- `TCPActorClient` — 创建的 TCP actor 客户端实例。

异常：

- `IllegalArgumentException` — 如果地址或端口无效则抛出。
- `SocketException` — 如果套接字连接失败则抛出。
- `SocketTimeoutException` — 如果套接字连接超时则抛出。

### prop hostInfo

```cangjie
public prop hostInfo: HostInfo
```

功能：TCP actor 客户端连接的主机信息。

### func find()

```cangjie
public func find(name: String): Option<ActorInfo>
```

功能：按名称查找 actor 并返回信息。

参数：

- `name: String` — 要查找的 actor 名称。

返回值：

- `Option<ActorInfo>` — 找到则返回 `Some(ActorInfo)`，否则 `None`。

异常：

- `TCPActorSystemRemoteException` — 如果连接丢失则抛出。
- `TCPActorSystemRequestTimeoutException` — 如果 TCP 请求超时则抛出。
- `TCPActorSystemSerializationException` — 如果信封序列化失败则抛出。
- `TCPActorSystemDeserializationException` — 如果响应信封反序列化失败则抛出。
- `TCPActorSystemInternalException` — 对于任何内部错误则抛出。

### func findAll()

```cangjie
public func findAll(): Array<ActorInfo>
```

功能：查找 TCP actor 主机中注册的全部 actor。

返回值：

- `Array<ActorInfo>` — 所有已注册 actor 的信息数组。

异常：

- `TCPActorSystemRemoteException` — 如果连接丢失则抛出。
- `TCPActorSystemRequestTimeoutException` — 如果请求超时则抛出。
- `TCPActorSystemSerializationException` — 如果信封序列化失败则抛出。
- `TCPActorSystemDeserializationException` — 如果响应信封反序列化失败则抛出。
- `TCPActorSystemInternalException` — 对于任何内部错误则抛出。

### func containsActor()

```cangjie
public func containsActor(name: String): Bool
```

功能：检查服务器是否导出了指定的 actor。

参数：

- `name: String` — actor 的名称。

返回值：

- `Bool` — 如果 actor 已导出则返回 `true`，否则返回 `false`。

异常：

- `TCPActorSystemRemoteException` — 如果连接丢失则抛出。
- `TCPActorSystemRequestTimeoutException` — 如果请求超时则抛出。
- `TCPActorSystemSerializationException` — 如果信封序列化失败则抛出。
- `TCPActorSystemDeserializationException` — 如果响应信封反序列化失败则抛出。
- `TCPActorSystemInternalException` — 对于任何内部错误则抛出。

### func getActor()

```cangjie
public func getActor(name: String): Option<ActorProxy>
```

功能：获取指定 actor 名称的 actor 代理。

参数：

- `name: String` — actor 的名称。

返回值：

- `Option<ActorProxy>` — 如果找到 actor 则返回 `Some(ActorProxy)`，否则返回 `None`。

异常：

- `ActorNotFoundException` — 如果在客户端找不到 actor 则抛出。
- `TCPActorSystemRemoteException` — 如果连接丢失则抛出。
- `TCPActorSystemRequestTimeoutException` — 如果 TCP 请求超时则抛出。
- `TCPActorSystemSerializationException` — 如果信封序列化失败则抛出。
- `TCPActorSystemDeserializationException` — 如果响应信封反序列化失败则抛出。
- `TCPActorSystemInternalException` — 对于任何内部错误则抛出。

### func getHostInfo()

```cangjie
public func getHostInfo(): HostInfo
```

功能：获取客户端的主机信息。

返回值：

- `HostInfo` — 标识此客户端连接到的远程主机的主机信息。

### func remoteCall()

```cangjie
public func remoteCall(invokeInfo: InvokeInfo): Unit
```

功能：根据调用信息对某个 actor 的 receiver 发起远程调用。

参数：

- `invokeInfo: InvokeInfo` — 远程调用的信息。

异常：

- `ActorNotFoundException` — 如果找不到 actor 则抛出。
- `ReceiverNotFoundException` — 如果找不到 receiver 则抛出。
- `IllegalArgumentException` — 如果参数无效则抛出。

- `ActorNotFoundException` — 如果找不到 actor 则抛出。
- `ReceiverNotFoundException` — 如果找不到 receiver 则抛出。
- `IllegalArgumentException` — 如果调用参数无效则抛出。
- `TCPActorSystemRemoteException` — 如果连接丢失则抛出。
- `TCPActorSystemRequestTimeoutException` — 如果请求超时则抛出。
- `TCPActorSystemSerializationException` — 如果信封序列化失败则抛出。
- `TCPActorSystemDeserializationException` — 如果响应信封反序列化失败则抛出。
- `TCPActorSystemInternalException` — 对于任何内部错误则抛出。

### func close()

```cangjie
public func close(): Unit
```

功能：关闭 TCP 客户端连接。可以安全地多次调用。

## class TCPActorHost

```cangjie
public class TCPActorHost <: ActorHost {
  public init(addr!: String, bindAt!: UInt16)
}
```

功能：基于 TCP 的 `ActorHost` 实现，负责通过 TCP 连接管理 actor 的导出与远程调用。提供服务器以接受客户端连接并在网络上管理 actor 通信。

### init(String, UInt16)

```cangjie
public init(addr!: String, bindAt!: UInt16)
```

功能：初始化并绑定到指定地址和端口。

参数：

- `addr!: String` — 服务器绑定的地址。
- `bindAt!: UInt16` — 服务器绑定的端口。

### func export()

```cangjie
public func export(name: String, a: Distributable): Option<ActorProxy>
```

功能：以指定名称导出 actor 实例。

参数：

- `name: String` — 用于导出 actor 的名称。
- `a: Distributable` — 待导出的 actor 实例。

返回值：

- `Option<ActorProxy>` — 导出成功返回 `Some(ActorProxy)`；若名称已被占用返回 `None`。

### func unexport()

```cangjie
public func unexport(name: String): Bool
```

功能：从主机取消导出指定 actor。

参数：

- `name: String` — 要取消导出的 actor 名称。

返回值：

- `Bool` — 取消导出成功返回 `true`；未找到则返回 `false`。

### func serve()

```cangjie
public func serve(): Future<Unit>
```

功能：创建新线程以处理请求并开始接受客户端连接。

返回值：

- `Future<Unit>` — 服务器线程的 Future 句柄。

异常：

- `SocketException` — 服务器套接字绑定失败时抛出。

### func getHostInfo()

```cangjie
public func getHostInfo(): HostInfo
```

功能：获取主机的主机信息。

返回值：

- `HostInfo` — 主机的主机信息。

### func close()

```cangjie
public func close(): Unit
```

功能：关闭所有客户端连接与服务器套接字，以关闭主机。
