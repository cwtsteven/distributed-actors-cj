package actors

import encoding.json.*

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
        public let name: String,
        public let metadata: Metadata
    ) {}

    /*
    * Creates an ActorInfo
    * @param name - the name of the actor
    * @param metadata - the metadata of the actor
    */
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
    * @param receivers - the receivers of the actor
    * @param description - the description of the actor
    * @param customInfo - the custom info of the actor
    */
    public Metadata(
        public let receivers: Array<ReceiverInfo>,
        public let description: String,
        public let customInfo: JsonValue
    ) {}

    /*
    * Converts the Metadata to a string
    */
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
* Information about a receiver
*/
public struct ReceiverInfo <: ToString & Equatable<ReceiverInfo> {

    /*
    * Initializes the ReceiverInfo
    * @param description - the description of the receiver
    * @param customInfo - the custom info of the receiver
    * @param methodName - the name of the receiver
    * @param paramSchema - the parameter schema of the receiver
    * @param retTypeModel - the return type model of the receiver
    */
    public ReceiverInfo(
        public let description: String,
        public let customInfo: JsonValue,
        public let methodName: String,
        public let paramSchema: Array<(String, TypeModel)>,
        public let retTypeModel: TypeModel
    ) {}

    /*
    * Converts the ReceiverInfo to a string
    */
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

    /*
    * Checks if the ReceiverInfo is equal to another ReceiverInfo
    * @param other - the other ReceiverInfo
    * @return true if the ReceiverInfo is equal to the other ReceiverInfo, false otherwise
    */
    public override operator func ==(other: ReceiverInfo): Bool {
        this.methodName == other.methodName
    }

    /*
    * Checks if the ReceiverInfo is not equal to another ReceiverInfo
    * @param other - the other ReceiverInfo
    * @return true if the ReceiverInfo is not equal to the other ReceiverInfo, false otherwise
    */
    public override operator func !=(other: ReceiverInfo): Bool {
        !(this == other)
    }
}

/*
* Type model
*/
public enum TypeModel <: ToString {
    | IntType
    | FloatType
    | BoolType
    | StringType
    | UnitType

    /*
    * Converts the TypeModel to a string
    */
    public override func toString(): String {
        match (this) {
            case IntType => "Int"
            case FloatType => "Float"
            case BoolType => "Bool"
            case StringType => "String"
            case UnitType => "Unit"
        }
    }
}