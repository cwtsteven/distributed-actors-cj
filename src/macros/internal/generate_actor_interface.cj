package actors.macros.internal

import std.ast.*
import std.collection.*

protected class GenerateActorInterface {

    protected static func Run(attrs: Tokens, input: Tokens): Tokens {
        GenerateActorInterface(attrs, input).run()
    }

    let errors: MacroErrors
    let aOpts: MacroOptionSet
    let headDecl: Decl
    let decl: InterfaceDecl

    private init(attrs: Tokens, input: Tokens) {
        errors = MacroErrors()
        aOpts = MacroOptionParser.Run(attrs, errors)
        headDecl = parseDecl(input)
        decl = match (findDeclUnderMacro<InterfaceDecl>(headDecl)) {
            case Some(d) => d
            case None =>
                errors.add(ActorInterfaceMacroInvalidDecl)
                errors.doThrow()
        }
    }

    private func run(): Tokens {
        if (aOpts.isDistributed()) {
            return GenerateDistributedActorInterface.Run(aOpts, headDecl, decl, errors)
        }

        checkOptions()
        let newDecls = ArrayList<Decl>()
        processReceivers(decl.body.decls, { d => newDecls.add(d) }, { mDecl => newDecls.add(newReceiver(mDecl)) })
        decl.body.decls = newDecls

        headDecl.toTokens()
    }

    private func checkOptions(): Unit {
        aOpts.checkOptions([EnableReceiverPriority(true), Distributed(true)], errors, ACTOR_INTERFACE_MACRO)
        errors.report()
    }

    private func newReceiver(mDecl: MacroExpandDecl): Decl {
        let rOpts = MacroOptionParser.Run(mDecl.macroAttrs, errors)

        checkReceiverOptions(rOpts)

        let headDecl: Decl = parseDecl(mDecl.macroInputs)
        let fd = match (findDeclUnderMacro<FuncDecl>(headDecl)) {
            case Some(fd) => fd
            case None =>
                errors.add(ReceiverMacroInvalidDecl)
                errors.doThrow()
        }

        checkReceiverDecl(fd)
        modifyFuncDecl(rOpts, fd)
        headDecl
    }

    private func checkReceiverOptions(rOpts: MacroOptionSet): Unit {
        if (!aOpts.hasEnabledReceiverPriority()) {
            rOpts.checkOptions([Priority(5)], errors, RECEIVER_MACRO)
        }
        errors.report()
    }

    private func checkReceiverDecl(fd: FuncDecl): Unit {
        if (aOpts.hasEnabledReceiverPriority()) {
            for (param in fd.funcParams) {
                // a named parameter named "priority"
                if (param.not.kind == TokenKind.NOT && param.identifier.value == "priority") {
                    errors.add(ReceiverMacroPriorityNameParameter)
                }
            }
        }
        if (fd.block.nodes.size != 0) {
            errors.add(ReceiverMacroInsideActorInterface)
        }
        errors.report()
    }

    private func modifyFuncDecl(rOpts: MacroOptionSet, fd: FuncDecl): Unit {
        if (aOpts.hasEnabledReceiverPriority()) {
            let defaultPriority = getPriority(rOpts)
            fd.funcParams.add(FuncParam(quote(
                priority!: Int64 = $defaultPriority
            )))
        }

        let retTy = fd.declType
        fd.declType = actorFutureType(retTy)
    }
}
