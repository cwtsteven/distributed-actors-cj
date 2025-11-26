# actors.distributed

## 功能说明

`actors.distributed` 包在核心 actor 编程模型基础上扩展，使 actor 能够跨网络边界通信。其提供远程 actor 通信、元数据管理与分布式 Future 的基础设施。

开发者可以借助该包在多节点上部署 actor，同时维持与本地 actor 相同的编程模型，从而构建可扩展的分布式系统。

## API 列表

### 类

| 类名 | 功能 |
| --- | --- |
| [ActorProxy](./distributed_package_api/distributed_package_classes.md#class-actorproxy) | 与远程 actor 通信的代理类，提供 Ask/Tell 两种调用方式。 |
| [DistributedFuture](./distributed_package_api/distributed_package_classes.md#class-distributedfuture) | 表示远程 receiver 调用待处理结果的具体类，提供获取与兑现结果的方法。 |
| [ActorNotFoundException](./distributed_package_api/distributed_package_classes.md#class-actornotfoundexception) | 在分布式 actor 系统中找不到指定名称的 actor 时抛出。 |
| [ReceiverNotFoundException](./distributed_package_api/distributed_package_classes.md#class-receivernotfoundexception) | 在指定 actor 接口中找不到 receiver 函数时抛出。 |
| [RemoteException](./distributed_package_api/distributed_package_classes.md#class-remoteexception) | 分布式 actor 通信过程中的远程连接失败异常。 |
| [ActorSystemException](./distributed_package_api/distributed_package_classes.md#class-actorsystemexception) | Actor 系统相关错误的通用异常，可携带自定义信息。 |
| [RemoteReceiverException](./distributed_package_api/distributed_package_classes.md#class-remotereceiverexception) | 包装远程 receiver 执行时抛出的不可序列化异常/错误，用于跨网络传输。 |

### 结构体

| 结构体名 | 功能 |
| --- | --- |
| [ActorInfo](./distributed_package_api/distributed_package_structs.md#struct-actorinfo) | 关于 actor 的信息，包括名称与元数据。 |
| [Metadata](./distributed_package_api/distributed_package_structs.md#struct-metadata) | 关于 actor 接口的元数据，包括 receiver 信息、描述与自定义数据。 |
| [ReceiverInfo](./distributed_package_api/distributed_package_structs.md#struct-receiverinfo) | 某个 receiver 的信息，包括参数模式、返回类型与元数据。 |
| [ReceiverParameter](./distributed_package_api/distributed_package_structs.md#struct-receiverparameter) | Receiver 参数的信息，包括名称、类型与描述。 |
| [FieldModel](./distributed_package_api/distributed_package_structs.md#struct-fieldmodel) | 结构体字段的信息，包括名称、类型与描述，是整体类型模型的一部分。 |
| [InvokeInfo](./distributed_package_api/distributed_package_structs.md#struct-invokeinfo) | 远程调用的信息，包含执行 receiver 所需的全部细节。 |

### 接口

| 接口名 | 功能 |
| --- | --- |
| [Distributable](./distributed_package_api/distributed_package_interfaces.md#interface-distributable) | 所有分布式 actor 所需实现的接口，提供将客户端远程调用分发到底层 actor 实例的方法。 |
| [ActorHost](./distributed_package_api/distributed_package_interfaces.md#interface-actorhost) | actor host 实现的接口，提供用于 *导出* 分布式 actor 的方法。 |
| [ActorClient](./distributed_package_api/distributed_package_interfaces.md#interface-actorclient) | actor client 实现的接口，提供用于 *查找* 分布式 actor 的方法。 |
| [LocalWaitable](./distributed_package_api/distributed_package_interfaces.md#interface-localwaitable) | 所有本地 `ActorFuture<T>` 类型共用的接口，提供以序列化形式（`DataModel`）获取 Future 结果的方法。 |
| [TypeSerializable](./distributed_package_api/distributed_package_interfaces.md#interface-typeserializable) | 为类型提供 `TypeModel` 类型模式描述的接口，用于分布式传输与元数据生成。 |

### 枚举

| 枚举名 | 功能 |
| --- | --- |
| [ReceiverMode](./distributed_package_api/distributed_package_enums.md#enum-receivermode) | Receiver 函数的调用模式，可取 `Ask` 或 `Tell`。 |
| [TypeModel](./distributed_package_api/distributed_package_enums.md#enum-typemodel) | Cangjie 类型的类型模式，用于描述该类型的结构。 |
