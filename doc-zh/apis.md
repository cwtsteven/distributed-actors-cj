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

### 常量

| 常量名 | 描述 |
|---------------|-------------|
| [MAX_PRIORITY](./actors_package_api/actors_package_structs.md#const-max_priority) | Receiver 调用的最大优先级值（10）。 |
| [MIN_PRIORITY](./actors_package_api/actors_package_structs.md#const-min_priority) | Receiver 调用的最小优先级值（1）。 |

## actors.distributed 包

### 类

| 类名 | 描述 |
|------------|-------------|
| [ActorProxy](./distributed_package_api/distributed_package_classes.md#class-actorproxy) | 与远程 actor 通信的代理类，提供 Ask/Tell 两种调用方式。 |
| [ClientManager](./distributed_package_api/distributed_package_classes.md#class-clientmanager) | 管理分布式 actor 系统中 actor client 的单例类，用于获取和注册 actor client 及其反序列化器。 |
| [DistributedFuture](./distributed_package_api/distributed_package_classes.md#class-distributedfuture) | 表示远程 receiver 调用待处理结果的具体类，提供获取与兑现结果的方法。 |

### 结构体

| 结构体名 | 描述 |
|-------------|-------------|
| [ActorInfo](./distributed_package_api/distributed_package_structs.md#struct-actorinfo) | 关于 actor 的信息，包括名称与元数据。 |
| [FieldModel](./distributed_package_api/distributed_package_structs.md#struct-fieldmodel) | 结构体字段的信息，包括名称、类型与描述，是整体类型模型的一部分。 |
| [InvokeInfo](./distributed_package_api/distributed_package_structs.md#struct-invokeinfo) | 远程调用的信息，包含执行 receiver 所需的全部细节。 |
| [Metadata](./distributed_package_api/distributed_package_structs.md#struct-metadata) | 关于 actor 接口的元数据，包括 receiver 信息、描述与自定义数据。 |
| [ReceiverInfo](./distributed_package_api/distributed_package_structs.md#struct-receiverinfo) | 某个 receiver 的信息，包括参数模式、返回类型与元数据。 |
| [ReceiverParameter](./distributed_package_api/distributed_package_structs.md#struct-receiverparameter) | Receiver 参数的信息，包括名称、类型与描述。 |
| [SpawnArgument](./distributed_package_api/distributed_package_structs.md#struct-spawnargument) | 在集群中创建分布式 actor 时使用的单个参数。 |

### 接口

| 接口名 | 描述 |
|----------------|-------------|
| [ActorClient](./distributed_package_api/distributed_package_interfaces.md#interface-actorclient) | actor client 实现的接口，提供用于 *查找* 分布式 actor 的方法。 |
| [ActorCluster](./distributed_package_api/distributed_package_interfaces.md#interface-actorcluster) | 用于创建集群系统以在其中创建和发现分布式 actor 的接口。 |
| [ActorHost](./distributed_package_api/distributed_package_interfaces.md#interface-actorhost) | actor host 实现的接口，提供用于 *导出* 分布式 actor 的方法。 |
| [HostInfo](./distributed_package_api/distributed_package_interfaces.md#interface-hostinfo) | 标识远程 actor host 的主机信息接口，提供创建客户端和获取类型信息的方法。 |
| [Distributable](./distributed_package_api/distributed_package_interfaces.md#interface-distributable) | 所有分布式 actor 所需实现的接口，提供将客户端远程调用分发到底层 actor 实例的方法。 |
| [LocalWaitable](./distributed_package_api/distributed_package_interfaces.md#interface-localwaitable) | 所有本地 `ActorFuture<T>` 类型共用的接口，提供以序列化形式（`DataModel`）获取 Future 结果的方法。 |
| [Proxyable](./distributed_package_api/distributed_package_interfaces.md#interface-proxyablet) | 为实现类型化代理 `getProxy` 能力的分布式 actor 接口提供的接口。 |
| [Spawnable](./distributed_package_api/distributed_package_interfaces.md#interface-spawnablet) | 可在集群中被动态创建的分布式 actor 接口。任何打算在集群中被创建的 actor 接口，都需要实现该接口。 |
| [TypeSerializable](./distributed_package_api/distributed_package_interfaces.md#interface-typeserializable) | 为类型提供 `TypeModel` 类型模式描述的接口，用于分布式传输与元数据生成。 |

### 枚举

| 枚举名 | 描述 |
|-----------|-------------|
| [ReceiverMode](./distributed_package_api/distributed_package_enums.md#enum-receivermode) | Receiver 函数的调用模式，可取 `Ask` 或 `Tell`。 |
| [TypeModel](./distributed_package_api/distributed_package_enums.md#enum-typemodel) | Cangjie 类型的类型模式，用于描述该类型的结构。 |

### 异常

| 异常名 | 描述 |
|----------------|-------------|
| [ActorClusterException](./distributed_package_api/distributed_package_exceptions.md#class-actorclusterexception) | 当分布式 actor 集群发生错误时抛出，例如集群管理或协调失败。 |
| [ActorNotFoundException](./distributed_package_api/distributed_package_exceptions.md#class-actornotfoundexception) | 在分布式 actor 系统中找不到指定名称的 actor 时抛出。 |
| [ActorSystemException](./distributed_package_api/distributed_package_exceptions.md#class-actorsystemexception) | Actor 系统相关错误的通用异常，可携带自定义信息。 |
| [DeserializationException](./distributed_package_api/distributed_package_exceptions.md#class-deserializationexception) | 当反序列化操作失败时抛出。 |
| [ReceiverNotFoundException](./distributed_package_api/distributed_package_exceptions.md#class-receivernotfoundexception) | 在指定 actor 接口中找不到 receiver 函数时抛出。 |
| [RemoteException](./distributed_package_api/distributed_package_exceptions.md#class-remoteexception) | 分布式 actor 通信过程中的远程连接失败异常。 |
| [RemoteReceiverException](./distributed_package_api/distributed_package_exceptions.md#class-remotereceiverexception) | 包装远程 receiver 执行时抛出的不可序列化异常/错误，用于跨网络传输。 |
| [SerializationException](./distributed_package_api/distributed_package_exceptions.md#class-serializationexception) | 当序列化操作失败时抛出。 |
| [SerializingFunctionsNotFoundException](./distributed_package_api/distributed_package_exceptions.md#class-serializingfunctionsnotfoundexception) | 当找不到序列化函数时抛出。 |

## actors.tcp_actor_system 包

### 类

| 类名 | 描述 |
|------------|-------------|
| [TCPActorClient](./tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorclient) | 基于 TCP 的 actor client 实现，提供用于 *查找* 分布式 actor 的方法。 |
| [TCPActorHost](./tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorhost) | 基于 TCP 的 actor host 实现，提供用于 *导出* 分布式 actor 的方法。 |
| [TCPActorSystem](./tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorsystem) | 提供 TCP actor 系统日志配置的主类。 |

### 异常

| 异常名 | 描述 |
|----------------|-------------|
| [TCPActorSystemDeserializationException](./tcp_actor_system_package_api/tcp_actor_system_package_exceptions.md#class-tcpactorsystemdeserializationexception) | TCP Actor 系统中反序列化操作失败时抛出的异常。 |
| [TCPActorSystemInternalException](./tcp_actor_system_package_api/tcp_actor_system_package_exceptions.md#class-tcpactorsysteminternalexception) | TCP Actor 系统中发生内部错误时抛出的异常。 |
| [TCPActorSystemRemoteException](./tcp_actor_system_package_api/tcp_actor_system_package_exceptions.md#class-tcpactorsystemremoteexception) | TCP Actor 系统中远程连接失败时抛出的异常。 |
| [TCPActorSystemRequestTimeoutException](./tcp_actor_system_package_api/tcp_actor_system_package_exceptions.md#class-tcpactorsystemrequesttimeoutexception) | TCP Actor 系统中请求超时时抛出的异常。 |
| [TCPActorSystemSerializationException](./tcp_actor_system_package_api/tcp_actor_system_package_exceptions.md#class-tcpactorsystemserializationexception) | TCP Actor 系统中序列化操作失败时抛出的异常。 |

### 结构体

| 结构体名 | 描述 |
|-------------|-------------|
| [TCPActorHostInfo](./tcp_actor_system_package_api/tcp_actor_system_package_structs.md#struct-tcpactorhostinfo) | 关于 TCP actor 主机的信息，包括主机地址和端口。 |

## actors.tcp_actor_system.cluster 包

### 类

| 类名 | 描述 |
|------------|-------------|
| [TCPCluster](./cluster/cluster_package_api/cluster_package_classes.md#class-tcpcluster) | 基于 TCP 的 `ActorCluster` 实现，由头节点与多个工作节点组成。提供在集群内创建与查找分布式 actor 的功能。 |

### 异常

| 异常名 | 描述 |
|----------------|-------------|
| [TCPClusterException](./cluster/cluster_package_api/cluster_package_exceptions.md#class-tcpclusterexception) | 当集群操作失败时抛出。 |

## actors.macros 包

### 宏

| 宏名 | 描述 |
|------------|-------------|
| [@Actor](./macros_package_api/macros_package_macros.md#actor-宏) | 将类转换为 actor。 |
| [@ActorInterface](./macros_package_api/macros_package_macros.md#actorinterface-macro) | 将接口转换为 actor 接口。 |
| [@Receiver](./macros_package_api/macros_package_macros.md#receiver-宏) | 将方法转换为 receiver。 |

## actors_mcp 包

该包由仓库中的 `subpackages/actors-mcp` 子包提供。

包概览与 API 请参阅 [actors_mcp 包概览](./api/actors_mcp_package_overview.md)。
