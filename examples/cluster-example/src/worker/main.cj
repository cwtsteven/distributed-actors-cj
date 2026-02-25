package cluster_example.worker

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

    let headServerAddr = args[0]
    let headServerPort = UInt16.parse(args[1])
    let workerId = args[2]
    let workerAddr = args[3]
    let workerPort = UInt16.parse(args[4])

    TCPCluster.createWorker(headServerAddr: headServerAddr, headServerPort: headServerPort, workerId: workerId, workerAddr: workerAddr, workerPort: workerPort).get()
}