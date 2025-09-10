package actors

import stdx.encoding.json.*

public type ActorInfo = (String, Metadata)

public struct Metadata <: ToString {
    public Metadata(
        public let receivers: Array<ReceiverInfo>,
        public let description: String,
        public let customInfo: JsonValue
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

public struct ReceiverInfo <: ToString & Equatable<ReceiverInfo> {

    public ReceiverInfo(
        public let description: String,
        public let customInfo: JsonValue,
        public let methodName: String,
        public let paramSchema: Array<(String, TypeModel)>,
        public let retTypeModel: TypeModel
    ) {}

    public override func toString(): String {
        var res = "${methodName} ("
        var i = 0
        for ((name, typeModel) in paramSchema) {
            res += "${name}: ${typeModel}"
            if (i < paramSchema.size - 1) {
                res += ", "
            }
            i += 1
        }
        res += "): ${retTypeModel}"
        res += " [${description}]"
        res += " [${customInfo}]"
        res
    }

    public override operator func ==(other: ReceiverInfo): Bool {
        this.methodName == other.methodName
    }

    public override operator func !=(other: ReceiverInfo): Bool {
        !(this == other)
    }
}

public enum TypeModel <: ToString {
    AnyType
    | IntType // more primitive types
    | BoolType
    | StringType
    | UnitType
    | SeqType
    | StructType(String, Array<FieldModel>)

    public override func toString(): String {
        match (this) {
            case AnyType => "Any"
            case IntType => "Int"
            case BoolType => "Bool"
            case StringType => "String"
            case UnitType => "Unit"
            case SeqType => "Seq"
            case StructType(name, fields) =>
                var res = "Struct ${name} { "
                for (field in fields) {
                    res += "${field}, "
                }
                res += "}"
                res
        }
    }
}

public struct FieldModel <: ToString {
    public FieldModel(
        public let name: String,
        public let typeModel: TypeModel
    ) {}

    public override func toString(): String {
        "${name}: typeModel"
    }
}