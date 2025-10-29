# actors.dummy_actor_system

## 功能说明

`actors.dummy_actor_system` 包提供分布式 Actor 系统接口的简易内存实现。该包主要用于测试与开发，作为无需网络通信的轻量替代方案。

通过该包，开发者可以在不引入网络复杂度的情况下测试分布式 Actor 功能，更容易地开发与调试基于 Actor 的应用。

## API 列表

### 类

| 类名 | 功能 |
| --- | --- |
| [DummyActorHost](./dummy_actor_system_package_api/dummy_actor_system_package_classes.md#class-dummyactorhost) | 内存中的 `ActorHost` 实现，管理 Actor 的注册并在同一进程内处理“远程调用”。 |
| [DummyActorClient](./dummy_actor_system_package_api/dummy_actor_system_package_classes.md#class-dummyactorclient) | 内存中的 `ActorClient` 实现，访问由 `DummyActorHost` 管理的 Actor。 |
