package chat_app_example.client

import std.collection.*
import std.console.*
import std.convert.*
import std.log.*
import std.fs.*
import std.time.*

import chat_app_example.common.*

import actors.*
import actors.macros.*
import actors.distributed.*
import actors.tcp_actor_system.*
import actors.tcp_actor_system.cluster.*

main(args: Array<String>) {
    TCPActorSystem.logger.level = LogLevel.DEBUG

    let headServerAddr = args[0]
    let headServerPort = UInt16.parse(args[1])
    let userId = args[2]
    let userAddr = args[3]
    let userPort = UInt16.parse(args[4])

    let logFile = File("${userId}-client.log", OpenOption.CreateOrTruncate(false))
    TCPActorSystem.logger.setOutput(logFile)

    TCPCluster.join(headServerAddr: headServerAddr, headServerPort: headServerPort)

    let host = TCPActorHost(addr: userAddr, bindAt: userPort)
    let userActor = UserActorImpl(userId)
    let proxy = UserActor.getProxy(host.export(userId, userActor).getOrThrow())
    host.serve()

    startLoop(userId, proxy)
}

func startLoop(userId: String, user: UserActor): Unit {
    while (true) {
        Console.stdOut.writeln<String>("Enter command: (open <name>, join <name>, exit)")
        let input = Console.stdIn.readln()
        let parts = input.getOrThrow().split(" ")
        let command = parts[0]
        if (command == "exit") {
            break
        } else if (command == "open") {
            let name = parts[1]
            TCPCluster.spawnActor<ChatRoomActor>(name, [SpawnArgument.create<String>("String", name)]).getOrThrow()
        } else if (command == "join") {
            let name = parts[1]
            let chatRoom = TCPCluster.getActor<ChatRoomActor>(name)
            match (chatRoom) {
                case Some(room) =>
                    room.joinRoom(userId, user).get()
                    Console.stdOut.writeln<String>("You have joined the chat room ${name}")
                    startChat(userId, room)
                    room.leaveRoom(userId).get()
                    Console.stdOut.writeln<String>("You have left the chat room ${name}")
                case None => Console.stdOut.writeln<String>("Chat room ${name} not found")
            }
        }
    }
}

func startChat(userId: String, chatRoom: ChatRoomActor): Unit {
    Console.stdOut.writeln<String>("You can now enter your messages to the chat room")
    while (true) {
        let input = Console.stdIn.readln()
        chatRoom.sendMessage(userId, input.getOrThrow(), tell: True)
    }
}