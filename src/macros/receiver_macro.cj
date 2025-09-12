macro package actors.macros

import std.ast.*

import actors.macros.internal.*

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
 *   6. the FuncDecl cannot have a parameter named config or tell.
 *
 * @throws MacroException for invalid options.
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
