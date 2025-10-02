import magic.prelude.*
import magic.dsl.*
import magic.config.*

import actors.distributed.mcp.ActorMCPClient
import actors.tcp_actor_system.*

@agent[model: "deepseek:deepseek-chat"]
class AssistantAgent {
    @prompt("You are a helpful assistant that can interact with distributed services.")
}

public class AgentManager {
    private let agent: AssistantAgent
    private let mcpClient = ActorMCPClient()

    init() {
        agent = AssistantAgent()
        Config.env["DEEPSEEK_API_KEY"] = "your-api-key"
    }

    func addActorClient(client: TCPActorClient): Unit {
        mcpClient.addActorClient(client)
        agent.toolManager.addTools(mcpClient.getTools())
    }

    func chat(userInput: String): String {
        let res = agent.chat(AgentRequest(userInput))
        res.content
    }
}

main() {
    let agentManager = AgentManager()
    let tcpClient = TCPActorClient("service", "localhost", 8080)
    agentManager.addActorClient(tcpClient)

    let response = agentManager.chat("Transfer $100 from Alice to Bob")
    println("Assistant: ${response}")
}