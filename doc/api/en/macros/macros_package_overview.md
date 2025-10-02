# actors.macros

## Function Description

The `actors.macros` package provides compile-time macros for declaring actors, actor interfaces, and receiver functions. These macros transform standard Cangjie code into actor-based implementations, supporting both local and distributed actor programming models with comprehensive configuration options.

Key features include:
- **Actor Class Generation**: Transform classes into actors with automatic dispatcher integration
- **Actor Interface Generation**: Create actor interfaces for both local and distributed communication
- **Receiver Function Generation**: Convert methods into actor receiver functions with ask/tell patterns
- **Distributed Support**: Generate distributed actor interfaces with serialization support
- **Priority Configuration**: Support for priority-based receiver function execution
- **Metadata Generation**: Automatic generation of actor metadata for distributed systems

This package enables developers to use a declarative approach to actor programming, where standard classes and interfaces are transformed into actor implementations through compile-time macro expansion.

## API List

### Macros

|              Macros          |           Function           |
| --------------------------- | ------------------------ |
| [@Actor](./macros_package_api/macros_package_macros.md#actor-macro)     | Transform a class into an actor with automatic dispatcher integration and receiver function generation. |
| [@ActorInterface](./macros_package_api/macros_package_macros.md#actorinterface-macro)     | Transform an interface into an actor interface for both local and distributed actor communication. |
| [@Receiver](./macros_package_api/macros_package_macros.md#receiver-macro)     | Transform a method into a receiver function that can be called by other actors with ask/tell patterns. |
