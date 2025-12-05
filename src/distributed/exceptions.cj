package actors.distributed

import std.collection.*
import actors.*
import serialization.serialization.*

/*
* Exception thrown when an actor system fails
*/
public open class ActorSystemException <: Exception {
    /*
    * Creates a ActorSystemException
    * @param msg - the message of the exception
    */
    protected init(msg: String) {
        super(msg)
    }

    protected open override func getClassName(): String {
        "ActorSystemException"
    }
}

/*
* Exception thrown when an actor is not found
*/
public open class ActorNotFoundException <: ActorSystemException {
    /*
    * Creates a ActorNotFoundException
    * @param name - the name of the actor
    */
    public init(name: String) {
        super("Actor with name = ${name} cannot be found.")
    }

    protected open override func getClassName(): String {
        "ActorNotFoundException"
    }
}

/*
* Exception thrown when a receiver is not found
*/
public open class ReceiverNotFoundException <: ActorSystemException {
    /*
    * Creates a ReceiverNotFoundException
    * @param name - the name of the actor interface
    * @param receiverName - the name of the receiver
    */
    public init(name: String, receiverName: String) {
        super("Receiver: ${receiverName} cannot be found in actor interface: ${name}.")
    }

    protected open override func getClassName(): String {
        "ReceiverNotFoundException"
    }
}

/*
* Exception thrown when a remote connection fails
*/
public open class RemoteException <: ActorSystemException {
    /*
    * Creates a RemoteException
    */
    protected init() {
        super("Remote connection has failed.")
    }

    protected init(msg: String) {
        super(msg)
    }

    protected open override func getClassName(): String {
        "SerializationException"
    }
}

public open class SerializationException <: ActorSystemException {
    protected init(message: String) {
        super(message)
    }

    protected open override func getClassName(): String {
        "DeserializationException"
    }
}

public open class DeserializationException <: ActorSystemException {
    protected init(message: String) {
        super(message)
    }

    protected open override func getClassName(): String {
        "DeserializationException"
    }
}

public open class ActorClusterException <: ActorSystemException {
    protected init(message: String) {
        super(message)
    }

    protected open override func getClassName(): String {
        "ActorClusterException"
    }
}

public open class SerializingFunctionsNotFoundException <: ActorClusterException {
    protected init(message: String) {
        super(message)
    }

    protected open override func getClassName(): String {
        "SerializingFunctionsNotFoundException"
    }
}

/*
* Exception thrown when a remote receiver fails
*/
public open class RemoteReceiverException <: ActorSystemException & Serializable<RemoteReceiverException> {
    /*
    * Creates a RemoteReceiverException from an Exception
    * @param e - the exception to wrap
    */
    protected init(e: Exception) {
        this(e.toStringWithStackTrace())
    }

    /*
    * Creates a RemoteReceiverException from an Error
    * @param e - the error to wrap
    */
    protected init(e: Error) {
        this(e.toStringWithStackTrace())
    }

    /*
    * Creates a RemoteReceiverException from a message
    * @param msg - the message to wrap
    */
    protected init(msg: String) {
        super(msg)
    }

    /*
    * Gets the class name
    * @return the class name
    */
    protected open override func getClassName(): String {
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
    * @throws DeserializationException - if the exception cannot be deserialized
    */
    public static func deserialize(dm: DataModel): RemoteReceiverException {
        match (dm) {
            case dm: DataModelStruct =>
                match (dm.get(msgKey)) {
                    case msgField: DataModelString =>
                        let message = String.deserialize(msgField)
                        RemoteReceiverException(message)
                    case _ =>
                        throw DeserializationException("Expected DataModelString for RemoteReceiverException deserialization")
                }
            case _ =>
                throw DeserializationException("Expected DataModelStruct for RemoteReceiverException deserialization")
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
