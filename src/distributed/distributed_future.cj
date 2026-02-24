package actors.distributed

import std.collection.*
import std.sync.*
import std.time.*

import actors.*

import stdx.serialization.serialization.*

/*
* A class representing a distributed future obtained from calling a remote receiver.
*/
public class DistributedFuture {
    private var result: FutureResult<DataModel> = unsafe { zeroValue<FutureResult<DataModel>>() }
    private let isReady = AtomicBool(false)
    private let mtx = Mutex()
    private let cond: Condition

    init() {
        synchronized(mtx) {
            cond = mtx.condition()
        }
    }

    /*
    * Blocks the current thread until the result is ready and returns the result
    * @return the result
    * @throws RemoteException - if the remote connection fails
    * @throws RemoteReceiverException - if the result is an exception or error thrown from the remote receiver execution
    * @throws ActorSystemException - for any system-specific errors
    */
    public func get(): DataModel {
        if (isReady.load()) {
            return result.getOrThrow()
        }
        synchronized(mtx) {
            while (!isReady.load()) {
                cond.wait()
            }
            return result.getOrThrow()
        }
    }

    /*
    * Blocks the current thread until the result is ready with a timeout and returns the result
    * @param timeout - the timeout duration
    * @return the result if it is ready within the timeout, None otherwise
    * @throws RemoteException - if the remote connection fails
    * @throws RemoteReceiverException - if the result is an exception or error thrown from the remote receiver execution
    * @throws ActorSystemException - for any system-specific errors
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
                cond.wait(timeout: d)
            }
        }
        tryGet()
    }

    /*
    * Tries to get the result
    * @return the result if it is ready, None otherwise
    * @throws RemoteException - if the remote connection fails
    * @throws RemoteReceiverException - if the result is an exception or error thrown from the remote receiver execution
    * @throws ActorSystemException - for any system-specific errors
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
    * @throws IllegalArgumentException - if the data model cannot be properly deserialized
    */
    public func fulfill(dataModel: DataModel): Bool {
        if (isReady.load()) {
            return false
        }
        try {
            setResult(deserializeFutureResult(dataModel))
        } catch (e: DeserializationException) {
            throw IllegalArgumentException("Invalid future result: " + e.message)
        }
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
        synchronized(mtx) {
            if (isReady.load()) {
                return false
            }
            this.result = result
            isReady.store(true)
            cond.notifyAll()
            true
        }
    }
}

/*
* A common interface for both local and distributed futures.
* Provides a method to get the result of the future in serialized form.
*/
public interface LocalWaitable {
    /*
    * Gets the result of the local waitable object
    * @return the result
    * @throws SerializationException - if the result cannot be serialized
    */
    func getResult(): DataModel
}

extend<T> ActorFuture<T> <: LocalWaitable where T <: Serializable<T> {

    /*
    * Blocks current thread until the result is ready and returns the result in serialized form
    * @return the result in serialized form
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
            fields.add(Field("type", DataModelString("Okay")))
            fields.add(Field("value", value))
            DataModelStruct(fields)
        case Exc(exception) =>
            let fields = ArrayList<Field>()
            fields.add(Field("type", DataModelString("Exc")))
            fields.add(Field("message", DataModelString(exception.message)))
            DataModelStruct(fields)
        case Err(error) =>
            let fields = ArrayList<Field>()
            fields.add(Field("type", DataModelString("Err")))
            fields.add(Field("message", DataModelString(error.message)))
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
