# 1 API

## `Supervisable` actors

Actors must implement the `Supervisable` inteface, which defines
the `onException` and `onError` functions.
The signature of these functions is `(Exception) -> ControlAction` or `(Error) -> ControlAction`,
where a `ControlAction` defines how the actor should respond whenever one of its
receivers throws an exception or an error.

```Cangjie
public enum ControlAction { Continue | Poison(Int64) | Stop }
```

- `Continue` means the actor should keep processing other receivers.
- `Poison(Int64)` means a `PoisonPill` should be added to the actor's mailbox
at the provided priority. 
When a `PoisonPill` is removed from the mailbox, the actor stops.
The value must be a valid priority, and will be ignored if receiver priority is disabled.
- `Stop` means the actor should stop immediately.

Example:

```Cangjie
@Actor
class Computer <: Supervisable {
    @Receiver
    func multiply(x: Int64, y: Int64): Int64 {
        if (x < 0 || y < 0) { throw IllegalArgumentException() }
        return x * y
    }

    override public func onException(e: Exception): ControlAction {
        match (e) {
            case _: IllegalArgumentException => throw e
            case _: OverflowException =>
                println("Overflow ocurred")
                Poison(5)
            case _ => Continue
        }
    }

    override public func onError(e: Error): ControlAction {
        throw e
    }
}
```

## Control effects

The function `controlEffect` can be used from inside a receiver
to control the actor loop's behaviour.

```Cangjie
public func controlEffect(action: ControlAction): Unit
```

Example:

```Cangjie
@Actor
class Computer <: Supervisable {
    @Receiver
    func divide(x: Float64, y: Float64): Float64 {
        if (abs(y) < 1e-10) {
            println("Value of y was too small")
            controlEffect(Stop)
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
class MyActor <: Supervisable {
    @Receiver
    public func stopActor(): Unit {
        controlEffect(Stop)
    }
}
```

## Actor lifecycle

Previously, the actor thread was only stopped whenever the instance of the `@Actor` annotated
class was finalized, which meant it wasn't possible to have a reference to a stopped actor.

This is no longer the case, it is perfectly possible to have a reference to a stopped actor
or to be waiting for the return value of an actor that has been stopped.
To prevent any dangling `LocalActorFuture`s, the following measures are taken:

- Any `LocalActorFuture`s returned after the actor is stopped will be _cancelled_ immediately and
will throw a `FutureCancelledException` when `get` is called.
- Any receivers pending execution will be cleared from the mailbox, which will remain empty.
Futures associated with cleared receivers will also throw a `FutureCancelledException` when `get`
is called.
- Any `LocalActoreFuture`s associated with receivers interrupted by control effects will
throw an `InterruptedReceiverException` when `get` is called.
