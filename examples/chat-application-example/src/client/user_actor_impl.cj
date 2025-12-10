package chat_app_example.client

import chat_app_example.common.*

import std.console.*

import actors.*
import actors.macros.*
import actors.distributed.*

import encoding.json.*
import serialization.serialization.*

@Actor
public class UserActorImpl <: UserActor {
    private let userId: String

    public init(userId: String) {
        this.userId = userId
    }

    @Receiver[mode: TellOnly]
    public func receiveMessage(sender: String, message: String): Unit {
        if (sender == userId) {
            return
        }
        Console.stdOut.writeln<String>("[${sender}] ${message}")
    }
}