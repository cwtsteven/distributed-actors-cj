package chat_app_example.common

import std.collection.*
import std.console.*

import actors.*
import actors.macros.*
import actors.distributed.*

import encoding.json.*
import serialization.serialization.*

@ActorInterface[distributed: true]
public interface UserActor {

    @Receiver[mode: TellOnly]
    func receiveMessage(sender: String, message: String): Unit
}