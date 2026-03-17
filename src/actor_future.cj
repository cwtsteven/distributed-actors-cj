package actors

import std.collection.*
import std.sync.*
import std.time.*

import stdx.serialization.serialization.*

/*
* A future that may complete from a remote actor call and therefore can surface
* distributed-system failures in addition to the underlying receiver result.
*/
public open class DistributedActorFuture<T> {
    var result: FutureResult<T> = unsafe { zeroValue<FutureResult<T>>() }
    let isReady = AtomicBool(false)
    let mtx = Mutex()
    let cond: Condition
    private let resolver: Option<FutureResolver<T>>
    private var blockingGet: Option<() -> T>
    private var localTask: Option<() -> T>

    /*
    * Initializes an unresolved distributed future.
    * The result must later be resolved through a resolver or fulfillment path.
    */
    protected init() {
        resolver = None
        blockingGet = None
        localTask = None
        synchronized(mtx) {
            cond = mtx.condition()
        }
    }

    /*
    * Initializes a derived future whose value is resolved from another future
    * without spawning a new task.
    * @param resolver - resolves the derived future from the source future
    */
    init(resolver: FutureResolver<T>) {
        this.resolver = Some(resolver)
        blockingGet = None
        localTask = None
        synchronized(mtx) {
            cond = mtx.condition()
        }
    }

    /*
    * Initializes a distributed future whose value is produced by a blocking
    * operation when the caller explicitly waits for the result.
    * @param blockingGet - blocks until the final result is available
    */
    protected init(blockingGet: () -> T) {
        resolver = None
        this.blockingGet = Some(blockingGet)
        localTask = None
        synchronized(mtx) {
            cond = mtx.condition()
        }
    }

    /*
    * Blocks the current thread until the result is ready
    * @return the result
    * @throws Exception - if the remote call resolves with an exception or the
    *   distributed future machinery encounters a failure
    * @throws Error - if the remote call resolves with an error
    */
    public open func get(): T {
        if (isReady.load()) {
            return result.getOrThrow()
        }

        match (resolver) {
            case Some(resolver) =>
                fulfill(resolver.resolve())
                return result.getOrThrow()
            case None => ()
        }
        match (blockingGet) {
            case Some(blockingGet) =>
                let resolved = try {
                    Okay(blockingGet())
                } catch (e: Exception) {
                    FutureResult<T>.Exc(e)
                } catch (e: Error) {
                    FutureResult<T>.Err(e)
                }
                fulfill(resolved)
                return result.getOrThrow()
            case None => ()
        }

        synchronized(mtx) {
            while (!isReady.load()) {
                cond.wait()
            }
            return result.getOrThrow()
        }
    }

    /*
    * Blocks the current thread until the result is ready with a timeout
    * @param timeout - the timeout duration
    * @return the result within the timeout, None otherwise
    * @throws Exception - if the remote call resolves with an exception or the
    *   distributed future machinery encounters a failure
    * @throws Error - if the remote call resolves with an error
    */
    public open func get(timeout: Duration): Option<T> {
        if (timeout <= Duration.Zero) {
            return Some(get())
        }
        if (isReady.load()) {
            return Some(result.getOrThrow())
        }
        match (resolver) {
            case Some(resolver) =>
                match (resolver.resolve(timeout)) {
                    case Some(resolved) =>
                        fulfill(resolved)
                        return Some(result.getOrThrow())
                    case None => return None
                }
            case None => ()
        }
        match (blockingGet) {
            case Some(_) => ()
            case None => ()
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
        return tryGet()
    }

    /*
    * Tries to get the result
    * @return the result if it is ready, None otherwise
    * @throws Exception - if the remote call resolves with an exception or the
    *   distributed future machinery encounters a failure
    * @throws Error - if the remote call resolves with an error
    */
    public open func tryGet(): Option<T> {
        if (isReady.load()) {
            return Some(result.getOrThrow())
        }
        match (resolver) {
            case Some(resolver) =>
                match (resolver.tryResolve()) {
                    case Some(resolved) =>
                        fulfill(resolved)
                        return Some(result.getOrThrow())
                    case None => return None
                }
            case None => ()
        }
        match (blockingGet) {
            case Some(_) => return None
            case None => ()
        }
        return None
    }

    /*
    * Transforms the result of a future without spawning a new task.
    * The transform is only applied to successful results. Exceptions and errors
    * are forwarded unchanged.
    * @param transform - transforms the successful future value
    * @return a derived future that resolves lazily from this future
    * @throws Exception - if this future resolves with an exception, or if the transform throws
    * @throws Error - if this future resolves with an error, or if the transform throws an error
    */
    public func map<U>(transform: (T) -> U): DistributedActorFuture<U> {
        this.mapResult<U>({ result => result.map(transform) })
    }

    /*
    * Transforms the full result state of a future without spawning a new task.
    * Unlike `map`, this can rewrite success, exception, and error outcomes.
    * @param transform - transforms the resolved future result state
    * @return a derived future that resolves lazily from this future
    */
    protected func mapResult<U>(transform: (FutureResult<T>) -> FutureResult<U>): DistributedActorFuture<U> {
        DistributedActorFuture<U>(MappedFutureResolver<T, U>(this, transform))
    }

    /*
    * Fulfills the future with a resolved result state.
    * Repeated calls after the first completion are ignored.
    * @param resolved - the resolved result state
    */
    protected func fulfill(resolved: FutureResult<T>): Unit {
        synchronized(mtx) {
            if (isReady.load()) {
                return
            }
            this.result = resolved
            isReady.store(true)
            cond.notifyAll()
        }
    }

    /*
    * Installs a blocking completion callback for distributed futures that are
    * backed by transport-specific wait handles.
    * @param blockingGet - blocks until the final result is available
    */
    protected func installBlockingGet(blockingGet: () -> T): Unit {
        this.blockingGet = Some(blockingGet)
    }

    /*
    * Installs the local task used by `ActorFuture`.
    * @param task - the local actor task to execute
    */
    protected func installLocalTask(task: () -> T): Unit {
        localTask = Some(task)
    }

    /*
    * Runs the installed local task and captures its result state.
    * @return the resolved local task result
    */
    protected func runLocalTask(): FutureResult<T> {
        match (localTask) {
            case Some(task) =>
                try {
                    Okay(task())
                } catch (e: Exception) {
                    FutureResult<T>.Exc(e)
                } catch (e: Error) {
                    FutureResult<T>.Err(e)
                }
            case None =>
                FutureResult<T>.Exc(Exception("ActorFuture task has not been initialized."))
        }
    }

}

/*
* A future that represents the result of a closure submitted to a local Actor.
*/
public class ActorFuture<T> <: DistributedActorFuture<T> {
    /*
    * Initializes the ActorFuture
    * @param task - the task to execute
    */
    init(task: () -> T) {
        super()
        installLocalTask(task)
    }

    /*
    * Executes the local task and fulfills the future with the result.
    * @throws Exception - if the task throws an exception
    * @throws Error - if the task throws an error
    */
    func execute(): Unit {
        fulfill(runLocalTask())
    }
}

/*
* Internal strategy for resolving a derived future from an existing future
* without allocating a worker task.
*/
interface FutureResolver<T> {
    /*
    * Resolves the full result, blocking if necessary.
    * @return the resolved result state
    */
    func resolve(): FutureResult<T>

    /*
    * Resolves the full result within the given timeout.
    * @param timeout - the maximum time to wait
    * @return the resolved result state, or None if the timeout expires first
    */
    func resolve(timeout: Duration): Option<FutureResult<T>>

    /*
    * Attempts to resolve the full result without blocking.
    * @return the resolved result state if available, None otherwise
    */
    func tryResolve(): Option<FutureResult<T>>
}

/*
* Resolver used by future mapping and transport conversion helpers.
*/
private class MappedFutureResolver<S, T> <: FutureResolver<T> {
    let source: DistributedActorFuture<S>
    let transform: (FutureResult<S>) -> FutureResult<T>

    /*
    * Initializes a resolver that derives a result from another future.
    * @param source - the source future to observe
    * @param transform - rewrites the resolved source result into the target result
    */
    init(source: DistributedActorFuture<S>, transform: (FutureResult<S>) -> FutureResult<T>) {
        this.source = source
        this.transform = transform
    }

    /*
    * Resolves the mapped result, blocking on the source future if needed.
    * @return the transformed source result
    */
    public func resolve(): FutureResult<T> {
        transform(try {
            Okay(source.get())
        } catch (e: Exception) {
            Exc(e)
        } catch (e: Error) {
            Err(e)
        })
    }

    /*
    * Resolves the mapped result within the given timeout.
    * @param timeout - the maximum time to wait for the source future
    * @return the transformed source result, or None if the timeout expires first
    */
    public func resolve(timeout: Duration): Option<FutureResult<T>> {
        let captured = try {
            match (source.get(timeout)) {
                case Some(value) => Some(Okay(value))
                case None => Option<FutureResult<S>>.None
            }
        } catch (e: Exception) {
            Some(FutureResult<S>.Exc(e))
        } catch (e: Error) {
            Some(FutureResult<S>.Err(e))
        }
        match (captured) {
            case Some(result) => Some(transform(result))
            case None => None
        }
    }

    /*
    * Attempts to resolve the mapped result without blocking.
    * @return the transformed source result if available, None otherwise
    */
    public func tryResolve(): Option<FutureResult<T>> {
        let captured = try {
            match (source.tryGet()) {
                case Some(value) => Some(Okay(value))
                case None => Option<FutureResult<S>>.None
            }
        } catch (e: Exception) {
            Some(FutureResult<S>.Exc(e))
        } catch (e: Error) {
            Some(FutureResult<S>.Err(e))
        }
        match (captured) {
            case Some(result) => Some(transform(result))
            case None => None
        }
    }
}

/*
* Enum representing the result of a future
*/
protected enum FutureResult<T> {
    Okay(T)
    | Exc(Exception)
    | Err(Error)

    /*
    * Gets the result
    * @return the result
    * @throws Exception - if the result is an exception
    * @throws Error - if the result is an error
    */
    func getOrThrow(): T {
        match (this) {
            case Okay(res) => return res
            case Exc(e) => throw e
            case Err(e) => throw e
        }
    }

    /*
    * Maps only the successful value of the result.
    * Exceptions and errors are propagated unchanged.
    * @param transform - transforms the successful result value
    * @return the transformed result
    * @throws Exception - if the transform throws while handling a successful value
    * @throws Error - if the transform throws an error while handling a successful value
    */
    func map<U>(transform: (T) -> U): FutureResult<U> {
        match (this) {
            case Okay(value) =>
                try {
                    Okay(transform(value))
                } catch (e: Exception) {
                    FutureResult<U>.Exc(e)
                } catch (e: Error) {
                    FutureResult<U>.Err(e)
                }
            case Exc(e) => FutureResult<U>.Exc(e)
            case Err(e) => FutureResult<U>.Err(e)
        }
    }

}

extend<T> DistributedActorFuture<T> where T <: Serializable<T> {
    /*
    * Converts a local or distributed future into a distributed transport future of DataModel.
    * The derived future is resolved lazily in the caller's thread and does not
    * spawn a worker task.
    * @return a future whose successful result is serialized into `DataModel`
    * @throws Exception - if this future resolves with an exception or serialization fails
    * @throws Error - if this future resolves with an error
    */
    public func toDataModel(): DistributedActorFuture<DataModel> {
        this.mapResult<DataModel>({ result =>
            Okay(result.serialize())
        })
    }

    /*
    * Converts a transport future of DataModel into a typed distributed future.
    * The derived future is resolved lazily in the caller's thread and does not
    * spawn a worker task.
    * @param actorFuture - a future whose successful result contains serialized data
    * @return a typed distributed future that deserializes the serialized result on demand
    * @throws Exception - if the transport future resolves with an exception, or if deserialization fails
    * @throws Error - if the transport future resolves with an error
    */
    public static func fromDataModel(actorFuture: DistributedActorFuture<DataModel>): DistributedActorFuture<T> {
        actorFuture.map<T>({ dataModel =>
            T.deserialize(dataModel)
        })
    }
}

extend<T> FutureResult<T> <: Serializable<FutureResult<T>> where T <: Serializable<T> {
    /*
    * Serializes a future result into a transportable `DataModel`.
    * Successful results preserve the serialized value, while failures preserve
    * only their message text.
    * @return the serialized future result
    */
    public func serialize(): DataModel {
        match (this) {
            case Okay(value) =>
                let fields = ArrayList<Field>()
                fields.add(Field("type", DataModelString("Okay")))
                fields.add(Field("value", value.serialize()))
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
    * Deserializes a future result from `DataModel`.
    * Serialized `"Exc"` and `"Err"` payloads are reconstructed as thrown
    * `Exception`s carrying the remote message.
    * @param dataModel - the serialized future result
    * @return the deserialized future result
    * @throws Exception - if the payload shape is invalid or the payload cannot be deserialized
    */
    public static func deserialize(dataModel: DataModel): FutureResult<T> {
        match (dataModel) {
            case dm: DataModelStruct =>
                let fields = dm.getFields()
                var kind: String = ""
                var value: DataModel = DataModelNull()
                var message: String = ""

                for (field in fields) {
                    match (field.getName()) {
                        case "type" =>
                            match (field.getData()) {
                                case str: DataModelString => kind = str.getValue()
                                case _ => throw Exception("Invalid type field in FutureResult deserialization.")
                            }
                        case "value" =>
                            value = field.getData()
                        case "message" =>
                            match (field.getData()) {
                                case str: DataModelString => message = str.getValue()
                                case _ => throw Exception("Invalid message field in FutureResult deserialization.")
                            }
                        case _ => ()
                    }
                }

                match (kind) {
                    case "Okay" => Okay(T.deserialize(value))
                    case "Exc" => Exc(Exception(message))
                    case "Err" => Exc(Exception(message))
                    case _ => throw Exception("Invalid FutureResult type: " + kind + ".")
                }
            case _ => throw Exception("Expected DataModelStruct for FutureResult deserialization.")
        }
    }
}
