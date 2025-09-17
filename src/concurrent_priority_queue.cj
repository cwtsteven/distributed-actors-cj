package actors

import std.collection.concurrent.*

const DEFAULT_CAPACITY = 10

class ConcurrentPriorityQueue<T> {
    let capacity: Int64
    let queuePool: Array<ConcurrentLinkedQueue<T>>

    init() {
        this(DEFAULT_CAPACITY)
    }

    init(capacity: Int64) {
        this.capacity = capacity
        this.queuePool = Array<ConcurrentLinkedQueue<T>>(capacity, { _ => ConcurrentLinkedQueue<T>() })
    }

    public func add(item: T, priority: Int64): Unit {
        if (priority <= 0 || priority > capacity) {
            throw IllegalArgumentException("Priority must be in the range of [1..${capacity}].")
        }

        // Note: ConcurrentLinkedQueue.add() will never return false
        queuePool[priority - 1].add(item)
    }

    public func remove(): Option<T> {
        var index: Int64 = -1
        for (i in 0..capacity) {
            if (!queuePool[i].isEmpty()) {
                index = i
            }
        }
        if (index != -1) {
            return queuePool[index].remove()
        }
        return None
    }
}
