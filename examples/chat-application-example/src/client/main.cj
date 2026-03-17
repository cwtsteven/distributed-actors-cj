package chat_app_example.client

import std.collection.*
import std.convert.*
import stdx.log.*
import std.env.*
import std.time.*

import chat_app_example.common.*

import actors.*
import actors.macros.*
import actors.distributed.*
import actors.tcp_actor_system.*
import actors.tcp_actor_system.cluster.*

main(args: Array<String>) {
    // TCPActorSystem.logger.level = LogLevel.DEBUG

    let headServerAddr = args[0]
    let headServerPort = UInt16.parse(args[1])
    let userId = args[2]
    let userAddr = args[3]
    let userPort = UInt16.parse(args[4])

    TCPCluster.join(headServerAddr: headServerAddr, headServerPort: headServerPort)

    let host = TCPActorHost(addr: userAddr, bindAt: userPort)
    let userActor = UserActorImpl(userId)
    host.publish(userId, userActor)
    let proxy = UserActor.getProxy(userId, host.getHostInfo())
    host.serve()

    startLoop(userId, proxy)
}

func startLoop(userId: String, user: UserActor): Unit {
    while (true) {
        getStdOut().writeln<String>("Enter command: (open <name>, join <name>, exit)")
        let input = getStdIn().readln()
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
                    getStdOut().writeln<String>("You have joined the chat room ${name}")
                    startChat(userId, room)
                    room.leaveRoom(userId).get()
                    getStdOut().writeln<String>("You have left the chat room ${name}")
                case None => getStdOut().writeln<String>("Chat room ${name} not found")
            }
        }
    }
}

func startChat(userId: String, chatRoom: ChatRoomActor): Unit {
    getStdOut().writeln<String>("You can now enter your messages to the chat room")
    while (true) {
        let input = getStdIn().readln()
        chatRoom.sendMessage(userId, input.getOrThrow(), tell: True)
    }
}
