package actors

import std.collection.concurrent.*

type Item = (SequentialDispatcher, () -> Unit)

interface Mailbox {
    func add(item: Item, priority: Int64): Unit
    func remove(): Option<Item>
    func removeBlock(): Item
    func poison(): Unit
}

class UnboundedMailbox <: Mailbox {
    private let queue = BlockingQueue<Item>()

    public func add(item: Item, _: Int64): Unit {
        queue.enqueue(item)
    }

    public func remove(): Option<Item> {
        queue.tryDequeue()
    }

    public func removeBlock(): Item {
        queue.dequeue()
    }

    public func poison(): Unit {
        queue.enqueue((unsafe { zeroValue<SequentialDispatcher>() }, { => () }))
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

    public func removeBlock(): Item {
        queue.removeBlock()
    }

    public func poison(): Unit {
        queue.add((unsafe { zeroValue<SequentialDispatcher>() }, { => () }), 10)
    }
}