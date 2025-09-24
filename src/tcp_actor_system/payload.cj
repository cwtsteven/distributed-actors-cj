package actors.tcp_actor_system

import serialization.serialization.*
import actors.*

enum Payload <: Equatable<Payload> & ToString {
    Ok
    | NotOk
    | Find(String)
    | FindAll
    | FindResponse(Array<ActorInfo>)
    | Ask(String, String, Array<DataModel>, ReceiverConfig, UInt64)
    | Tell(String, String, Array<DataModel>, ReceiverConfig)
    | Fulfill(UInt64, DataModel)

    public operator func ==(other: Payload): Bool {
        match ((this, other)) {
            case (Ok, Ok) => true
            case (NotOk, NotOk) => true
            case (Find(n1), Find(n2)) => n1 == n2
            case (FindAll, FindAll) => true
            case _ => false
        }
    }

    public operator func !=(other: Payload): Bool {
        !(this == other)
    }

    public func toString(): String {
        match (this) {
            case Ok => "Ok"
            case NotOk => "NotOk"
            case Find(name) => "Find(${name})"
            case FindAll => "FindAll"
            case FindResponse(_) => "FindResponse"
            case Ask(name, methodName, _, _, _) => "Ask ${name}.${methodName}"
            case Tell(name, methodName, _, _) => "Tell ${name}.${methodName}"
            case Fulfill(futId, _) => "Fullfill(${futId})"
        }
    }
}