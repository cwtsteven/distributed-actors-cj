macro package actors.macros

import std.ast.*

import actors.macros.internal.*

/**
 * This macro can be only defined at interfaces.
 *
 * @since
 *
 * @throws MacroException if
 *   1. the input is not an InterfaceDecl; or
 *   2. any @prefixReceiver marked function is not abstract.
 *
 * @throws MacroException for invalid options. TOD
 *
 * This macro essentially does the following translation:
 *
 *   @ActorInterface[opts1]
 *   interface Service {
 *     @prefixReceiver[opts2]
 *     func foo(arg: T1): T
 *   }
 *
 *     == translate into ==>
 *
 *   interface Service {
 *     func foo(arg: T1, config!: ReceiverConfig): ActorFuture<T>
 *     func foo(arg: T1, config!: ReceiverConfig, tell!: Tell): Unit
 *   }
 *
 * where the parts inside `...` depends on the options provided by the users.
 *
 * When it is set as a distributed actor interface, i.e. with [distributed: true],
 * the translation is more complex.
 *
* @throws MacroException if
 *   1. the input is not an InterfaceDecl; or
 *   2. the InterfaceDecl has type parameters; or
 *   3. any @prefixReceiver marked function is not abstract; or
 *   4. any @prefixReceiver marked function has type parameters; or
 *   5. any two @prefixReceiver marked function having the same identifier.
 *
 * @throws MacroException for invalid options.
 *
 * This macro essentially does the following translation:
 *
 *   @ActorInterface[distributed: true, opts1]
 *   interface Service {
 *     @prefixReceiver[opts2]
 *     func foo(arg: T1): T
 *   }
 *
 *     == translate into ==>
 *
 *   interface Service <: Distributable & Proxyable<Service> {
 *     func foo(arg: T1): ActorFuture<T>
 *     func foo(arg: T1, config!: ReceiverConfig): ActorFuture<T>
 *     func foo(arg: T1, tell!: Tell): Unit
 *     func foo(arg: T1, config!: ReceiverConfig, tell!: Tell): Unit
 *
 *     static func getMetadata(): Metadata
 *     static func getProxy(name: String, info: HostInfo): Service
 *
 *     func dispatchTell(receiverName: String, args: Array<DataModel>, config: ReceiverConfig): Unit
 *     func dispatchAsk(receiverName: String, args: Array<DataModel>, config: ReceiverConfig): Waitable
 *   }
 *
 *   public class ServiceProxy <: Service {
 *     static let dispatchTellMap = HashMap<String, (Service, Array<DataModel>, ReceiverConfig) -> Unit>()
 *     static let dispatchAskMap = HashMap<String, (Service, Array<DataModel>, ReceiverConfig) -> Waitable>()
 *     static let receiverInfosArray = ArrayList<ReceiverInfo>()
 *
 *     static init() {
 *       dispatchTellMap.add("foo", { a, args, config =>
 *         a.foo(Int64.deserialize(args[0]), config: config, tell: True)
 *       })
 *       dispatchAskMap.add("foo", { a, args, config =>
 *           a.foo(Int64.deserialize(args[0]), config: config)
 *       })
 *       receiverInfosArray.add(
 *         ReceiverInfo("foo", description, customInfo,
 *         [("x", TypeModel.of<Int64>())], TypeModel.of<Int64>())
 *       )
 *     }
 *
 *     private let proxy: ActorProxy
 *
 *     public init(name: String, info: HostInfo) {
 *       proxy = ActorProxy(name, info)
 *     }
 *
 *     func foo(arg: T1, config!: ReceiverConfig = ReceiverConfig.default): ActorFuture<T> {
 *       proxy.dispatchAsk("foo", [arg.serialize()], config)
 *     }
 *
 *     func foo(arg: T1, config!: ReceiverConfig = ReceiverConfig.default, tell!: Tell): Unit {
 *       proxy.dispatchTell("foo", [arg.serialize()], config)
 *     }
 *   }
 *
 * where the parts inside `...` depends on the options provided by the users.
 *
 */
public macro ActorInterface(attrs: Tokens, input: Tokens): Tokens {
    GenerateActorInterface.Run(attrs, input)
}

public macro ActorInterface(input: Tokens): Tokens {
    GenerateActorInterface.Run(Tokens(), input)
}