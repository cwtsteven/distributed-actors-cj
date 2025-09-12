package actors

public class SequentialDispatcher {
    let mailbox: Mailbox
    let numMsg: SingleConsumerSemaphore
    let threadHandle: Future<Unit>

    public init(enableReceiverPriority!: Bool = false) {
        this.mailbox = if (enableReceiverPriority) {
            UnboundedPriorityMailbox()
        } else {
            UnboundedMailbox()
        }
        this.numMsg = SingleConsumerSemaphore()
        this.threadHandle = startActorLoop(mailbox, numMsg)
    }

    static func nextItem(mailbox: Mailbox): Option<() -> Unit> {
        match (mailbox.remove()) {
            case None => None
            case Some((_, f)) => f
        }
    }

    static func startActorLoop(mailbox: Mailbox, numMsg: SingleConsumerSemaphore): Future<Unit> {
        spawn {
            while (true) {
                numMsg.wait()

                if (Thread.currentThread.hasPendingCancellation) {
                    return
                }

                match (nextItem(mailbox)) {
                    case Some(f) => f()
                    case None => ()
                }
            }
        }
    }

    public func post<T>(f: () -> T, config!: ReceiverConfig = ReceiverConfig.default): LocalActorFuture<T> {
        let fut = LocalActorFuture<T>(f)
        mailbox.add((this, fut.execute), config.priority)
        numMsg.signal()
        return fut
    }

    public func postMessage(f: () -> Unit, config!: ReceiverConfig = ReceiverConfig.default): Unit {
        mailbox.add((this, f), config.priority)
        numMsg.signal()
    }

    ~init() {
        while (!threadHandle.thread.hasPendingCancellation) {
            threadHandle.cancel()
        }
        numMsg.signal()
    }
}