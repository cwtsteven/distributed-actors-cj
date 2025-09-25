package actors

import std.sync.*
import std.time.*

import serialization.serialization.*

/*
* Abstract base class representing the pending result of a closure submitted to an Actor.
*/
sealed abstract class ActorFuture<T> {
    protected var result: FutureResult<T> = unsafe { zeroValue<FutureResult<T>>() }
    protected let isReady = AtomicBool(false)
    protected let mtx = Monitor()

    protected init() {}

    /*
    * Blocks the current thread until the result is ready
    * @return the result
    * @throws Exception - if the closure throws an exception
    * @throws Error - if the closure throws an error
    */
    public open func get(): T {
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
    * Blocks the current thread until the result is ready with a timeout
    * @param timeout - the timeout duration
    * @return the result within the timeout, None otherwise
    * @throws Exception - if the closure throws an exception
    * @throws Error - if the closure throws an error
    */
    public open func get(timeout: Duration): Option<T> {
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
    * @throws Exception - if the closure throws an exception
    * @throws Error - if the closure throws an error
    */
    public open func tryGet(): Option<T> {
        if (isReady.load()) {
            return Some(result.getOrThrow())
        }
        return None
    }
}

/*
* A concrete implementation of ActorFuture for local actor communication
*/
public class LocalActorFuture<T> <: ActorFuture<T> {
    private let closure: () -> T

    /*
    * Initializes the LocalActorFuture
    * @param task - the task to execute
    */
    init(task: () -> T) {
        closure = task
    }

    /*
    * Executes the task
    */
    func execute(): Unit {
        synchronized(mtx) {
            try {
                this.result = Okay(closure())
            } catch (e: Exception) {
                this.result = Exc(e)
            } catch (e: Error) {
                this.result = Err(e)
            }

            isReady.store(true)
            mtx.notifyAll()
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
}

extend<T> ActorFuture<T> <: Waitable where T <: Serializable<T> {
    /*
    * Waits for the future to be ready
    * @return the result
    * @throws Exception - if the future throws an exception
    * @throws Error - if the future throws an error
    */
    public func wait(): DataModel {
        try {
            get()
        } catch (_: Exception) {
        } catch (_: Error) {}

        this.result.serialize()
    }
}