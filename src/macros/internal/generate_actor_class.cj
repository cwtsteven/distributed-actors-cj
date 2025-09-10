package actors.macros.internal

import std.ast.*
import std.collection.*

protected class GenerateActorClass {

    protected static func Run(attrs: Tokens, input: Tokens): Tokens {
        GenerateActorClass(attrs, input).run()
    }

    let errors: MacroErrors
    let aOpts: MacroOptionSet
    let headDecl: Decl
    let decl: ClassDecl

    static let allowedOptions: Array<MacroOption> = [
        EnableReceiverPriority(true)
    ]

    static let allowedReceiverOptions: Array<MacroOption> = [
        Priority(5),
        Mode(AskAndTell)
    ]

    private init(attrs: Tokens, input: Tokens) {
        errors = MacroErrors()
        aOpts = MacroOptionParser.Run(attrs, errors)
        headDecl = parseDecl(input)
        decl = match (findDeclUnderMacro<ClassDecl>(headDecl)) {
            case Some(d) => d
            case None =>
                errors.add(ActorMacroInvalidDecl)
                errors.doThrow()
        }
    }

    private func run(): Tokens {

        checkOptions()
        checkClassDecl()

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

        addDispatcherVar()

        headDecl.toTokens()
    }

    private func checkOptions(): Unit {
        aOpts.checkOptions(allowedOptions, errors, ACTOR_MACRO)
        errors.report()
    }

    private func checkClassDecl(): Unit {
        if (!checkModifiers(decl.modifiers, [ABSTRACT, OPEN, SEALED])) {
            errors.add(ActorMacroInvalidClassModifier)
            errors.doThrow()
        }
    }

    private func addDispatcherVar(): Unit {
        let dInit = quote(
            $seqDispatcherTypeToken($enableReceiverPriorityToken: $(aOpts.hasEnabledReceiverPriority()))
        )

        decl.body.decls.add(VarDecl(quote(
            private let $dispatcherToken = $dInit
        )))
    }

    private func checkReceiverOptions(rOpts: MacroOptionSet): Unit {
        rOpts.checkOptions(allowedReceiverOptions, errors, ACTOR_MACRO)
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

        checkReceiverDecl(fd, rOpts)
        modifyFuncDecl(rOpts, fd, behaviour)
        headDecl
    }

    private func checkReceiverDecl(fd: FuncDecl, rOpts: MacroOptionSet): Unit {
        for (param in fd.funcParams) {
            if (aOpts.hasEnabledReceiverPriority() && param.not.kind == TokenKind.NOT && param.identifier.value == "priority") {
                // a named parameter named "priority"
                errors.add(ReceiverMacroPriorityNameParameter)
            }
            if (rOpts.shouldTell() && param.not.kind == TokenKind.NOT && param.identifier.value == "tell") {
                // a named parameter named "tell"
                errors.add(ReceiverMacroTellNameParameter)
            }
        }
        errors.report()
    }

    private func modifyFuncDecl(rOpts: MacroOptionSet, fd: FuncDecl, behaviour: Behaviour): Unit {
        if (aOpts.hasEnabledReceiverPriority()) {
            let defaultPriority = getPriority(rOpts)
            fd.funcParams.add(FuncParam(quote(
                priority!: Int64 = $defaultPriority
            )))
        }

        let declaredType = fd.declType

        fd.declType = match (behaviour) {
            case Ask => RefType(quote(LocalActorFuture<$declaredType>))
            case Tell => PrimitiveType(quote(Unit))
        }

        let priorityArg = Tokens()
        if (aOpts.hasEnabledReceiverPriority()) {
            priorityArg.append(Token(COMMA))
            priorityArg.append(quote(priority: priority))
        }

        let postCall = match (behaviour) {
            case Ask => quote(post<$declaredType>({ => $(fd.block.nodes)} $priorityArg))
            case Tell => quote(
                postMessage(
                    { =>
                        try {
                            { => $(fd.block.nodes) }()
                        } catch (_: Exception) {
                        } catch (_: Error) {}
                        return
                    }
                    $priorityArg
                )
            )
        }

        let retExpr = ReturnExpr(quote(return $dispatcherToken.$postCall))

        fd.block.nodes.clear()

        if (let Tell <- behaviour) {
            // Add the `tell` parameter
            fd.funcParams.add(FuncParam(quote(
                tell!: $tellTypeToken
            )))
            let discardTellParam = VarDecl(quote(let dummy = tell))
            // For some reason VarDecl parses "let _ = tell" as "let = tell"
            // so we add the wildcard manually instead
            discardTellParam.identifier = Token(WILDCARD)
            fd.block.nodes.add(discardTellParam)
        }

        fd.block.nodes.add(retExpr)
    }
}
