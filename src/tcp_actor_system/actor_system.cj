package actors.tcp_actor_system

import std.collection.concurrent.*
import std.net.*
import std.sync.*

import encoding.json.*
import serialization.serialization.*

import actors.*
import actors.macros.*

import std.log.*

public class TCPActorSystem {
    private static var __logger: ?Logger = None
    public static mut prop logger: Logger {
        get() {
            match (__logger) {
                case Some(l) => l
                case None =>
                    let l = SimpleLogger()
                    __logger = Some(l)
                    l
            }
        }
        set(l) {
            __logger = Some(l)
        }
    }
}