package actors

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

                let (_, f) = mailbox.removeBlock()
                f()
            }
        }
    }

    /*
    * Posts a task to the dispatcher and returns a future for the result
    * @param f - the task to post
    * @param config - the configuration of the task
    * @return the future of the task
    */
    public func post<T>(f: () -> T, config!: ReceiverConfig = ReceiverConfig.default): ActorFuture<T> {
        let fut = LocalActorFuture<T>(f)
        mailbox.add((this, fut.execute), config.priority)
        return fut
    }

    /*
    * Posts a task to the dispatcher without expecting a return value
    * @param f - the task to post
    * @param config - the configuration of the task
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
        // to activate the loop and trigger the cancellation
        mailbox.add((unsafe { zeroValue<SequentialDispatcher>() }, { => () }), 10)
    }
}