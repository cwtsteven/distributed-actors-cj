# actors.distributed

## 功能说明

`actors.distributed` 包在核心 Actor 编程模型之上扩展，支持跨网络边界通信的分布式系统。该包提供远程 Actor 通信、元数据管理与分布式 Future 等基础设施。

主要特性包括：
- **分布式 Actor 通信**：提供远程 Actor 通信抽象
- **分布式 Future**：远程操作的异步结果处理
- **序列化支持**：跨网络边界的数据序列化/反序列化

该包使开发者能够在多个节点上部署 Actor，同时保持与本地 Actor 一致的编程模型，从而构建可扩展的分布式系统。

## API 列表

### 类

| 类名 | 功能 |
| --- | --- |
| [ActorProxy](./distributed_package_api/distributed_package_classes.md#class-actorproxy) | 与远程 Actor 通信的代理，支持 Ask/Tell 两种模式。 |
| [DistributedFuture](./distributed_package_api/distributed_package_classes.md#class-distributedfuture) | 分布式 Actor 通信的 Future，实现序列化数据模型与远程结果完成。 |
| [ActorNotFoundException](./distributed_package_api/distributed_package_classes.md#class-actornotfoundexception) | 当在分布式 Actor 系统中找不到指定名称的 Actor 时抛出。 |
| [ReceiverNotFoundException](./distributed_package_api/distributed_package_classes.md#class-receivernotfoundexception) | 当在指定 Actor 接口中找不到 Receiver 函数时抛出。 |
| [RemoteException](./distributed_package_api/distributed_package_classes.md#class-remoteexception) | 分布式通信过程中远程连接失败时抛出。 |
| [ActorSystemException](./distributed_package_api/distributed_package_classes.md#class-actorsystemexception) | Actor 系统相关错误的通用异常。 |
| [RemoteReceiverException](./distributed_package_api/distributed_package_classes.md#class-remotereceiverexception) | 包装远程 Receiver 执行中抛出的不可序列化异常/错误，可序列化以跨网络传输。 |

### 结构体

| 结构体名 | 功能 |
| --- | --- |
| [ActorInfo](./distributed_package_api/distributed_package_structs.md#struct-actorinfo) | 包含 Actor 名称与其元数据的信息。 |
| [Metadata](./distributed_package_api/distributed_package_structs.md#struct-metadata) | 关于 Actor 接口的元数据，包括 Receiver 信息、描述与自定义数据。 |
| [ReceiverInfo](./distributed_package_api/distributed_package_structs.md#struct-receiverinfo) | 某个 Receiver 函数的信息，包括参数模式、返回类型与元数据。 |
| [ReceiverParameter](./distributed_package_api/distributed_package_structs.md#struct-receiverparameter) | Receiver 函数参数的信息，包括名称、类型与描述。 |
| [FieldModel](./distributed_package_api/distributed_package_structs.md#struct-fieldmodel) | 结构体字段信息，包括名称、类型与描述。 |
| [InvokeInfo](./distributed_package_api/distributed_package_structs.md#struct-invokeinfo) | 远程调用所需的信息，包含调用 Actor/Receiver、参数与配置等。 |

### 接口

| 接口名 | 功能 |
| --- | --- |
| [Distributable](./distributed_package_api/distributed_package_interfaces.md#interface-distributable) | 分布式 Actor 接口需实现的接口，支持远程通信。 |
| [ActorHost](./distributed_package_api/distributed_package_interfaces.md#interface-actorhost) | 管理分布式 Actor 系统中 Actor 的注册/注销。 |
| [ActorClient](./distributed_package_api/distributed_package_interfaces.md#interface-actorclient) | 为分布式系统提供远程访问 Actor 的客户端接口。 |
| [LocalWaitable](./distributed_package_api/distributed_package_interfaces.md#interface-localwaitable) | 可在本地等待并提供序列化结果的对象接口。 |

### 枚举

| 枚举名 | 功能 |
| --- | --- |
| [ReceiverMode](./distributed_package_api/distributed_package_enums.md#enum-receivermode) | Receiver 函数的调用模式（AskOnly、TellOnly、AskAndTell）。 |
| [TypeModel](./distributed_package_api/distributed_package_enums.md#enum-typemodel) | 序列化与元数据生成中的类型信息，支持原生类型、结构体与列表。 |
