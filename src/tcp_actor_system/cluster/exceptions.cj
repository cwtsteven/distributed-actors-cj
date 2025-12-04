package actors.tcp_actor_system.cluster

public class TCPClusterException <: Exception {
    public init(msg: String) {
        super(msg)
    }
}