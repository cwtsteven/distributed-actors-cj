# actors.dummy_actor_system

## Function Description

The `actors.dummy_actor_system` package provides a simple in-memory implementation of the distributed actor system interfaces. This package is primarily used for testing and development purposes, offering a lightweight alternative to full network-based distributed actor systems.

Key features include:
- **In-Memory Actor Management**: Actors are stored in memory using concurrent data structures
- **Local Communication**: All actor communication happens within the same process
- **Testing Support**: Ideal for unit testing and integration testing of distributed actor functionality
- **Simple Implementation**: Straightforward implementation of ActorHost and ActorClient interfaces
- **Future Management**: Support for both ask and tell patterns with proper future handling

This package enables developers to test distributed actor functionality without the complexity of network communication, making it easier to develop and debug actor-based applications.

## API List

### Classes

|                 Class Name              |                Function                 |
| --------------------------------- | ---------------------------------- |
| [DummyActorHost](./dummy_actor_system_package_api/dummy_actor_system_package_classes.md#class-dummyactorhost) | In-memory implementation of ActorHost that manages actor registration and handles remote calls within the same process. |
| [DummyActorClient](./dummy_actor_system_package_api/dummy_actor_system_package_classes.md#class-dummyactorclient) | In-memory implementation of ActorClient that provides access to actors managed by a DummyActorHost. |
