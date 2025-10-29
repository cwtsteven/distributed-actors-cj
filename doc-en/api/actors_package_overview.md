# actors

## Function Description

The `actors` package provides the core actor programming model in Cangjie, enabling concurrent and asynchronous programming through the actor paradigm. This package includes fundamental components for actor communication, task dispatching, and configuration management.

This package serves as the foundation for actor-based systems, with additional functionality available in sub-packages like `actors.distributed` for remote communication and `actors.macros` for an easy-to-use DSL for creating actors.

## API List

### Classes

|                 Class Name              |                Function                 |
| --------------------------------- | ---------------------------------- |
| [ActorFuture\<T>](./actors_package_api/actors_package_classes.md#class-actorfuture) | Concrete class for representing the pending result of a closure submitted to an Actor. Provides methods for blocking and non-blocking result retrieval with timeout support. |
| [SequentialDispatcher](./actors_package_api/actors_package_classes.md#class-sequentialdispatcher) | Thread-safe dispatcher that queues and executes closures sequentially on a dedicated thread. Supports priority-based task scheduling and is typically used internally by the actor system. |

### Structs

|                 Struct Name              |                Function                 |
| --------------------------------- | ---------------------------------- |
| [ReceiverConfig](./actors_package_api/actors_package_structs.md#struct-receiverconfig) | Configuration struct for receiver function calls, including priority settings (1-10 scale) and other call parameters. Used to control the execution order and behavior of actor operations. |

### Enumerations

| Enumeration Name |      Function       |
| ---------------- | ------------------- |
| [Tell](./actors_package_api/actors_package_enums.md#enum-tell) | Single-valued enumeration that enables fire-and-forget messaging by bypassing the ActorFuture mechanism. Use `tell: True` as a named argument when calling receiver functions. |
