import std.collection.*
import std.collection.concurrent.*
import std.time.*
import std.sync.*
import std.socket.*
import std.io.*
import std.fs.*

import actors.*
import actors.macros.*
import actors.distributed.*
import actors.tcp_actor_system.*
import serialization.serialization.*
import encoding.json.*
import std.log.*

main(args: Array<String>) {
    TCPActorSystem.logger = if (args.size < 1) {
        SimpleLogger()
    } else {
        let logFile = args[0]
        let os = File(logFile, OpenOption.CreateOrTruncate(false))
        SimpleLogger("client", LogLevel.DEBUG, os)
    }
    TCPActorSystem.logger.level = LogLevel.DEBUG

    let client = TCPActorClient("1", "localhost", 52185)
    let proxy = ActorProxy("testService 1", client)

    while (true) {
        let fut = proxy.ask("addTen", [5.serialize()])
        let result = Int64.deserialize(fut.get())
        println(result)

        let info = client.find("testService 1")
        println("Info: ${info}")

        let infos = client.findAll()
        println("Infos: ${infos}")

        sleep(Duration.second * 3)
    }

    client.close()
}