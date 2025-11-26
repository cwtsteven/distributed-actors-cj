# actors.tcp_actor_system

## Function Description

The `actors.tcp_actor_system` package provides a TCP-based implementation of the distributed actors, enabling actors to communicate across network boundaries using TCP sockets. This package implements the `ActorHost` and `ActorClient` interfaces with full network communication support, making it suitable for production distributed actor systems.

This package enables building real distributed actor systems where actors can be deployed across different machines and communicate reliably over TCP networks.

## API List

### Classes

|                 Class Name              |                Function                 |
| --------------------------------- | ---------------------------------- |
| [TCPActorHost](./tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorhost) | TCP-based actor host implementation providing methods to *export* distributed actors. |
| [TCPActorClient](./tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorclient) | TCP-based actor client implementation providing methods to *find* distributed actors. |
| [TCPActorSystemSerializationException](./tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorsystemserializationexception) | Exception thrown when a serialization operation fails in the TCP actor system. |
| [TCPActorSystemDeserializationException](./tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorsystemdeserializationexception) | Exception thrown when a deserialization operation fails in the TCP actor system. |

### Enumerations

| Enumeration Name |      Function       |
| ---------------- | ------------------- |
| [Payload](./tcp_actor_system_package_api/tcp_actor_system_package_enums.md#enum-payload) | Message protocol between TCPActorHost and TCPActorClient, including various message types for actor communication. |
| [TCPActorSystemError](./tcp_actor_system_package_api/tcp_actor_system_package_enums.md#enum-tcpactorsystemerror) | Enum representing the error codes of the TCPActorSystem, including common error conditions. |
