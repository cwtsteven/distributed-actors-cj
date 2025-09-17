package actors

import std.sync.*
import std.time.*

public interface Waitable {
    func wait(): Any
}

sealed abstract class ActorFuture<T> <: Waitable {
    protected var result: FutureResult<T> = unsafe { zeroValue<FutureResult<T>>() }
    protected let isReady = AtomicBool(false)
    protected let mtx = Monitor()

    protected init() {
    }

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