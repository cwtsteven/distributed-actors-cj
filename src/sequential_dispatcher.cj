package actors

public class SequentialDispatcher {
    let mailbox: Mailbox
    let threadHandle: Future<Unit>

    public init(enableReceiverPriority!: Bool = false) {
        this.mailbox = if (enableReceiverPriority) {
            UnboundedPriorityMailbox()
        } else {
            UnboundedMailbox()
        }
        this.threadHandle = startActorLoop(mailbox)
    }

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

    public func post<T>(f: () -> T, config!: ReceiverConfig = ReceiverConfig.default): LocalActorFuture<T> {
        let fut = LocalActorFuture<T>(f)
        mailbox.add((this, fut.execute), config.priority)
        return fut
    }

    public func postMessage(f: () -> Unit, config!: ReceiverConfig = ReceiverConfig.default): Unit {
        mailbox.add((this, f), config.priority)
    }

    ~init() {
        while (!threadHandle.thread.hasPendingCancellation) {
            threadHandle.cancel()
        }
        mailbox.poison()
    }
}