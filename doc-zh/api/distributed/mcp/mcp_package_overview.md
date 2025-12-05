# actors.distributed.mcp

## 功能说明

`actors.distributed.mcp` 包为分布式 Actor 提供 MCP（Model Context Protocol）集成，使 Actor 能够作为 MCP 工具暴露给外部系统调用。该包连接分布式 Actor 系统与 MCP 生态，实现与 MCP 客户端/服务器的无缝集成。

该包使分布式 Actor 能够在 MCP 生态中以标准化协议被外部系统使用，将 Actor 能力以工具形式开放。

## API 列表

### 类

| 类名 | 功能 |
| --- | --- |
| [ActorToolManager](./mcp_package_api/mcp_package_classes.md#class-actortoolmanager) | 管理多个 Actor 客户端并将其 Receiver 函数作为 MCP 工具对外暴露的工具管理器实现。 |
| [ReceiverTool](./mcp_package_api/mcp_package_classes.md#class-receivertool) | 将 Actor 的 Receiver 函数封装为 MCP 工具的实现。 |

### 异常

| 异常名 | 功能 |
| --- | --- |
| [ActorMCPException](./mcp_package_api/mcp_package_classes.md#class-actormcpexception) | MCP 相关操作失败（如工具不存在、参数非法等）时抛出的异常。 |
