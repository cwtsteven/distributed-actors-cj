package actors

import std.collection.concurrent.*
import std.sync.AtomicBool

class Mailbox {
    private let itemQueue: ItemQueue

    Mailbox(enablePriority: Bool) {
        itemQueue = if (enablePriority) {
            ConcurrentPriorityQueue<Item>()
        } else {
            ConcurrentLinkedQueue<Item>()
        }
    } 

    private let numItems = SingleConsumerSemaphore()
    private let isOpen = AtomicBool(true)

    func add(item: Item, priority: Int64): Bool {
        if (!isOpen.load()) { return false }
        itemQueue.add(item, priority)
        numItems.signal()
        true
    }

    func waitNext(): Item {
        numItems.wait()
        if (!isOpen.load()) { return PoisonPill }
        itemQueue.remove().getOrThrow {
            IllegalStateException("Expected to find an item in this mailbox, found none")
        }
    }

    func close(): Unit {
        if (!isOpen.load()) { return }
        while (isOpen.load() && !isOpen.compareAndSwap(true, false)) {}
        numItems.signal()
        itemQueue.clear()
    }

    func poison(priority: Int64): Unit {
        if (priority <= 0 || priority > 10) {
            throw IllegalArgumentException("Poison must have a priority in the range [1..10].")
        }
        add(PoisonPill, priority)
    }
}

type Task = () -> Unit
type Cancellation = () -> Unit

enum Item {
    | PoisonPill
    | TellMessage(SequentialDispatcher, Task, Handler)
    | AskMessage(SequentialDispatcher, Task, Handler, Cancellation)
}

interface ItemQueue {
    func add(item: Item, priority: Int64): Unit 
    func remove(): Option<Item>
    func clear(): Unit
}

extend ConcurrentLinkedQueue<Item> <: ItemQueue {
    public func add(item: Item, _: Int64): Unit {
        add(item)
    }

    public func clear(): Unit {
        while (let Some(item) <- remove()) {
            if (let AskMessage(_, _, _, cancel) <- item) {
                cancel()
            }
        }
    }
}

extend ConcurrentPriorityQueue<Item> <: ItemQueue {
    public func clear(): Unit {
        for (queue in queuePool) {
            queue.clear()
        }
    }
}