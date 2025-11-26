# actors.macros

## 功能说明

`actors.macros` 包提供用于声明 actor、actor 接口和 receiver 的 DSL。这些宏将标准 Cangjie 代码转换为基于 actor 的实现，支持本地与分布式编程模型。

该包使开发者能够以声明式方式进行 actor 编程：标准类与接口会在编译期宏展开时被转换为 actor 域代码。

## API 列表

### 宏

| 宏 | 功能 |
| --- | --- |
| [@Actor](./macros_package_api/macros_package_macros.md#actor-宏) | 将类转换为 actor。 |
| [@ActorInterface](./macros_package_api/macros_package_macros.md#actorinterface-macro) | 将接口转换为 actor 接口。 |
| [@Receiver](./macros_package_api/macros_package_macros.md#receiver-宏) | 将方法转换为 receiver。 |
