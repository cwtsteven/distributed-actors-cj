# 类

## class DummyActorHost

```cangjie
public class DummyActorHost <: ActorHost
```

功能：内存中的 `ActorHost` 实现，管理 Actor 注册并在同一进程内处理“远程调用”。使用并发数据结构存储 Actor 与其元数据，便于在无网络通信的环境下测试分布式功能。

### func register()

```cangjie
public func register(name: String, a: Distributable): Bool
```

功能：以指定名称在 Dummy 系统中注册 Actor 实例。

参数：

- `name: String` — 注册名。
- `a: Distributable` — 待注册的 Actor 实例，需实现 `Distributable`。

返回值：

- `Bool` — 成功返回 `true`；若名称已被占用返回 `false`。

### func deregister()

```cangjie
public func deregister(name: String): Bool
```

功能：从 Dummy 系统移除指定 Actor。

参数：

- `name: String` — 要移除的 Actor 名称。

返回值：

- `Bool` — 成功返回 `true`；未找到则返回 `false`。

## class DummyActorClient

```cangjie
public class DummyActorClient <: ActorClient {
  public DummyActorClient(let host: DummyActorHost)
}
```

功能：内存中的 `ActorClient` 实现，访问由 `DummyActorHost` 管理的 Actor；无需网络开销即可与之通信。

### init(DummyActorHost)

```cangjie
public DummyActorClient(let host: DummyActorHost)
```

功能：创建连接到指定 `DummyActorHost` 的客户端。

参数：

- `host: DummyActorHost` — 目标 Dummy 主机。

### prop id

```cangjie
public prop id: String
```

功能：Dummy 客户端的唯一标识，始终为 "dummy"。

### func find()

```cangjie
public func find(name: String): Option<ActorInfo>
```

功能：按名称查找 Actor 并返回信息。

参数：

- `name: String` — 要查找的 Actor 名称。

返回值：

- `Option<ActorInfo>` — 找到则 `Some(ActorInfo)`，否则 `None`。

### func findAll()

```cangjie
public func findAll(): Array<ActorInfo>
```

功能：查询 Dummy 系统中注册的全部 Actor。

返回值：

- `Array<ActorInfo>` — Actor 信息数组。

### func remoteCall()

```cangjie
public func remoteCall(invokeInfo: InvokeInfo): Unit
```

功能：远程调用 Actor 的 Receiver，并以结果完成提供的 Future。

参数：

- `invokeInfo: InvokeInfo` — 远程调用的信息。
