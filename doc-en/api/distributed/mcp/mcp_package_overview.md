# actors.distributed.mcp

## Function Description

The `actors.distributed.mcp` package provides Model Context Protocol (MCP) integration for distributed actors, enabling actors to be exposed as MCP tools that can be called from external systems. This package bridges the gap between distributed actor systems and MCP-compatible tools, allowing for seamless integration with MCP clients and servers.

This package enables distributed actors to be used as tools in MCP ecosystems, making actor functionality accessible to external systems through standardized MCP protocols.

## API List

### Classes

|                 Class Name              |                Function                 |
| --------------------------------- | ---------------------------------- |
| [ActorToolManager](./mcp_package_api/mcp_package_classes.md#class-actortoolmanager) | Tool manager implementation that manages multiple actor clients and exposes their receiver functions as MCP tools. |
| [ReceiverTool](./mcp_package_api/mcp_package_classes.md#class-receivertool) | MCP tool implementation that wraps actor receiver functions, enabling them to be called as MCP tools. |

### Exceptions

| Exception Name | Function |
|----------------|----------|
| [ActorMCPException](./mcp_package_api/mcp_package_classes.md#class-actormcpexception) | Exception thrown when MCP-related operations fail, such as tool not found or invalid arguments. |
