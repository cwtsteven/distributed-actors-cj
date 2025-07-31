macro package actors.macros

import std.ast.*

const PREFIX = "___actors_08275892475824___"
const ACTOR_MACRO_NAME = "Actor"
const RECEIVER_MARKER_NAME = PREFIX + "Receiver"
const DISPATCHER_NAME = PREFIX + "dispatcher"

let receiverMarkerToken = Token(IDENTIFIER, RECEIVER_MARKER_NAME)

let dispatcherToken = Token(IDENTIFIER, DISPATCHER_NAME)

func actorFutureType(t: TypeNode): RefType {
    RefType(quote(
        ActorFuture<$t>
    ))
}