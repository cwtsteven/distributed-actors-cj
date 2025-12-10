package actors.distributed.mcp

import magic.prelude.*
import magic.dsl.*
import magic.config.Config
import magic.core.tool.*
import magic.tool.SimpleToolManager

import actors.*
import actors.distributed.*

public class ActorToolManager <: ToolManager {

    private let clients = HashMap<HostInfo, ActorClient>()

    public ActorToolManager(
        private let baseManager!: ToolManager = SimpleToolManager()
    ) {}

    public override func addTool(tool: Tool): Unit {
        baseManager.addTool(tool)
    }

    public override func delTool(tool: Tool): Unit {
        baseManager.delTool(tool)
    }

    public override func addTools(tools: Array<Tool>): Unit {
        baseManager.addTools(tools)
    }

    public override func clear(): Unit {
        baseManager.clear()
    }

    public override func findTool(name: String): Option<Tool> {
        baseManager.findTool(name)
    }

    public override func getTools(): Array<Tool> {
        baseManager.getTools()
    }

    public override func filterTool(question: String, config: ToolSearchConfig): Array<Tool> {
        baseManager.filterTool(question, config)
    }

    public prop enableFilter: Bool { get() { baseManager.enableFilter } }

    public func addActorClient(client: ActorClient): Unit {
        clients.put(client.getHostInfo(), client)
        let actorInfos = client.findAll()
        let newTools = generateMCPToolsFromActorInfos(client, actorInfos)
        for (tool in newTools) {
            baseManager.addTool(tool)
        }
    }

    public func removeActorClient(info: HostInfo): Unit {
        let client = match (clients.remove(info)) {
                case Some(client) => client
                case None => throw ActorMCPException("Client ${info} not found")
            }

        let actorInfos = client.findAll()
        let toolsToRemove = generateMCPToolsFromActorInfos(client, actorInfos)
        for (tool in toolsToRemove) {
            baseManager.delTool(tool)
        }
    }
}