package actors.macros.internal

import std.ast.*
import std.collection.*

import encoding.json.*

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
        CustomInfos(JsonObject())
    ]

    static let allowedReceiverOptions: Array<MacroOption> = [
        Mode(AskAndTell),
        Description(""),
        CustomInfos(JsonObject())
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

        decl.superTypes.append(RefType(quote(
            $distributableTypeToken
        )))
        decl.superTypes.append(RefType(quote(
            $proxyableTypeToken<$interfaceName>
        )))

        let proxyClassDecl = generateProxyClassDecl()
        let staticInit = FuncDecl(quote(
            static init() {}
        ))
        proxyClassDecl.body.decls.append(staticInit)

        let newDecls = ArrayList<Decl>()

        let receiverNames = HashSet<String>()

        processReceivers(decl.body.decls, { d => newDecls.append(d) },
            { mDecl =>
                let rOpts = MacroOptionParser.Run(mDecl.macroAttrs, errors)
                checkReceiverOptions(rOpts)

                createReceiverInfo(mDecl, rOpts, proxyClassDecl, staticInit, receiverNames)

                if (rOpts.shouldAsk()) {
                    newDecls.append(newReceiver(mDecl, rOpts, behaviour: Ask))
                    newDecls.append(newDefaultReceiver(mDecl, rOpts, behaviour: Ask))
                    proxyClassDecl.body.decls.append(newProxyReceiver(mDecl, rOpts, behaviour: Ask))
                }
                if (rOpts.shouldTell()) {
                    newDecls.append(newReceiver(mDecl, rOpts, behaviour: Tell))
                    newDecls.append(newDefaultReceiver(mDecl, rOpts, behaviour: Tell))
                    proxyClassDecl.body.decls.append(newProxyReceiver(mDecl, rOpts, behaviour: Tell))
                }
            })

        decl.body.decls = newDecls

        decl.body.decls.append(newGetMetadataFunc())
        decl.body.decls.append(newDispatchTellFunc())
        decl.body.decls.append(newDispatchAskFunc())
        decl.body.decls.append(getProxyFunc())

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
        receiverNames.put(fd.identifier.value)

        checkReceiverDecl(fd)

        let receiverInfoVarIdent = Token(IDENTIFIER, fd.identifier.value + RECEIVER_INFO_NAME)
        match (newReceiverInfo(receiverInfoVarIdent, rOpts, fd, fd.declType, errors)) {
            case Some(varDecl) => proxyClassDecl.body.decls.append(varDecl)
            case None => ()
        }

        if (rOpts.shouldTell()) {
            let callExpr = deserializeFuncParams(fd, true)
            staticInit.block.nodes.append(CallExpr(quote(
                $dispatchTellHashMapVarToken.put($(fd.identifier.value), { a, args, config =>
                    a.$(fd.identifier)$(callExpr)
                })
            )))
        }

        if (rOpts.shouldAsk()) {
            let callExpr = deserializeFuncParams(fd, false)
            staticInit.block.nodes.append(CallExpr(quote(
                $dispatchAskHashMapVarToken.put($(fd.identifier.value), { a, args, config =>
                    a.$(fd.identifier)$(callExpr)
                })
            )))
        }
        // Add receiver info to the static receivers array
        staticInit.block.nodes.append(CallExpr(quote(
            $receiverInfosArrayVarToken.append($receiverInfoVarIdent)
        )))
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

        let modeToken = Token(IDENTIFIER, rOpts.getMode().toString())
        Some(VarDecl(quote(
            static let $receiverInfoVarIdent: $receiverInfoToken = $receiverInfoToken(
                description: $(description),
                customInfo: JsonObject.fromStr($(customInfo.toString())).asObject(),
                methodName: $(fd.identifier.value),
                paramSchema: $paramSchema,
                retTypeModel: $retTypeModel,
                mode: $modeToken
            )
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

    private func newDefaultReceiver(mDecl: MacroExpandDecl, rOpts: MacroOptionSet, behaviour!: Behaviour): Decl {
        let headDecl: Decl = parseDecl(mDecl.macroInputs)
        let fd = match (findDeclUnderMacro<FuncDecl>(headDecl)) {
            case Some(fd) => fd
            case None =>
                errors.add(ReceiverMacroInvalidDecl)
                errors.doThrow()
        }

        modifyDefaultFuncDecl(rOpts, fd, behaviour)
        headDecl
    }

    private func newGetMetadataFunc(): FuncDecl {
        let desc = aOpts.getDescription()
        let customInfo = aOpts.getCustomInfos()
        FuncDecl(quote(
            func getMetadata(): Metadata {
                Metadata(
                    receivers: $proxyClassIdent.$receiverInfosArrayVarToken.toArray(),
                    description: $desc,
                    customInfo: JsonObject.fromStr($(customInfo.toString())).asObject()
                )
            }
        ))
    }

    private func newDispatchTellFunc(): FuncDecl {
        FuncDecl(quote(
            func dispatchTell(receiverName: String, args: Array<DataModel>, config: ReceiverConfig): Unit {
                match ($proxyClassIdent.$dispatchTellHashMapVarToken.get(receiverName)) {
                    case Some(f) => f(this, args, config)
                    case None => throw ReceiverNotFoundException($(interfaceName.value), receiverName)
                }
            }
        ))
    }

    private func newDispatchAskFunc(): FuncDecl {
        FuncDecl(quote(
            func dispatchAsk(receiverName: String, args: Array<DataModel>, config: ReceiverConfig): LocalWaitable {
                match ($proxyClassIdent.$dispatchAskHashMapVarToken.get(receiverName)) {
                    case Some(f) => f(this, args, config)
                    case None => throw ReceiverNotFoundException($(interfaceName.value), receiverName)
                }
            }
        ))
    }

    private func getProxyFunc(): FuncDecl {
        FuncDecl(quote(
            static func getProxy(name: String, client: ActorClient): $interfaceName {
                $proxyClassIdent(name, client)
            }
        ))
    }

    private func generateProxyClassDecl(): ClassDecl {
        ClassDecl(quote(
            private class $proxyClassIdent <: ActorProxy & $interfaceName {
                static let $dispatchTellHashMapVarToken = HashMap<String, ($interfaceName, Array<DataModel>, ReceiverConfig) -> Unit>()
                static let $dispatchAskHashMapVarToken = HashMap<String, ($interfaceName, Array<DataModel>, ReceiverConfig) -> LocalWaitable>()
                static let $receiverInfosArrayVarToken = ArrayList<ReceiverInfo>()

                public init(name: String, client: ActorClient) {
                    super(name, client)
                }
            }
        ))
    }

    private func newProxyReceiver(mDecl: MacroExpandDecl, rOpts: MacroOptionSet, behaviour!: Behaviour): Decl {
        let headDecl: Decl = parseDecl(mDecl.macroInputs)
        let fd = match (findDeclUnderMacro<FuncDecl>(headDecl)) {
            case Some(fd) => fd
            case None =>
                errors.add(ReceiverMacroInvalidDecl)
                errors.doThrow()
        }

        modifyProxyFuncDecl(rOpts, fd, behaviour)
        headDecl
    }

    private func modifyProxyFuncDecl(rOpts: MacroOptionSet, fd: FuncDecl, behaviour: Behaviour): Unit {
        var args = quote([)
        for (i in 0..fd.funcParams.size) {
            let fp = fd.funcParams[i]
            args += quote($(fp.identifier).serialize())
            if (i < fd.funcParams.size - 1) {
                args += quote(, )
            }
        }
        args += quote(])

        let defaultPriority = rOpts.getPriority()
        fd.funcParams.append(FuncParam(quote(
            config!: ReceiverConfig = ReceiverConfig(priority: $defaultPriority)
        )))

        if (let Tell <- behaviour) {
            // Add the `tell` parameter
            fd.funcParams.append(FuncParam(quote(
                tell!: $tellTypeToken
            )))
        }

        let declaredType = fd.declType

        fd.declType = match (behaviour) {
            case Ask => RefType(quote(ActorFuture<$declaredType>))
            case Tell => PrimitiveType(quote(Unit))
        }

        fd.modifiers.append(Modifier(Token(PUBLIC)))
        fd.block = Block()
        fd.block.lBrace = Token(LCURL)
        fd.block.rBrace = Token(RCURL)

        match (behaviour) {
            case Ask =>
                fd.block.nodes.append(CallExpr(quote(
                    this.ask($(fd.identifier.value), $args, config: config).toActorFuture<$declaredType>()
                )))
            case Tell =>
                let discardTellParam = VarDecl(quote(let dummy = tell))
                // For some reason VarDecl parses "let _ = tell" as "let = tell"
                // so we add the wildcard manually instead
                discardTellParam.identifier = Token(WILDCARD)
                fd.block.nodes.append(discardTellParam)
                fd.block.nodes.append(CallExpr(quote(
                    this.tell($(fd.identifier.value), $args, config: config)
                )))
        }
    }

    private func modifyFuncDecl(_: MacroOptionSet, fd: FuncDecl, behaviour: Behaviour): Unit {
        fd.funcParams.append(FuncParam(quote(
            config!: ReceiverConfig
        )))

        if (let Tell <- behaviour) {
            // Add the `tell` parameter
            fd.funcParams.append(FuncParam(quote(
                tell!: $tellTypeToken
            )))
        }

        fd.declType = match (behaviour) {
            case Ask => RefType(quote(ActorFuture<$(fd.declType)>))
            case Tell => PrimitiveType(quote(Unit))
        }
    }

    private func modifyDefaultFuncDecl(rOpts: MacroOptionSet, fd: FuncDecl, behaviour: Behaviour): Unit {
        var args = generateParamList(fd)

        if (let Tell <- behaviour) {
            // Add the `tell` parameter
            fd.funcParams.append(FuncParam(quote(
                tell!: $tellTypeToken
            )))
        }

        let declaredType = fd.declType

        fd.declType = match (behaviour) {
            case Ask => RefType(quote(ActorFuture<$declaredType>))
            case Tell => PrimitiveType(quote(Unit))
        }

        fd.block = Block()
        fd.block.lBrace = Token(LCURL)
        fd.block.rBrace = Token(RCURL)

        args += if (args.size > 0) {
            quote(, config: ReceiverConfig.default)
        } else {
            quote(config: ReceiverConfig.default)
        }

        match (behaviour) {
            case Ask =>
                fd.block.nodes.append(CallExpr(quote(
                    ($(fd.identifier)($args) as ActorFuture<$declaredType>).getOrThrow()
                )))
            case Tell =>
                fd.block.nodes.append(CallExpr(quote(
                    $(fd.identifier)($args, tell: tell)
                )))
        }
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
        schema += quote(ReceiverParameter(name: $(fp.identifier.value), typeModel: $paramTypeModel, description: $(fp.identifier.value)))
        if (i < fd.funcParams.size - 1) {
            schema += quote(, )
        }
    }
    schema += quote(])
    schema
}

private func getTypeModel(typeNode: TypeNode): Tokens {
    match (typeNode) {
        case ty: RefType =>
            let typeName = getTypeName(ty)
            quote($(Token(IDENTIFIER, typeName)).typeModel())
        case ty: PrimitiveType =>
            let typeName = getTypeName(ty)
            quote($(Token(IDENTIFIER, typeName)).typeModel())
        case _ => throw Exception("Unsupported type")
    }
}

private func getTypeName(ty: TypeNode): String {
    match (ty) {
        case ty: RefType =>
            var typeName = ty.identifier.value
            if (ty.typeArguments.size > 0) {
                typeName += "<"
            }
            for (i in 0..ty.typeArguments.size) {
                typeName += getTypeName(ty.typeArguments[i])
                if (i < ty.typeArguments.size - 1) {
                    typeName += ", "
                }
            }
            if (ty.typeArguments.size > 0) {
                typeName += ">"
            }
            typeName
        case ty: PrimitiveType => ty.keyword.value
        case _ => throw Exception("Unsupported type")
    }
}