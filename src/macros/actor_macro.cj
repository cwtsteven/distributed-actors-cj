macro package actors.macros

import std.ast.*
import std.collection.*

const DEFAULT_PRIORITY = 5

public macro Actor(attrs: Tokens, input: Tokens): Tokens {
    ActorMacro.Run(attrs, input)
}

public macro Actor(input: Tokens): Tokens {
    ActorMacro.Run(Tokens(), input)
}

class ActorMacro {

    static func Run(attrs: Tokens, input: Tokens): Tokens {
        let errors = MacroErrors()

        // parse the options
        let opts = MacroOptionParser.Run(attrs, errors)
        errors.report()

        let actorMacro = ActorMacro(input, opts, errors)

        // check the options
        actorMacro.checkOptions()

        // check if it is a class decl
        actorMacro.checkOptions()

        // check if it is a class decl
        actorMacro.checkDecl()

        // check if thi classs decl is valid
        actorMacro.checkClassDecl()

        // modify actor body
        actorMacro.processBody()

        // return the headDecl
        actorMacro.headDecl.toTokens()
    }

    private let opts: MacroOptionSet
    private let errors: MacroErrors
    /*
        When using annotations within @Actor, for example
            @Actor
            @Annotation1 // the headDecl
            @Annotation2
            class MyActor { ... }
        These annotations are interpreter as MacroExpandDecl, and thus
        the input tokens could be parsed into the following structure:
        head-MacroExpandDecl --> ... --> actual ClassDecl
    */
    private let headDecl: Decl
    private var cd: ClassDecl = unsafe { zeroValue<ClassDecl>() }

    private init(input: Tokens, opts: MacroOptionSet, errors: MacroErrors) {
        this.opts = opts
        this.errors = errors
        this.headDecl = parseDecl(input)
    }

    private func checkOptions(): Unit {
        opts.iterate { opt =>
            match (opt) {
                case EnableReceiverPriority(_) => ()
                case _ => errors.add()
            }
            true
        }
        errors.report()
    }

    private func checkDecl(): Unit {
        var decl = headDecl
        while (true) {
            if (let Some(cd) <- (decl as ClassDecl)) {
                this.cd = cd
                return
            }
            if (let Some(mc) <- (decl as MacroExpandDecl)) {
                decl = mc.macroInputDecl
            } else {
                errors.add()
                errors.doThrow()
            }
        }
    }

    private func checkClassDecl(): Unit {
        for (mod in cd.modifiers) {
            if (mod.keyword.kind == ABSTRACT || mod.keyword.kind == OPEN || mod.keyword.kind == SEALED) {
                errors.add()
            }
        }
        errors.report()
    }

    private func processBody(): Unit {
        let newDecls = ArrayList<Decl>()

        // add dispatcher member
        addDispatcherVar(newDecls)

        for (decl in cd.body.decls) {
            match (decl) {
                case mDecl: MacroExpandDecl =>
                    // not a receiver
                    if (mDecl.identifier.value != receiverMarkerToken.value) {
                        newDecls.add(decl)
                        continue
                    }
                    // a receiver
                    let receiverOpts = MacroOptionParser.Run(mDecl.macroAttrs, errors)
                    newDecls.add(ReceiverModification.Run(mDecl.macroInputs, opts, receiverOpts, errors))
                case _ => newDecls.add(decl)
            }
        }
        cd.body.decls = newDecls
    }

    private func addDispatcherVar(newDecls: ArrayList<Decl>): Unit {
        let dInit = quote(
            SequentialDispatcher(enableReceiverPriority: $(opts.hasEnabledReceiverPriority()))
        )

        newDecls.add(VarDecl(quote(
            private let $dispatcherToken = $dInit
        )))
    }
}

private class ReceiverModification {

    static func Run(input: Tokens, actorOpts: MacroOptionSet, receiverOpts: MacroOptionSet, errors: MacroErrors): Decl {
        let rModify = ReceiverModification(input, actorOpts, receiverOpts, errors)

        rModify.checkReceiverOptions()

        rModify.checkDecl()

        rModify.checkReceiver()

        rModify.modifyReceiver()

        rModify.headDecl
    }

    private let headDecl: Decl
    private var fd: FuncDecl = unsafe { zeroValue<FuncDecl>() }

    private ReceiverModification(
        input: Tokens,
        private let actorOpts: MacroOptionSet,
        private let receiverOpts: MacroOptionSet,
        private let errors: MacroErrors
    ) {
        headDecl = parseDecl(input)
    }

    private func checkDecl(): Unit {
        var decl = headDecl
        while (true) {
            if (let Some(fd) <- (decl as FuncDecl)) {
                this.fd = fd
                return
            }
            if (let Some(mc) <- (decl as MacroExpandDecl)) {
                decl = mc.macroInputDecl
            } else {
                errors.add()
                errors.doThrow()
            }
        }
    }

    private func checkReceiverOptions(): Unit {
        if (!actorOpts.hasEnabledReceiverPriority()) {
            receiverOpts.iterate { opt =>
                match (opt) {
                    case Priority(_) => errors.add()
                    case _ => ()
                }
                true
            }
        }
        errors.report()
    }

    private func checkReceiver(): Unit {
        if (actorOpts.hasEnabledReceiverPriority()) {
            for (param in fd.funcParams) {
                // a named parameter named "priority"
                if (param.not.kind == TokenKind.NOT && param.identifier.value == "priority") {
                    errors.add()
                }
            }
        }
        errors.report()
    }

    private func modifyReceiver(): Unit {
        if (actorOpts.hasEnabledReceiverPriority()) {
            modifyReceiverWithPriority()
            return
        }

        let retTy = fd.declType
        fd.declType = actorFutureType(retTy)

        let retExpr = ReturnExpr(quote(
            return $dispatcherToken.post<$retTy>({ => $(fd.block.nodes)})
        ))

        fd.block.nodes.clear()
        fd.block.nodes.add(retExpr)
    }

    private func modifyReceiverWithPriority(): Unit {
        let defaultPriorityBox: Box<Int64> = Box(DEFAULT_PRIORITY)
        receiverOpts.iterate { opt =>
            match (opt) {
                case Priority(p) => defaultPriorityBox.value = Int64(p); false
                case _ => true
            }
        }
        let defaultPriority = defaultPriorityBox.value

        let retTy = fd.declType
        fd.declType = actorFutureType(retTy)
        fd.funcParams.add(FuncParam(quote(
            priority!: Int64 = $defaultPriority
        )))

        let retExpr = ReturnExpr(quote(
            return $dispatcherToken.post<$retTy>({ => $(fd.block.nodes), priority: priority})
        ))

        fd.block.nodes.clear()
        fd.block.nodes.add(retExpr)
    }
}