package actors.tcp_actor_system

/*
* Enum representing the error codes of the TCPActorSystem
*/
enum TCPActorSystemError <: ToString & Equatable<TCPActorSystemError> {
    | UnknownError
    | ActorNotFound
    | ReceiverNotFound

    public override func toString(): String {
        match (this) {
            case UnknownError => "UnknownError"
            case ActorNotFound => "ActorNotFound"
            case ReceiverNotFound => "ReceiverNotFound"
        }
    }

    public override operator func ==(other: TCPActorSystemError): Bool {
        match ((this, other)) {
            case (UnknownError, UnknownError) => true
            case (ActorNotFound, ActorNotFound) => true
            case (ReceiverNotFound, ReceiverNotFound) => true
            case _ => false
        }
    }

    public override operator func !=(other: TCPActorSystemError): Bool {
        !(this == other)
    }
}