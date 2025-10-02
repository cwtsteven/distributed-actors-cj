# Classes

## class ActorMCPClient

```cangjie
public class ActorMCPClient <: MCPClient
```

Function: MCP client implementation that manages multiple actor clients and exposes their receiver functions as MCP tools. This class acts as a bridge between the MCP protocol and distributed actor systems, automatically generating MCP tools from actor metadata.

### func getTools()

```cangjie
public func getTools(): Array<Tool>
```

Function: Gets all available MCP tools generated from registered actor clients.

Return Value:

- Array<Tool> - An array of all available MCP tools.

### func callTool()

```cangjie
public func callTool(name: String, args: Array<(String, ToJsonValue)>): ToolResponse
```

Function: Calls an MCP tool by name with the provided arguments.

Parameters:

- name: String - The name of the tool to call.
- args: Array<(String, ToJsonValue)> - The arguments for the tool call.

Return Value:

- ToolResponse - The response from the tool execution.

Exceptions:

- ActorMCPException - If the tool is not found.

### func addActorClient()

```cangjie
public func addActorClient(client: ActorClient): Unit
```

Function: Adds an actor client to the MCP client, making its actors available as MCP tools.

Parameters:

- client: ActorClient - The actor client to add.

### func removeActorClient()

```cangjie
public func removeActorClient(clientId: String): Unit
```

Function: Removes an actor client from the MCP client, making its actors no longer available as MCP tools.

Parameters:

- clientId: String - The ID of the actor client to remove.

## class ReceiverTool

```cangjie
public class ReceiverTool <: Tool
```

Function: MCP tool implementation that wraps actor receiver functions, enabling them to be called as MCP tools. This class handles the conversion between MCP arguments and actor parameters, and manages the execution of actor receiver functions.

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

Function: Creates a ReceiverTool with the specified configuration.

Parameters:

- name!: String - The name of the tool.
- description!: String - The description of the tool.
- parameters!: Array<ToolParameter> - The parameters for the tool.
- retType!: TypeSchema - The return type schema for the tool.
- examples!: Array<String> - Example usage strings for the tool.
- extra!: HashMap<String, String> - Extra metadata for the tool.
- client!: ActorClient - The actor client to use for communication.
- info!: ReceiverInfo - The receiver information for the actor function.

### prop name

```cangjie
public prop name: String
```

Function: The name of the MCP tool.

### prop description

```cangjie
public prop description: String
```

Function: The description of the MCP tool.

### prop parameters

```cangjie
public prop parameters: Array<ToolParameter>
```

Function: The parameters for the MCP tool.

### prop retType

```cangjie
public prop retType: TypeSchema
```

Function: The return type schema for the MCP tool.

### prop examples

```cangjie
public prop examples: Array<String>
```

Function: Example usage strings for the MCP tool.

### prop extra

```cangjie
public prop extra: HashMap<String, String>
```

Function: Extra metadata for the MCP tool.

### prop client

```cangjie
public prop client: ActorClient
```

Function: The actor client used for communication.

### prop info

```cangjie
public prop info: ReceiverInfo
```

Function: The receiver information for the actor function.

### func invoke()

```cangjie
public func invoke(args: HashMap<String, ToJsonValue>): ToolResponse
```

Function: Invokes the MCP tool with the provided arguments, converting them to actor parameters and executing the receiver function.

Parameters:

- args: HashMap<String, ToJsonValue> - The arguments for the tool invocation.

Return Value:

- ToolResponse - The response from the tool execution.

### func toString()

```cangjie
public override func toString(): String
```

Function: Converts the ReceiverTool to a string representation.

Return Value:

- String - A string representation of the ReceiverTool.

## class ActorMCPException

```cangjie
public class ActorMCPException <: Exception {
  public init(msg: String)
}
```

Function: Exception thrown when MCP-related operations fail, such as tool not found, invalid arguments, or other MCP-specific errors.

### init(String)

```cangjie
public init(msg: String)
```

Function: Creates an ActorMCPException with a custom error message.

Parameters:

- msg: String - The custom error message describing the MCP error.
