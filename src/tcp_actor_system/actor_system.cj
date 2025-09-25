package actors.tcp_actor_system

import std.log.*

/*
* TCPActorSystem
*/
public class TCPActorSystem {
    private static var __logger: ?Logger = None

    /*
    * A mutable variable representing the logger of the TCPActorSystem
    */
    public static mut prop logger: Logger {
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