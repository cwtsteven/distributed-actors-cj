package actors

import std.collection.concurrent.*

const DEFAULT_CAPACITY = 10

type ConcurrentLinkedQueue<T> = NonBlockingQueue<T>

class ConcurrentPriorityQueue<T> {
    private let capacity: Int64
    private let queuePool: Array<ConcurrentLinkedQueue<T>>

    init() {
        this(DEFAULT_CAPACITY)
    }

    init(capacity: Int64) {
        this.capacity = capacity
        this.queuePool = Array<ConcurrentLinkedQueue<T>>(capacity, { _ => ConcurrentLinkedQueue<T>() })
    }

    func add(item: T, priority: Int64): Unit {
        if (priority <= 0 || priority > capacity) {
            throw IllegalArgumentException("Priority must be in the range of [1..${capacity}].")
        }

        // Note: ConcurrentLinkedQueue.add() will never return false
        queuePool[priority - 1].enqueue(item)
    }

    func remove(): Option<T> {
        var index: Int64 = -1
        for (i in 0..capacity) {
            if (queuePool[i].size > 0) {
                index = i
            }
        }
        if (index != -1) {
            return queuePool[index].dequeue()
        }
        return None
    }
}