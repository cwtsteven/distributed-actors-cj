package actors.tcp_actor_system

import std.sync.*
import std.time.*

/*
* A class representing a timer that calls a callback periodically
*/
class Timer {
    private let interval: Duration
    private var callback: () -> Unit = { => () }
    private var fut: ?Future<Unit> = None

    /*
    * Initializes the timer
    * @param interval - the interval duration for calling the callback
    */
    Timer(interval: Duration) {
        this.interval = interval
    }

    /*
    * Sets the callback function
    * @param callback - the callback function to call periodically
    */
    func setCallback(callback: () -> Unit): Unit {
        this.callback = callback
    }

    /*
    * Starts the timer
    */
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

    /*
    * Stops the timer
    */
    func stop(): Unit {
        if (let Some(fut) <- this.fut) {
            while (!fut.thread.hasPendingCancellation) {
                fut.cancel()
            }
        }
    }
}