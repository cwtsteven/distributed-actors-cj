package actors

import std.reflect.*

import stdx.serialization.serialization.*

// const KEY_METHOD_NAME = "m"
// const KEY_TYPE_ARGS = "t"
// const KEY_PARAM_TYPES = "pt"
// const KEY_QNAME = "q"
// const KEY_PAYLOAD = "pl"

// const FROM_JSON = "from_json"

public type CustomInfo = Array<(String, String)>

public struct Metadata {
    public Metadata(
        public let receivers: Array<ReceiverInfo>,
        public let description: String,
        public let customInfo: CustomInfo
    ) {}
}

public struct ReceiverInfo <: ToString {
    
    public ReceiverInfo(
        public let methodName: String,
        public let paramSchema: Array<(String, TypeModel)>,
        public let retTypeModel: TypeModel
    ) {}

    public override func toString(): String {
        var res = "${methodName} ("
        for ((name, typeModel) in paramSchema) {
            res += "${name}: ${typeModel}, "
        }
        res += "): ${retTypeModel}"
        res
    }
}

public enum TypeModel <: ToString {
    IntType // more primitive types
    | StringType
    | SeqType
    | StructType(String, Array<FieldModel>)

    public override func toString(): String {
        match (this) {
            case IntType => "Int"
            case StringType => "String"
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