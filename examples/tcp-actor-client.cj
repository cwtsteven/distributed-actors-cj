import std.collection.*
import std.collection.concurrent.*
import std.time.*
import std.sync.*
import std.socket.*

import actors.*
import actors.macros.*
import actors.tcp_actor_system.*
import serialization.serialization.*
import encoding.json.*

main() {
    let client = TCPActorClient("localhost", 52185)
    let proxy = ActorProxy("testService", client)
    let fut = proxy.post<Int64>("addTen", [5.serialize()])
    let result = fut.get()
    println(result)
    client.close()
}