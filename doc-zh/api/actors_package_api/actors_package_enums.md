# 枚举

## enum Tell

```Cangjie
public enum Tell {
    True
}
```

功能：单值枚举，用于在调用 [@Receiver](../macros/macros_package_api/macros_package_macros.md#receiver-macro) 时绕过 [ActorFuture](./actors_package_classes.md#class-actorfuture) 机制。调用 Receiver 时以命名参数 `tell: True` 传入。
