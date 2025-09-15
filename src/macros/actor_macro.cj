macro package actors.macros

import std.ast.*

import actors.macros.internal.*

/**
 * This macro can be only defined at non-inheritable class, i.e. a class that is not open nor abstract nor sealed.
 *
 * @since
 *
 * @throws MacroException if
 *   1. the input is not a ClassDecl; or
 *   2. the ClassDecl has a OPEN modifier; or
 *   3. the ClassDecl has a ABSTRACT modifier; or
 *   4. the ClassDecl has a SEALED modifier.
 *
 * @throws MacroException for invalid options.
 *
 * This macro essentially does the following translation:
 *
 *   @Actor[opts1]
 *   class MyActor {
 *     @prefixReceiver[opts2]
 *     func foo(arg: T1): T { body }
 *   }
 *
 *     == translate into ==>
 *
 *   class MyActor {
 *     private let sequentialDispatch = SequentialDispatcher(enableReceiverPriority: `get from opts1`)
 *
 *     func foo(arg: T1, config!: ReceiverConfig = ReceiverConfig.default): ActorFuture<T> {
 *       sequentialDispatch.post<T>( { => body }, config )
 *     }
 *
 *     func foo(arg: T1, config!: ReceiverConfig = ReceiverConfig.default, tell!: Tell): Unit {
 *       let _ = tell
 *       sequentialDispatch.postMessage( { => body }, config )
 *     }
 *   }
 *
 * where the parts inside `...` depends on the options provided by the users.
 *
 */
public macro Actor(attrs: Tokens, input: Tokens): Tokens {
    GenerateActorClass.Run(attrs, input)
}

public macro Actor(input: Tokens): Tokens {
    GenerateActorClass.Run(Tokens(), input)
}
