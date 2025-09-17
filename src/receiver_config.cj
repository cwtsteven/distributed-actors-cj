package actors

public class ReceiverConfig {
    public static let default = ReceiverConfig()

    public ReceiverConfig(
        public let priority!: Int64 = 5,
        public let onException!: (Exception) -> ControlAction = { e => throw e },
        public let onError!: (Error) -> ControlAction = { e => throw e }
    ) {}
}