# Call @Receiver without ActorFuture

## 1 Brief summary

Introduce `@Receiver`s that can be called in `Tell` (fire-and-forget) mode
which bypasses the `ActorFuture` mechanism.

## 2 Motivation

Currently, member functions annotated with `@Receiver` can only be called in
`Ask` mode, that is, they return an `ActorFuture`.
This is useful if the caller wants to wait for the
function to return a value or needs to synchronize with the actor.
However, in many situations this synchronization is not required, so
`ActorFuture`s introduce an unnecessary overhead that users should
be able to bypass when appropriate. We propose to allow
`Receiver`-annotated functions to be called in `Tell` mode, bypassing
the `ActorFuture` mechanism.

## 3 Impact analysis

This will impact the `actors` and `actors.macros` libraries.
Existing programs using this library might be affected if
methods annotated by `@Receiver` have a parameter named
`tell`.

## 4 Design proposal

Allow callers to pass an additional argument of type `Tell`
to functions annotated with `@Receiver` to make them return `Unit` and
prevent them from using `ActorFuture`s.
Developpers can restrict the generation of either `Ask`-ing or `Tell`-ing functions
by setting a `mode` option in the `@Receiver` macro.
This is of special interest to developpers who use
`internal` `@Receiver`-annotated functions and only use one of the modes within the
package, which would trigger 'unused function' warnings.

## 5 Implementation

Introduce the `postMessage` function as a member of `SequentialDispatcher`.
```Cangjie
public func postMessage(f: () -> Unit, priority!: Int64 = 5): Unit {
    mailbox.add((this, f), priority)
    numMsg.signal()
}
```

For functions annotated with `@Receiver`, an additional
`Tell`-ing function will be generated that can be used
to call the function without `ActorFuture` synchronization:

```Cangjie
@Actor
class A {

    /* ... */

    @Receiver
    func foo() Int64 { 42 }
}


// becomes

class A {

    /* ... */

    func foo(): ActorFuture<Int64> {
        return dispatcher.post<Int64>({ => 42 })
    }

    func foo(tell!: Tell): Unit {
        let _ = tell
        return dispatcher.postMessage({ =>
            { => 42 }()
            return
        })
    }
}
```

The `tell` parameter serves as a way to have different
function signatures while keeping the same function identifier.

The `mode` option can be used to restrict the generation of `Tell`-ing or `Ask`-ing
functions:

```Cangjie
@Actor
class A {

    /* ... */

    @Receiver[mode: AskOnly]
    func foo(): Int64 {
        42
    }

    @Receiver[mode: TellOnly]
    func bar(): Unit {
        println("bar")
    }
}

// becomes

@Actor
class A {

    /* ... */

    func foo(): ActorFuture<Int64> {
        return dispatcher.post<Int64>({ => 42 })
    }

    func bar(tell!: Tell): Unit {
        let _ = tell
        return dispatcher.postMessage({ =>
            { => println("bar") }()
            return
        })
    }
}
```

## 6 Test plan

## 7 Conclusion

