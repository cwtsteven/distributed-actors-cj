package actors.distributed.mcp

import std.collection.*

import actors.*
import actors.distributed.*

import magic.core.tool.*
import magic.mcp.*
import magic.jsonable.*

public class ActorMCPClient <: MCPClient {
    private let clients = ArrayList<ActorClient>()
    private let tools = HashMap<String, Tool>()

    public func getTools(): Array<Tool> {
        updateTools()
        return tools.values().toArray()
    }

    public func callTool(name: String, args: Array<(String, ToJsonValue)>): ToolResponse {
        updateTools()
        match (tools.get(name)) {
            case Some(tool) =>
                let res = HashMap<String, ToJsonValue>()
                for (arg in args) {
                    res.put(arg[0], arg[1])
                }
                tool.invoke(res)
            case None => throw ActorMCPException("Tool ${name} not found")
        }
    }

    public func addClient(client: ActorClient) {
        clients.append(client)
    }

    private func updateTools() {
        for (client in clients) {
            let actorInfos = client.findAll()
            let newTools = generateMCPToolsFromActorInfos(client, actorInfos)
            for (tool in newTools) {
                tools.put(tool.name, tool)
            }
        }
    }
}