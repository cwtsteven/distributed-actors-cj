package actors.macros.internal

import std.ast.*
import std.collection.*

import stdx.encoding.json.*

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
        CustomInfos((JsonValue.fromStr("{}") as JsonObject).getOrThrow())
    ]

    static let allowedReceiverOptions: Array<MacroOption> = [
        Mode(AskAndTell),
        Description(""),
        CustomInfos((JsonValue.fromStr("{}") as JsonObject).getOrThrow())
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
            $distributableTypeToken
        )))

        let proxyClassDecl = generateProxyClassDecl()
        let staticInit = FuncDecl(quote(
            static init() {}
        ))
        proxyClassDecl.body.decls.add(staticInit)

        let newDecls = ArrayList<Decl>()

        let receiverNames = HashSet<String>()

        processReceivers(decl.body.decls, { d => newDecls.add(d) },
            { mDecl =>
                let rOpts = MacroOptionParser.Run(mDecl.macroAttrs, errors)
                checkReceiverOptions(rOpts)

                createReceiverInfo(mDecl, rOpts, proxyClassDecl, staticInit, receiverNames)

                if (rOpts.shouldAsk()) {
                    newDecls.add(newReceiver(mDecl, rOpts, behaviour: Ask))
                }
                if (rOpts.shouldTell()) {
                    newDecls.add(newReceiver(mDecl, rOpts, behaviour: Tell))
                }
            })

        decl.body.decls = newDecls

        decl.body.decls.add(newGetMetadataFunc())
        decl.body.decls.add(newDispatchTellFunc())
        decl.body.decls.add(newDispatchAskFunc())

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

    private func createReceiverInfo(mDecl: MacroExpandDecl, rOpts: MacroOptionSet, proxyClassDecl: ClassDecl, staticInit: FuncDecl, receiverNames: HashSet<String>): Unit {
        let headDecl: Decl = parseDecl(mDecl.macroInputs)
        let fd = match (findDeclUnderMacro<FuncDecl>(headDecl)) {
            case Some(fd) => fd
            case None =>
                errors.add(ReceiverMacroInvalidDecl)
                errors.doThrow()
        }

        if (receiverNames.contains(fd.identifier.value)) {
            errors.add(ReceiverMacroDuplicateIdentifier(fd.identifier.value))
            errors.doThrow()
        }
        receiverNames.add(fd.identifier.value)

        checkReceiverDecl(fd)

        let receiverInfoVarIdent = Token(IDENTIFIER, fd.identifier.value + RECEIVER_INFO_NAME)
        match (newReceiverInfo(receiverInfoVarIdent, rOpts, fd, fd.declType, errors)) {
            case Some(varDecl) => proxyClassDecl.body.decls.add(varDecl)
            case None => ()
        }

        if (rOpts.shouldTell()) {
            let callExpr = deserializeFuncParams(fd, true)
            staticInit.block.nodes.add(CallExpr(quote(
                $dispatchTellHashMapVarToken.add($(fd.identifier.value), { a, args, config =>
                    a.$(fd.identifier)$(callExpr)
                })
            )))
        }

        if (rOpts.shouldAsk()) {
            let callExpr = deserializeFuncParams(fd, false)
            staticInit.block.nodes.add(CallExpr(quote(
                $dispatchAskHashMapVarToken.add($(fd.identifier.value), { a, args, config =>
                    a.$(fd.identifier)$(callExpr)
                })
            )))
        }
        // Add receiver info to the static receivers array
        staticInit.block.nodes.add(CallExpr(quote(
            $receiverInfosArrayVarToken.add($receiverInfoVarIdent)
        )))
    }

    private func newReceiver(mDecl: MacroExpandDecl, rOpts: MacroOptionSet, behaviour!: Behaviour): Decl {
        let headDecl: Decl = parseDecl(mDecl.macroInputs)
        let fd = match (findDeclUnderMacro<FuncDecl>(headDecl)) {
            case Some(fd) => fd
            case None =>
                errors.add(ReceiverMacroInvalidDecl)
                errors.doThrow()
        }

        modifyFuncDecl(rOpts, fd, behaviour)
        headDecl
    }

    private func newGetMetadataFunc(): FuncDecl {
        let desc = aOpts.getDescription()
        let customInfo = aOpts.getCustomInfos()
        FuncDecl(quote(
            static func getMetadata(): Metadata {
                Metadata($proxyClassIdent.$receiverInfosArrayVarToken.toArray(), $desc, (JsonValue.fromStr($(customInfo.toString())) as JsonObject).getOrThrow())
            }
        ))
    }

    private func newDispatchTellFunc(): FuncDecl {
        FuncDecl(quote(
            func dispatchTell(receiverName: String, args: Array<DataModel>, config: ReceiverConfig): Unit {
                $proxyClassIdent.$dispatchTellHashMapVarToken[receiverName](this, args, config)
            }
        ))
    }

    private func newDispatchAskFunc(): FuncDecl {
        FuncDecl(quote(
            func dispatchAsk(receiverName: String, args: Array<DataModel>, config: ReceiverConfig): Waitable {
                $proxyClassIdent.$dispatchAskHashMapVarToken[receiverName](this, args, config)
            }
        ))
    }

    private func generateProxyClassDecl(): ClassDecl {
        ClassDecl(quote(
            private class $proxyClassIdent {
                static let $dispatchTellHashMapVarToken = HashMap<String, ($interfaceName, Array<DataModel>, ReceiverConfig) -> Unit>()
                static let $dispatchAskHashMapVarToken = HashMap<String, ($interfaceName, Array<DataModel>, ReceiverConfig) -> Waitable>()
                static let $receiverInfosArrayVarToken = ArrayList<ReceiverInfo>()
            }
        ))
    }

    private func checkReceiverDecl(fd: FuncDecl): Unit {
        if (fd.block.nodes.size != 0) {
            errors.add(ReceiverMacroInsideActorInterface)
        }
        // Check that the function has no type parameters
        if (fd.isGenericDecl) {
            errors.add(ReceiverMacroInvalidDecl)
        }

        errors.report()
    }

    private func modifyFuncDecl(_: MacroOptionSet, fd: FuncDecl, behaviour: Behaviour): Unit {
        fd.funcParams.add(FuncParam(quote(
            config!: ReceiverConfig
        )))

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
                $(description), (JsonValue.fromStr($(customInfo.toString())) as JsonObject).getOrThrow(), $(fd.identifier.value), $paramSchema, $retTypeModel
            )
        )))
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
        case "Float64" => quote(FloatType)
        case "Bool" => quote(BoolType)
        case "String" => quote(StringType)
        case "Unit" => quote(UnitType)
        case _ => throw Exception("Unsupported type: ${typeName}")
    }
}