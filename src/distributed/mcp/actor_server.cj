package actors.distributed.mcp

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

    public func addClient(client: ActorClient) {
        clients.append(client)
        this.addTools(generateMCPToolsFromActorInfos(client, client.findAll()))
    }

    public func removeClient(client: ActorClient) {
        // clients.remove(client)
    }
}