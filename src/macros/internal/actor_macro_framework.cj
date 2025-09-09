package actors.macros.internal

import std.ast.*
import std.collection.*

const DEFAULT_PRIORITY = 5

func actorFutureType(t: TypeNode): RefType {
    RefType(quote(
        ActorFuture<$t>
    ))
}

func findDeclUnderMacro<D>(headDecl: Decl): Option<D> where D <: Decl {
    var decl = headDecl
    while (true) {
        if (let Some(d) <- (decl as D)) {
            return Some(d)
        }
        if (let Some(mc) <- (decl as MacroExpandDecl)) {
            decl = mc.macroInputDecl
        } else {
            return None
        }
    }
    return None
}

func checkModifiers(mods: ArrayList<Modifier>, notAllowed: Array<TokenKind>): Bool {
    for (mod in mods) {
        for (a in notAllowed) {
            if (a == mod.keyword.kind) {
                return false
            }
        }
    }
    return true
}

func processReceivers(
    decls: ArrayList<Decl>,
    nonReceiverAction: (Decl) -> Unit,
    receiverAction: (MacroExpandDecl) -> Unit
): Unit {
    for (decl in decls) {
        match (decl) {
            case mDecl: MacroExpandDecl =>
                // not a receiver
                if (mDecl.identifier.value != receiverMarkerToken.value) {
                    nonReceiverAction(decl)
                    continue
                }
                // a receiver
                receiverAction(mDecl)

            case _ => nonReceiverAction(decl)
        }
    }
}

func getPriority(rOpts: MacroOptionSet): Int64 {
    let defaultPriorityBox: Box<Int64> = Box(DEFAULT_PRIORITY)
    rOpts.iterate { opt =>
        match (opt) {
            case Priority(p) => defaultPriorityBox.value = Int64(p); false
            case _ => true
        }
    }
    defaultPriorityBox.value
}