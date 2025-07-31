# Distributed actors framework

## Requirements

### Functional requirements

- define an actor declaration
- define an actor interface (possibly distributed)
- register a distributed actor with a name, this will also register relevant meta-data (desc, input schema, etc.)
- deregister a distributed actor with a name
- find a distributed actor with a name
- get a list of available distributed actors and their meta-data
- call receivers on a distributed actor

### Non-functional requirements:**

- cross-language support, i.e. call receivers from outside of Cangjie, could be done by generating an FFI bindings for different languages, or generate an IDL/schema of data conversion, for instance exposing a restful-api and runs an http server, or runs an grpc-server
- authorization and security
- failure handling, message-loss, node crash, etc.

## Concept/Tutorial

### Step 1: defining a distributed actor interface

```cangjie
@ActorInterface[
    distributed: true,
    desc: "....",
    customInfo: [
        OHOSActorSystem: { // custom information used by OHOSActorSystem specifically
            abilityName: "..."
        }
    ]
]
public interface Service {
    @Receiver[
        desc: "....",
        customInfo: [
            ...
        ]
    ]
    func foo(): Int64
}
```

The macro will generate relevant meta-data for this interface.

i.e.

```cangjie
public interface Service {
    ...

    public static func getMetadata(): Metadata {
        // generated from @ActorInterface
    }
}
```

```cangjie
public class Metadata {
    private let actorName: String
    private let receivers: Array<ReceiverInfo>
    private let description: String
    private let customInfo: Array<CustomInfo>
    ...
}
```

### Step 2: defining an actor implementing the actor interface

```cangjie
@Actor
public class ServiceImpl {
    @Receiver
    public func foo(): Int64 { 42 }
}
```

### Step 3: registering this actor with a name

```cangjie
main() {
    actorSystem.register<Service>("myService", ServiceImpl())
}
```

The `register` function will also call the `Service.getMetadata()` function to get the relevant metadata information and register with it.


### Step 4: finding this actor from another node via name or type

```cangjie
main() {
    let proxy: Service = actorSystem.find<Service>("myService")
    let arr: Array<Service> = actorSystem.findAll<Service>()
    let genericProxy: ActorProxy = actorSystem.find("myService")
}
```

### Step 5: calling a receiver on a distributed actor

```cangjie
main() {
    let proxy: Service = actorSystem.find<Service>("myService")
    let fut: ActorFuture<Int64> = proxy.foo()
    let res: Int64 = fut.get()
    println(res) // 42

    let genericProxy: ActorProxy = actorSystem.find("myService")
    let fut: ActorFuture<Int64> = genericProxy.remoteCall<Int64>(ReceiverInfo("foo"), [])
    let res: Int64 = fut.get()
    println(res) // 42
}
```

### Step 6: getting a list of all registered actors

```cangjie
main() {
    let registered: Array<(String, Metadata)> = actorSystem.getAll()
}
```

Users can find the appropriate actors by using the metadata and calls relevant receivers. This is useful for interacting with agents.

### Step 7: deregister this actor

```cangjie
main() {
    actorSystem.deregister("myService")
}
```

## Design

### Metadata

```cangjie
public struct Metadata {
    // need someone to do this
}
```

### @ActorInterface macro
