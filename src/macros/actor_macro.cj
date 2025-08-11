macro package actors.macros

import std.ast.*
import std.collection.*

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
 * @throws MacroException for invalid options. TODO
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
 *     func foo(arg: T1 `, priority!: Int64 = default priority defined in opts2`): ActorFuture<T> { 
 *       sequentialDispatch.post<T>( { => body } `, priority: priority` )
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

class GenerateActorClass {

    static func Run(attrs: Tokens, input: Tokens): Tokens {
        GenerateActorClass(attrs, input).run()
    }

    let errors: MacroErrors
    let aOpts: MacroOptionSet
    let headDecl: Decl
    let decl: ClassDecl

    private init(attrs: Tokens, input: Tokens) {
        errors = MacroErrors()
        aOpts = MacroOptionParser.Run(attrs, errors)
        headDecl = parseDecl(input)
        decl = findDeclUnderMacro<ClassDecl>(headDecl, errors)
    }

    private func run(): Tokens {

        checkOptions()
        checkClassDecl()

        let newDecls = ArrayList<Decl>()
        processReceivers(decl.body.decls, { d => newDecls.add(d) }, { mDecl => newDecls.add(newReceiver(mDecl))})
        decl.body.decls = newDecls
        
        addDispatcherVar()

        headDecl.toTokens()
    }

    private func checkOptions(): Unit {
        aOpts.checkOptions([EnableReceiverPriority(true)], errors)
        errors.report()
    }

    private func checkClassDecl(): Unit {
        checkModifiers(decl.modifiers, [ABSTRACT, OPEN, SEALED], errors)
        errors.report()
    }

    private func addDispatcherVar(): Unit {
        let dInit = quote(
            $seqDispatcherTypeToken($enableReceiverPriorityToken: $(aOpts.hasEnabledReceiverPriority()))
        )

        decl.body.decls.add(VarDecl(quote(
            private let $dispatcherToken = $dInit
        )))
    }

    private func newReceiver(mDecl: MacroExpandDecl): Decl {
        let rOpts = MacroOptionParser.Run(mDecl.macroAttrs, errors)

        checkReceiverOptions(rOpts)

        let headDecl: Decl = parseDecl(mDecl.macroInputs)
        let fd = findDeclUnderMacro<FuncDecl>(headDecl, errors)

        checkReceiverDecl(fd)
        modifyFuncDecl(rOpts, fd)
        headDecl
    }

    private func checkReceiverOptions(rOpts: MacroOptionSet): Unit {
        if (!aOpts.hasEnabledReceiverPriority()) {
            rOpts.checkOptions([Priority(5)], errors)
        }
        errors.report()
    }

    private func checkReceiverDecl(fd: FuncDecl): Unit {
        if (aOpts.hasEnabledReceiverPriority()) {
            for (param in fd.funcParams) {
                // a named parameter named "priority"
                if (param.not.kind == TokenKind.NOT && param.identifier.value == "priority") {
                    errors.add()
                }
            }
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
        // fd.declType = actorFutureType(retTy) TODO
        fd.declType = RefType(quote(
            LocalActorFuture<$retTy>
        ))

        let retExpr = ReturnExpr(if (aOpts.hasEnabledReceiverPriority()) {
            quote(
                return $dispatcherToken.post<$retTy>({ => $(fd.block.nodes), priority: priority})
            )
        } else {
            quote(
                return $dispatcherToken.post<$retTy>({ => $(fd.block.nodes)})
            )
        })

        fd.block.nodes.clear()
        fd.block.nodes.add(retExpr)
    }
}
