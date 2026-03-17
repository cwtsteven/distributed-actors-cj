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

        decl.superTypes.add(RefType(quote(
            $distributableTypeToken
        )))
        decl.superTypes.add(RefType(quote(
            $proxyableTypeToken<$interfaceName>
        )))
        decl.superTypes.add(RefType(quote(
            $serializableTypeToken<$interfaceName>
        )))
        decl.superTypes.add(RefType(quote(
            $typeSerializableTypeToken
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
                    newDecls.add(newDefaultReceiver(mDecl, rOpts, behaviour: Ask))
                    proxyClassDecl.body.decls.add(newProxyReceiver(mDecl, rOpts, behaviour: Ask))
                }
                if (rOpts.shouldTell()) {
                    newDecls.add(newReceiver(mDecl, rOpts, behaviour: Tell))
                    newDecls.add(newDefaultReceiver(mDecl, rOpts, behaviour: Tell))
                    proxyClassDecl.body.decls.add(newProxyReceiver(mDecl, rOpts, behaviour: Tell))
                }
            })

        decl.body.decls = newDecls

        decl.body.decls.add(newGetMetadataFunc())
        decl.body.decls.add(newDispatchTellFunc())
        decl.body.decls.add(newDispatchAskFunc())
        decl.body.decls.add(getProxyFunc())
        decl.body.decls.add(getProxyFromActorProxyFunc())
        decl.body.decls.add(newSerializeFunc())
        decl.body.decls.add(newDeserializeFunc())
        decl.body.decls.add(newTypeModelFunc())

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
        let allowedReceiverOptions = ArrayList<MacroOption>([
            Mode(AskAndTell),
            Description(""),
            CustomInfos(JsonObject())
        ])
        if (aOpts.hasEnabledReceiverPriority()) {
            allowedReceiverOptions.add(Priority(5))
        }
        rOpts.checkOptions(allowedReceiverOptions.toArray(), errors, ACTOR_DISTRIBUTED_INTERFACE_MACRO)
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
            // let argsToken = if (fd.funcParams.size > 0) { quote(args) } else { Tokens([Token(WILDCARD)]) }
            staticInit.block.nodes.add(CallExpr(quote(
                $dispatchTellHashMapVarToken.add($(fd.identifier.value), { a, args, config =>
                    if (args.size != $(fd.funcParams.size)) {
                        throw IllegalArgumentException("Number of arguments (args.size) not equal to expected number of parameters ($(fd.funcParams.size)) for receiver $(fd.identifier.value)")
                    }
                    try {
                        a.$(fd.identifier)$(callExpr)
                    } catch (e: DataModelException) {
                        throw IllegalArgumentException("Error deserializing arguments for receiver $(fd.identifier.value): " + e.message)
                    }
                })
            )))
        }

        if (rOpts.shouldAsk()) {
            let callExpr = deserializeFuncParams(fd, false)
            // let argsToken = if (fd.funcParams.size > 0) { quote(args) } else { Tokens([Token(WILDCARD)]) }
            staticInit.block.nodes.add(CallExpr(quote(
                $dispatchAskHashMapVarToken.add($(fd.identifier.value), { a, args, config =>
                    if (args.size != $(fd.funcParams.size)) {
                        throw IllegalArgumentException("Number of arguments (args.size) not equal to expected number of parameters ($(fd.funcParams.size)) for receiver $(fd.identifier.value)")
                    }
                    try {
                        serializeActorFutureResult(a.$(fd.identifier)$(callExpr))
                    } catch (e: DataModelException) {
                        throw IllegalArgumentException("Error deserializing arguments for receiver $(fd.identifier.value): " + e.message)
                    }
                })
            )))
        }
        // Add receiver info to the static receivers array
        staticInit.block.nodes.add(CallExpr(quote(
            $receiverInfosArrayVarToken.add($receiverInfoVarIdent)
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
            func dispatchAsk(receiverName: String, args: Array<DataModel>, config: ReceiverConfig): ActorFuture<DataModel> {
                match ($proxyClassIdent.$dispatchAskHashMapVarToken.get(receiverName)) {
                    case Some(f) => f(this, args, config)
                    case None => throw ReceiverNotFoundException($(interfaceName.value), receiverName)
                }
            }
        ))
    }

    private func getProxyFunc(): FuncDecl {
        FuncDecl(quote(
            static func getProxy(name: String, info: HostInfo): $interfaceName {
                $proxyClassIdent(name, info)
            }
        ))
    }

    private func getProxyFromActorProxyFunc(): FuncDecl {
        FuncDecl(quote(
            static func getProxy(proxy: ActorProxy): $interfaceName {
                $proxyClassIdent(proxy.actorName, proxy.hostInfo)
            }
        ))
    }

    private func newSerializeFunc(): FuncDecl {
        FuncDecl(quote(
            func serialize(): DataModel {
                // TODO
                throw Exception("Serialization not supported for actor interface.")
            }
        ))
    }

    private func newDeserializeFunc(): FuncDecl {
        FuncDecl(quote(
            static func deserialize(dataModel: DataModel): $interfaceName {
                $proxyClassIdent.deserialize(dataModel)
            }
        ))
    }

    private func newTypeModelFunc(): FuncDecl {
        FuncDecl(quote(
            static func typeModel(): TypeModel {
                $proxyClassIdent.typeModel()
            }
        ))
    }

    private func generateProxyClassDecl(): ClassDecl {
        ClassDecl(quote(
            private class $proxyClassIdent <: $interfaceName {
                static let $dispatchTellHashMapVarToken = HashMap<String, ($interfaceName, Array<DataModel>, ReceiverConfig) -> Unit>()
                static let $dispatchAskHashMapVarToken = HashMap<String, ($interfaceName, Array<DataModel>, ReceiverConfig) -> ActorFuture<DataModel>>()
                static let $receiverInfosArrayVarToken = ArrayList<ReceiverInfo>()

                private let actorName: String
                private let hostInfo: HostInfo

                public init(actorName: String, hostInfo: HostInfo) {
                    this.actorName = actorName
                    this.hostInfo = hostInfo
                }

                public func serialize(): DataModel {
                    ActorProxy(actorName, hostInfo).serialize()
                }

                public static func deserialize(dataModel: DataModel): $interfaceName {
                    let proxy = ActorProxy.deserialize(dataModel)
                    $proxyClassIdent(proxy.actorName, proxy.hostInfo)
                }

                public static func typeModel(): TypeModel {
                    TypeModel.StructType([
                        FieldModel(name: "proxy", description: "ActorProxy", typeModel: ActorProxy.typeModel())
                    ])
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
        fd.funcParams.add(FuncParam(quote(
            config!: ReceiverConfig = ReceiverConfig(priority: $defaultPriority)
        )))

        if (let Tell <- behaviour) {
            // Add the `tell` parameter
            fd.funcParams.add(FuncParam(quote(
                tell!: $tellTypeToken
            )))
        }

        let declaredType = fd.declType

        fd.declType = match (behaviour) {
            case Ask => RefType(quote(ActorFuture<$declaredType>))
            case Tell => PrimitiveType(quote(Unit))
        }

        fd.modifiers.add(Modifier(Token(PUBLIC)))
        fd.block = Block()
        fd.block.lBrace = Token(LCURL)
        fd.block.rBrace = Token(RCURL)

        match (behaviour) {
            case Ask =>
                fd.block.nodes.add(CallExpr(quote(
                    deserializeActorFutureResult<$declaredType>(ActorProxy(actorName, hostInfo).ask($(fd.identifier.value), $args, config: config))
                )))
            case Tell =>
                let discardTellParam = VarDecl(quote(let dummy = tell))
                // For some reason VarDecl parses "let _ = tell" as "let = tell"
                // so we add the wildcard manually instead
                discardTellParam.identifier = Token(WILDCARD)
                fd.block.nodes.add(discardTellParam)
                fd.block.nodes.add(CallExpr(quote(
                    ActorProxy(actorName, hostInfo).tell($(fd.identifier.value), $args, config: config)
                )))
        }
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

        fd.declType = match (behaviour) {
            case Ask => RefType(quote(ActorFuture<$(fd.declType)>))
            case Tell => PrimitiveType(quote(Unit))
        }
    }

    private func modifyDefaultFuncDecl(rOpts: MacroOptionSet, fd: FuncDecl, behaviour: Behaviour): Unit {
        var args = generateParamList(fd)
        let defaultPriority = rOpts.getPriority()

        if (let Tell <- behaviour) {
            // Add the `tell` parameter
            fd.funcParams.add(FuncParam(quote(
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
            quote(, config: ReceiverConfig(priority: $defaultPriority))
        } else {
            quote(config: ReceiverConfig(priority: $defaultPriority))
        }

        match (behaviour) {
            case Ask =>
                fd.block.nodes.add(CallExpr(quote(
                    ($(fd.identifier)($args) as ActorFuture<$declaredType>).getOrThrow()
                )))
            case Tell =>
                fd.block.nodes.add(CallExpr(quote(
                    $(fd.identifier)($args, tell: tell)
                )))
        }
    }

    // private func generateExtendTypedProxyDecl(): ExtendDecl {
    //     ExtendDecl(quote(
    //         extend TypedProxy<$interfaceName> {
    //             public static func deserialize(dataModel: DataModel): TypedProxy<$interfaceName> {
    //                 $proxyClassIdent.deserialize(dataModel)
    //             }

    //             public static func typeModel(): TypeModel {
    //                 $proxyClassIdent.typeModel()
    //             }
    //         }
    //     ))
    // }

    // private func newExtendTypedProxyReceiver(mDecl: MacroExpandDecl, rOpts: MacroOptionSet, behaviour!: Behaviour): Decl {
    //     let headDecl: Decl = parseDecl(mDecl.macroInputs)
    //     let fd = match (findDeclUnderMacro<FuncDecl>(headDecl)) {
    //         case Some(fd) => fd
    //         case None =>
    //             errors.add(ReceiverMacroInvalidDecl)
    //             errors.doThrow()
    //     }

    //     modifyExtendTypedProxyFuncDecl(rOpts, fd, behaviour)
    //     headDecl
    // }

    // private func modifyExtendTypedProxyFuncDecl(rOpts: MacroOptionSet, fd: FuncDecl, behaviour: Behaviour): Unit {
    //     var args = quote([)
    //     for (i in 0..fd.funcParams.size) {
    //         let fp = fd.funcParams[i]
    //         args += quote($(fp.identifier).serialize())
    //         if (i < fd.funcParams.size - 1) {
    //             args += quote(, )
    //         }
    //     }
    //     args += quote(])

    //     let defaultPriority = rOpts.getPriority()
    //     fd.funcParams.add(FuncParam(quote(
    //         config!: ReceiverConfig = ReceiverConfig(priority: $defaultPriority)
    //     )))

    //     if (let Tell <- behaviour) {
    //         // Add the `tell` parameter
    //         fd.funcParams.add(FuncParam(quote(
    //             tell!: $tellTypeToken
    //         )))
    //     }

    //     let declaredType = fd.declType

    //     fd.declType = match (behaviour) {
    //         case Ask => RefType(quote(ActorFuture<$declaredType>))
    //         case Tell => PrimitiveType(quote(Unit))
    //     }

    //     fd.modifiers.add(Modifier(Token(PUBLIC)))
    //     fd.block = Block()
    //     fd.block.lBrace = Token(LCURL)
    //     fd.block.rBrace = Token(RCURL)

    //     match (behaviour) {
    //         case Ask =>
    //             fd.block.nodes.add(CallExpr(quote(
    //                 (this as $proxyClassIdent).getOrThrow().$(fd.identifier)($args, config: config)
    //             )))
    //         case Tell =>
    //             fd.block.nodes.add(CallExpr(quote(
    //                 (this as $proxyClassIdent).getOrThrow().$(fd.identifier)($args, config: config, tell: tell)
    //             )))
    //     }
    // }
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
