package actors

/*
* Configuration for a receiver call
*/
public struct ReceiverConfig <: Equatable<ReceiverConfig> {
    /*
    * The default receiver config
    */
    public static let default = ReceiverConfig()

    /*
    * The priority of the receiver call
    */
    public let priority: Int64

    /*
    * Initializes the ReceiverConfig
    * @param priority - the priority of the receiver call
    */
    public ReceiverConfig(priority!: Int64 = 5) {
        this.priority = priority
    }

    public override operator func ==(other: ReceiverConfig): Bool {
        this.priority == other.priority
    }

    public override operator func !=(other: ReceiverConfig): Bool {
        !(this == other)
    }
}