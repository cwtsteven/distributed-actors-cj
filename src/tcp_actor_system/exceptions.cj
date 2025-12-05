package actors.tcp_actor_system

import actors.distributed.*

/*
* Exception thrown when a serialization operation fails
*/
public class TCPActorSystemSerializationException <: ActorSystemException {
    protected init(message: String) {
        super(message)
    }

    protected override func getClassName(): String {
        "TCPActorSystemSerializationException"
    }
}

/*
* Exception thrown when a deserialization operation fails
*/
public class TCPActorSystemDeserializationException <: ActorSystemException {
    protected init(message: String) {
        super(message)
    }

    protected override func getClassName(): String {
        "TCPActorSystemDeserializationException"
    }
}

public class TCPActorSystemRemoteException <: RemoteException {
    protected init(message: String) {
        super(message)
    }

    protected init() {
        super()
    }

    protected override func getClassName(): String {
        "TCPActorSystemRemoteException"
    }
}

public class TCPActorSystemRequestTimeoutException <: RemoteException {
    protected init(message: String) {
        super(message)
    }

    protected init() {
        super("Request timeout.")
    }

    protected override func getClassName(): String {
        "TCPActorSystemRequestTimeoutException"
    }
}

public class TCPActorSystemInternalException <: ActorSystemException {
    protected init(message: String) {
        super(message)
    }

    protected override func getClassName(): String {
        "TCPActorSystemInternalException"
    }
}

extend Exception {
    public func toStringWithStackTrace(): String {
        stackTraceToString(message, getStackTrace())
    }
}

extend Error {
    public func toStringWithStackTrace(): String {
        stackTraceToString(message, getStackTrace())
    }
}