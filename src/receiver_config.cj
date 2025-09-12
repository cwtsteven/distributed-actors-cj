package actors

public class ReceiverConfig {
    public static let default = ReceiverConfig()

    public let priority: Int64

    public ReceiverConfig(priority!: Int64 = 5) {
        this.priority = priority
    }
}