package actors

import std.collection.concurrent.*

type Item = (SequentialDispatcher, () -> Unit)

interface Mailbox {
    /*
    * Adds an item to the mailbox
    * @param item - the item to add
    * @param priority - the priority of the item
    * @throws IllegalArgumentException - if the priority is out of range
    */
    func add(item: Item, priority: Int64): Unit
    /*
    * Removes an item from the mailbox
    * @return the item if it exists, None otherwise
    */
    func remove(): Option<Item>
    /*
    * Blocks the current thread until an item is available
    * @return the item
    */
    func removeBlock(): Item
}

/*
* A mailbox that can hold an unbounded number of items
*/
class UnboundedMailbox <: Mailbox {
    private let queue = LinkedBlockingQueue<Item>()

    public func add(item: Item, _: Int64): Unit {
        queue.add(item)
    }

    public func remove(): Option<Item> {
        queue.tryRemove()
    }

    public func removeBlock(): Item {
        queue.remove()
    }
}

/*
* A mailbox that can hold an unbounded number of items with priority
*/
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
}
