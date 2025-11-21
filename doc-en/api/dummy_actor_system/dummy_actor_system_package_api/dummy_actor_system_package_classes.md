# Classes

## class DummyActorHost

```cangjie
public class DummyActorHost <: ActorHost
```

Function: In-memory implementation of ActorHost that manages actor registration and handles remote calls within the same process. This class uses concurrent data structures to store actors and their metadata, and provides a simple way to test distributed actor functionality without network communication.

### func register()

```cangjie
public func register(name: String, a: Distributable): Bool
```

Function: Registers an actor instance with the dummy actor system under the specified name.

Parameters:

- name: String - The name to register the actor under.
- a: Distributable - The actor instance to register, must implement Distributable.

Return Value:

- Bool - Returns `true` if the actor was successfully registered, `false` if the name is already taken.

### func deregister()

```cangjie
public func deregister(name: String): Bool
```

Function: Removes an actor from the dummy actor system.

Parameters:

- name: String - The name of the actor to deregister.

Return Value:

- Bool - Returns `true` if the actor was successfully deregistered, `false` if the actor was not found.

## class DummyActorClient

```cangjie
public class DummyActorClient <: ActorClient {
  public DummyActorClient(let host: DummyActorHost)
}
```

Function: In-memory implementation of ActorClient that provides access to actors managed by a DummyActorHost. This client enables communication with actors registered in the dummy actor system without network overhead.

### init(DummyActorHost)

```cangjie
public DummyActorClient(let host: DummyActorHost)
```

Function: Creates a DummyActorClient that connects to the specified DummyActorHost.

Parameters:

- host: DummyActorHost - The dummy actor host to connect to.

### prop id

```cangjie
public prop id: String
```

Function: The unique identifier of the dummy actor client. Always returns "dummy".

### func find()

```cangjie
public func find(name: String): Option<ActorInfo>
```

Function: Finds an actor by name and returns its information.

Parameters:

- name: String - The name of the actor to find.

Return Value:

- `Option<ActorInfo>` - Returns `Some(ActorInfo)` if the actor is found, `None` otherwise.

### func findAll()

```cangjie
public func findAll(): Array<ActorInfo>
```

Function: Finds all actors registered in the dummy actor system.

Return Value:

- `Array<ActorInfo>` - An array containing information about all registered actors.

### func remoteCall()

```cangjie
public func remoteCall(invokeInfo: InvokeInfo): Unit
```

Function: Makes a remote call to an actor's receiver function and fulfills the provided future with the result.

Parameters:

- invokeInfo: InvokeInfo - The information about the remote call invocation.
