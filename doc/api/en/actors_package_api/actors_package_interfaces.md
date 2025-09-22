# Interfaces

## interface ActorSystem

```cangjie
public interface ActorSystem
```

Function: Interface for actor system implementations that manage actor registration and remote communication. This interface defines the contract that distributed actor systems must implement to support actor discovery and remote method invocation.

### func register<T>()

```cangjie
public func register<T>(name: String, a: T): Bool where T <: Distributable
```

Function: Registers an actor instance with the actor system under the specified name.

Parameters:

- name: String - The name to register the actor under.
- a: T - The actor instance to register, must implement Distributable.

Return Value:

- Bool - Returns `true` if the actor was successfully registered, `false` if the name is already taken.

### func deregister()

```cangjie
public func deregister(name: String): Bool
```

Function: Removes an actor from the actor system.

Parameters:

- name: String - The name of the actor to deregister.

Return Value:

- Bool - Returns `true` if the actor was successfully deregistered, `false` if the actor was not found.

### func find()

```cangjie
public func find(name: String): Option<ActorInfo>
```

Function: Finds an actor by name and returns its information.

Parameters:

- name: String - The name of the actor to find.

Return Value:

- Option<ActorInfo> - Returns the actor information if found, `None` otherwise.

### func findAll()

```cangjie
public func findAll(): Array<ActorInfo>
```

Function: Returns information about all registered actors in the system.

Return Value:

- Array<ActorInfo> - An array containing information about all registered actors.

### func remoteCall()

```cangjie
public func remoteCall(name: String, receiverName: String, args: Array<DataModel>, config: ReceiverConfig, fut: Fullfillable): Unit
```

Function: Makes a remote call to an actor's receiver function and fulfills the provided future with the result.

Parameters:

- name: String - The name of the target actor.
- receiverName: String - The name of the receiver function to call.
- args: Array<DataModel> - Serialized arguments for the receiver function.
- config: ReceiverConfig - Configuration for the call.
- fut: Fullfillable - The future to fulfill with the result.

### func remoteTell()

```cangjie
public func remoteTell(name: String, receiverName: String, args: Array<DataModel>, config: ReceiverConfig): Unit
```

Function: Sends a message to an actor's receiver function without expecting a return value.

Parameters:

- name: String - The name of the target actor.
- receiverName: String - The name of the receiver function to call.
- args: Array<DataModel> - Serialized arguments for the receiver function.
- config: ReceiverConfig - Configuration for the call.

## interface Distributable

```cangjie
public interface Distributable
```

Function: Interface that distributed actor interfaces must implement to support remote communication. This interface provides the necessary methods for remote method invocation and metadata access.

### static func getMetadata()

```cangjie
public static func getMetadata(): Metadata
```

Function: Returns metadata about the actor interface, including information about all receiver functions.

Return Value:

- Metadata - The metadata describing the actor interface.

### func dispatchTell()

```cangjie
public func dispatchTell(receiverName: String, args: Array<DataModel>, config: ReceiverConfig): Unit
```

Function: Dispatches a Tell-mode call to the specified receiver function.

Parameters:

- receiverName: String - The name of the receiver function to call.
- args: Array<DataModel> - Serialized arguments for the receiver function.
- config: ReceiverConfig - Configuration for the call.

### func dispatchAsk()

```cangjie
public func dispatchAsk(receiverName: String, args: Array<DataModel>, config: ReceiverConfig): Waitable
```

Function: Dispatches an Ask-mode call to the specified receiver function and returns a waitable result.

Parameters:

- receiverName: String - The name of the receiver function to call.
- args: Array<DataModel> - Serialized arguments for the receiver function.
- config: ReceiverConfig - Configuration for the call.

Return Value:

- Waitable - A waitable object that will contain the result of the call.

## interface Fullfillable

```cangjie
public interface Fullfillable
```

Function: Interface for objects that can be fulfilled with a result value. This is typically used by distributed actor futures to receive results from remote operations.

### func fulfill()

```cangjie
public func fulfill(value: Any): Bool
```

Function: Fulfills the object with a result value.

Parameters:

- value: Any - The result value to fulfill the object with.

Return Value:

- Bool - Returns `true` if the object was successfully fulfilled, `false` if it was already fulfilled.

## interface Supervisable

```cangjie
public interface Supervisable
```

Function: This interface must be implemented by [`@Actor`](../macros/macros_package_api/macros_package_macros.md#actor-macro)-annotated classes.
It provides functions for exception and error handling.

### func onException(Exception)

```cangjie
public func onException(e: Exception): ControlAction
```

Function: This function will be called by the actor thread whenever a receiver throws an exception.

Parameters:

- e: Exception - the exception thrown by the receiver.

Return value:

- [`ControlAction](./actors_package_enums.md#enum-controlaction) - Returns the action to be taken by the actor thread.
By default, this function throws the input exception, which is functionally equivalent to printing the exception's
stack trace and returning `Stop`.

### func onError(Error)

```cangjie
public func onError(e: Error): ControlAction
```

Function: This function will be called by the actor thread whenever a receiver throws an error.

Parameters:

- e: Error - the error thrown by the receiver.

Return value:

- [`ControlAction](./actors_package_enums.md#enum-controlaction) - Returns the action to be taken by the actor thread.
By default, this function throws the input error, which is functionally equivalent to printing the error's
stack trace and returning `Stop`.

## interface Waitable

```cangjie
public interface Waitable
```

Function: Interface for objects that can be waited upon for completion. This interface is implemented by ActorFuture and its subclasses to provide a common way to wait for asynchronous operations to complete.

### func wait()

```cangjie
public func wait(): Any
```

Function: Waits for the operation to complete and returns the result.

Return Value:

- Any - The result of the operation when it completes.
