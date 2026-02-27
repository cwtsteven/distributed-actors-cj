# actors_mcp

## Function Description

The `actors_mcp` package provides Model Context Protocol (MCP) integration for distributed actors, enabling actors to be exposed as MCP tools that can be called from external systems.

This API is shipped via the `actors_mcp` subpackage (`subpackages/actors-mcp`) in this repository.

## API List

### Classes

| Class Name | Function |
| --- | --- |
| [ActorToolManager](./distributed/mcp/mcp_package_api/mcp_package_classes.md#class-actortoolmanager) | Tool manager implementation that manages multiple actor clients and exposes their receiver functions as MCP tools. |
| [ReceiverTool](./distributed/mcp/mcp_package_api/mcp_package_classes.md#class-receivertool) | MCP tool implementation that wraps actor receiver functions, enabling them to be called as MCP tools. |

### Exceptions

| Exception Name | Function |
| --- | --- |
| [ActorMCPException](./distributed/mcp/mcp_package_api/mcp_package_classes.md#class-actormcpexception) | Exception thrown when MCP-related operations fail, such as tool not found or invalid arguments. |
