package actors.mcp

import std.collection.*

import actors.*
import actors.distributed.*

import magic.core.tool.*
import magic.mcp.*
import magic.jsonable.*

public class ReceiverTool <: Tool {

    private let __name: String
    private let __description: String
    private let __parameters: Array<ToolParameter>
    private let __retType: TypeSchema
    private let __examples: Array<String>
    private let __extra: HashMap<String, String>
    private let __client: ActorClient

    public init(
        name!: String,
        description!: String,
        parameters!: Array<ToolParameter>,
        retType!: TypeSchema,
        examples!: Array<String>,
        extra!: HashMap<String, String>,
        client!: ActorClient
    ) {
        __name = name
        __description = description
        __parameters = parameters
        __retType = retType
        __examples = examples
        __extra = extra
        __client = client
    }

    public prop name: String { get() { __name } }
    public prop description: String { get() { __description } }
    public prop parameters: Array<ToolParameter> { get() { __parameters } }
    public prop retType: TypeSchema { get() { __retType } }
    public prop examples: Array<String> { get() { __examples } }
    public prop extra: HashMap<String, String> { get() { __extra } }
    public prop client: ActorClient { get() { __client } }

    public func invoke(args: HashMap<String, ToJsonValue>): ToolResponse {
        let names = __name.split(".")
        if (names.size != 2) {
            throw ActorMCPException("Invalid tool name: ${__name}")
        }
        let actorName = names[0]
        let receiverName = names[1]

        let proxy = ActorProxy(actorName, __client)
        // proxy.ask(receiverName, args)
        throw Exception("not implemented")
    }

    public override func toString(): String {
        throw Exception("not implemented")
    }
}

func generateMCPToolsFromActorInfos(client: ActorClient, actorInfos: Array<ActorInfo>): Array<ReceiverTool> {
    let allTools = ArrayList<ReceiverTool>()
    for (actorInfo in actorInfos) {
        allTools.appendAll(generateMCPToolsFromActorInfo(client, actorInfo))
    }
    allTools.toArray()
}

func generateMCPToolsFromActorInfo(client: ActorClient, actorInfo: ActorInfo): Array<ReceiverTool> {
    let tools = ArrayList<ReceiverTool>()
    for (receiver in actorInfo.metadata.receivers) {
        tools.append(
            ReceiverTool(
                name: actorInfo.name + "." + receiver.methodName,
                description: receiver.description,
                parameters: receiver.paramSchema.map({ param =>
                    ToolParameter(
                        param.name,
                        param.description,
                        generateTypeSchemaFromTypeModel(param.typeModel)
                    )
                }),
                retType: generateTypeSchemaFromTypeModel(receiver.retTypeModel),
                examples: [],
                extra: HashMap<String, String>(),
                client: client
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
    }
}