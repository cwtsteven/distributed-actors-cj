package actors

import std.collection.*
import serialization.serialization.*

public interface Fullfillable {
    func fulfill(dataModel: DataModel): Bool
}

public interface Distributable {
    func getMetadata(): Metadata

    func dispatchTell(receiverName: String, args: Array<DataModel>, config: ReceiverConfig): Unit
    func dispatchAsk(receiverName: String, args: Array<DataModel>, config: ReceiverConfig): Waitable
}

public class ActorProxy {
    public ActorProxy(
        public let name: String,
        public let client: ActorClient
    ) {}

    public func postMessage(receiverName: String, args: Array<DataModel>, config!: ReceiverConfig = ReceiverConfig.default): Unit {
        client.remoteTell(name, receiverName, args, config)
    }

    public func post<T>(receiverName: String, args: Array<DataModel>, config!: ReceiverConfig = ReceiverConfig.default): ActorFuture<T> where T <: Serializable<T> {
        let fut = DistributedActorFuture<T>()
        client.remoteCall(name, receiverName, args, config, fut)
        fut
    }
}

public interface ActorHost {
    func register(name: String, a: Distributable): Bool
    func deregister(name: String): Bool
}

public interface ActorClient {
    func find(name: String): Option<ActorInfo>
    func findAll(): Array<ActorInfo>
    func remoteCall(name: String, receiverName: String, args: Array<DataModel>, config: ReceiverConfig, fut: Fullfillable): Unit
    func remoteTell(name: String, receiverName: String, args: Array<DataModel>, config: ReceiverConfig): Unit
}

public class DistributedActorFuture<T> <: ActorFuture<T> & Fullfillable where T <: Serializable<T> {
    init() {}

    public func fulfill(dataModel: DataModel): Bool {
        if (isReady.load()) {
            return false
        }

        let res: FutureResult<T> = FutureResult<T>.deserialize(dataModel)

        synchronized(mtx) {
            if (isReady.load()) {
                return false
            }
            this.result = res
            isReady.store(true)
            mtx.notifyAll()
            true
        }
    }

    public func wait(): DataModel {
        try {
            this.get()
        } catch (_: Exception) {
        } catch (_: Error) {}

        this.result.serialize()
    }
}

extend<T> FutureResult<T> <: Serializable<FutureResult<T>> where T <: Serializable<T> {
    public func serialize(): DataModel {
        match (this) {
            case Okay(value) =>
                let fields = ArrayList<Field>()
                fields.append(Field("type", DataModelString("Okay")))
                fields.append(Field("value", value.serialize()))
                DataModelStruct(fields)
            case Exc(exception) =>
                let fields = ArrayList<Field>()
                fields.append(Field("type", DataModelString("Exc")))
                fields.append(Field("message", DataModelString(exception.message)))
                DataModelStruct(fields)
            case Err(error) =>
                let fields = ArrayList<Field>()
                fields.append(Field("type", DataModelString("Err")))
                fields.append(Field("message", DataModelString(error.message)))
                DataModelStruct(fields)
        }
    }

    public static func deserialize(dataModel: DataModel): FutureResult<T> {
        match (dataModel) {
            case dm: DataModelStruct =>
                let fields = dm.getFields()
                var resultType: String = ""
                var valueData: DataModel = DataModelNull()
                var message: String = ""

                for (field in fields) {
                    match (field.getName()) {
                        case "type" =>
                            match (field.getData()) {
                                case str: DataModelString => resultType = str.getValue()
                                case _ => throw Exception("Invalid type field in FutureResult deserialization")
                            }
                        case "value" =>
                            valueData = field.getData()
                        case "message" =>
                            match (field.getData()) {
                                case str: DataModelString => message = str.getValue()
                                case _ => throw Exception("Invalid message field in FutureResult deserialization")
                            }
                        case _ => () // ignore unknown fields for forward compatibility
                    }
                }

                match (resultType) {
                    case "Okay" =>
                        let value = T.deserialize(valueData)
                        Okay(value)
                    case "Exc" =>
                        Exc(RemoteReceiverException(message))
                    case "Err" =>
                        Exc(RemoteReceiverException(message))
                    case _ =>
                        throw Exception("Invalid FutureResult type: " + resultType)
                }
            case _ =>
                throw Exception("Expected DataModelStruct for FutureResult deserialization")
        }
    }
}