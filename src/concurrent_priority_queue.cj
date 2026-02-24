package actors

import std.collection.concurrent.*

/*
* The default number of priorities of the concurrent priority queue
*/
const DEFAULT_NUM_OF_PRIORITIES = 10

type ConcurrentLinkedQueue<T> = LinkedBlockingQueue<T>

/*
* A concurrent priority queue
*/
class ConcurrentPriorityQueue<T> {
    private let numOfPriorities: Int64
    private let queuePool: Array<ConcurrentLinkedQueue<T>>
    private let semaphore = SingleConsumerSemaphore()

    /*
    * Initializes the concurrent priority queue
    */
    init() {
        this(DEFAULT_NUM_OF_PRIORITIES)
    }

    /*
    * Initializes the concurrent priority queue
    * @param numOfPriorities - the number of priorities of the concurrent priority queue
    */
    init(numOfPriorities: Int64) {
        this.numOfPriorities = numOfPriorities
        this.queuePool = Array<ConcurrentLinkedQueue<T>>(numOfPriorities, { _ => ConcurrentLinkedQueue<T>() })
    }

    /*
    * Adds an item to the concurrent priority queue
    * @param item - the item to add
    * @param priority - the priority of the item
    * @throws IllegalArgumentException - if the priority is out of range
    */
    func add(item: T, priority: Int64): Unit {
        if (priority <= 0 || priority > numOfPriorities) {
            throw IllegalArgumentException("Priority must be in the range of [1..${numOfPriorities}].")
        }

        queuePool[priority - 1].add(item)
        semaphore.signal()
    }

    /*
    * Removes an item from the concurrent priority queue
    * @return the item if it is found, None otherwise
    */
    func remove(): Option<T> {
        var index: Int64 = -1
        for (i in 0..numOfPriorities) {
            if (queuePool[i].size > 0) {
                index = i
            }
        }
        if (index != -1) {
            return queuePool[index].tryRemove()
        }
        return None
    }

    /*
    * Blocks the current thread until an item is available
    * @return the item
    */
    func removeBlock(): T {
        while (true) {
            semaphore.wait()
            var index: Int64 = -1
            for (i in 0..numOfPriorities) {
                if (queuePool[i].size > 0) {
                    index = i
                }
            }
            if (index != -1) {
                return queuePool[index].remove()
            }
        }
        // this should never happen
        throw IllegalStateException("Queue is empty")
    }
}
