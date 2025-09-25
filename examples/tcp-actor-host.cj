import std.collection.*
import std.collection.concurrent.*
import std.time.*
import std.sync.*
import std.socket.*
import std.io.*
import std.fs.*

import actors.*
import actors.macros.*
import actors.tcp_actor_system.*
import serialization.serialization.*
import encoding.json.*
import std.log.*

@ActorInterface[
    distributed: true,
    description: "Test distributed service"
]
public interface TestService {
    @Receiver[description: "Adds 10 to input"]
    func addTen(x: Int64): Int64
}

@Actor
public class TestServiceImpl <: TestService {
    @Receiver
    public func addTen(x: Int64): Int64 {
        x + 10
    }
}

main(args: Array<String>) {
    TCPActorSystem.logger = if (args.size < 1) {
        SimpleLogger()
    } else {
        let logFile = args[0]
        let os = File(logFile, OpenOption.CreateOrTruncate(false))
        SimpleLogger("host", LogLevel.DEBUG, os)
    }
    TCPActorSystem.logger.level = LogLevel.DEBUG

    let host = TCPActorHost(bindAt: 52185)
    for (i in 0..100) {
        let service = TestServiceImpl()
        host.register("testService ${i}", service)
    }
    host.serve()
    while (true) {
        sleep(Duration.second)
    }
}