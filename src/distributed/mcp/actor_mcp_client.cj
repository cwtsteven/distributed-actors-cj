package actors.distributed.mcp

// import std.collection.*

// import actors.*
// import actors.distributed.*

// import magic.core.tool.*
// import magic.mcp.*
// import magic.jsonable.*

// class ActorMCPClient <: MCPClient {
//     private let clients = HashMap<String, ActorClient>()
//     private let tools = HashMap<String, Tool>()

//     public func getTools(): Array<Tool> {
//         return tools.values().toArray()
//     }

//     public func callTool(name: String, args: Array<(String, ToJsonValue)>): ToolResponse {
//         match (tools.get(name)) {
//             case Some(tool) =>
//                 let res = HashMap<String, ToJsonValue>()
//                 for (arg in args) {
//                     res.put(arg[0], arg[1])
//                 }
//                 tool.invoke(res)
//             case None => throw ActorMCPException("Tool ${name} not found")
//         }
//     }

//     public func addActorClient(client: ActorClient) {
//         clients.put(client.id, client)
//         let actorInfos = client.findAll()
//         let newTools = generateMCPToolsFromActorInfos(client, actorInfos)
//         for (tool in newTools) {
//             tools.put(tool.name, tool)
//         }
//     }

//     public func removeActorClient(clientId: String) {
//         clients.remove(clientId)
//         let actorInfos = client.findAll()
//         let toolsToRemove = generateMCPToolsFromActorInfos(client, actorInfos)
//         for (tool in toolsToRemove) {
//             tools.remove(tool.name)
//         }
//     }
// }