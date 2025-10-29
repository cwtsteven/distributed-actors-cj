# 类

## class ActorToolManager

```cangjie
public class ActorToolManager <: ToolManager
```

功能：管理多个 Actor 客户端并将其 Receiver 函数暴露为 MCP 工具的工具管理器。充当 MCP 协议与分布式 Actor 系统的桥梁，基于 Actor 元数据自动生成 MCP 工具。

### init(ToolManager)

```cangjie
public init(baseManager!: ToolManager = SimpleToolManager())
```

功能：使用可选基础工具管理器创建 `ActorToolManager`。

参数：

- `baseManager!: ToolManager` — 委托的基础工具管理器，默认 `SimpleToolManager()`。

### func addTool()

```cangjie
public override func addTool(tool: Tool): Unit
```

功能：向管理器添加工具。

参数：

- `tool: Tool` — 要添加的工具。

### func delTool()

```cangjie
public override func delTool(tool: Tool): Unit
```

功能：从管理器移除工具。

参数：

- `tool: Tool` — 要移除的工具。

### func addTools()

```cangjie
public override func addTools(tools: Array<Tool>): Unit
```

功能：批量添加工具。

参数：

- `tools: Array<Tool>` — 待添加的工具集合。

### func clear()

```cangjie
public override func clear(): Unit
```

功能：移除所有工具。

### func findTool()

```cangjie
public override func findTool(name: String): Option<Tool>
```

功能：按名称查找工具。

参数：

- `name: String` — 工具名称。

返回值：

- `Option<Tool>` — 找到则 `Some(tool)`，否则 `None`。

### func getTools()

```cangjie
public override func getTools(): Array<Tool>
```

功能：获取所有可用工具。

返回值：

- `Array<Tool>` — 可用工具数组。

### func filterTool()

```cangjie
public override func filterTool(question: String, config: ToolSearchConfig): Array<Tool>
```

功能：根据问题与搜索配置筛选工具。

参数：

- `question: String` — 搜索问题。
- `config: ToolSearchConfig` — 搜索配置。

返回值：

- `Array<Tool>` — 筛选结果。

### prop enableFilter

```cangjie
public prop enableFilter: Bool
```

功能：获取是否启用工具筛选。

### func addActorClient()

```cangjie
public func addActorClient(client: ActorClient): Unit
```

功能：向工具管理器添加 Actor 客户端，使其 Actor 暴露为 MCP 工具。

参数：

- `client: ActorClient` — 要添加的 Actor 客户端。

### func removeActorClient()

```cangjie
public func removeActorClient(clientId: String): Unit
```

功能：从工具管理器移除 Actor 客户端，使其 Actor 不再作为 MCP 工具提供。

参数：

- `clientId: String` — 要移除的 Actor 客户端 ID。

异常：

- `ActorMCPException` — 未找到客户端时抛出。

## class ReceiverTool

```cangjie
public class ReceiverTool <: Tool
```

功能：将 Actor 的 Receiver 封装为 MCP 工具；负责 MCP 参数与 Actor 参数的转换，并管理 Receiver 的执行。

### init(String, String, Array<ToolParameter>, TypeSchema, Array<String>, HashMap<String, String>, ActorClient, ReceiverInfo)

```cangjie
public init(
  name!: String,
  description!: String,
  parameters!: Array<ToolParameter>,
  retType!: TypeSchema,
  examples!: Array<String>,
  extra!: HashMap<String, String>,
  client!: ActorClient,
  info!: ReceiverInfo
)
```

功能：以指定配置创建 `ReceiverTool`。

参数：

- `name!: String` — 工具名（格式："actorName;__actors_08275892475824__;receiverName"）。
- `description!: String` — 工具描述。
- `parameters!: Array<ToolParameter>` — 工具参数。
- `retType!: TypeSchema` — 工具返回类型的架构。
- `examples!: Array<String>` — 示例用法。
- `extra!: HashMap<String, String>` — 额外元数据。
- `client!: ActorClient` — 用于通信的 Actor 客户端。
- `info!: ReceiverInfo` — Receiver 的元信息。

### prop name

```cangjie
public prop name: String
```

功能：工具名称。

### prop description

```cangjie
public prop description: String
```

功能：工具描述。

### prop parameters

```cangjie
public prop parameters: Array<ToolParameter>
```

功能：工具参数。

### prop retType

```cangjie
public prop retType: TypeSchema
```

功能：工具返回类型架构。

### prop examples

```cangjie
public prop examples: Array<String>
```

功能：示例用法。

### prop extra

```cangjie
public prop extra: HashMap<String, String>
```

功能：额外元数据。

### prop client

```cangjie
public prop client: ActorClient
```

功能：用于通信的 Actor 客户端。

### prop info

```cangjie
public prop info: ReceiverInfo
```

功能：Actor 函数的 Receiver 信息。

### func invoke()

```cangjie
public func invoke(args: HashMap<String, ToJsonValue>): ToolResponse
```

功能：以给定参数调用 MCP 工具，将其转换为 Actor 参数并执行 Receiver。解析工具名以提取 Actor 与 Receiver 名称，创建 `ActorProxy` 进行调用。

参数：

- `args: HashMap<String, ToJsonValue>` — 工具调用参数；可包含可选 `"config"` 字段来传入 `ReceiverConfig`。

返回值：

- `ToolResponse` — 工具执行的序列化字符串响应。

异常：

- `ActorMCPException` — 工具名格式非法或缺少必要参数。

### func toString()

```cangjie
public override func toString(): String
```

功能：将 `ReceiverTool` 转换为字符串表示。

返回值：

- `String` — "name [description]" 格式的字符串。

## class ActorMCPException

```cangjie
public class ActorMCPException <: Exception {
  public init(msg: String)
}
```

功能：当 MCP 相关操作失败（如工具不存在、参数非法等）时抛出。

### init(String)

```cangjie
public init(msg: String)
```

功能：创建带自定义错误信息的 `ActorMCPException`。

参数：

- `msg: String` — MCP 错误的描述信息。

