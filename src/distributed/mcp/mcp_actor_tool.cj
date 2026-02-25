package actors.distributed.mcp

import std.collection.*

import actors.*
import actors.distributed.*

import stdx.serialization.serialization.*
import stdx.encoding.json.*

import magic.core.tool.*
import magic.mcp.*
import magic.jsonable.*
import magic.tool.AbsTool

const SEPARATOR = ";__actors_08275892475824__;"

let receiverConfigTypeModel =
    TypeModel.StructType([
        FieldModel(name: "priority", description: "The priority of the receiver call", typeModel: TypeModel.IntType)
    ])

let receiverConfigTypeSchema =
    TypeSchema.Obj([
        FieldSchema("priority", "The priority of the receiver call", TypeSchema.Int)
    ])

/*
* A tool that wraps an actor receiver function
*/
public class ReceiverTool <: AbsTool {

    private let __name: String
    private let __description: String
    private let __parameters: Array<ToolParameter>
    private let __retType: TypeSchema
    private let __examples: Array<String>
    private let __hostInfo: HostInfo
    private let __info: ReceiverInfo

    /*
    * Initializes the ReceiverTool
    * @param name - the name of the tool
    * @param description - the description of the tool
    * @param parameters - the parameters of the tool
    * @param retType - the return type of the tool
    * @param examples - the examples of the tool
    * @param extra - the extra of the tool
    */
    public init(
        name!: String,
        description!: String,
        parameters!: Array<ToolParameter>,
        retType!: TypeSchema,
        examples!: Array<String>,
        extra!: HashMap<String, String>,
        hostInfo!: HostInfo,
        info!: ReceiverInfo
    ) {
        __name = name
        __description = description
        __parameters = parameters
        __retType = retType
        __examples = examples
        _extra = extra
        __hostInfo = hostInfo
        __info = info
    }

    public prop name: String { get() { __name } }
    public prop description: String { get() { __description } }
    public prop parameters: Array<ToolParameter> { get() { __parameters } }
    public prop retType: TypeSchema { get() { __retType } }
    public prop examples: Array<String> { get() { __examples } }
    public prop hostInfo: HostInfo { get() { __hostInfo } }
    public prop info: ReceiverInfo { get() { __info } }

    /*
    * Invokes the tool with the given arguments
    * @param args - the arguments to invoke the tool with
    * @return the response from the tool
    * @throws ActorMCPException - if the tool name is invalid
    * @throws DeserializationException - if the deserialization fails
    * @throws ActorNotFoundException - if the receiver is not found on the client
    * @throws ReceiverNotFoundException - if the receiver is not found on the actor
    * @throws RemoteException - if the remote connection fails
    */
    public func invoke(args: HashMap<String, JsonValue>): ToolResponse {
        let names = __name.split(SEPARATOR)
        if (names.size != 2) {
            throw ActorMCPException("Invalid tool name: ${__name}")
        }
        let actorName = names[0]
        let receiverName = names[1]

        let proxy = ActorProxy(actorName, __hostInfo)

        try {
            let config = match (args.get("config")) {
                case Some(config) =>
                    let dm = generateDataModelFromToJsonValue(receiverConfigTypeModel, config)
                    ReceiverConfig(priority: (dm as DataModelInt).getOrThrow().getValue())
                case None => ReceiverConfig.default
            }

            let result = if (info.mode == ReceiverMode.TellOnly) {
                proxy.tell(receiverName, generateArgsFromTypeModel(args), config: config)
                DataModelNull()
            } else {
                let fut = proxy.ask(receiverName, generateArgsFromTypeModel(args), config: config)
                fut.get()
            }
            return ToolResponse(deserializeFromDataModelToString(info.retTypeModel, result))
        } catch (e: Exception) {
            return ToolResponse(e.toString(), isError: true)
        } catch (e: Error) {
            return ToolResponse(e.toString(), isError: true)
        }
    }

    public func toString(): String {
        "${__name} [${__description}]"
    }

    func generateArgsFromTypeModel(args: HashMap<String, JsonValue>): Array<DataModel> {
        let res = ArrayList<DataModel>()
        for (parameter in info.paramSchema) {
            let arg = match (args.get(parameter.name)) {
                case Some(arg) => arg
                case None => throw ActorMCPException("Argument ${parameter.name} not found")
            }
            res.add(generateDataModelFromToJsonValue(parameter.typeModel, arg))
        }
        res.toArray()
    }
}

func generateDataModelFromToJsonValue(typeModel: TypeModel, arg: JsonValue): DataModel {
    match (typeModel) {
        case TypeModel.IntType => DataModelInt(arg.asInt().getValue())
        case TypeModel.FloatType => DataModelFloat(arg.asFloat().getValue())
        case TypeModel.BoolType => DataModelBool(arg.asBool().getValue())
        case TypeModel.StringType => DataModelString(arg.asString().getValue())
        case TypeModel.UnitType => DataModelNull()
        case TypeModel.StructType(fieldTypeModels) =>
            let structValue = arg.asObject()
            let fields = ArrayList<Field>()
            for (field in fieldTypeModels) {
                fields.add(Field(
                    field.name,
                    generateDataModelFromToJsonValue(field.typeModel, structValue.get(field.name).getOrThrow())
                ))
            }
            DataModelStruct(fields)
        case TypeModel.ListType(itemType) =>
            let dataModels = ArrayList<DataModel>()
            for (item in arg.asArray().getItems()) {
                dataModels.add(generateDataModelFromToJsonValue(itemType, item))
            }
            DataModelSeq(dataModels)
    }
}

func deserializeFromDataModelToString(typeModel: TypeModel, dm: DataModel): String {
    try {
        match (typeModel) {
            case TypeModel.IntType => (dm as DataModelInt).getOrThrow().getValue().toString()
            case TypeModel.FloatType => (dm as DataModelFloat).getOrThrow().getValue().toString()
            case TypeModel.BoolType => (dm as DataModelBool).getOrThrow().getValue().toString()
            case TypeModel.StringType => (dm as DataModelString).getOrThrow().getValue()
            case TypeModel.UnitType => "()"
            case TypeModel.StructType(fields) =>
                var result = ""
                let structValue = (dm as DataModelStruct).getOrThrow()
                result += "{"
                for (field in fields) {
                    let fieldType = field.typeModel
                    let fieldValue = structValue.get(field.name)
                    let valueString = deserializeFromDataModelToString(fieldType, fieldValue)
                    result += "${field.name} = ${valueString}, "
                }
                result + "}"
            case TypeModel.ListType(itemType) =>
                var result = "["
                let seq = (dm as DataModelSeq).getOrThrow()
                for (item in seq.getItems()) {
                    let valueString = deserializeFromDataModelToString(itemType, item)
                    result += "${valueString}, "
                }
                result + "]"
        }
    } catch (e: NoneValueException) {
        throw DeserializationException("Cannot deserialize data model.")
    }
}

func generateMCPToolsFromActorInfos(client: ActorClient, actorInfos: Array<ActorInfo>): Array<Tool> {
    let allTools = ArrayList<Tool>()
    for (actorInfo in actorInfos) {
        allTools.add(all: generateMCPToolsFromActorInfo(client, actorInfo))
    }
    allTools.toArray()
}

func generateMCPToolsFromActorInfo(client: ActorClient, actorInfo: ActorInfo): Array<Tool> {
    let tools = ArrayList<Tool>()
    for (receiver in actorInfo.metadata.receivers) {
        let parameters = ArrayList<ToolParameter>()
        for (param in receiver.paramSchema) {
            parameters.add(ToolParameter(
                param.name,
                param.description,
                generateTypeSchemaFromTypeModel(param.typeModel)
            ))
        }
        parameters.add(ToolParameter(
            "config",
            "The configuration of the receiver call",
            receiverConfigTypeSchema
        ))
        tools.add(
            ReceiverTool(
                name: actorInfo.name + SEPARATOR + receiver.methodName,
                description: receiver.description,
                parameters: parameters.toArray(),
                retType: generateTypeSchemaFromTypeModel(receiver.retTypeModel),
                examples: [],
                extra: HashMap<String, String>(),
                hostInfo: client.getHostInfo(),
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
        case TypeModel.StructType(fields) =>
            let schemas = ArrayList<FieldSchema>()
            for (field in fields) {
                schemas.add(FieldSchema(field.name, field.description, generateTypeSchemaFromTypeModel(field.typeModel)))
            }
            TypeSchema.Obj(schemas.toArray())
        case TypeModel.ListType(itemType) => TypeSchema.Arr(generateTypeSchemaFromTypeModel(itemType))
    }
}
