package actors

import std.time.*

/*
* A dispatcher that executes closures sequentially
*/
public class SequentialDispatcher {
    let mailbox: Mailbox
    let threadHandle: Future<Unit>

    /*
    * Initializes the dispatcher
    * @param enableReceiverPriority - whether to enable receiver priority
    */
    public init(enableReceiverPriority!: Bool = false) {
        this.mailbox = if (enableReceiverPriority) {
            UnboundedPriorityMailbox()
        } else {
            UnboundedMailbox()
        }
        this.threadHandle = startActorLoop(mailbox)
    }

    /*
    * Starts the actor loop
    * @param mailbox - the mailbox to use
    * @return the future handle of the actor loop
    */
    static func startActorLoop(mailbox: Mailbox): Future<Unit> {
        spawn {
            while (true) {

                if (Thread.currentThread.hasPendingCancellation) {
                    return
                }

                match (mailbox.remove(timeout: Duration.second * 5)) {
                    case Some((_, f)) => f()
                    case None => ()
                }
            }
        }
    }

    /*
    * Posts a task to the dispatcher and returns a future for the result
    * @param f - the task to post
    * @param config - the configuration of the task
    * @return the future of the task
    * @throws IllegalArgumentException - if the priority is out of range
    */
    public func post<T>(f: () -> T, config!: ReceiverConfig = ReceiverConfig.default): ActorFuture<T> {
        let fut = ActorFuture<T>(f)
        mailbox.add((this, fut.execute), config.priority)
        return fut
    }

    /*
    * Posts a task to the dispatcher without expecting a return value
    * @param f - the task to post
    * @param config - the configuration of the task
    * @throws IllegalArgumentException - if the priority is out of range
    */
    public func tell(f: () -> Unit, config!: ReceiverConfig = ReceiverConfig.default): Unit {
        mailbox.add((this, f), config.priority)
    }

    /*
    * Destroys the dispatcher by canceling the thread handle
    */
    ~init() {
        while (!threadHandle.thread.hasPendingCancellation) {
            threadHandle.cancel()
        }
    }
}