macro package actors.macros

import std.ast.*
import std.collection.*

/**
 * This macro can be only defined at function declaration inside @Actor or @ActorInterface.
 *
 * @since 
 *
 * @throws MacroException if 
 *   1. the input is not a FuncDecl; or
 *   2. the FuncDecl has a STATIC modifier; or
 *   3. the FuncDecl has a OVERRIDE modifier; or
 *   4. the FuncDecl has a OPEN modifier; or
 *   5. the FuncDecl does not have an explicit return type.
 *
 * @throws MacroException for invalid options. TODO
 *
 * This macro essentially does the following translation:
 *
 *   @Receiver[opts]
 *   func decl
 *
 *     == translate into ==>
 *
 *   @prefixReceiver[opts]
 *   func decl
 *
 */
public macro Receiver(attrs: Tokens, input: Tokens): Tokens {
    ReceiverMacro.Run(attrs, input)
}

public macro Receiver(input: Tokens): Tokens {
    ReceiverMacro.Run(Tokens(), input)
}

class ReceiverMacro {
    static func Run(attrs: Tokens, input: Tokens): Tokens {
        let errors = MacroErrors()

        // first check if @Receiver is inside @Actor or @ActorInterface
        if (!insideParentContext(ACTOR_MACRO_NAME) && !insideParentContext(ACTOR_INTERFACE_MACRO_NAME)) {
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
        opts.checkOptions([Priority(5)], errors, RECEIVER_MACRO)
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