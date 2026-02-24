package actors

import std.sync.*

/*
* A semaphore that allows only one thread wait on but multiple threads to signal
*/
class SingleConsumerSemaphore {
    private let cnt = AtomicUInt64(0)
    private let mtx = Mutex()
    private let cond: Condition

    init() {
        synchronized(mtx) {
            cond = mtx.condition()
        }
    }

    /*
    * Increments cnt by 1
    * If cnt was 0, unblocks all threads waiting on the semaphore
    */
    func signal(): Unit {
        let n = cnt.fetchAdd(1)
        if (n == 0) {
            synchronized(mtx) {
                cond.notifyAll()
            }
        }
    }

    /*
    * Blocks the current thread if cnt is 0 until cnt is incremented by signal()
    */
    func wait(): Unit {
        let n = cnt.load()
        if (n == 0) {
            synchronized(mtx) {
                while (cnt.load() == 0) {
                    cond.wait()
                }
            }
        }
        cnt.fetchSub(1)
    }
}
