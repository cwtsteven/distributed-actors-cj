/**
 * Created on 16/09/2025
 */

package actors.tcp_actor_system

import std.log.*

class TCPActorSystem {
    private static var __logger: ?Logger = None
    static mut prop logger: Logger {
        get() {
            match (__logger) {
                case Some(l) => l
                case None =>
                    let l = SimpleLogger()
                    __logger = Some(l)
                    l
            }
        }
        set(l) {
            __logger = Some(l)
        }
    }
}

extend<T> Array<T> {
    func fill(x: T) {
        for (i in 0..size) {
            this[i] = x
        }
    }
}