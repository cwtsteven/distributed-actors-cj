package actors.tcp_actor_system

import std.binary.*

/*
* Enum representing the error codes of the TCPActorSystem
*/
enum TCPActorSystemError <: Equatable<TCPActorSystemError> & ToString {
    ActorNotFound

    public func toString(): String {
        match (this) {
            case ActorNotFound => "ActorNotFound"
        }
    }

    public override operator func ==(other: TCPActorSystemError): Bool {
        match ((this, other)) {
            case (ActorNotFound, ActorNotFound) => true
        }
    }

    public override operator func !=(other: TCPActorSystemError): Bool {
        !(this == other)
    }
}