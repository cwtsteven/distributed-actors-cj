package actors.distributed

import std.collection.*
import std.sync.*
import std.time.*

import actors.*

import serialization.serialization.*

/*
* A class representing a distributed future
*/
public class DistributedFuture {
    private var result: FutureResult<DataModel> = unsafe { zeroValue<FutureResult<DataModel>>() }
    private let isReady = AtomicBool(false)
    private let mtx = Monitor()

    init() {}

    /*
    * Blocks the current thread until the result is ready and returns the result
    * @return the result
    * @throws Exception - if the result is an exception
    * @throws Error - if the result is an error
    */
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

    /*
    * Blocks the current thread until the result is ready with a timeout and returns the result
    * @param timeout - the timeout duration
    * @return the result if it is ready within the timeout, None otherwise
    * @throws Exception - if the result is an exception
    * @throws Error - if the result is an error
    */
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

    /*
    * Tries to get the result
    * @return the result if it is ready, None otherwise
    * @throws Exception - if the result is an exception
    * @throws Error - if the result is an error
    */
    public func tryGet(): Option<DataModel> {
        if (isReady.load()) {
            return Some(result.getOrThrow())
        }
        return None
    }

    /*
    * Fulfills the future with a serialized result value
    * @param dataModel - the serialized result value to fulfill the future with
    * @return true if the future was successfully fulfilled, false if it was already fulfilled
    */
    public func fulfill(dataModel: DataModel): Bool {
        if (isReady.load()) {
            return false
        }

        setResult(deserializeFutureResult(dataModel))
    }

    /*
    * Fulfills the future with an exception
    * @param exception - the exception to fulfill the future with
    * @return true if the future was successfully fulfilled, false if it was already fulfilled
    */
    public func exn(exception: Exception): Bool {
        setResult(Exc(exception))
    }

    /*
    * Converts the distributed future to an actor future
    * @param T - the type of the result
    * @return the actor future
    */
    public func toActorFuture<T>(): ActorFuture<T> where T <: Serializable<T> {
        let fut = ActorFuture<T>({ => T.deserialize(this.get()) })
        spawn { fut.execute() }
        fut
    }


    /*
    * Sets the result of the future
    * @param result - the result to set
    * @return true if the future was successfully set, false if it was already set
    */
    func setResult(result: FutureResult<DataModel>): Bool {
        if (isReady.load()) {
            return false
        }
        synchronized(mtx) {
            if (isReady.load()) {
                return false
            }
            this.result = result
            isReady.store(true)
            mtx.notifyAll()
            true
        }
    }
}

/*
* An interface for local waitable objects
*/
public interface LocalWaitable {
    /*
    * Gets the result of the local waitable object
    * @return the result
    * @throws SerializationException - if the result cannot be serialized
    */
    func getResult(): DataModel

    // /*
    // * Creates a local waitable object from an actor future
    // * @param obj - the actor future to create the local waitable object from
    // * @return the local waitable object
    // */
    // static func fromActorFuture<T>(obj: Object): LocalWaitable where T <: Serializable<T> {
    //     if (let Some(actorFuture) = obj as ActorFuture<T>) {
    //         return actorFuture
    //     }
    //     throw IllegalArgumentException("Object is not an actor future.")
    // }
}

extend<T> ActorFuture<T> <: LocalWaitable where T <: Serializable<T> {

    /*
    * Gets the result of the local waitable object
    * @return the result
    */
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
* @throws DeserializationException - if the future result cannot be deserialized
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
                            case _ => throw DeserializationException("Invalid type field in FutureResult deserialization.")
                        }
                    case "value" =>
                        valueData = field.getData()
                    case "message" =>
                        match (field.getData()) {
                            case str: DataModelString => message = str.getValue()
                            case _ => throw DeserializationException("Invalid message field in FutureResult deserialization.")
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
                    throw DeserializationException("Invalid FutureResult type: " + resultType + ".")
            }
        case _ =>
            throw DeserializationException("Expected DataModelStruct for FutureResult deserialization.")
    }
}