package actors_mcp

import std.collection.*

import magic.core.tool.*
import magic.tool.SimpleToolManager

import actors.*
import actors.distributed.*

public class ActorToolManager <: ToolManager {

    private let clients = HashMap<String, ActorClient>()

    public ActorToolManager(
        private let baseManager!: ToolManager = SimpleToolManager()
    ) {}

    public override prop name: String {
        get() { baseManager.name }
    }

    public override prop tools: Array<Tool> {
        get() { baseManager.tools }
    }

    public override func addTool(tool: Tool): Unit {
        baseManager.addTool(tool)
    }

    public override func delTool(tool: Tool): Unit {
        baseManager.delTool(tool)
    }

    public override func addTools(tools: Collection<Tool>): Unit {
        baseManager.addTools(tools)
    }

    public override func clear(): Unit {
        baseManager.clear()
    }

    public override func findTool(name: String): Option<Tool> {
        baseManager.findTool(name)
    }

    public override func filterTool(question: String, filter: ToolFilter): Array<Tool> {
        baseManager.filterTool(question, filter)
    }

    public prop enableFilter: Bool { get() { baseManager.enableFilter } }

    public func addActorClient(client: ActorClient): Unit {
        clients.add(toHostKey(client.getHostInfo()), client)
        let actorInfos = client.findAll()
        let newTools = generateMCPToolsFromActorInfos(client, actorInfos)
        for (tool in newTools) {
            baseManager.addTool(tool)
        }
    }

    public func removeActorClient(info: HostInfo): Unit {
        let client = match (clients.remove(toHostKey(info))) {
                case Some(client) => client
                case None => throw ActorMCPException("Client ${info} not found")
            }

        let actorInfos = client.findAll()
        let toolsToRemove = generateMCPToolsFromActorInfos(client, actorInfos)
        for (tool in toolsToRemove) {
            baseManager.delTool(tool)
        }
    }

    private func toHostKey(info: HostInfo): String {
        "${info.getTypeName()}::${info.toString()}"
    }
}
