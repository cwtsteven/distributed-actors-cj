# 完整 API 参考

本文档提供了分布式 actor 框架中所有公共 API 的综合列表，按包组织。

## actors 包

### 类

| 类名 | 描述 |
|------------|-------------|
| [ActorFuture\<T>](./actors_package_api/actors_package_classes.md#class-actorfuture) | 表示提交给 Actor 的闭包的待处理结果；提供带超时的阻塞与非阻塞结果获取方法。 |
| [SequentialDispatcher](./actors_package_api/actors_package_classes.md#class-sequentialdispatcher) | 一个在专用线程上按顺序排队并执行闭包调度器，并提供提交闭包的方法；支持基于优先级的任务调度，通常由 Actor 系统内部使用。 |

### 结构体

| 结构体名 | 描述 |
|-------------|-------------|
| [ReceiverConfig](./actors_package_api/actors_package_structs.md#struct-receiverconfig) | Receiver 函数调用的配置，包括优先级（1-10）及其他调用参数，用于控制 Actor 操作的执行顺序与行为。 |

### 枚举

| 枚举名 | 描述 |
|-----------|-------------|
| [Tell](./actors_package_api/actors_package_enums.md#enum-tell) | 单值枚举，用于绕过 ActorFuture 机制实现即发即忘；调用 Receiver 时以命名参数 `tell: True` 传入。 |

## actors.distributed 包

### 类

| 类名 | 描述 |
|------------|-------------|
| [ActorProxy](./distributed_package_api/distributed_package_classes.md#class-actorproxy) | 与远程 actor 通信的代理类，提供 Ask/Tell 两种调用方式。 |
| [DistributedFuture](./distributed_package_api/distributed_package_classes.md#class-distributedfuture) | 表示远程 receiver 调用待处理结果的具体类，提供获取与兑现结果的方法。 |
| [ActorNotFoundException](./distributed_package_api/distributed_package_classes.md#class-actornotfoundexception) | 在分布式 actor 系统中找不到指定名称的 actor 时抛出。 |
| [ReceiverNotFoundException](./distributed_package_api/distributed_package_classes.md#class-receivernotfoundexception) | 在指定 actor 接口中找不到 receiver 函数时抛出。 |
| [RemoteException](./distributed_package_api/distributed_package_classes.md#class-remoteexception) | 分布式 actor 通信过程中的远程连接失败异常。 |
| [ActorSystemException](./distributed_package_api/distributed_package_classes.md#class-actorsystemexception) | Actor 系统相关错误的通用异常，可携带自定义信息。 |
| [RemoteReceiverException](./distributed_package_api/distributed_package_classes.md#class-remotereceiverexception) | 包装远程 receiver 执行时抛出的不可序列化异常/错误，用于跨网络传输。 |

### 接口

| 接口名 | 描述 |
|----------------|-------------|
| [Distributable](./distributed_package_api/distributed_package_interfaces.md#interface-distributable) | 所有分布式 actor 所需实现的接口，提供将客户端远程调用分发到底层 actor 实例的方法。 |
| [ActorHost](./distributed_package_api/distributed_package_interfaces.md#interface-actorhost) | actor host 实现的接口，提供用于 *导出* 分布式 actor 的方法。 |
| [ActorClient](./distributed_package_api/distributed_package_interfaces.md#interface-actorclient) | actor client 实现的接口，提供用于 *查找* 分布式 actor 的方法。 |
| [LocalWaitable](./distributed_package_api/distributed_package_interfaces.md#interface-localwaitable) | 所有本地 `ActorFuture<T>` 类型共用的接口，提供以序列化形式（`DataModel`）获取 Future 结果的方法。 |

### 结构体

| 结构体名 | 描述 |
|-------------|-------------|
| [ActorInfo](./distributed_package_api/distributed_package_structs.md#struct-actorinfo) | 关于 actor 的信息，包括名称与元数据。 |
| [Metadata](./distributed_package_api/distributed_package_structs.md#struct-metadata) | 关于 actor 接口的元数据，包括 receiver 信息、描述与自定义数据。 |
| [ReceiverInfo](./distributed_package_api/distributed_package_structs.md#struct-receiverinfo) | 某个 receiver 的信息，包括参数模式、返回类型与元数据。 |
| [ReceiverParameter](./distributed_package_api/distributed_package_structs.md#struct-receiverparameter) | Receiver 参数的信息，包括名称、类型与描述。 |
| [FieldModel](./distributed_package_api/distributed_package_structs.md#struct-fieldmodel) | 结构体字段的信息，包括名称、类型与描述，是整体类型模型的一部分。 |
| [InvokeInfo](./distributed_package_api/distributed_package_structs.md#struct-invokeinfo) | 远程调用的信息，包含执行 receiver 所需的全部细节。 |

### 枚举

| 枚举名 | 描述 |
|-----------|-------------|
| [ReceiverMode](./distributed_package_api/distributed_package_enums.md#enum-receivermode) | Receiver 函数的调用模式，可取 `Ask` 或 `Tell`。 |
| [TypeModel](./distributed_package_api/distributed_package_enums.md#enum-typemodel) | Cangjie 类型的类型模式，用于描述该类型的结构。 |

## actors.distributed.mcp 包

### 类

| 类名 | 描述 |
|------------|-------------|
| [ActorToolManager](./mcp_package_api/mcp_package_classes.md#class-actortoolmanager) | 管理多个 Actor 客户端并将其 Receiver 函数作为 MCP 工具对外暴露的工具管理器实现。 |
| [ReceiverTool](./mcp_package_api/mcp_package_classes.md#class-receivertool) | 将 Actor 的 Receiver 函数封装为 MCP 工具的实现。 |
| [ActorMCPException](./mcp_package_api/mcp_package_classes.md#class-actormcpexception) | MCP 相关操作失败（如工具不存在、参数非法等）时抛出的异常。 |

## actors.tcp_actor_system 包

### 类

| 类名 | 描述 |
|------------|-------------|
| [TCPActorHost](./tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorhost) | 基于 TCP 的 actor host 实现，提供用于 *导出* 分布式 actor 的方法 |
| [TCPActorClient](./tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorclient) | 基于 TCP 的 actor client 实现，提供用于 *查找* 分布式 actor 的方法 |
| [TCPActorSystemSerializationException](./tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorsystemserializationexception) | TCP Actor 系统中的序列化失败异常。 |
| [TCPActorSystemDeserializationException](./tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorsystemdeserializationexception) | TCP Actor 系统中的反序列化失败异常。 |

### 枚举

| 枚举名 | 描述 |
|-----------|-------------|
| [Payload](./tcp_actor_system_package_api/tcp_actor_system_package_enums.md#enum-payload) | TCP 主机与客户端间的消息协议，定义用于 Actor 通信的消息类型。 |
| [TCPActorSystemError](./tcp_actor_system_package_api/tcp_actor_system_package_enums.md#enum-tcpactorsystemerror) | TCPActorSystem 的错误码。 |

## actors.macros 包

### 宏

| 宏名 | 描述 |
|------------|-------------|
| [@Actor](./macros_package_api/macros_package_macros.md#actor-宏) | 将类转换为 actor。 |
| [@ActorInterface](./macros_package_api/macros_package_macros.md#actorinterface-macro) | 将接口转换为 actor 接口。 |
| [@Receiver](./macros_package_api/macros_package_macros.md#receiver-宏) | 将方法转换为 receiver。 |


