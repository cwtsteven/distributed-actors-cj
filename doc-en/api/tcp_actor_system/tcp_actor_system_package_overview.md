# actors.tcp_actor_system

## Function Description

The `actors.tcp_actor_system` package provides a TCP-based implementation of the distributed actors, enabling actors to communicate across network boundaries using TCP sockets. This package implements the `ActorHost` and `ActorClient` interfaces with full network communication support, making it suitable for production distributed actor systems.

This package enables building real distributed actor systems where actors can be deployed across different machines and communicate reliably over TCP networks.

## API List

### Classes

|                 Class Name              |                Function                 |
| --------------------------------- | ---------------------------------- |
| [TCPActorClient](./tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorclient) | TCP-based actor client implementation providing methods to *find* distributed actors. |
| [TCPActorHost](./tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorhost) | TCP-based actor host implementation providing methods to *export* distributed actors. |
| [TCPActorSystem](./tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorsystem) | Main system class that provides logging configuration for the TCP actor system. |

### Exceptions

| Exception Name                              | Function                                                                                 |
| ------------------------------------------- | ---------------------------------------------------------------------------------------- |
| [TCPActorSystemDeserializationException](./tcp_actor_system_package_api/tcp_actor_system_package_exceptions.md#class-tcpactorsystemdeserializationexception) | Exception thrown when a deserialization operation fails in the TCP actor system. |
| [TCPActorSystemInternalException](./tcp_actor_system_package_api/tcp_actor_system_package_exceptions.md#class-tcpactorsysteminternalexception) | Exception thrown when an internal error occurs in the TCP actor system. |
| [TCPActorSystemRemoteException](./tcp_actor_system_package_api/tcp_actor_system_package_exceptions.md#class-tcpactorsystemremoteexception) | Exception thrown when a remote connection fails in the TCP actor system. |
| [TCPActorSystemRequestTimeoutException](./tcp_actor_system_package_api/tcp_actor_system_package_exceptions.md#class-tcpactorsystemrequesttimeoutexception) | Exception thrown when a request timeout occurs in the TCP actor system. |
| [TCPActorSystemSerializationException](./tcp_actor_system_package_api/tcp_actor_system_package_exceptions.md#class-tcpactorsystemserializationexception) | Exception thrown when a serialization operation fails in the TCP actor system. |

### Structs

| Struct Name | Function |
|-------------|----------|
| [TCPActorClientInfo](./tcp_actor_system_package_api/tcp_actor_system_package_structs.md#struct-tcpactorclientinfo) | Information about a TCP actor client, including the client ID, address, and port. |
