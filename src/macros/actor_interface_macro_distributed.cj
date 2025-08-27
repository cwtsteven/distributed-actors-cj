macro package actors.macros

import std.ast.*
import std.collection.*

/**
 * This macro can be only defined at interfaces.
 *
 * @since 
 *
 * @throws MacroException if 
 *   1. the input is not an InterfaceDecl; or
 *   2. the InterfaceDecl has type parameters; or
 *   3. any @prefixReceiver marked function is not abstract; or
 *   4. any @prefixReceiver marked function has type parameters; or 
 *   5. any two @prefixReceiver marked function having the same identifier. 
 *
 * @throws MacroException for invalid options. TODO
 *
 * This macro essentially does the following translation:
 *
 *   @ActorInterface[distributed: true, opts1]
 *   interface Service {
 *     @prefixReceiver[opts2]
 *     func foo(arg: T1): T
 *   }
 *
 *     == translate into ==>
 *
 *   interface Service <: Distributable<Service> {
 *     func foo(arg: T1 `, priority!: Int64 = default priority defined in opts2`): ActorFuture<T>
 *      
 *     static func newProxy(name: String, actorSystem: ActorSystem): Service {
 *       ServiceProxy(ActorProxy(name, actorSystem))
 *     }
 *
 *     static func getMetadata(): Metadata { TODO }
 *
 *     static func dispatch(a: Service, info: ReceiverInfo, args: Array<DataModel>): Any { TODO }
 *   }
 *
 *   private class ServiceProxy {
 *     private let proxy = ActorProxy
 *     
 *     init(proxy: ActorProxy) { this.proxy = proxy }
 *     
 *     static let fooReceiverInfo = ReceiverInfo(...)
 *
 *     func foo(arg: T1`, priority!: Int64 = default priority defined in opts2`): ActorFuture<T> {
 *       proxy.post<T>(fooReceiverInfo, [arg1.serialzie() `, priority.serializer()`])
 *     }
 *   }
 * 
 * where the parts inside `...` depends on the options provided by the users. 
 * 
 */
class GenerateDistributedActorInterface {

    let errors: MacroErrors
    let aOpts: MacroOptionSet
    let headDecl: Decl
    let decl: InterfaceDecl

    let interfaceName: Token
    let proxyClassIdent: Token

    static func Run(aOpts: MacroOptionSet, headDecl: Decl, decl: InterfaceDecl, errors: MacroErrors) {
        GenerateDistributedActorInterface(aOpts, headDecl, decl, errors).run()
    }

    private init(aOpts: MacroOptionSet, headDecl: Decl, decl: InterfaceDecl, errors: MacroErrors) {
        this.errors = errors
        this.aOpts = aOpts
        this.headDecl = headDecl
        this.decl = decl
        this.interfaceName = decl.identifier
        this.proxyClassIdent = Token(IDENTIFIER, PREFIX + interfaceName.value)
    }

    private func run(): Tokens {
        checkOptions()
        checkInterfaceDecl()

        decl.superTypes.add(RefType(quote(
            $distributableTypeToken<$interfaceName>
        )))

        let proxyClassDecl = generateProxyClassDecl()
        let staticInit = FuncDecl(quote(
            static init() {}
        ))
        proxyClassDecl.body.decls.add(staticInit)

        let newDecls = ArrayList<Decl>()

        processReceivers(decl.body.decls, { d => newDecls.add(d) }, { mDecl => 
            let rOpts = MacroOptionParser.Run(mDecl.macroAttrs, errors)
            checkReceiverOptions(rOpts)

            let headDecl: Decl = parseDecl(mDecl.macroInputs)
            let fd = match (findDeclUnderMacro<FuncDecl>(headDecl)) {
                case Some(fd) => fd
                case None => 
                    errors.add(ReceiverMacroInvalidDecl)
                    errors.doThrow()
            }
            let retTy = fd.declType // original T 

            checkReceiverDecl(fd)
            modifyFuncDecl(rOpts, fd)
            newDecls.add(headDecl)

            let receiverInfoVarIdent = Token(IDENTIFIER, fd.identifier.value + RECEIVER_INFO_NAME)
            proxyClassDecl.body.decls.add(newReceiverInfo(receiverInfoVarIdent, fd))
            proxyClassDecl.body.decls.add(newProxyReceiver(receiverInfoVarIdent, FuncDecl(fd.toTokens()), retTy))

            let callExpr = deserializeFuncParams(fd)
            staticInit.block.nodes.add(CallExpr(quote(
                $dispatchHashMapVarToken.add($(fd.identifier.value), { a, args =>
                    a.$(fd.identifier)$(callExpr)
                })
            )))
        })

        decl.body.decls = newDecls

        decl.body.decls.add(newProxyFunc())
        decl.body.decls.add(newGetMetadataFunc())
        decl.body.decls.add(newDispatchFunc())

        headDecl.toTokens() + proxyClassDecl.toTokens()
    }

    private func checkOptions(): Unit {
        aOpts.checkOptions([EnableReceiverPriority(true), Distributed(true)], errors, ACTOR_INTERFACE_MACRO)
        errors.report()
    }

    private func checkInterfaceDecl(): Unit {
        // TODO: no type args for instance
    }

    private func newProxyFunc(): FuncDecl {
        FuncDecl(quote(
            static func newProxy(name: String, actorSystem: ActorSystem): Service {
                $proxyClassIdent($actorProxyToken(name, actorSystem))
            }
        ))
    }

    private func newGetMetadataFunc(): FuncDecl {
        FuncDecl(quote(
            static func getMetadata(): Metadata {
                // TODO
                // We need reflection to generate the type model schema
                throw Exception()
            }
        ))
    }

    private func newDispatchFunc(): FuncDecl {
        FuncDecl(quote(
            static func dispatch(a: $interfaceName, info: ReceiverInfo, args: Array<DataModel>): Any {
                $proxyClassIdent.$dispatchHashMapVarToken[info.methodName](a, args)
            }
        ))
    }

    private func generateProxyClassDecl(): ClassDecl {
        ClassDecl(quote(
            private class $proxyClassIdent <: $interfaceName {
                static let $dispatchHashMapVarToken = HashMap<String, ($interfaceName, Array<DataModel>) -> Any>()
                private let $proxyVarToken: $actorProxyToken
                init($proxyVarToken: $actorProxyToken) {
                    this.$proxyVarToken = $proxyVarToken
                }
            }
        ))
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
        // TODO: check no type args
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

    private func newReceiverInfo(receiverInfoVarIdent: Token, fd: FuncDecl): VarDecl {
        // TODO
        let paramSchema = quote([])

        VarDecl(quote(
            static let $receiverInfoVarIdent: $receiverInfoToken = $receiverInfoToken(
                $(fd.identifier.value), $paramSchema, AnyType
            )
        ))
    }

    private func newProxyReceiver(receiverInfoVarIdent: Token, fd: FuncDecl, oriTy: TypeNode): FuncDecl {
        fd.modifiers.add(Modifier(Token(PUBLIC)))

        var args = quote([)
        var i = 0
        for (fp in fd.funcParams) {
            args += quote($(fp.identifier).serialize())
            if (i < fd.funcParams.size - 1) {
                args += quote(, )
            }
        }
        args += quote(])
        
        fd.block.lBrace = Token(LCURL)
        fd.block.rBrace = Token(RCURL)
        fd.block.nodes.add(ReturnExpr(quote(
            return $proxyVarToken.post<$oriTy>($receiverInfoVarIdent, $args)
        )))
        fd
    }
}
