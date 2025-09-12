import stdx.encoding.json.*
import stdx.serialization.serialization.*

import actors.*
import actors.macros.*

// @ActorInterface
// public interface Service {
//     @Receiver
//     func foo(x: Int64): Int64
// }

// generated
public interface Service <: Distributable<Service> {
    func foo(x: Int64, config!: ReceiverConfig): ActorFuture<Int64>

    static func newProxy(name: String, actorSystem: ActorSystem): Service {
        ServiceProxy(ActorProxy(name, actorSystem))
    }

    static func getMetadata(): Metadata {
        Metadata([ServiceProxy.fooReceiverInfo], "", JsonValue.fromStr("{}"))
    }

    static func dispatch(a: Service, receiverName: String, args: Array<DataModel>, config!: ReceiverConfig): Any {
        // here it should compare info with all other info and chooese the one to call
        let _ = receiverName
        let x = Int64.deserialize(args[0])
        a.foo(x, config: config)
    }
}

// generated
class ServiceProxy <: Service {
    ServiceProxy(private let proxy: ActorProxy) {}

    public func foo(x: Int64, config!: ReceiverConfig = ReceiverConfig.default): ActorFuture<Int64> {
        proxy.post<Int64>("foo", [x.serialize()], config: config)
    }

    // note: need reflection to generate the schema
    static let fooReceiverInfo = ReceiverInfo("foo", JsonValue.fromStr("{}"), "foo", [("x", IntType)], IntType)
}

@Actor
public class MyService <: Service {

    @Receiver
    public func foo(x: Int64): Int64 {
        x + 42
    }
}

main() {
    println("ok")
}