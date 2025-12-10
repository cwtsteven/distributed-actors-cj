<div align="center">
<h1>distributed-actors-cj</h1>
</div>

<p align="center">
<img alt="" src="https://img.shields.io/badge/release-v0.0.1-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjc-v0.53.18-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjcov-0.0%25-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/state-孵化/毕业-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/domain-OHOS/Cloud-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/points- ？/100-brightgreen" style="display: inline-block;" />
</p>

## 介绍

一个为仓颉编程语言设计的分布式 Actor 框架，提供基于 Actor 的并发与分布式计算能力，支持本地与远程通信，并可通过 MCP 协议将 Actor 以工具形式集成到 AI 智能体中。

### 项目特性

- **Actor 编程模型**：基于异步方法调用的主动对象抽象
- **分布式 Actor**：用于定义分布式 Actor 接口与实现的声明式语法
- **TCP Actor 系统**：基于 TCP 的分布式 Actor 系统实现
- **TCP 集群**：基于集群的分布式 Actor 系统，支持多节点部署和自动 actor 放置
- **智能体集成**：通过 MCP 协议将 Actor 以工具形式提供给 AI 智能体使用

### 项目计划

- [x] 类型安全的 Actor 代理
- [x] 可序列化的代理
- [ ] 同地协作 actor 的快捷 receiver 调用
- [ ] 消息传递语义（至少一次 vs 最多一次）
- [ ] 失败消息传递的重试机制
- [ ] 增强异常与错误处理
- [ ] 可重入的 Actor
- [x] 集群

## 项目架构

### 源码目录

```shell
actors                   # 核心 Actor 编程模型与本地 Actor 系统
├── ActorFuture          # 异步结果处理
├── SequentialDispatcher # 线程安全的任务调度器
│
├── actors.distributed      # 分布式 Actor 接口与元数据
│   ├── ActorHost           # Actor 注册接口
│   ├── ActorClient         # 远程 Actor 访问接口
│   ├── ActorProxy          # 远程 Actor 的客户端代理
│   ├── DistributedFuture   # 分布式操作结果
│   ├── ActorCluster
│   │
│   └── actors.distributed.mcp  # Model Context Protocol (MCP) 集成
│       ├── ActorMCPClient      # 用于 AI 智能体集成的 MCP 客户端
│       └── ReceiverTool        # Actor 接收器的 MCP 工具封装
│
├── actors.macros          # 编译期 Actor 与接口生成
│   ├── @Actor             # 将类转换为 Actor
│   ├── @ActorInterface    # 将接口转换为 Actor 接口
│   └── @Receiver          # 将方法转换为接收函数
│
├── actors.tcp_actor_system # 基于 TCP 的分布式 Actor 实现
    ├── TCPActorHost        # 基于 TCP 的 Actor 主机
    ├── TCPActorClient      # 基于 TCP 的 Actor 客户端
    ├── TCPActorSystem      # TCP Actor 系统的主配置
    │
    └── actors.tcp_actor_system.cluster  # 基于集群的分布式 Actor 系统
        └── TCPCluster                   # 集群管理器（头服务器和工作节点）
```

### 接口说明

有关详细的 API 参考，请参阅 [API 文档](doc-zh/apis.md).

## 使用说明

### 使用 Git 依赖（推荐）

在你的 cjpm.toml 中添加如下内容：

```toml
[dependencies]
  actors = { git = "https://gitcode.com/Cangjie-TPC/distributed-actors-cj.git", branch = "main", version = "0.0.1" }
```

### 编译构建

```shell
# 构建包
make
```

```shell
# 构建示例
make example
```

### 测试

```shell
# 运行所有测试
make test
```

大多数测试应能通过。已知未通过的测试：

- `testGarbageCollection`
- `testForkJoinGarbageCollection`

这些问题已在更新版本的仓颉编译器中得到修复，但本库尚未支持该版本。

### 教程

完整教程可见于 [教程](doc-zh/tutorial.md)。

### 功能示例

有关更详细的示例，请参考

- **[示例](examples/)**：演示各项功能的示例
- **[Impresario Demo](https://github.com/Huawei-Edinburgh-Programming-Languages/impresario-demo/)**：展示在 HarmonyOS 上使用分布式 Actor 和智能体集成的 AI 应用示例

#### 本地 Actor

```cangjie
import actors.*
import actors.macros.*

@Actor
public class Counter {
    private var value: Int64 = 0

    @Receiver
    public func increment(): Int64 {
        value += 1
        return value
    }

    @Receiver
    public func getValue(): Int64 {
        return value
    }
}

main() {
    let counter = Counter()
    let future = counter.increment()
    println("Counter value: ${future.get()}")
}
```

执行结果如下：

```shell
1
```

#### 分布式 Actor

```cangjie
import std.collection.*

import actors.*
import actors.macros.*
import actors.distributed.*
import actors.tcp_actor_system.*

import encoding.json.*
import serialization.serialization.*

@ActorInterface[distributed: true, description: "Bank service"]
public interface BankAccount {
    @Receiver[description: "Deposit money into the account"]
    func deposit(amount: Float64): Bool

    @Receiver[description: "Withdraw money from the account"]
    func withdraw(amount: Float64): Bool

    @Receiver[description: "Get the balance of the account"]
    func getBalance(): Float64
}

@Actor
public class BankAccountImpl <: BankAccount {
    private let name: String
    private var balance: Float64

    public init(name: String, balance: Float64) {
        this.name = name
        this.balance = balance
    }

    @Receiver
    public func deposit(amount: Float64): Bool {
        balance += amount
        true
    }

    @Receiver
    public func withdraw(amount: Float64): Bool {
        if (balance < amount) {
            return false
        }
        balance -= amount
        true
    }

    @Receiver
    public func getBalance(): Float64 {
        balance
    }
}

const PORT: UInt16 = 52165

main() {
    // Host side
    let tcpHost = TCPActorHost(addr: "localhost", bindAt: PORT)
    let serverFuture = tcpHost.serve() // start the server

    let bankAccount = BankAccountImpl("Steven", 0.0)
    tcpHost.export("Steven", bankAccount)

    // Client side
    let tcpClient = TCPActorClient.create("localhost", PORT)
    let proxy = tcpClient.getActor("Steven").getOrThrow()

    // Using untyped proxy
    proxy.ask("deposit", [100.0.serialize()]).get()
    let res = Float64.deserialize(proxy.ask("getBalance", []).get())
    println("Steven balance: ${res}") // 100.0

    // Using typed proxy
    let steven = BankAccount.getProxy(proxy)
    steven.deposit(100.0).get()
    let res2 = steven.getBalance().get()
    println("Steven balance: ${res2}") // 200.0
}
```

执行结果如下：

```shell
Steven balance: 100.0
Steven balance: 200.0
```

#### AI 智能体整合

```cangjie
import magic.prelude.*
import magic.dsl.*
import magic.config.Config

import actors.distributed.mcp.*
import actors.tcp_actor_system.*

@agent[model: "deepseek:deepseek-chat"]
class AssistantAgent {
    @prompt("You are a helpful assistant that can interact with distributed services.")

    init(toolManager!: ToolManager) {
        __TOOL_MANAGER__ = Some(toolManager)
    }
}

main() {
    let toolManager = ActorToolManager()
    let agent = AssistantAgent(toolManager: toolManager)

    let tcpClient = TCPActorClient.create("localhost", 8080)
    toolManager.addActorClient(tcpClient)

    let response = agent.chat("Transfer $100 from Alice to Bob")
    println("Assistant: ${response}")
}
```

## 约束与限制

目前代码仅在以下版本能够正确编译执行：

- Cangjie 0.53.18（通用版）
- DevEco Studio for Windows 5.0.13.200 和 DevEco Studio Cangjie Plugin Canary for Windows 5.0.13.200（鸿蒙版）

如果使用了其他版本的 Cangjie SDK，可能需要直接修改项目源代码进行适配。

## 开源协议

[MIT License](./LICENSE)

## 参与贡献

欢迎给我们提交PR，欢迎给我们提交Issue，欢迎参与任何形式的贡献。

