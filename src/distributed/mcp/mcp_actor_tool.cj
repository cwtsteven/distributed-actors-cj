package actors.distributed.mcp

import std.collection.*

import actors.*
import actors.distributed.*

import serialization.serialization.*

import magic.core.tool.*
import magic.mcp.*
import magic.jsonable.*

const SEPARATOR = ";__actors_08275892475824__;"

let receiverConfigTypeModel =
    TypeModel.StructType([
        FieldModel(name: "priority", typeModel: TypeModel.IntType)
    ])

let receiverConfigTypeSchema =
    TypeSchema.Obj([
        FieldSchema("priority", "The priority of the receiver call", TypeSchema.Int)
    ])

public class ReceiverTool <: Tool {

    private let __name: String
    private let __description: String
    private let __parameters: Array<ToolParameter>
    private let __retType: TypeSchema
    private let __examples: Array<String>
    private let __extra: HashMap<String, String>
    private let __client: ActorClient
    private let __info: ReceiverInfo

    public init(
        name!: String,
        description!: String,
        parameters!: Array<ToolParameter>,
        retType!: TypeSchema,
        examples!: Array<String>,
        extra!: HashMap<String, String>,
        client!: ActorClient,
        info!: ReceiverInfo
    ) {
        __name = name
        __description = description
        __parameters = parameters
        __retType = retType
        __examples = examples
        __extra = extra
        __client = client
        __info = info
    }

    public prop name: String { get() { __name } }
    public prop description: String { get() { __description } }
    public prop parameters: Array<ToolParameter> { get() { __parameters } }
    public prop retType: TypeSchema { get() { __retType } }
    public prop examples: Array<String> { get() { __examples } }
    public prop extra: HashMap<String, String> { get() { __extra } }
    public prop client: ActorClient { get() { __client } }
    public prop info: ReceiverInfo { get() { __info } }

    // TODO: support config
    public func invoke(args: HashMap<String, ToJsonValue>): ToolResponse {
        let names = __name.split(SEPARATOR)
        if (names.size != 2) {
            throw ActorMCPException("Invalid tool name: ${__name}")
        }
        let actorName = names[0]
        let receiverName = names[1]

        let proxy = ActorProxy(actorName, __client)

        try {
            let result = if (info.mode == ReceiverMode.TellOnly) {
                proxy.tell(receiverName, generateArgsFromTypeModel(args))
                DataModelNull()
            } else {
                let fut = proxy.ask(receiverName, generateArgsFromTypeModel(args))
                fut.get()
            }
            return ToolResponse(deserializeFromDataModelToString(info.retTypeModel, result))
        } catch (e: Exception) {
            return ToolResponse(e.toString(), isError: true)
        } catch (e: Error) {
            return ToolResponse(e.toString(), isError: true)
        }
    }

    public override func toString(): String {
        "${__name} [${__description}]"
    }

    func generateArgsFromTypeModel(args: HashMap<String, ToJsonValue>): Array<DataModel> {
        let res = ArrayList<DataModel>()
        for (parameter in info.paramSchema) {
            let arg = match (args.get(parameter.name)) {
                case Some(arg) => arg
                case None => throw ActorMCPException("Argument ${parameter.name} not found")
            }
            res.append(generateDataModelFromToJsonValue(parameter.typeModel, arg))
        }
        res.toArray()
    }
}

func generateDataModelFromToJsonValue(typeModel: TypeModel, arg: ToJsonValue): DataModel {
    match (typeModel) {
        case TypeModel.IntType => DataModelInt(arg.toJsonValue().asInt().getValue())
        case TypeModel.FloatType => DataModelFloat(arg.toJsonValue().asFloat().getValue())
        case TypeModel.BoolType => DataModelBool(arg.toJsonValue().asBool().getValue())
        case TypeModel.StringType => DataModelString(arg.toJsonValue().asString().getValue())
        case _ => throw ActorMCPException("Unsupported type model: ${typeModel}")
    }
}

func generateMCPToolsFromActorInfos(client: ActorClient, actorInfos: Array<ActorInfo>): Array<Tool> {
    let allTools = ArrayList<Tool>()
    for (actorInfo in actorInfos) {
        allTools.appendAll(generateMCPToolsFromActorInfo(client, actorInfo))
    }
    allTools.toArray()
}

func generateMCPToolsFromActorInfo(client: ActorClient, actorInfo: ActorInfo): Array<Tool> {
    let tools = ArrayList<Tool>()
    for (receiver in actorInfo.metadata.receivers) {
        let parameters = receiver.paramSchema.map({ param =>
            ToolParameter(
                param.name,
                param.description,
                generateTypeSchemaFromTypeModel(param.typeModel)
            )
        })
        // parameters.append(ToolParameter(
        //     "config",
        //     "The configuration of the receiver call",
        //     receiverConfigTypeSchema
        // ))
        tools.append(
            ReceiverTool(
                name: actorInfo.name + SEPARATOR + receiver.methodName,
                description: receiver.description,
                parameters: parameters,
                retType: generateTypeSchemaFromTypeModel(receiver.retTypeModel),
                examples: [],
                extra: HashMap<String, String>(),
                client: client,
                info: receiver
            )
        )
    }
    tools.toArray()
}

func generateTypeSchemaFromTypeModel(typeModel: TypeModel): TypeSchema {
    match (typeModel) {
        case TypeModel.IntType => TypeSchema.Int
        case TypeModel.FloatType => TypeSchema.Float
        case TypeModel.BoolType => TypeSchema.Boolean
        case TypeModel.StringType => TypeSchema.Str
        case TypeModel.UnitType => TypeSchema.Boolean
        case TypeModel.StructType(fields) => TypeSchema.Obj(fields.map({ field =>
            FieldSchema(field.name, field.name, generateTypeSchemaFromTypeModel(field.typeModel))
        }))
    }
}

func deserializeFromDataModelToString(typeModel: TypeModel, dm: DataModel): String {
    try {
        match (typeModel) {
            case TypeModel.IntType => (dm as DataModelInt).getOrThrow().getValue().toString()
            case TypeModel.FloatType => (dm as DataModelFloat).getOrThrow().getValue().toString()
            case TypeModel.BoolType => (dm as DataModelBool).getOrThrow().getValue().toString()
            case TypeModel.StringType => (dm as DataModelString).getOrThrow().getValue()
            case _ => throw ActorMCPException("Unsupported type model: ${typeModel}")
        }
    } catch (e: NoneValueException) {
        throw DataModelException("Cannot deserialize data model.")
    }
}