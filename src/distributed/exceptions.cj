package actors.distributed

import std.collection.*
import actors.*
import serialization.serialization.*

/*
* Exception thrown when an actor is not found
*/
public class ActorNotFoundException <: Exception {
    /*
    * Creates a ActorNotFoundException
    * @param name - the name of the actor
    */
    public init(name: String) {
        super("Actor with name = ${name} cannot be found.")
    }
}

/*
* Exception thrown when a receiver is not found
*/
public class ReceiverNotFoundException <: Exception {
    /*
    * Creates a ReceiverNotFoundException
    * @param name - the name of the actor interface
    * @param receiverName - the name of the receiver
    */
    public init(name: String, receiverName: String) {
        super("Receiver: ${receiverName} cannot be found in actor interface: ${name}.")
    }
}

/*
* Exception thrown when a remote connection fails
*/
public class RemoteException <: Exception {
    /*
    * Creates a RemoteException
    */
    public init() {
        super("Remote connection has failed.")
    }
}

/*
* Exception thrown when an actor system fails
*/
public class ActorSystemException <: Exception {
    /*
    * Creates a ActorSystemException
    * @param msg - the message of the exception
    */
    public init(msg: String) {
        super(msg)
    }
}

/*
* Exception thrown when a remote receiver fails
*/
public class RemoteReceiverException <: Exception & Serializable<RemoteReceiverException> {
    /*
    * Creates a RemoteReceiverException from an Exception
    * @param e - the exception to wrap
    */
    public init(e: Exception) {
        this(e.toStringWithStackTrace())
    }

    /*
    * Creates a RemoteReceiverException from an Error
    * @param e - the error to wrap
    */
    public init(e: Error) {
        this(e.toStringWithStackTrace())
    }

    /*
    * Creates a RemoteReceiverException from a message
    * @param msg - the message to wrap
    */
    init(msg: String) {
        super(msg)
    }

    /*
    * Gets the class name
    * @return the class name
    */
    protected override func getClassName(): String {
        "RemoteReceiverException"
    }

    private static let msgKey = "m"

    /*
    * Serializes the RemoteReceiverException
    * @return the serialized exception
    */
    public override func serialize(): DataModel {
        let list = ArrayList<Field>([Field(msgKey, message.serialize())])
        DataModelStruct(list)
    }

    /*
    * Deserializes the RemoteReceiverException
    * @param dm - the serialized exception
    * @return the deserialized exception
    * @throws DataModelException - if the exception cannot be deserialized
    */
    public static func deserialize(dm: DataModel): RemoteReceiverException {
        match (dm) {
            case dm: DataModelStruct =>
                match (dm.get(msgKey)) {
                    case msgField: DataModelString =>
                        let message = String.deserialize(msgField)
                        RemoteReceiverException(message)
                    case _ =>
                        throw DataModelException("Expected DataModelString for RemoteReceiverException deserialization")
                }
            case _ =>
                throw DataModelException("Expected DataModelStruct for RemoteReceiverException deserialization")
        }
    }
}

extend Exception {
    public func toStringWithStackTrace(): String {
        stackTraceToString(message, getStackTrace())
    }
}

extend Error {
    public func toStringWithStackTrace(): String {
        stackTraceToString(message, getStackTrace())
    }
}
