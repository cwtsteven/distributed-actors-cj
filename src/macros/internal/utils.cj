package actors.macros.internal

import std.ast.*
import std.collection.*

const PREFIX = "___actors_08275892475824___"
const ACTOR_MACRO_NAME = "Actor"
const ACTOR_INTERFACE_MACRO_NAME = "ActorInterface"
const RECEIVER_MARKER_NAME = PREFIX + "Receiver"
const DISPATCHER_NAME = PREFIX + "dispatcher"
const ACTOR_PROXY_NAME = "ActorProxy"
const RECEIVER_INFO_NAME = "ReceiverInfo"
const TELL_TYPE_NAME = "Tell"
const PROXY_NAME = "proxy"
const SEQ_DISPATCHER_NAME = "SequentialDispatcher"
const ENABLE_RECEIVER_PRIORITY_NAME = "enableReceiverPriority"
const DISPATCH_HASH_MAP_VAR_NAME = "dispatchMap"
const RECEIVER_INFOS_ARRAY_VAR_NAME = "receiverInfos"
const DISTRIBUTABLE_TYPE_NAME = "Distributable"

const ACTOR_MACRO = "@Actor"
const ACTOR_INTERFACE_MACRO = "@ActorInterface"
const ACTOR_DISTRIBUTED_INTERFACE_MACRO = "@ActorInterface[distributed: true]"
const RECEIVER_MACRO = "@Receiver"

let receiverMarkerToken = Token(IDENTIFIER, RECEIVER_MARKER_NAME)

let dispatcherToken = Token(IDENTIFIER, DISPATCHER_NAME)

let actorProxyToken = Token(IDENTIFIER, ACTOR_PROXY_NAME)

let receiverInfoToken = Token(IDENTIFIER, RECEIVER_INFO_NAME)

let tellTypeToken = Token(IDENTIFIER, TELL_TYPE_NAME)

let proxyVarToken = Token(IDENTIFIER, PROXY_NAME)

let dispatchHashMapVarToken = Token(IDENTIFIER, DISPATCH_HASH_MAP_VAR_NAME)

let receiverInfosArrayVarToken = Token (IDENTIFIER, RECEIVER_INFOS_ARRAY_VAR_NAME)

let seqDispatcherTypeToken = Token(IDENTIFIER, SEQ_DISPATCHER_NAME)

let enableReceiverPriorityToken = Token(IDENTIFIER, ENABLE_RECEIVER_PRIORITY_NAME)

let distributableTypeToken = Token(IDENTIFIER, DISTRIBUTABLE_TYPE_NAME)

func deserializeFuncParams(fd: FuncDecl): Tokens {
    if (fd.funcParams.size == 0) {
        return quote((config: config))
    }

    var res = Tokens(Token(TokenKind.LPAREN))
    for (i in 0..fd.funcParams.size - 1) {
        let fp = fd.funcParams[i]
        res += quote($(fp.paramType).deserialize(args[$i]), )
    }

    let lastTy = fd.funcParams[fd.funcParams.size - 1].paramType
    res += quote($lastTy.deserialize(args[args.size - 1]))
    res += quote(, config: config)
    res += Token(TokenKind.RPAREN)
    res
}

enum Behaviour {
    | Ask | Tell
}