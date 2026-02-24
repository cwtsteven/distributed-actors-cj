package actors.distributed

import actors.*
import stdx.encoding.json.*
import stdx.serialization.serialization.*

/*
* Information about an actor including its name and metadata
* Metadata includes information about the actor's receivers, description, and custom info
* This is used by actor systems to provide information about registered actors
*/
public struct ActorInfo <: ToString {
    /*
    * Initializes the ActorInfo
    * @param name - the name of the actor
    * @param metadata - the metadata of the actor
    */
    public ActorInfo(
        public let name!: String,
        public let metadata!: Metadata
    ) {}

    public override func toString(): String {
        "ActorInfo(name: ${name}, metadata: ${metadata.toString()})"
    }
}

/*
* Metadata about an actor
*/
public struct Metadata <: ToString {
    /*
    * Initializes the Metadata
    * @param receivers - the receiver info of the actor
    * @param description - the description of the actor
    * @param customInfo - the custom info of the actor
    */
    public Metadata(
        public let receivers!: Array<ReceiverInfo>,
        public let description!: String,
        public let customInfo!: JsonObject
    ) {}

    public override func toString(): String {
        var result = "Metadata(\n"
        result += "    receiver count: ${receivers.size},\n"
        result += "    receivers: [\n"
        for (i in 0..receivers.size) {
            result += "        ${receivers[i].toString()}"
            if (i < receivers.size - 1) {
                result += ","
            }
            result += "\n"
        }
        result += "    ],\n"
        result += "    description: ${description},\n"
        result += "    customInfo: ${customInfo}\n"
        result += ")"
        result
    }
}

/*
* The mode of a receiver
*/
public enum ReceiverMode <: ToString & Equatable<ReceiverMode> {
    | AskOnly
    | TellOnly
    | AskAndTell

    public override func toString(): String {
        match (this) {
            case AskOnly => "AskOnly"
            case TellOnly => "TellOnly"
            case AskAndTell => "AskAndTell"
        }
    }

    public override operator func ==(other: ReceiverMode): Bool {
        match ((this, other)) {
            case (AskOnly, AskOnly) => true
            case (TellOnly, TellOnly) => true
            case (AskAndTell, AskAndTell) => true
            case _ => false
        }
    }

    public override operator func !=(other: ReceiverMode): Bool {
        !(this == other)
    }
}

/*
* Information about a receiver
*/
public struct ReceiverInfo <: ToString {

    /*
    * Initializes the ReceiverInfo
    * @param description - the description of the receiver
    * @param customInfo - the custom info of the receiver
    * @param methodName - the name of the receiver
    * @param paramSchema - the parameter schema of the receiver
    * @param retTypeModel - the return type model of the receiver
    * @param mode - the calling mode of the receiver (AskOnly, TellOnly, AskAndTell)
    */
    public ReceiverInfo(
        public let description!: String,
        public let customInfo!: JsonObject,
        public let methodName!: String,
        public let paramSchema!: Array<ReceiverParameter>,
        public let retTypeModel!: TypeModel,
        public let mode!: ReceiverMode
    ) {}

    public override func toString(): String {
        var res = "${methodName} ("
        var i = 0
        for (param in paramSchema) {
            res += "${param.name}: ${param.typeModel} [${param.description}]"
            if (i < paramSchema.size - 1) {
                res += ", "
            }
            i += 1
        }
        res += "): ${retTypeModel}"
        res += " [${mode}]"
        res += " [${description}]"
        res += " [${customInfo}]"
        res
    }
}

/*
* Information about a receiver parameter
*/
public struct ReceiverParameter <: ToString {
    public ReceiverParameter(
        public let name!: String,
        public let typeModel!: TypeModel,
        public let description!: String
    ) {}

    public override func toString(): String {
        "${name}: ${typeModel} [${description}]"
    }
}

/*
* The type model of a Cangjie type
*/
public enum TypeModel <: ToString & Equatable<TypeModel> {
    | IntType
    | FloatType
    | BoolType
    | StringType
    | UnitType
    | StructType(Array<FieldModel>)
    | ListType(TypeModel)

    public override func toString(): String {
        match (this) {
            case IntType => "Int"
            case FloatType => "Float"
            case BoolType => "Bool"
            case StringType => "String"
            case UnitType => "Unit"
            case StructType(fields) => "Struct(${fields})"
            case ListType(itemType) => "List(${itemType})"
        }
    }

    public override operator func ==(other: TypeModel): Bool {
        match ((this, other)) {
            case (IntType, IntType) => true
            case (FloatType, FloatType) => true
            case (BoolType, BoolType) => true
            case (StringType, StringType) => true
            case (UnitType, UnitType) => true
            case (StructType(fields1), StructType(fields2)) => fields1 == fields2
            case (ListType(itemType1), ListType(itemType2)) => itemType1 == itemType2
            case _ => false
        }
    }

    public override operator func !=(other: TypeModel): Bool {
        !(this == other)
    }
}

/*
* Information about a field of a struct
*/
public struct FieldModel <: ToString & Equatable<FieldModel> {
    public FieldModel(
        public let name!: String,
        public let description!: String,
        public let typeModel!: TypeModel
    ) {}

    public override operator func ==(other: FieldModel): Bool {
        this.name == other.name && this.description == other.description && this.typeModel == other.typeModel
    }

    public override operator func !=(other: FieldModel): Bool {
        !(this == other)
    }

    public override func toString(): String {
        "${name}: ${typeModel} [${description}]"
    }
}

/*
* Information about a receiver invocation
*/
public struct InvokeInfo {
    /*
    * Initializes the InvokeInfo
    * @param name - the name of the invocation
    * @param receiverName - the name of the receiver
    * @param args - the arguments of the invocation
    * @param config - the configuration of the invocation
    * @param fut - the distributed future of the invocation
    */
    public InvokeInfo(
        public let name!: String,
        public let receiverName!: String,
        public let args!: Array<DataModel>,
        public let config!: ReceiverConfig,
        public let fut!: ?DistributedFuture
    ) {}
}
