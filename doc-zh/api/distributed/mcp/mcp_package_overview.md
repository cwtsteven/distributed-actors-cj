# actors.distributed.mcp

## 功能说明

`actors.distributed.mcp` 包为分布式 Actor 提供 MCP（Model Context Protocol）集成，使 Actor 能够作为 MCP 工具暴露给外部系统调用。该包连接分布式 Actor 系统与 MCP 生态，实现与 MCP 客户端/服务器的无缝集成。

主要特性包括：
- **自动工具生成**：MCP 客户端自动发现可用的 Actor Receiver 函数，并将其暴露为 AI 代理可用的工具
- **Actor Client 集成**：单个工具管理器中支持多个 Actor 客户端
- **类型安全调用**：在 MCP 参数与 Actor 参数之间进行类型安全转换
- **动态工具发现**：自动发现与注册 Actor 工具
- **错误处理**：提供完备的 MCP 工具操作错误处理

该包使分布式 Actor 能够在 MCP 生态中以标准化协议被外部系统使用，将 Actor 能力以工具形式开放。

## API 列表

### 类

| 类名 | 功能 |
| --- | --- |
| [ActorToolManager](./mcp_package_api/mcp_package_classes.md#class-actortoolmanager) | 管理多个 Actor 客户端并将其 Receiver 函数作为 MCP 工具对外暴露的工具管理器实现。 |
| [ReceiverTool](./mcp_package_api/mcp_package_classes.md#class-receivertool) | 将 Actor 的 Receiver 函数封装为 MCP 工具的实现。 |
| [ActorMCPException](./mcp_package_api/mcp_package_classes.md#class-actormcpexception) | MCP 相关操作失败（如工具不存在、参数非法等）时抛出的异常。 |
