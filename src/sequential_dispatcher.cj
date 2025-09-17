package actors

public class SequentialDispatcher {
    private let mailbox: Mailbox

    public init(enableReceiverPriority!: Bool = false) {
        mailbox = Mailbox(enableReceiverPriority)
        startActorLoop(mailbox)
    }

    static func startActorLoop(mailbox: Mailbox) {
        spawn {
            try {
                while (true) {
                    let (task, handler) = match (mailbox.waitNext()) {
                        case PoisonPill => break
                        case TellMessage(_, f, handler) => (f, handler)
                        case AskMessage(_, f, handler, _) => (f, handler)
                    }

                    let action: ControlAction = try {
                        try {
                            task()
                            Continue
                        } catch (eff: ControlEffect) {
                            eff.action
                        } catch (e: Exception) {
                            handler.handleException(e)
                        } catch (e: Error) {
                            handler.handleError(e)
                        }
                    } catch (eff: ControlEffect) {
                        // Necessary in case handlers throw effects
                        eff.action
                    }

                    match (action) {
                        case Continue => continue
                        case Poison(priority) => mailbox.poison(priority)
                        case Stop => break
                    }
                }
            } finally {
                mailbox.close()
            }
        }
    }

    public func postAsk<T>(f: () -> T, config!: ReceiverConfig = ReceiverConfig.default): LocalActorFuture<T> {
        let fut = LocalActorFuture<T>(f)
        let success = mailbox.add(AskMessage(this, fut.execute, Handler(config.onException, config.onError), fut.cancel), config.priority)
        if (!success) {
            fut.cancel()
        }
        return fut
    }

    public func postTell(f: () -> Unit, config!: ReceiverConfig = ReceiverConfig.default): Unit {
        mailbox.add(TellMessage(this, f, Handler(config.onException, config.onError)), config.priority)
    }

    ~init() {
        mailbox.close()
    }
}
