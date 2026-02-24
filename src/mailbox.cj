package actors

import std.collection.concurrent.*
import std.time.*

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
    func remove(timeout!: Duration): Option<Item>
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

    public func remove(timeout!: Duration = Duration.Zero): Option<Item> {
        queue.remove(timeout)
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

    public func remove(timeout!: Duration = Duration.Zero): Option<Item> {
        queue.remove(timeout)
    }

    public func removeBlock(): Item {
        queue.removeBlock()
    }
}
