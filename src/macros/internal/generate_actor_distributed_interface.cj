package actors.macros.internal

import std.ast.*
import std.collection.*

import stdx.encoding.json.*

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
 * @throws MacroException for invalid options.
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
protected class GenerateDistributedActorInterface {

    let errors: MacroErrors
    let aOpts: MacroOptionSet
    let headDecl: Decl
    let decl: InterfaceDecl

    let interfaceName: Token
    let proxyClassIdent: Token

    static let allowedOptions: Array<MacroOption> = [
        EnableReceiverPriority(true),
        Distributed(true),
        Description(""),
        CustomInfos(JsonValue.fromStr("{}"))
    ]

    static let allowedReceiverOptions: Array<MacroOption> = [
        Priority(5),
        // Mode(AskAndTell),
        Description(""),
        CustomInfos(JsonValue.fromStr("{}"))
    ]

    protected static func Run(aOpts: MacroOptionSet, headDecl: Decl, decl: InterfaceDecl, errors: MacroErrors) {
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

        // Add static receivers array field
        let receiversField = VarDecl(quote(
            static let $receiverInfosArrayVarToken = ArrayList<ReceiverInfo>()
        ))
        proxyClassDecl.body.decls.add(receiversField)

        let newDecls = ArrayList<Decl>()

        processReceivers(decl.body.decls, { d => newDecls.add(d) },
            { mDecl =>
                let rOpts = MacroOptionParser.Run(mDecl.macroAttrs, errors)
                checkReceiverOptions(rOpts)

                if (rOpts.shouldAsk()) {
                    newDecls.add(newReceiver(mDecl, rOpts, proxyClassDecl, staticInit, behaviour: Ask))
                }
                // if (rOpts.shouldTell()) {
                //     newDecls.add(newReceiver(mDecl, rOpts, proxyClassDecl, staticInit, behaviour: Tell))
                // }
            })

        decl.body.decls = newDecls

        decl.body.decls.add(newProxyFunc())
        decl.body.decls.add(newGetMetadataFunc())
        decl.body.decls.add(newDispatchFunc())

        headDecl.toTokens() + proxyClassDecl.toTokens()
    }

    private func checkOptions(): Unit {
        aOpts.checkOptions(allowedOptions, errors, ACTOR_DISTRIBUTED_INTERFACE_MACRO)
        errors.report()
    }

    private func checkInterfaceDecl(): Unit {
        // Check that the interface has no type parameters
        if (decl.isGenericDecl) {
            errors.add(ActorInterfaceMacroInvalidDecl)
            errors.doThrow()
        }
    }

    private func checkReceiverOptions(rOpts: MacroOptionSet): Unit {
        rOpts.checkOptions(allowedReceiverOptions, errors, ACTOR_DISTRIBUTED_INTERFACE_MACRO)
        errors.report()
    }

    private func newReceiver(mDecl: MacroExpandDecl, rOpts: MacroOptionSet, proxyClassDecl: ClassDecl, staticInit: FuncDecl, behaviour!: Behaviour): Decl {
        let headDecl: Decl = parseDecl(mDecl.macroInputs)
        let fd = match (findDeclUnderMacro<FuncDecl>(headDecl)) {
            case Some(fd) => fd
            case None =>
                errors.add(ReceiverMacroInvalidDecl)
                errors.doThrow()
        }
        let retTy = fd.declType // original T

        checkReceiverDecl(fd)
        modifyFuncDecl(rOpts, fd, behaviour)

        let receiverInfoVarIdent = Token(IDENTIFIER, fd.identifier.value + RECEIVER_INFO_NAME)
        match (newReceiverInfo(receiverInfoVarIdent, rOpts, fd, retTy, errors)) {
            case Some(varDecl) => proxyClassDecl.body.decls.add(varDecl)
            case None => ()
        }
        proxyClassDecl.body.decls.add(newProxyReceiver(receiverInfoVarIdent, FuncDecl(fd.toTokens()), retTy))

        let callExpr = deserializeFuncParams(fd)
        staticInit.block.nodes.add(CallExpr(quote(
            $dispatchHashMapVarToken.add($(fd.identifier.value), { a, args =>
                a.$(fd.identifier)$(callExpr)
            })
        )))

        // Add receiver info to the static receivers array
        staticInit.block.nodes.add(CallExpr(quote(
            $receiverInfosArrayVarToken.add($receiverInfoVarIdent)
        )))
        headDecl
    }
    private func newProxyFunc(): FuncDecl {
        FuncDecl(quote(
            static func newProxy(name: String, actorSystem: ActorSystem): $interfaceName {
                $proxyClassIdent($actorProxyToken(name, actorSystem))
            }
        ))
    }

    private func newGetMetadataFunc(): FuncDecl {
        let desc = aOpts.getDescription()
        let customInfo = aOpts.getCustomInfos()
        FuncDecl(quote(
            static func getMetadata(): Metadata {
                Metadata($proxyClassIdent.$receiverInfosArrayVarToken.toArray(), $desc, JsonValue.fromStr($(customInfo.toString())))
            }
        ))
    }

    private func newDispatchFunc(): FuncDecl {
        FuncDecl(quote(
            static func dispatch(a: $interfaceName, receiverName: String, args: Array<DataModel>): Any {
                $proxyClassIdent.$dispatchHashMapVarToken[receiverName](a, args)
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
        // Check that the function has no type parameters
        if (fd.isGenericDecl) {
            errors.add(ReceiverMacroInvalidDecl)
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

    private func newReceiverInfo(receiverInfoVarIdent: Token, rOpts: MacroOptionSet, fd: FuncDecl, retTy: TypeNode, errors: MacroErrors): ?VarDecl {
        let description = rOpts.getDescription()
        let customInfo = rOpts.getCustomInfos()
        let paramSchema = try {
            buildParamSchema(fd)
        } catch (_: Exception) {
            // Add error for unsupported type and return empty parameter schema
            errors.add(MacroReceiverInfoUnsupportedType)
            errors.doThrow()
        }
        let retTypeModel = try {
            getTypeModel(retTy)
        } catch (_: Exception) {
            // Add error for unsupported type and return empty parameter schema
            errors.add(MacroReceiverInfoUnsupportedType)
            errors.doThrow()
        }

        Some(VarDecl(quote(
            static let $receiverInfoVarIdent: $receiverInfoToken = $receiverInfoToken(
                $(description), JsonValue.fromStr($(customInfo.toString())), $(fd.identifier.value), $paramSchema, $retTypeModel
            )
        )))
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
            i += 1
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

private func buildParamSchema(fd: FuncDecl): Tokens {
    if (fd.funcParams.size == 0) {
        return quote([])
    }

    var schema = quote([)
    for (i in 0..fd.funcParams.size) {
        let fp = fd.funcParams[i]
        let paramTypeModel = getTypeModel(fp.paramType)
        schema += quote(($(fp.identifier.value), $paramTypeModel))
        if (i < fd.funcParams.size - 1) {
            schema += quote(, )
        }
    }
    schema += quote(])
    schema
}

private func getTypeModel(typeNode: TypeNode): Tokens {
    match (typeNode) {
        case ty: RefType => getTypeModelByName(ty.identifier.value)
        case ty: PrimitiveType => getTypeModelByName(ty.keyword.value)
        case _ => throw Exception("Unsupported type")
    }
}

private func getTypeModelByName(typeName: String): Tokens {
    match (typeName) {
        case "Int64" => quote(IntType)
        case "String" => quote(StringType)
        case "Bool" => quote(BoolType)
        case "Unit" => quote(UnitType)
        case "Tell" => quote(UnitType)
        case _ => throw Exception("Unsupported type: ${typeName}")
    }
}