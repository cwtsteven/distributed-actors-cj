# Classes

## class DistributedActorFuture\<T>

```cangjie
public open class DistributedActorFuture<T>
```

Function: Base future type for distributed actor calls. It provides blocking and non-blocking result retrieval, lazy result mapping, and transport conversion helpers. Unlike local `ActorFuture`, this type may surface remote transport or actor-system failures.

## class ActorFuture\<T>

```cangjie
public class ActorFuture<T>
```

Function: A concrete local actor future representing the pending result of a closure submitted to an Actor. `ActorFuture<T>` inherits all retrieval and conversion APIs from `DistributedActorFuture<T>` and adds local task execution semantics.

### func get()

```cangjie
public func get(): T
```

Function: Blocks the current thread until the closure execution completes. If the closure throws an exception or error, this method will throw the same exception or error.

Return Value:

- `T` - The execution result of the corresponding closure.

### func get(Duration)

```cangjie
public func get(timeout: Duration): Option<T>
```

Function: Blocks the current thread until either the specified timeout has expired or the result is ready. If the result is ready, this method will return the result; otherwise, it will return `None`. If an exception or error is thrown, this method will throw the same exception or error. If the timeout is set to zero, it means there is no time limit, and it is essentially the same as calling `get()`.

Parameters:

- `timeout: Duration` - The maximum time to wait.

Return Value:

- `Option<T>` - Returns `None` if the result is not ready within the specified timeout, otherwise returns the result value.

### func tryGet()

```cangjie
public func tryGet(): Option<T>
```

Function: If the result is ready, it immediately returns the result; otherwise, it returns `None`. If the result is an exception or error, this method will throw the same exception or error.

Return Value:

- `Option<T>` - If the result is not yet ready, it returns `None`; otherwise, it returns the result value.

### func map\<U>()

```cangjie
public func map<U>(transform: (T) -> U): DistributedActorFuture<U>
```

Function: Creates a derived future that transforms the successful result of this future without spawning a new task. Exceptions and errors are forwarded unchanged.

Parameters:

- `transform: (T) -> U` - Maps the successful value into a new value.

Return Value:

- `DistributedActorFuture<U>` - A lazily resolved derived future.

### func toDataModel()

```cangjie
public func toDataModel(): DistributedActorFuture<DataModel>
```

Function: Converts a serializable future into a transport future whose successful result is encoded as `DataModel`.

Return Value:

- `DistributedActorFuture<DataModel>` - A derived distributed future carrying the serialized result payload.

### static func fromDataModel()

```cangjie
public static func fromDataModel(actorFuture: DistributedActorFuture<DataModel>): DistributedActorFuture<T>
```

Function: Converts a transport future of serialized data back into a typed future.

Parameters:

- `actorFuture: DistributedActorFuture<DataModel>` - The serialized remote result.

Return Value:

- `DistributedActorFuture<T>` - A typed distributed future that deserializes the successful payload on demand.

## class SequentialDispatcher

```cangjie
public class SequentialDispatcher {
  public init(enableReceiverPriority!: Bool = false)
}
```

Function: A dispatcher that queues and executes closures sequentially on a dedicated thread, and provides methods for submitting closures. Supports priority-based scheduling.

Typically, users do not need to use this class directly. Instead, they should use the [@Actor](../macros/macros_package_api/macros_package_macros.md#actor-macro) macro.

### init(Bool)

```cangjie
public init(enableReceiverPriority!: Bool = false)
```

Function: Creates a `SequentialDispatcher` instance and starts a thread to execute the closures submitted to it.

Parameters:

- `enableReceiverPriority!: Bool` - When set to `true`, it enables the priority feature, allowing closures with higher priority to be executed first. Defaults to `false`.

### func post\<T>(() -> T, ReceiverConfig)

```cangjie
public func post<T>(f: () -> T, config!: ReceiverConfig = ReceiverConfig.default): ActorFuture<T>
```

Function: Submits a closure to the dispatcher, which will be queued and executed on the dispatcher thread. This method returns an [ActorFuture\<T>](actors_package_classes.md#class-actorfuture), representing the pending result of the closure. If the dispatcher was created with `enableReceiverPriority` set to true, closures with higher priority will be executed first. If `enableReceiverPriority` is set to false, the `priority` value inside [ReceiverConfig](./actors_package_structs.md#struct-receiverconfig) will have no effect.

Parameters:

- `f: () -> T` - The closure submitted to the dispatcher.
- `config!: ReceiverConfig` - The configuration for the submitted task, defaults to `ReceiverConfig.default`.

Return Value:

- [ActorFuture\<T>](actors_package_classes.md#class-actorfuture) - Pending result of the submitted closure.

Exceptions:

- `IllegalArgumentException` - Thrown if the priority is out of range.

### func tell(() -> Unit, ReceiverConfig)

```cangjie
public func tell(f: () -> Unit, config!: ReceiverConfig = ReceiverConfig.default): Unit
```

Function: Submits a closure to the dispatcher without expecting a return value (`Tell` mode or fire-and-forget mode).

Parameters:

- `f: () -> Unit` - The closure submitted to the dispatcher.
- `config!: ReceiverConfig` - The configuration for the submitted task, defaults to `ReceiverConfig.default`.

Exceptions:

- `IllegalArgumentException` - Thrown if the priority is out of range.
