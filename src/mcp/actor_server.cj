package actors.mcp

import std.collection.*

import actors.*
import actors.distributed.*

import magic.core.tool.*
import magic.mcp.*
import magic.jsonable.*

public class MCPActorToolStdioServer <: StdioMCPServer {

    private let clients = ArrayList<ActorClient>()

    public init() {
        super()
    }

    protected func handleCallTool(callToolRequest: CallToolRequest): ToJsonValue {
        throw Exception("not implemented")
    }

    public func addClient(client: ActorClient) {
        // clients.append(client)
        // this.tools.appendAll(generateMCPToolsFromActorInfos(client, client.findAll()))
    }

    public func removeClient(client: ActorClient) {
        // clients.remove(client)
        // this.tools.removeAll({ tool =>
        //     match (tool) {
        //         case tr: ReceiverTool => tr.client == client
        //         case _ => false
        //     }
        // })
    }
}