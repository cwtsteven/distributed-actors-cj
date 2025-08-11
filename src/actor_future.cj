package actors

import std.sync.*
import std.time.*

sealed abstract class ActorFuture<T> {
    protected var result: FutureResult<T> = unsafe { zeroValue<FutureResult<T>>() }
    protected let isReady = AtomicBool(false)
    protected let mtx = Mutex()
    protected let cond: Condition

    protected init() {
        synchronized(mtx) {
            cond = mtx.condition()
        }
    }

    public open func get(): T {
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
                cond.wait(timeout: d)
            }
        }
        return tryGet()
    }

    public open func tryGet(): Option<T> {
        if (isReady.load()) {
            return Some(result.getOrThrow())
        }
        return None
    }
}

public class LocalActorFuture<T> <: ActorFuture<T> {
    private let closure: () -> T

    init(task: () -> T) {
        closure = task
    }

    public override func get(): T {
        super.get()
    }

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
            cond.notifyAll()
        }
    }
}

public class DistributedActorFuture<T> <: ActorFuture<T> {
    init() {}

    public func fulfill(value: Any): Bool {
        if (isReady.load()) {
            return false
        }

        let res: FutureResult<T> = match (value) {
            case v: T => Okay(v)
            case e: Exception => Exc(e)
            case e: Error => Err(e)
            case _ =>
                throw IllegalArgumentException("TODO")
        }

        synchronized(mtx) {
            if (isReady.load()) {
                return false
            }
            this.result = res
            isReady.store(true)
            cond.notifyAll()
            true
        }
    }
}

protected enum FutureResult<T> {
    Okay(T)
    | Exc(Exception)
    | Err(Error)

    func getOrThrow(): T {
        match (this) {
            case Okay(res) => return res
            case Exc(e) => throw e
            case Err(e) => throw e
        }
    }
}