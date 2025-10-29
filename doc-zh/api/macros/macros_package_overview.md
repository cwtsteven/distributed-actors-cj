# actors.macros

## 功能说明

`actors.macros` 包提供用于声明 Actor、Actor 接口与 Receiver 函数的编译期宏。这些宏将标准的 Cangjie 代码转换为基于 Actor 的实现，支持本地与分布式两种编程模型，并提供完善的配置能力。

主要特性包括：
- **Actor 类生成**：将类转换为 Actor
- **Actor 接口生成**：创建 Actor 接口
- **Receiver 函数生成**：将方法转换为支持 Ask/Tell 模式的 Receiver 函数
- **元数据生成**：为分布式系统自动生成 Actor 元数据

该包支持以声明式方式进行 Actor 编程：通过编译期宏展开，将标准类与接口转换为 Actor 实现。

## API 列表

### 宏

| 宏 | 功能 |
| --- | --- |
| [@Actor](./macros_package_api/macros_package_macros.md#actor-宏) | 将类转换为 Actor，并自动集成调度器与生成 Receiver 函数。 |
| [@ActorInterface](./macros_package_api/macros_package_macros.md#actorinterface-macro) | 将接口转换为可用于本地与分布式通信的 Actor 接口。 |
| [@Receiver](./macros_package_api/macros_package_macros.md#receiver-宏) | 将方法转换为可被其他 Actor 调用的 Receiver 函数，支持 Ask/Tell 模式。 |
