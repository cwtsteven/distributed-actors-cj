# actors.distributed.mcp

## Function Description

The `actors.distributed.mcp` package provides Model Context Protocol (MCP) integration for distributed actors, enabling actors to be exposed as MCP tools that can be called from external systems. This package bridges the gap between distributed actor systems and MCP-compatible tools, allowing for seamless integration with MCP clients and servers.

Key features include:
- **Automatic Tool Generation**: The MCP client automatically discovers all available actor receiver functions and makes them available as tools to the AI agent
- **Actor Client Integration**: Support for multiple actor clients in a single tool manager
- **Type-Safe Tool Invocation**: Type-safe conversion between MCP arguments and actor parameters
- **Dynamic Tool Discovery**: Automatic discovery and registration of actor tools
- **Error Handling**: Comprehensive error handling for MCP tool operations

This package enables distributed actors to be used as tools in MCP ecosystems, making actor functionality accessible to external systems through standardized MCP protocols.

## API List

### Classes

|                 Class Name              |                Function                 |
| --------------------------------- | ---------------------------------- |
| [ActorToolManager](./mcp_package_api/mcp_package_classes.md#class-actortoolmanager) | Tool manager implementation that manages multiple actor clients and exposes their receiver functions as MCP tools. |
| [ReceiverTool](./mcp_package_api/mcp_package_classes.md#class-receivertool) | MCP tool implementation that wraps actor receiver functions, enabling them to be called as MCP tools. |
| [ActorMCPException](./mcp_package_api/mcp_package_classes.md#class-actormcpexception) | Exception thrown when MCP-related operations fail, such as tool not found or invalid arguments. |
