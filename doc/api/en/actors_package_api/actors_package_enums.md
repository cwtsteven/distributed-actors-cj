# Enums

## enum Tell

```Cangjie
public enum Tell {
    True
}
```

Function: Single valued enumeration to call a [@Receiver](../macros/macros_package_api/macros_package_macros.md#receiver-macro) while bypassing the [ActorFuture](./actors_package_classes.md#class-actorfuture) mechanism. `tell: True` should be passed to the [@Receiver](../macros/macros_package_api/macros_package_macros.md#receiver-macro) as a named argument.
