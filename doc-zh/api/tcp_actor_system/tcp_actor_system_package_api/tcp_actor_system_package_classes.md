# 类

## class TCPActorSystem

```cangjie
public class TCPActorSystem
```

功能：提供 TCP Actor 系统日志配置的主类。管理整个 TCP Actor 系统用于调试与监控的全局日志器实例。

### static mut prop logger

```cangjie
public static mut prop logger: Logger
```

功能：可变的全局日志器属性，供 TCP Actor 系统各组件使用。

返回值：

- `Logger` — TCP Actor 系统使用的日志器实例。

## class TCPActorHost

```cangjie
public class TCPActorHost <: ActorHost {
  public init(bindAt!: UInt16)
}
```

功能：基于 TCP 的 `ActorHost` 实现，负责通过 TCP 连接管理 Actor 注册与远程调用。提供服务器以接受客户端连接并管理网络通信。

### init(UInt16)

```cangjie
public init(bindAt!: UInt16)
```

功能：初始化并绑定到指定端口。

参数：

- `bindAt!: UInt16` — 服务器绑定的端口。

### func register()

```cangjie
public func register(name: String, a: Distributable): Bool
```

功能：以指定名称注册 Actor。

参数：

- `name: String` — 注册名。
- `a: Distributable` — 待注册的 Actor 实例。

返回值：

- `Bool` — 成功返回 `true`；若名称已被占用返回 `false`。

### func deregister()

```cangjie
public func deregister(name: String): Bool
```

功能：从主机注销指定 Actor。

参数：

- `name: String` — 要注销的 Actor 名称。

返回值：

- `Bool` — 成功返回 `true`；未找到则返回 `false`。

### func serve()

```cangjie
public func serve(): Future<Unit>
```

功能：创建新线程以处理请求并开始接受客户端连接。

返回值：

- `Future<Unit>` — 服务器线程的 Future 句柄。

异常：

- `SocketException` — 服务器套接字绑定失败时抛出。

### func close()

```cangjie
public func close(): Unit
```

功能：关闭所有客户端连接与服务器套接字，以关闭主机。

## class TCPActorClient

```cangjie
public class TCPActorClient <: ActorClient {
  public init(id: String, addr: String, port: UInt16)
}
```

功能：基于 TCP 的 `ActorClient` 实现，连接到 TCP Actor 主机以访问远程 Actor。

### init(String, String, UInt16)

```cangjie
public init(id: String, addr: String, port: UInt16)
```

功能：初始化为连接到指定主机与端口的客户端。

参数：

- `id: String` — 客户端唯一标识。
- `addr: String` — 目标主机地址。
- `port: UInt16` — 目标主机端口。

### prop id

```cangjie
public prop id: String
```

功能：TCP 客户端的唯一标识。

### func find()

```cangjie
public func find(name: String): Option<ActorInfo>
```

功能：按名称查找 Actor 并返回信息。

参数：

- `name: String` — 要查找的 Actor 名称。

返回值：

- `Option<ActorInfo>` — 找到则返回 `Some(ActorInfo)`，否则 `None`。

### func findAll()

```cangjie
public func findAll(): Array<ActorInfo>
```

功能：获取主机上注册的全部 Actor 信息。

返回值：

- `Array<ActorInfo>` — 所有已注册 Actor 的信息数组。

### func remoteCall()

```cangjie
public func remoteCall(invokeInfo: InvokeInfo): Unit
```

功能：远程调用 Actor 的 Receiver，并以结果完成提供的 Future。

参数：

- `invokeInfo: InvokeInfo` — 远程调用的信息。

### func close()

```cangjie
public func close(): Unit
```

功能：关闭 TCP 客户端连接。

## class TCPActorSystemSerializationException

```cangjie
public class TCPActorSystemSerializationException <: Exception {
  TCPActorSystemSerializationException(message: String)
}
```

功能：TCP Actor 系统中序列化操作失败时抛出的异常。

### init(String)

```cangjie
TCPActorSystemSerializationException(message: String)
```

功能：创建带自定义错误信息的序列化异常。

参数：

- `message: String` — 序列化错误的描述信息。

## class TCPActorSystemDeserializationException

```cangjie
public class TCPActorSystemDeserializationException <: Exception {
  TCPActorSystemDeserializationException(message: String)
}
```

功能：TCP Actor 系统中反序列化操作失败时抛出的异常。

### init(String)

```cangjie
TCPActorSystemDeserializationException(message: String)
```

功能：创建带自定义错误信息的反序列化异常。

参数：

- `message: String` — 反序列化错误的描述信息。
