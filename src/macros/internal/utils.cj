package actors.macros.internal

import std.ast.*
import std.collection.*

const PREFIX = "___actors_08275892475824___"
const ACTOR_MACRO_NAME = "Actor"
const ACTOR_INTERFACE_MACRO_NAME = "ActorInterface"
const RECEIVER_MARKER_NAME = PREFIX + "Receiver"
const DISPATCHER_NAME = PREFIX + "dispatcher"
const RECEIVER_INFO_NAME = "ReceiverInfo"
const TELL_TYPE_NAME = "Tell"
const SEQ_DISPATCHER_NAME = "SequentialDispatcher"
const ENABLE_RECEIVER_PRIORITY_NAME = "enableReceiverPriority"
const DISPATCH_HASH_MAP_VAR_NAME = "dispatchMap"
const RECEIVER_INFOS_ARRAY_VAR_NAME = "receiverInfos"
const DISTRIBUTABLE_TYPE_NAME = "Distributable"
const PROXYABLE_TYPE_NAME = "Proxyable"

const ACTOR_MACRO = "@Actor"
const ACTOR_INTERFACE_MACRO = "@ActorInterface"
const ACTOR_DISTRIBUTED_INTERFACE_MACRO = "@ActorInterface[distributed: true]"
const RECEIVER_MACRO = "@Receiver"

let receiverMarkerToken = Token(IDENTIFIER, RECEIVER_MARKER_NAME)

let dispatcherToken = Token(IDENTIFIER, DISPATCHER_NAME)

let receiverInfoToken = Token(IDENTIFIER, RECEIVER_INFO_NAME)

let tellTypeToken = Token(IDENTIFIER, TELL_TYPE_NAME)

let dispatchTellHashMapVarToken = Token(IDENTIFIER, DISPATCH_HASH_MAP_VAR_NAME + "Tell")
let dispatchAskHashMapVarToken = Token(IDENTIFIER, DISPATCH_HASH_MAP_VAR_NAME + "Ask")

let receiverInfosArrayVarToken = Token (IDENTIFIER, RECEIVER_INFOS_ARRAY_VAR_NAME)

let seqDispatcherTypeToken = Token(IDENTIFIER, SEQ_DISPATCHER_NAME)

let enableReceiverPriorityToken = Token(IDENTIFIER, ENABLE_RECEIVER_PRIORITY_NAME)

let distributableTypeToken = Token(IDENTIFIER, DISTRIBUTABLE_TYPE_NAME)

let proxyableTypeToken = Token(IDENTIFIER, PROXYABLE_TYPE_NAME)

func deserializeFuncParams(fd: FuncDecl, isTell: Bool): Tokens {
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
    if (isTell) {
        res += quote(, tell: True)
    }
    res += Token(TokenKind.RPAREN)
    res
}

enum Behaviour {
    | Ask | Tell
}

func generateParamList(fd: FuncDecl): Tokens {
    var res = Tokens()
    for (i in 0..fd.funcParams.size) {
        let fp = fd.funcParams[i]
        res += quote($(fp.identifier))
        if (i < fd.funcParams.size - 1) {
            res += quote(, )
        }
    }
    res
}