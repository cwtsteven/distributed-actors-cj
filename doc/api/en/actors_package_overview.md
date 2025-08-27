# actors

## Function Description

Provides actor programming model in Cangjie. 

## API List

### Classes

|                 Class Name              |                Function                 |
| --------------------------------- | ---------------------------------- |
| [ActorFuture\<T>](./actors_package_api/actors_package_classes.md#class-actorfuture) | Calling a receiver returns an [ActorFuture\<T>](./actors_package_api/actors_package_classes.md#class-actorfuture) object, which can be used to retrieve its result.                      |
| [SequentialDispatcher](./actors_package_api/actors_package_classes.md#class-actor) | Provides the functionality to queue multiple closures for execution on the same thread. Typically, users do not need to use this type directly.          |

### Enumerations

| Enumeration Name |      Function       |
| ---------------- | ------------------- |
| [Tell](./actors_package_api/actors_package_enums.md#enum-tell) | Single valued enumeration to call a `@Receiver` while bypassing the `ActorFuture` mechanism.|
