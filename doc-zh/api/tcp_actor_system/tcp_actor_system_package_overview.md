# actors.tcp_actor_system

## 功能说明

`actors.tcp_actor_system` 包提供基于 TCP 的分布式 Actor 系统实现，使 Actor 可通过 TCP 套接字跨网络通信。该包实现了 `ActorHost` 与 `ActorClient` 接口，具备完整的网络通信支持，适合生产环境的分布式 Actor 系统。

主要特性包括：
- **TCP 网络通信**：基于 TCP 套接字的主机与客户端通信
- **并发连接管理**：支持多个并发客户端连接
- **消息序列化**：内置 Actor 消息的序列化/反序列化
- **错误处理**：覆盖网络与 Actor 通信的错误处理
- **日志支持**：集成日志以便调试与监控
- **异步处理**：非阻塞消息处理与完善的 Future 管理

该包可用于构建真正的分布式 Actor 系统，使 Actor 能够部署在不同机器并通过 TCP 可靠通信。

## API 列表

### 类

| 类名 | 功能 |
| --- | --- |
| [TCPActorClient](./tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorclient) | 基于 TCP 的 actor client 实现，提供用于 *查找* 分布式 actor 的方法。 |
| [TCPActorHost](./tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorhost) | 基于 TCP 的 actor host 实现，提供用于 *导出* 分布式 actor 的方法。 |
| [TCPActorSystem](./tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorsystem) | 提供 TCP actor 系统日志配置的主类。 |

### 异常

| 异常名 | 功能 |
| --- | --- |
| [TCPActorSystemDeserializationException](./tcp_actor_system_package_api/tcp_actor_system_package_exceptions.md#class-tcpactorsystemdeserializationexception) | TCP Actor 系统中反序列化操作失败时抛出的异常。 |
| [TCPActorSystemInternalException](./tcp_actor_system_package_api/tcp_actor_system_package_exceptions.md#class-tcpactorsysteminternalexception) | TCP Actor 系统中发生内部错误时抛出的异常。 |
| [TCPActorSystemRemoteException](./tcp_actor_system_package_api/tcp_actor_system_package_exceptions.md#class-tcpactorsystemremoteexception) | TCP Actor 系统中远程连接失败时抛出的异常。 |
| [TCPActorSystemRequestTimeoutException](./tcp_actor_system_package_api/tcp_actor_system_package_exceptions.md#class-tcpactorsystemrequesttimeoutexception) | TCP Actor 系统中请求超时时抛出的异常。 |
| [TCPActorSystemSerializationException](./tcp_actor_system_package_api/tcp_actor_system_package_exceptions.md#class-tcpactorsystemserializationexception) | TCP Actor 系统中序列化操作失败时抛出的异常。 |

### 结构体

| 结构体名 | 功能 |
| --- | --- |
| [TCPActorClientInfo](./tcp_actor_system_package_api/tcp_actor_system_package_structs.md#struct-tcpactorclientinfo) | 关于 TCP actor 客户端的信息，包括客户端 ID、地址和端口。 |
