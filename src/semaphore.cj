package actors

import std.sync.*

class SingleConsumerSemaphore {
    private let cnt = AtomicUInt64(0)
    private let mtx = Mutex()
    private let cond: Condition

    init() {
        synchronized(mtx) {
            cond = mtx.condition()
        }
    }

    func signal(): Unit {
        let n = cnt.fetchAdd(1)
        if (n == 0) {
            synchronized(mtx) {
                cond.notifyAll()
            }
        }
    }

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