package actors.distributed

import std.collection.*
import std.sync.*
import std.time.*

import actors.*

import serialization.serialization.*

public class DistributedFuture {
    private var result: FutureResult<DataModel> = unsafe { zeroValue<FutureResult<DataModel>>() }
    private let isReady = AtomicBool(false)
    private let mtx = Monitor()

    init() {}

    public func get(): DataModel {
        if (isReady.load()) {
            return result.getOrThrow()
        }

        synchronized(mtx) {
            while (!isReady.load()) {
                mtx.wait()
            }
            return result.getOrThrow()
        }
    }

    public func get(timeout: Duration): Option<DataModel> {
        if (timeout <= Duration.Zero) {
            return Some(get())
        }
        if (isReady.load()) {
            return Some(result.getOrThrow())
        }
        let start = DateTime.now()
        synchronized(mtx) {
            while (true) {
                if (isReady.load()) {
                    break
                }
                let timeElapsed = DateTime.now() - start
                if (timeElapsed >= timeout) {
                    break
                }
                let d = timeout - timeElapsed
                mtx.wait(timeout: d)
            }
        }
        return tryGet()
    }

    public func tryGet(): Option<DataModel> {
        if (isReady.load()) {
            return Some(result.getOrThrow())
        }
        return None
    }

    public func fulfill(dataModel: DataModel): Bool {
        if (isReady.load()) {
            return false
        }

        let res: FutureResult<DataModel> = deserializeFutureResult(dataModel)

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

    public func toActorFuture<T>(): ActorFuture<T> where T <: Serializable<T> {
        let fut = ActorFuture<T>({ => T.deserialize(this.get()) })
        spawn { fut.execute() }
        fut
    }
}

public interface LocalWaitable {
    func getResult(): DataModel

    static func fromActorFuture<T>(obj: Object): LocalWaitable where T <: Serializable<T> {
        (obj as ActorFuture<T>).getOrThrow()
    }
}

extend<T> ActorFuture<T> <: LocalWaitable where T <: Serializable<T> {

    public func getResult(): DataModel {
        let res: FutureResult<DataModel> = try {
            Okay(this.get().serialize())
        } catch (e: Exception) {
            Exc(e)
        } catch (e: Error) {
            Err(e)
        }
        serializeFutureResult(res)
    }
}

/*
* Serializes the future result
* @return the serialized future result
* @throws DataModelException - if the future result cannot be serialized
*/
func serializeFutureResult(result: FutureResult<DataModel>): DataModel {
    match (result) {
        case Okay(value) =>
            let fields = ArrayList<Field>()
            fields.append(Field("type", DataModelString("Okay")))
            fields.append(Field("value", value))
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

/*
* Deserializes the future result
* @param dataModel - the data model to deserialize the future result from
* @return the deserialized future result
* @throws DataModelException - if the future result cannot be deserialized
*/
func deserializeFutureResult(dataModel: DataModel): FutureResult<DataModel> {
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
                            case _ => throw DataModelException("Invalid type field in FutureResult deserialization")
                        }
                    case "value" =>
                        valueData = field.getData()
                    case "message" =>
                        match (field.getData()) {
                            case str: DataModelString => message = str.getValue()
                            case _ => throw DataModelException("Invalid message field in FutureResult deserialization")
                        }
                    case _ => () // ignore unknown fields for forward compatibility
                }
            }

            match (resultType) {
                case "Okay" =>
                    Okay(valueData)
                case "Exc" =>
                    Exc(RemoteReceiverException(message))
                case "Err" =>
                    Exc(RemoteReceiverException(message))
                case _ =>
                    throw DataModelException("Invalid FutureResult type: " + resultType)
            }
        case _ =>
            throw DataModelException("Expected DataModelStruct for FutureResult deserialization")
    }
}