package agent_example

import magic.prelude.*
import magic.dsl.*
import magic.config.Config

import actors.distributed.mcp.*
import actors.tcp_actor_system.*

@agent[model: "deepseek:deepseek-chat"]
class AssistantAgent {
    @prompt("You are a helpful assistant that can interact with distributed services.")

    init(toolManager!: ToolManager) {
        __TOOL_MANAGER__ = Some(toolManager)
    }
}

main() {
    let toolManager = ActorToolManager()
    let agent = AssistantAgent(toolManager: toolManager)

    let tcpClient = TCPActorClient.create("localhost", 8080)
    toolManager.addActorClient(tcpClient)

    let response = agent.chat("Transfer $100 from Alice to Bob")
    println("Assistant: ${response}")
}