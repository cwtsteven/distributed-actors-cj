package actors

import std.collection.concurrent.*

private type Item = (SequentialDispatcher, () -> Unit)

interface Mailbox {
    func add(item: Item, priority: Int64): Unit
    func remove(): Option<Item>
}

class UnboundedMailbox <: Mailbox {
    private let queue = ConcurrentLinkedQueue<Item>()

    public func add(item: Item, _: Int64): Unit {
        queue.enqueue(item)
    }

    public func remove(): Option<Item> {
        queue.dequeue()
    }
}

class UnboundedPriorityMailbox <: Mailbox {
    private let queue = ConcurrentPriorityQueue<Item>()

    public func add(item: Item, priority: Int64): Unit {
        queue.add(item, priority)
    }

    public func remove(): Option<Item> {
        queue.remove()
    }
}