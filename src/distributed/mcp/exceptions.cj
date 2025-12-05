package actors.distributed.mcp

import actors.distributed.*

public class ActorMCPException <: ActorSystemException {
    public init(msg: String) {
        super(msg)
    }

    public override func getClassName(): String {
        "ActorMCPException"
    }
}