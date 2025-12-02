# actors.tcp_actor_system.cluster

## 功能说明

`actors.tcp_actor_system.cluster` 包在核心 TCP actor 系统之上构建了一个基于 TCP 的集群管理器。该包提供头节点与工作节点的协作机制，用于在多个 TCP 主机之间创建、放置、查找与移除分布式 actor。

## API 列表

### 类

| 类名 | 功能 |
| --- | --- |
| [TCPCluster](./cluster_package_api/cluster_package_classes.md#class-tcpcluster) | 基于 TCP 的 `ActorCluster` 实现，由头节点与多个工作节点组成。提供在集群内创建与查找分布式 actor 的功能。 |

