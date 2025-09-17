package actors

import std.collection.*

import serialization.serialization.*

public class ActorNotFoundException <: Exception {
    public init(name: String) {
        super("Actor with name = ${name} cannot be found.")
    }
}

public class RemoteException <: Exception {
    public init() {
        super("Remote connection has failed.")
    }
}

public class ActorSystemException <: Exception {
    public init(msg: String) {
        super(msg)
    }
}

public class RemoteReceiverException <: Exception & Serializable<RemoteReceiverException> {
    public init(e: Exception) {
        this(stackTraceToString(e.toString(), e.getStackTrace()))
    }

    public init(e: Error) {
        this(stackTraceToString(e.toString(), e.getStackTrace()))
    }

    init(msg: String) {
        super(msg)
    }

    static func stackTraceToString(msg: String, traceElementArray: Array<StackTraceElement>): String {
        var res = "A non-serializable exception or error has been thrown from the receiver execution, below shows its stack trace in the remote machine:\n"
        res += "\t" + msg + "\n"
        for (element in traceElementArray) {
            if (element.declaringClass.isEmpty() && element.methodName.isEmpty()) { // simple stack trace format
                eprintln("\t at ${element.fileName}:${element.lineNumber}")
            } else {
                let packageDelimiter: String = if (element.declaringClass.isEmpty()) { "" } else { "." }
                eprintln(
                    "\t at ${element.declaringClass}${packageDelimiter}${element.methodName}(${element.fileName}:${element.lineNumber})")
            }
        }
        res
    }

    protected override func getClassName(): String {
        "RemoteReceiverException"
    }

    static let msgKey = "m"

    public override func serialize(): DataModel {
        let list = ArrayList<Field>([Field(msgKey, message.serialize())])
        DataModelStruct(list)
    }

    public static func deserialize(dm: DataModel): RemoteReceiverException {
        let structDm = (dm as DataModelStruct).getOrThrow()
        let msgField = (structDm.get(msgKey) as DataModelString).getOrThrow()
        let message = String.deserialize(msgField)
        RemoteReceiverException(message)
    }
}