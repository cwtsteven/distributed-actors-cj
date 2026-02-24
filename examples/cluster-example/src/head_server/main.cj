package cluster_example.head_server

import std.convert.*
import stdx.log.*

import actors.distributed.*
import actors.tcp_actor_system.*
import actors.tcp_actor_system.cluster.*

import stdx.encoding.json.*
import stdx.serialization.serialization.*

import cluster_example.common.*

main(args: Array<String>) {
    TCPActorSystem.logger.level = LogLevel.DEBUG

    let port = UInt16.parse(args[0])
    TCPCluster.createHeadServer(headServerAddr: "localhost", headServerPort: port).get()
}