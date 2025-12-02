# actors.tcp_actor_system.cluster

## Function Description

The `actors.tcp_actor_system.cluster` package builds a TCP-based cluster manager on top of the core TCP actor system. It provides a head server and worker nodes that cooperate to spawn, place, look up, and remove distributed actors across multiple TCP hosts.

## API List

### Classes

| Class Name | Function |
| --- | --- |
| [TCPCluster](./cluster_package_api/cluster_package_classes.md#class-tcpcluster) | TCP-based implementation of `ActorCluster` consist of a head-server and multiple worker nodes. Provides functionalities to spawn and lookup distributed actors within the cluster. |


