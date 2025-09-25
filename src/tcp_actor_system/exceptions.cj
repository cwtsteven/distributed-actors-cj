package actors.tcp_actor_system

import actors.*

/*
* Exception thrown when a serialization operation fails
*/
public class TCPActorSystemSerializationException <: Exception {
    TCPActorSystemSerializationException(message: String) {
        super(message)
    }
}

/*
* Exception thrown when a deserialization operation fails
*/
public class TCPActorSystemDeserializationException <: Exception {
    TCPActorSystemDeserializationException(message: String) {
        super(message)
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