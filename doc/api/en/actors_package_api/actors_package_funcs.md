# Functions

## func controlEffect(ControlAction)

```Cangjie
public func controlEffect(action: ControlAction): Unit
```

Function: Interrupts the execution of the current receiver and gives
back the control to the actor thread. `controlEffect(ControlAction)` should only be called
within the scope of a receiver, or within the scope of an exception/error handler.
If not called within any of these scopes, an exception will be thrown.

> **Note**
>
> The current implementation of `controlEffect` throws a private exception that is
> catched by the actor thread.

Parameters:

- action: [`ControlAction](./actors_package_enums.md#enum-controlaction) - The action to be
taken by the actor thread.