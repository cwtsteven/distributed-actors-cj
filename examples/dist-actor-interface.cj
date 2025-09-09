import std.collection.*

import stdx.serialization.serialization.*

import actors.*
import actors.macros.*

@ActorInterface[distributed: true]
public interface Service {

    @Receiver
    func foo(x: Int64): Int64
}

@Actor
public class MyService <: Service {

    @Receiver
    public func foo(x: Int64): Int64 {
        println("inside foo")
        x + 42
    }
}

func test(s: Service) {
    s.foo(0).get()
}

main() {}