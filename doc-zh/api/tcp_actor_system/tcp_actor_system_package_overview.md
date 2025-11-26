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
| [TCPActorHost](./tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorhost) | 基于 TCP 的 actor host 实现，提供用于 *导出* 分布式 actor 的方法 |
| [TCPActorClient](./tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorclient) | 基于 TCP 的 actor client 实现，提供用于 *查找* 分布式 actor 的方法 |
| [TCPActorSystemSerializationException](./tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorsystemserializationexception) | TCP Actor 系统中的序列化失败异常。 |
| [TCPActorSystemDeserializationException](./tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorsystemdeserializationexception) | TCP Actor 系统中的反序列化失败异常。 |

### 枚举

| 枚举名 | 功能 |
| --- | --- |
| [Payload](./tcp_actor_system_package_api/tcp_actor_system_package_enums.md#enum-payload) | TCP 主机与客户端间的消息协议，定义用于 Actor 通信的消息类型。 |
| [TCPActorSystemError](./tcp_actor_system_package_api/tcp_actor_system_package_enums.md#enum-tcpactorsystemerror) | TCPActorSystem 的错误码。 |
