import actors.*
import actors.macros.*

@Actor
public class Ping <: Supervisable {
    @Receiver
    func ping(other: Pong): Unit {
        println("ping")
        other.pong(this)
    }
}

@Actor
public class Pong <: Supervisable {
    @Receiver
    func pong(other: Ping): Unit {
        println("pong")
        other.ping(this)
    }
}

main() {
    let ping = Ping()
    let pong = Pong()
    ping.ping(pong)
    while (true) {}
}