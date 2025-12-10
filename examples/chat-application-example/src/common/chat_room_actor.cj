package chat_app_example.common

import std.collection.*

import actors.*
import actors.macros.*
import actors.distributed.*

import encoding.json.*
import serialization.serialization.*

@ActorInterface[distributed: true]
public interface ChatRoomActor <: Spawnable<ChatRoomActor> {
    @Receiver[mode: AskOnly]
    func joinRoom(userId: String): Bool

    @Receiver[mode: AskOnly]
    func leaveRoom(userId: String): Bool

    @Receiver[mode: TellOnly]
    func sendMessage(userId: String, message: String): Unit

    static func typeName(): String {
        "ChatRoomActor"
    }

    static func spawnWith(args: Array<SpawnArgument>): Option<ChatRoomActor> {
        if (args.size != 1) {
            return None
        }
        match (args[0].value) {
            case roomId: String => Some(ChatRoomActorImpl(roomId))
            case _ => None
        }
    }
}

@Actor
public class ChatRoomActorImpl <: ChatRoomActor {
    private let roomId: String
    private let users: HashMap<String, UserActor> = HashMap<String, UserActor>()

    static init() {
        ActorCluster.registerSpawningFunc<ChatRoomActor>(ChatRoomActor.typeName(), ChatRoomActor.spawnWith)
        ActorCluster.registerSpawnArgument<String>("String")
    }

    public init(roomId: String) {
        this.roomId = roomId
    }

    @Receiver[mode: AskOnly]
    public func joinRoom(userId: String): Bool {
        if (users.contains(userId)) {
            return false
        }
        users.put(userId, UserActor.getProxy(userId, TCPActorClient(userId.address, userId.port)))
        true
    }

    @Receiver[mode: AskOnly]
    public func leaveRoom(userId: String): Bool {
        if (!users.contains(userId)) {
            return false
        }
        users.remove(userId)
        true
    }

    @Receiver[mode: TellOnly]
    public func sendMessage(userId: String, message: String): Unit {
        if (!users.contains(userId)) {
            return
        }
        users.get(userId).sendMessage(message)
        true
    }
}