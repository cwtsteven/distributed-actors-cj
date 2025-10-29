# 完整 API 参考

本文档提供了分布式 actor 框架中所有公共 API 的综合列表，按包组织。

## actors 包

### 类

| 类名 | 描述 |
|------------|-------------|
| **[ActorFuture\<T>](api/actors_package_api/actors_package_classes.md#class-actorfuture)** | 表示提交给 Actor 的闭包的待处理结果的具体类 |
| **[SequentialDispatcher](api/actors_package_api/actors_package_classes.md#class-sequentialdispatcher)** | 用于顺序任务执行的线程安全调度器 |

### 结构体

| 结构体名 | 描述 |
|-------------|-------------|
| **[ReceiverConfig](api/actors_package_api/actors_package_structs.md#struct-receiverconfig)** | receiver 函数调用的配置 |

### 枚举

| 枚举名 | 描述 |
|-----------|-------------|
| **[Tell](api/actors_package_api/actors_package_enums.md#enum-tell)** | 用于绕过 ActorFuture 机制的单值枚举 |

## actors.distributed 包

### 类

| 类名 | 描述 |
|------------|-------------|
| **[ActorProxy](api/distributed/distributed_package_api/distributed_package_classes.md#class-actorproxy)** | 用于与远程 actor 通信的代理 |
| **[DistributedFuture](api/distributed/distributed_package_api/distributed_package_classes.md#class-distributedfuture)** | 分布式 actor 通信的 Future |
| **[ActorNotFoundException](api/distributed/distributed_package_api/distributed_package_classes.md#class-actornotfoundexception)** | actor 未找到异常 |
| **[ReceiverNotFoundException](api/distributed/distributed_package_api/distributed_package_classes.md#class-receivernotfoundexception)** | receiver 未找到异常 |
| **[RemoteException](api/distributed/distributed_package_api/distributed_package_classes.md#class-remoteexception)** | 远程连接失败异常 |
| **[ActorSystemException](api/distributed/distributed_package_api/distributed_package_classes.md#class-actorsystemexception)** | 通用 actor 系统异常 |
| **[RemoteReceiverException](api/distributed/distributed_package_api/distributed_package_classes.md#class-remotereceiverexception)** | 远程 receiver 失败的可序列化异常 |

### 接口

| 接口名 | 描述 |
|----------------|-------------|
| **[Distributable](api/distributed/distributed_package_api/distributed_package_interfaces.md#interface-distributable)** | 分布式 actor 接口的接口 |
| **[ActorHost](api/distributed/distributed_package_api/distributed_package_interfaces.md#interface-actorhost)** | actor host 实现的接口 |
| **[ActorClient](api/distributed/distributed_package_api/distributed_package_interfaces.md#interface-actorclient)** | actor client 实现的接口 |
| **[LocalWaitable](api/distributed/distributed_package_api/distributed_package_interfaces.md#interface-localwaitable)** | 本地可等待对象的接口 |

### 结构体

| 结构体名 | 描述 |
|-------------|-------------|
| **[ActorInfo](api/distributed/distributed_package_api/distributed_package_structs.md#struct-actorinfo)** | 关于 actor 的信息 |
| **[Metadata](api/distributed/distributed_package_api/distributed_package_structs.md#struct-metadata)** | 关于 actor 接口的元数据 |
| **[ReceiverInfo](api/distributed/distributed_package_api/distributed_package_structs.md#struct-receiverinfo)** | 关于 receiver 函数的信息 |
| **[ReceiverParameter](api/distributed/distributed_package_api/distributed_package_structs.md#struct-receiverparameter)** | 关于 receiver 参数的信息 |
| **[FieldModel](api/distributed/distributed_package_api/distributed_package_structs.md#struct-fieldmodel)** | 关于结构体字段的信息 |
| **[InvokeInfo](api/distributed/distributed_package_api/distributed_package_structs.md#struct-invokeinfo)** | 关于远程调用调用的信息 |

### 枚举

| 枚举名 | 描述 |
|-----------|-------------|
| **[ReceiverMode](api/distributed/distributed_package_api/distributed_package_enums.md#enum-receivermode)** | receiver 函数的调用模式 |
| **[TypeModel](api/distributed/distributed_package_api/distributed_package_enums.md#enum-typemodel)** | 序列化的类型信息 |

## actors.distributed.mcp 包

### 类

| 类名 | 描述 |
|------------|-------------|
| **[ActorToolManager](api/distributed/mcp/mcp_package_api/mcp_package_classes.md#class-actortoolmanager)** | 分布式 actor 的工具管理器 |
| **[ReceiverTool](api/distributed/mcp/mcp_package_api/mcp_package_classes.md#class-receivertool)** | receiver 函数的 MCP 工具实现 |
| **[ActorMCPException](api/distributed/mcp/mcp_package_api/mcp_package_classes.md#class-actormcpexception)** | MCP 操作异常 |

## actors.dummy_actor_system 包

### 类

| 类名 | 描述 |
|------------|-------------|
| **[DummyActorHost](api/dummy_actor_system/dummy_actor_system_package_api/dummy_actor_system_package_classes.md#class-dummyactorhost)** | 内存中 actor host 实现 |
| **[DummyActorClient](api/dummy_actor_system/dummy_actor_system_package_api/dummy_actor_system_package_classes.md#class-dummyactorclient)** | 内存中 actor client 实现 |

## actors.tcp_actor_system 包

### 类

| 类名 | 描述 |
|------------|-------------|
| **[TCPActorSystem](api/tcp_actor_system/tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorsystem)** | 主 TCP actor 系统类 |
| **[TCPActorHost](api/tcp_actor_system/tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorhost)** | 基于 TCP 的 actor host 实现 |
| **[TCPActorClient](api/tcp_actor_system/tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorclient)** | 基于 TCP 的 actor client 实现 |
| **[TCPActorSystemSerializationException](api/tcp_actor_system/tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorsystemserializationexception)** | 序列化异常 |
| **[TCPActorSystemDeserializationException](api/tcp_actor_system/tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorsystemdeserializationexception)** | 反序列化异常 |

### 枚举

| 枚举名 | 描述 |
|-----------|-------------|
| **[Payload](api/tcp_actor_system/tcp_actor_system_package_api/tcp_actor_system_package_enums.md#enum-payload)** | TCP host 和 client 之间的消息协议 |
| **[TCPActorSystemError](api/tcp_actor_system/tcp_actor_system_package_api/tcp_actor_system_package_enums.md#enum-tcpactorsystemerror)** | TCP actor 系统的错误代码 |

## actors.macros 包

### 宏

| 宏名 | 描述 |
|------------|-------------|
| **[@ActorInterface](api/macros/macros_package_api/macros_package_macros.md#actorinterface-macro)** | 将接口转换为 actor 接口 |
| **[@Actor](api/macros/macros_package_api/macros_package_macros.md#actor-macro)** | 将类转换为 actor |
| **[@Receiver](api/macros/macros_package_api/macros_package_macros.md#receiver-macro)** | 将方法转换为 receiver 函数 |


