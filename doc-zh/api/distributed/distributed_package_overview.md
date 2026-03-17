# actors.distributed

## 功能说明

`actors.distributed` 包在核心 actor 编程模型基础上扩展，使 actor 能够跨网络边界通信。其提供远程 actor 通信、元数据管理，以及通过 `DistributedActorFuture<DataModel>` 传输远程结果的基础设施。

开发者可以借助该包在多节点上部署 actor，同时维持与本地 actor 相同的编程模型，从而构建可扩展的分布式系统。

## API 列表

### 类

| 类名 | 功能 |
| --- | --- |
| [ActorProxy](./distributed_package_api/distributed_package_classes.md#class-actorproxy) | 与远程 actor 通信的代理类，提供 Ask/Tell 两种调用方式。 |
| [ClientManager](./distributed_package_api/distributed_package_classes.md#class-clientmanager) | 管理分布式 actor 系统中 actor client 的单例类，用于获取和注册 actor client 及其反序列化器。 |

### 结构体

| 结构体名 | 功能 |
| --- | --- |
| [ActorInfo](./distributed_package_api/distributed_package_structs.md#struct-actorinfo) | 关于 actor 的信息，包括名称与元数据。 |
| [FieldModel](./distributed_package_api/distributed_package_structs.md#struct-fieldmodel) | 结构体字段的信息，包括名称、类型与描述，是整体类型模型的一部分。 |
| [Metadata](./distributed_package_api/distributed_package_structs.md#struct-metadata) | 关于 actor 接口的元数据，包括 receiver 信息、描述与自定义数据。 |
| [ReceiverInfo](./distributed_package_api/distributed_package_structs.md#struct-receiverinfo) | 某个 receiver 的信息，包括参数模式、返回类型与元数据。 |
| [ReceiverParameter](./distributed_package_api/distributed_package_structs.md#struct-receiverparameter) | Receiver 参数的信息，包括名称、类型与描述。 |
| [SpawnArgument](./distributed_package_api/distributed_package_structs.md#struct-spawnargument) | 在集群中创建分布式 actor 时使用的单个参数。 |

### 接口

| 接口名 | 功能 |
| --- | --- |
| [ActorClient](./distributed_package_api/distributed_package_interfaces.md#interface-actorclient) | actor client 实现的接口，提供用于 *查找* 分布式 actor 的方法。 |
| [ActorCluster](./distributed_package_api/distributed_package_interfaces.md#interface-actorcluster) | 用于创建集群系统以在其中创建和发现分布式 actor 的接口。 |
| [ActorHost](./distributed_package_api/distributed_package_interfaces.md#interface-actorhost) | actor host 实现的接口，提供用于 *导出* 分布式 actor 的方法。 |
| [HostInfo](./distributed_package_api/distributed_package_interfaces.md#interface-hostinfo) | 标识远程 actor 主机的主机信息接口，提供创建客户端和获取类型信息的方法。 |
| [Distributable](./distributed_package_api/distributed_package_interfaces.md#interface-distributable) | 所有分布式 actor 所需实现的接口，提供将客户端远程调用分发到底层 actor 实例的方法。 |
| [Proxyable](./distributed_package_api/distributed_package_interfaces.md#interface-proxyablet) | 为实现类型化代理 `getProxy` 能力的分布式 actor 接口提供的接口。 |
| [Spawnable](./distributed_package_api/distributed_package_interfaces.md#interface-spawnablet) | 可在集群中被动态创建的分布式 actor 接口。任何打算在集群中被创建的 actor 接口，都需要实现该接口。 |
| [TypeSerializable](./distributed_package_api/distributed_package_interfaces.md#interface-typeserializable) | 为类型提供 `TypeModel` 类型模式描述的接口，用于分布式传输与元数据生成。 |

### 枚举

| 枚举名 | 功能 |
| --- | --- |
| [ReceiverMode](./distributed_package_api/distributed_package_enums.md#enum-receivermode) | Receiver 函数的调用模式，可取 `Ask` 或 `Tell`。 |
| [TypeModel](./distributed_package_api/distributed_package_enums.md#enum-typemodel) | Cangjie 类型的类型模式，用于描述该类型的结构。 |

### 异常

| 异常名 | 功能 |
| --- | --- |
| [ActorClusterException](./distributed_package_api/distributed_package_exceptions.md#class-actorclusterexception) | 当分布式 actor 集群发生错误时抛出，例如集群管理或协调失败。 |
| [ActorNotFoundException](./distributed_package_api/distributed_package_exceptions.md#class-actornotfoundexception) | 在分布式 actor 系统中找不到指定名称的 actor 时抛出。 |
| [ActorSystemException](./distributed_package_api/distributed_package_exceptions.md#class-actorsystemexception) | Actor 系统相关错误的通用异常，可携带自定义信息。 |
| [DeserializationException](./distributed_package_api/distributed_package_exceptions.md#class-deserializationexception) | 当反序列化操作失败时抛出。 |
| [ReceiverNotFoundException](./distributed_package_api/distributed_package_exceptions.md#class-receivernotfoundexception) | 在指定 actor 接口中找不到 receiver 函数时抛出。 |
| [RemoteException](./distributed_package_api/distributed_package_exceptions.md#class-remoteexception) | 分布式 actor 通信过程中的远程连接失败异常。 |
| [RemoteReceiverException](./distributed_package_api/distributed_package_exceptions.md#class-remotereceiverexception) | 包装远程 receiver 执行时抛出的不可序列化异常/错误，用于跨网络传输。 |
| [SerializationException](./distributed_package_api/distributed_package_exceptions.md#class-serializationexception) | 当序列化操作失败时抛出。 |
| [SerializingFunctionsNotFoundException](./distributed_package_api/distributed_package_exceptions.md#class-serializingfunctionsnotfoundexception) | 当找不到序列化函数时抛出。 |
