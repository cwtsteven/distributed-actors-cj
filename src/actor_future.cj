package actors

import std.sync.*
import std.time.*

/*
* A future that represents the result of a closure submitted to an Actor.
*/
public class ActorFuture<T> {
    var result: FutureResult<T> = unsafe { zeroValue<FutureResult<T>>() }
    let isReady = AtomicBool(false)
    let mtx = Monitor()
    let closure: () -> T

    /*
    * Initializes the ActorFuture
    * @param task - the task to execute
    */
    init(task: () -> T) {
        closure = task
    }

    /*
    * Blocks the current thread until the result is ready
    * @return the result
    * @throws Exception - if the closure throws an exception
    * @throws Error - if the closure throws an error
    */
    public func get(): T {
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
    public func get(timeout: Duration): Option<T> {
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
    public func tryGet(): Option<T> {
        if (isReady.load()) {
            return Some(result.getOrThrow())
        }
        return None
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
