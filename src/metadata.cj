package actors

public type CustomInfo = (String, String)
public type ActorInfo = (String, Metadata)

public struct Metadata {
    public Metadata(
        public let receivers: Array<ReceiverInfo>,
        public let description: String,
        public let customInfo: Array<CustomInfo>
    ) {}
}

public struct ReceiverInfo <: ToString & Equatable<ReceiverInfo> {
    
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
    | StringType
    | SeqType
    | StructType(String, Array<FieldModel>)

    public override func toString(): String {
        match (this) {
            case AnyType => "Any"
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