package chat_app_example.client

import std.collection.*
import std.console.*
import std.convert.*
import std.time.*

import chat_app_example.common.*

import actors.*
import actors.macros.*
import actors.distributed.*
import actors.tcp_actor_system.*

main(args: Array<String>) {
    TCPActorSystem.logger.level = LogLevel.DEBUG

    let headServerAddr = args[0]
    let headServerPort = UInt16.parse(args[1])
    let userId = args[2]
    let userAddr = args[3]
    let userPort = UInt16.parse(args[4])

    TCPCluster.join(headServerAddr: headServerAddr, headServerPort: headServerPort).get()

    let host = TCPActorHost(bindAt: userPort)
    let userActor = UserActorImpl(userId)
    host.export(userId, userActor)
    host.serve()

    startLoop(userActor)
}

func startLoop(user: UserActor): Unit {
    let currentRoom: Option<ChatRoomActor> = None
    while (true) {
        Console.stdOut.writeln<String>("Enter command: (open <name>, join <name>, close <name>, exit)")
        let input = Console.stdIn.readln()
        let parts = input.split(" ")
        let command = parts[0]
        if (command == "exit") {
            break
        } else if (command == "open") {
            let name = parts[1]
            let chatRoom = TCPCluster.spawnActor<ChatRoomActor>(name, [SpawnArgument.create<String>(name)]).get()
            currentRoom = Some(chatRoom)
        } else if (command == "join") {
            let name = parts[1]
            match (currentRoom) {
                Some(room) => room.joinRoom(name),
                None => Console.stdOut.writeln<String>("No chat room opened")
            }
        }
    }
}

func startChat(client: TCPActorClient, name: String): Unit {
    let chatRoom = ChatRoom.getProxy(name, client)
    Console.stdOut.writeln<String>("Chatroom ${name} opened!")
    Console.stdOut.writeln<String>("Please enter your name:")
    let myName = Console.stdIn.readln()
    let history = chatRoom.getHistory().get()
    for (message in history) {
        Console.stdOut.writeln<String>("[${message.sender}] ${message.content}")
    }
    while (true) {
        let input = Console.stdIn.readln()
        if (input == "exit") {
            break
        }
        chatRoom.send(Message(myName, input))
    }
    chatRoom.leave(myName)
}