package actors

struct Handler {
    Handler(
        let handleException: (Exception) -> ControlAction,
        let handleError: (Error) -> ControlAction
    ) {}
}

public enum ControlAction <: ToString {
    | Continue
    | Poison(Int64)
    | Stop

    public func toString(): String {
        match (this) {
            case Continue => "Continue"
            case Poison(priority) => "Poison(priority: ${priority})"
            case Stop => "Stop"
        }
    }
}

public func controlEffect(action: ControlAction): Unit {
    throw ControlEffect(action)
}

class ControlEffect <: Exception {
    ControlEffect(public let action: ControlAction) {
        super("Uncaught control effect with action ${action}")
    }

    public func getClassName(): String {
        "UncaughtControlEffectException"
    }
}

