import stdx.serialization.serialization.*

import actors.*
import actors.macros.*

// @ActorInterface
// public interface Service {
//     func foo(x: Int64): Int64
// }

// generated
public interface Service <: Distributable<Service> {
    func foo(x: Int64): ActorFuture<Int64>

    static func newProxy(name: String, actorSystem: ActorSystem): Service {
        ServiceProxy(ActorProxy(name, actorSystem))
    }

    static func getMetadata(): Metadata {
        Metadata([ServiceProxy.fooInfo], "", [])
    }

    static func dispatch<Actor>(a: Actor, info: ReceiverInfo, args: Array<DataModel>): Any where Actor <: Service {
        // here it should compare info with all other info and chooese the one to call
        let _ = info
        let x = Int64.deserialize(args[0])
        a.foo(x)
    }
}

// generated
class ServiceProxy <: Service {
    ServiceProxy(private let proxy: ActorProxy) {}

    public func foo(x: Int64): ActorFuture<Int64> {
        proxy.post<Int64>(fooInfo, [x.serialize()])
    }

    // note: need reflection to generate the schema
    static let fooInfo = ReceiverInfo("foo", [("x", IntType)], IntType)
}

@Actor
public class MyService <: Service {

    @Receiver
    public func foo(x: Int64): Int64 {
        x + 42
    }
}

main() {}