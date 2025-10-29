# actors.tcp_actor_system

## Function Description

The `actors.tcp_actor_system` package provides a TCP-based implementation of the distributed actor system, enabling actors to communicate across network boundaries using TCP sockets. This package implements the ActorHost and ActorClient interfaces with full network communication support, making it suitable for production distributed actor systems.

Key features include:
- **TCP Network Communication**: Full TCP socket-based communication between actor hosts and clients
- **Concurrent Connection Management**: Support for multiple concurrent client connections
- **Message Serialization**: Built-in serialization and deserialization of actor messages
- **Error Handling**: Comprehensive error handling for network operations and actor communication
- **Logging Support**: Integrated logging for debugging and monitoring
- **Asynchronous Processing**: Non-blocking message processing with proper future handling

This package enables building real distributed actor systems where actors can be deployed across different machines and communicate reliably over TCP networks.

## API List

### Classes

|                 Class Name              |                Function                 |
| --------------------------------- | ---------------------------------- |
| [TCPActorSystem](./tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorsystem) | Main system class that provides logging configuration for the TCP actor system. |
| [TCPActorHost](./tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorhost) | TCP-based implementation of ActorHost that manages actor registration and handles remote calls over TCP connections. |
| [TCPActorClient](./tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorclient) | TCP-based implementation of ActorClient that provides remote access to actors over TCP connections. |
| [TCPActorSystemSerializationException](./tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorsystemserializationexception) | Exception thrown when a serialization operation fails in the TCP actor system. |
| [TCPActorSystemDeserializationException](./tcp_actor_system_package_api/tcp_actor_system_package_classes.md#class-tcpactorsystemdeserializationexception) | Exception thrown when a deserialization operation fails in the TCP actor system. |

### Enumerations

| Enumeration Name |      Function       |
| ---------------- | ------------------- |
| [Payload](./tcp_actor_system_package_api/tcp_actor_system_package_enums.md#enum-payload) | Enum representing the message protocol between TCPActorHost and TCPActorClient, including various message types for actor communication. |
| [TCPActorSystemError](./tcp_actor_system_package_api/tcp_actor_system_package_enums.md#enum-tcpactorsystemerror) | Enum representing the error codes of the TCPActorSystem, including common error conditions. |
