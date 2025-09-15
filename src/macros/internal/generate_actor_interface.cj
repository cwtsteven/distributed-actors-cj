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

    static let allowedOptions: Array<MacroOption> = [
        EnableReceiverPriority(true),
        Distributed(false)
    ]

    static let allowedReceiverOptions: Array<MacroOption> = [
        Mode(AskAndTell)
    ]

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
        processReceivers(
            decl.body.decls,
            { d => newDecls.add(d) },
            { mDecl =>
                let rOpts = MacroOptionParser.Run(mDecl.macroAttrs, errors)
                checkReceiverOptions(rOpts)

                if (rOpts.shouldAsk()) {
                    newDecls.add(newReceiver(mDecl, rOpts, behaviour: Ask))
                }
                if (rOpts.shouldTell()) {
                    newDecls.add(newReceiver(mDecl, rOpts, behaviour: Tell))
                }
            }
        )
        decl.body.decls = newDecls

        headDecl.toTokens()
    }

    private func checkOptions(): Unit {
        aOpts.checkOptions(allowedOptions, errors, ACTOR_INTERFACE_MACRO)
        errors.report()
    }

    private func checkReceiverOptions(rOpts: MacroOptionSet): Unit {
        rOpts.checkOptions(allowedReceiverOptions, errors, ACTOR_INTERFACE_MACRO)
        errors.report()
    }

    private func newReceiver(mDecl: MacroExpandDecl, rOpts: MacroOptionSet, behaviour!: Behaviour): Decl {
        let headDecl: Decl = parseDecl(mDecl.macroInputs)
        let fd = match (findDeclUnderMacro<FuncDecl>(headDecl)) {
            case Some(fd) => fd
            case None =>
                errors.add(ReceiverMacroInvalidDecl)
                errors.doThrow()
        }

        checkReceiverDecl(fd)
        modifyFuncDecl(rOpts, fd, behaviour)
        headDecl
    }

    private func checkReceiverDecl(fd: FuncDecl): Unit {
        if (fd.block.nodes.size != 0) {
            errors.add(ReceiverMacroInsideActorInterface)
        }
        errors.report()
    }

    private func modifyFuncDecl(_: MacroOptionSet, fd: FuncDecl, behaviour: Behaviour): Unit {
        fd.funcParams.add(FuncParam(quote(
            config!: ReceiverConfig
        )))

        if (let Tell <- behaviour) {
            // Add the `tell` parameter
            fd.funcParams.add(FuncParam(quote(
                tell!: $tellTypeToken
            )))
        }

        let retTy = fd.declType
        fd.declType = match (behaviour) {
            case Ask => actorFutureType(retTy)
            case Tell => PrimitiveType(quote(Unit))
        }
    }
}
