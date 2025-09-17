package actors

import std.sync.*

class SingleConsumerSemaphore {
    private let cnt = AtomicUInt64(0)
    private let mtx = Monitor()

    func signal(): Unit {
        let n = cnt.fetchAdd(1)
        if (n == 0) {
            synchronized(mtx) {
                mtx.notifyAll()
            }
        }
    }

    func wait(): Unit {
        let n = cnt.load()
        if (n == 0) {
            synchronized(mtx) {
                while (cnt.load() == 0) {
                    mtx.wait()
                }
            }
        }
        cnt.fetchSub(1)
    }
}