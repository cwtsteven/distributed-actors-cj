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
 *   }
 *
 * where the parts inside `...` depends on the options provided by the users.
 *
 * When it is set as a distributed actor interface, i.e. with [distributed: true],
 * the translation is more complex. Please refers to actor_interface_macro_distributed.cj for details.
 *
 */
public macro ActorInterface(attrs: Tokens, input: Tokens): Tokens {
    GenerateActorInterface.Run(attrs, input)
}

public macro ActorInterface(input: Tokens): Tokens {
    GenerateActorInterface.Run(Tokens(), input)
}

/**
 * This macro can be only defined at interfaces.
 *
 * @since
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
 *   interface Service <: Distributable<Service> {
 *     func foo(arg: T1, config!: ReceiverConfig): ActorFuture<T>
 *
 *     static func newProxy(name: String, actorSystem: ActorSystem): Service {
 *       ServiceProxy(ActorProxy(name, actorSystem))
 *     }
 *
 *     static func getMetadata(): Metadata { TODO }
 *
 *     static func dispatch(a: Service, info: ReceiverInfo, args: Array<DataModel>): Any { TODO }
 *   }
 *
 *   private class ServiceProxy {
 *     private let proxy = ActorProxy
 *
 *     init(proxy: ActorProxy) { this.proxy = proxy }
 *
 *     static let fooReceiverInfo = ReceiverInfo(...)
 *
 *     func foo(arg: T1, config!: ReceiverConfig = ReceiverConfig.default): ActorFuture<T> {
 *       proxy.post<T>(fooReceiverInfo, [arg1.serialzie()], config)
 *     }
 *   }
 *
 * where the parts inside `...` depends on the options provided by the users.
 *
 */