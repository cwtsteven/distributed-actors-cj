package actors.tcp_actor_system.cluster

/*
* Exception thrown when a cluster operation fails
*/
public class TCPClusterException <: Exception {
    /*
    * Initializes the TCPClusterException
    * @param msg - the message of the exception
    */
    public init(msg: String) {
        super(msg)
    }

    public override func getClassName(): String {
        "TCPClusterException"
    }
}