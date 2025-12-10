package chat_app_example.common

import actors.*
import actors.macros.*
import actors.distributed.*

import encoding.json.*
import serialization.serialization.*

@ActorInterface[distributed: true]
public interface UserActor {

    @Receiver[mode: TellOnly]
    func receiveMessage(message: String): Unit
}