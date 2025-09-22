# Exceptions

## class FutureCancelledException

## class InterruptedReceiverException

public class FutureCancelledException <: Exception {
    public init() {
        super("Failed to access the result of this future because the actor's mailbox closed'.")
    }
}

public class InterruptedReceiverException <: Exception {
    public InterruptedReceiverException(public let action: ControlAction) {
        super("Failed to access the result of this future because its execution was interrupted by a ${action} effect")
    }
}