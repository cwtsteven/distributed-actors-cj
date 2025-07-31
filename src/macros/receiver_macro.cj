macro package actors.macros

import std.ast.*
import std.collection.*

public macro Receiver(attrs: Tokens, input: Tokens): Tokens {
    ReceiverMacro.Run(attrs, input)
}

public macro Receiver(input: Tokens): Tokens {
    ReceiverMacro.Run(Tokens(), input)
}

class ReceiverMacro {

    static func Run(attrs: Tokens, input: Tokens): Tokens {
        let errors = MacroErrors()

        // first check if @Receiver is inside @Actor
        if (!insideParentContext(ACTOR_MACRO_NAME)) {
            errors.add()
            return errors.doThrow()
        }

        // parse the options
        let opts = MacroOptionParser.Run(attrs, errors)
        errors.report()

        let rMacro = ReceiverMacro(input, opts, errors)

        rMacro.checkOptions()

        rMacro.checkDecl()

        rMacro.checkReceiver()

        rMacro.modifyReceiver(attrs)
    }

    private let opts: MacroOptionSet
    private let errors: MacroErrors
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

    private init(input: Tokens, opts: MacroOptionSet, errors: MacroErrors) {
        this.opts = opts
        this.errors = errors
        this.headDecl = parseDecl(input)
    }

    private func checkOptions(): Unit {
        opts.iterate { opt =>
            match (opt) {
                case Priority(_) => ()
                case _ =>
                    errors.add()
            }
            true
        }
        errors.report()
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

    private func checkReceiver(): Unit {
        for (mod in fd.modifiers) {
            if (mod.keyword.kind == STATIC || mod.keyword.kind == OPEN || mod.keyword.kind == OVERRIDE) {
                errors.add()
            }
        }

        // check having explicit return type
        try {
            fd.declType
        } catch (_: ASTException) {
            errors.add()
        }

        errors.report()
    }

    private func modifyReceiver(attrs: Tokens): Tokens {
        /*
            @Receiver[expr]
            func decl
            ===>
            @prefixReceiver[expr]
            func decl
        */
        let options = if (attrs.size == 0) { Tokens() } else { quote([$attrs]) }
        quote(
            @$receiverMarkerToken$options
            $headDecl
        )
    }
}