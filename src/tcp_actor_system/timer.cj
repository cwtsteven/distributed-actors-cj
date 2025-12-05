package actors.tcp_actor_system

import std.sync.*
import std.time.*

class Timer {
    private let interval: Duration
    private var callback: () -> Unit = { => () }
    private var fut: ?Future<Unit> = None

    Timer(interval: Duration) {
        this.interval = interval
    }

    func setCallback(callback: () -> Unit): Unit {
        this.callback = callback
    }

    func start(): Unit {
        let fut = spawn {
            while (true) {
                if (Thread.currentThread.hasPendingCancellation) {
                    return
                }
                sleep(interval)
                callback()
            }
        }
        this.fut = Some(fut)
    }

    func stop(): Unit {
        if (let Some(fut) <- this.fut) {
            while (!fut.thread.hasPendingCancellation) {
                fut.cancel()
            }
        }
    }
}