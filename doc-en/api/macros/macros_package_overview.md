# actors.macros

## Function Description

The `actors.macros` package provides a DSL for declaring actors, actor interfaces, and receivers. These macros transform standard Cangjie code into actor-domain code, supporting both local and distributed actor programming models.

This package enables developers to use a declarative approach to actor programming, where standard classes and interfaces are transformed into actors through compile-time macro expansion.

## API List

### Macros

|              Macros          |           Function           |
| --------------------------- | ------------------------ |
| [@Actor](./macros_package_api/macros_package_macros.md#actor-macro)     | Transform a class into an actor. |
| [@ActorInterface](./macros_package_api/macros_package_macros.md#actorinterface-macro)     | Transform an interface into an actor interface. |
| [@Receiver](./macros_package_api/macros_package_macros.md#receiver-macro)     | Transform a method into a receiver. |
