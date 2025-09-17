package actors

import std.sync.*
import std.time.*

public interface Waitable {
    func wait(): Any
}

sealed abstract class ActorFuture<T> <: Waitable {
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

    public open func wait(): Any {
        this.get()
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

    public func cancel(): Unit {
        synchronized(mtx) {
            this.result = Exc(FutureCancelledException())
            isReady.store(true)
            cond.notifyAll()
        }
    }

    func execute(): Unit {
        synchronized(mtx) {
            if (isReady.load()) { return }
            try {
                this.result = Okay(closure())
            } catch (eff: ControlEffect) {
                this.result = Exc(InterruptedReceiverException(eff.action))
                throw eff
            } catch (e: Exception) {
                this.result = Exc(e)
                throw e
            } catch (e: Error) {
                this.result = Err(e)
                throw e
            } finally {
                isReady.store(true)
                cond.notifyAll()
            }
        }
    }
}
