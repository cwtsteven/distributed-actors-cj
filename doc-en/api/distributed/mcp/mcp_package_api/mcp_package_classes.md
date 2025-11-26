# Classes

## class ActorToolManager

```cangjie
public class ActorToolManager <: ToolManager
```

Function: Tool manager implementation that manages multiple actor clients and exposes their receiver functions as MCP tools. This class acts as a bridge between the MCP protocol and distributed actor systems, automatically generating MCP tools from actor metadata.

### init(ToolManager)

```cangjie
public init(baseManager!: ToolManager = SimpleToolManager())
```

Function: Creates an ActorToolManager with an optional base tool manager.

Parameters:

- `baseManager!: ToolManager` - The base tool manager to delegate to, defaults to SimpleToolManager().

### func addTool()

```cangjie
public override func addTool(tool: Tool): Unit
```

Function: Adds a tool to the tool manager.

Parameters:

- `tool: Tool` - The tool to add.

### func delTool()

```cangjie
public override func delTool(tool: Tool): Unit
```

Function: Removes a tool from the tool manager.

Parameters:

- `tool: Tool` - The tool to remove.

### func addTools()

```cangjie
public override func addTools(tools: Array<Tool>): Unit
```

Function: Adds multiple tools to the tool manager.

Parameters:

- `tools: Array<Tool>` - The tools to add.

### func clear()

```cangjie
public override func clear(): Unit
```

Function: Removes all tools from the tool manager.

### func findTool()

```cangjie
public override func findTool(name: String): Option<Tool>
```

Function: Finds a tool by name.

Parameters:

- `name: String` - The name of the tool to find.

Return Value:

- `Option<Tool>` - Some(tool) if found, None otherwise.

### func getTools()

```cangjie
public override func getTools(): Array<Tool>
```

Function: Gets all available tools in the tool manager.

Return Value:

- `Array<Tool>` - An array of all available tools.

### func filterTool()

```cangjie
public override func filterTool(question: String, config: ToolSearchConfig): Array<Tool>
```

Function: Filters tools based on a question and search configuration.

Parameters:

- `question: String` - The search question.
- `config: ToolSearchConfig` - The search configuration.

Return Value:

- `Array<Tool>` - An array of filtered tools.

### prop enableFilter

```cangjie
public prop enableFilter: Bool
```

Function: Gets whether tool filtering is enabled.

### func addActorClient()

```cangjie
public func addActorClient(client: ActorClient): Unit
```

Function: Adds an actor client to the tool manager, making its actors available as MCP tools.

Parameters:

- `client: ActorClient` - The actor client to add.

### func removeActorClient()

```cangjie
public func removeActorClient(clientId: String): Unit
```

Function: Removes an actor client from the tool manager, making its actors no longer available as MCP tools.

Parameters:

- `clientId: String` - The ID of the actor client to remove.

Exceptions:

- `ActorMCPException` - Thrown if the client is not found.

## class ReceiverTool

```cangjie
public class ReceiverTool <: Tool
```

Function: MCP tool implementation that wraps actor receiver functions, enabling them to be called as MCP tools. This class handles the conversion from MCP tool parameters into arguments of the respective actor call, and manages the execution of actor receiver functions.

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

- `name!: String` - The name of the tool (format: "actorName;__actors_08275892475824__;receiverName").
- `description!: String` - The description of the tool.
- `parameters!: Array<ToolParameter>` - The parameters for the tool.
- `retType!: TypeSchema` - The return type schema for the tool.
- `examples!: Array<String>` - Example usage strings for the tool.
- `extra!: HashMap<String, String>` - Extra metadata for the tool.
- `client!: ActorClient` - The actor client to use for communication.
- `info!: ReceiverInfo` - The receiver information for the actor function.

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

Function: Invokes the MCP tool with the provided arguments, converting them to actor parameters and executing the receiver function. The tool name is parsed to extract the actor name and receiver name, then an ActorProxy is created to call the receiver.

Parameters:

- `args: HashMap<String, ToJsonValue>` - The arguments for the tool invocation, including an optional "config" parameter for ReceiverConfig.

Return Value:

- `ToolResponse` - The response from the tool execution, serialized as a string.

Exceptions:

- `ActorMCPException` - Thrown if the tool name format is invalid or required arguments are missing.

### func toString()

```cangjie
public override func toString(): String
```

Function: Converts the ReceiverTool to a string representation.

Return Value:

- `String` - A string representation of the ReceiverTool in the format "name [description]".

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

- `msg: String` - The custom error message describing the MCP error.
