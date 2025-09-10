package actors.macros.internal

import std.ast.*
import stdx.encoding.json.*

protected class ReceiverMacro {
    protected static func Run(attrs: Tokens, input: Tokens, bypassParentContextCheck!: Bool = false): Tokens {
        let errors = MacroErrors()

        // first check if @Receiver is inside @Actor or @ActorInterface
        if (!bypassParentContextCheck && !insideParentContext(ACTOR_MACRO_NAME) && !insideParentContext(ACTOR_INTERFACE_MACRO_NAME)) {
            errors.add(ReceiverMacroInsideActor)
            return errors.doThrow()
        }

        // parse the options
        let opts = MacroOptionParser.Run(attrs, errors)
        errors.report()

        let rMacro = ReceiverMacro(attrs, input, opts, errors)
        rMacro.run()
    }

    /*
        When using annotations within @Receiver, for example
            @Receiver
            @Annotation1 // the headDecl
            @Annotation2
            func foo { ... }
        These annotations are interpreter as MacroExpandDecl, and thus
        the input tokens could be parsed into the following structure:
        head-MacroExpandDecl --> ... --> actual FuncDecl
    */
    private let headDecl: Decl
    private var fd: FuncDecl = unsafe { zeroValue<FuncDecl>() }
    private let attrs: Tokens
    private let opts: MacroOptionSet
    private let errors: MacroErrors

    static let allowedOptions: Array<MacroOption> = [
        Priority(5),
        Mode(AskAndTell),
        Description(""),
        CustomInfos(JsonValue.fromStr("{}"))
    ]

    private init(attrs: Tokens, input: Tokens, opts: MacroOptionSet, errors: MacroErrors) {
        this.attrs = attrs
        this.opts = opts
        this.errors = errors
        this.headDecl = parseDecl(input)
    }

    private func run(): Tokens {
        checkOptions()
        findDecl()
        checkReceiver()
        newReceiver()
    }

    private func checkOptions(): Unit {
        opts.checkOptions(allowedOptions, errors, RECEIVER_MACRO)
        errors.report()
    }

    private func findDecl(): Unit {
        this.fd = match (findDeclUnderMacro<FuncDecl>(headDecl)) {
            case Some(fd) => fd
            case None =>
                errors.add(ReceiverMacroInvalidDecl)
                errors.doThrow()
        }
    }

    private func checkReceiver(): Unit {
        if (!checkModifiers(fd.modifiers, [STATIC, OPEN, OVERRIDE])) {
            errors.add(ReceiverMacroInvalidModifier(fd.identifier.value))
        }

        // check having explicit return type
        try {
            fd.declType
        } catch (_: ASTException) {
            errors.add(ReceiverMacroInvalidReturnType(fd.identifier.value))
        }

        errors.report()
    }

    /*
        @Receiver[expr]
        func decl
        ===>
        @prefixReceiver[expr]
        func decl
    */
    private func newReceiver(): Tokens {
        let options = if (attrs.size == 0) { Tokens() } else { quote([$attrs]) }
        quote(
            @$receiverMarkerToken$options
            $headDecl
        )
    }
}