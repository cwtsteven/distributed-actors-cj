# actors

## 功能说明

`actors` 包在 Cangjie 中提供核心的 Actor 编程模型，通过 Actor 范式实现并发与异步编程。该包包含 Actor 通信、任务调度与配置管理等基础组件。

该包是基于 Actor 的系统的基础；更多功能可在子包中获得，例如 `actors.distributed` 用于远程通信，`actors.macros` 提供用于创建 Actor 的易用 DSL。

## API 列表

### 类

| 类名 | 功能 |
| --- | --- |
| [ActorFuture\<T>](./actors_package_api/actors_package_classes.md#class-actorfuture) | 表示提交给 Actor 的闭包的待处理结果；提供带超时的阻塞与非阻塞结果获取方法。 |
| [SequentialDispatcher](./actors_package_api/actors_package_classes.md#class-sequentialdispatcher) | 一个在专用线程上按顺序排队并执行闭包的调度器，并提供提交闭包的方法；支持基于优先级的任务调度，通常由 Actor 系统内部使用。 |

### 结构体

| 结构体名 | 功能 |
| --- | --- |
| [ReceiverConfig](./actors_package_api/actors_package_structs.md#struct-receiverconfig) | Receiver 函数调用的配置，包括优先级（1-10）及其他调用参数，用于控制 Actor 操作的执行顺序与行为。 |

### 枚举

| 枚举名 | 功能 |
| --- | --- |
| [Tell](./actors_package_api/actors_package_enums.md#enum-tell) | 单值枚举，用于绕过 ActorFuture 机制实现即发即忘；调用 Receiver 时以命名参数 `tell: True` 传入。 |
