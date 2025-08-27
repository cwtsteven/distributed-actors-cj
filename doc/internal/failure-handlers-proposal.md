# 1 API

## `@Receiver`-level handlers

The `@Receiver` macro has `onException` and `onError` options that
accept closures as values. These closures are known as _exception handlers_
and _error handlers_, respectively.
Handlers have type `(Exception) -> ControlAction` or `(Error) -> ControlAction`,
where a `ControlAction` defines the behaviour of the actor when it finds
an `Exception` or an `Error`:

```Cangjie
public enum ControlAction { Continue | Poison(Int64) | Stop }
```

- `Continue` means the actor should keep processing other receivers.
- `Poison(Int64)` means a `PoisonPill` should be added to the actor's mailbox
at the provided priority. 
When a `PoisonPill` is removed from the mailbox, the actor stops.
The value must be a valid priority, and will
be ignored if out of range or if receiver priority is disabled.
- `Stop` means the actor should stop immediately.

Example:

```Cangjie
class Computer {
    @Receiver[onException: handle, onError: { e => throw e }]
    func multiply(x: Int64, y: Int64): Int64 {
        if (x < 0 || y < 0) { throw IllegalArgumentException() }
        return x * y
    }

    func handle(e: Exception): ControlAction {
        match (e) {
            case _: IllegalArgumentException => throw e
            case _: OverflowException =>
                println("Overflow ocurred")
                Poison(5)
            case _ => Continue
        }
    }
}
```

In the example above, if the receiver `multiply` throws an exception, the member function `handle` will be called,
and the returned `ControlAction` will be executed.
Note that exceptions thrown from exception or error handlers will not be caught and will stop the actor immediately.
In the previous example, if the receiver `multiply` throws an `IllegalArgumentException` or an `Error`, the actor will
stop immediately and the `Error`/`Exception` will be thrown on the actor thread.

Note that the `onError` and `onException` options have access to any variable that
is accessible from the beginning of the body of the receiver (i.e. function parameters, member variables and global variables).

Example:

```Cangjie
class Computer {
    @Receiver[onException: processException]
    func multiply(x: Int64, y: Int64, processException: (Exception) => ControlAction): Int64 {
        if (x < 0 || y < 0) { throw IllegalArgumentException() }
        return x * y
    }
}
```

## `@Actor`-level handlers

It is also possible to provide exception and error handlers at the actor level by providing `onException` and `onError`
options to the `@Actor` macro. These options set the handler for all the receiver functions of this actor.
Naturally, handlers defined at the receiver level override handlers defined at the actor level.

Note that `onException` and `onError` options at the actor level do **not** have access to any non-static members of the
`@Actor`-annotated class.

## Aliases

Besides closures, `onException` and `onError` options accept the following aliases:

- `Continue` is an alias for `{ _ => Continue }`
- `Poison(<value>)` is an alias for `{ _ => Poison(<value>)}`
- `Poison` is an alias for `{ _ => Poison(5) }`
- `Stop` is an alias for `{ _ => Stop }`
- `Throw` is an alias for `{ e => throw e }`

Since these aliases are independent of the type of failure,
`onFailure: <alias>` can be used as a shorthand for `onException: <alias>, onError: <alias>`.

Example:

```Cangjie
@Actor[onFailure: Continue]
class Computer {
    @Receiver[onException: Stop, onError: Poison]
    func divide(x: Float64, y: Float64): Float64 {
        return x / y
    }
}
```

## Control effects

A `ControlEffect` can be thrown from inside a receiver
to control the actor loop's behaviour.

```Cangjie
public class ControlEffect <: Exception {
    public ControlEffect(public let action: ControlAction) {
        super("Uncaught control effect with action ${action}")
    }
}
```

Example:

```Cangjie
@Actor
class Computer {
    @Receiver
    func divide(x: Float64, y: Float64): Float64 {
        if (abs(y) < 1e-10) {
            println("Value of y was too small)
            throw ControlEffect(Stop)
        }
        return x / y
    }
}
```

This allows developpers to provide an API
to control the actor thread using receiver calls.

Example:

```Cangjie
@Actor
class MyActor {
    @Receiver
    public func stopActor(): Unit {
        throw ControlEffect(Stop)
    }
}
```

Note that `ControlEffect`s thrown from exception or error handlers will be processed as any other exception:
they will be thrown on the actor thread, which will stop the actor immediately.

# 2 Implementation
