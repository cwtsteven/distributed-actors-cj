package actors.tests.end2end

import std.unittest.*
import std.unittest.testmacro.*

import actors.*
import actors.macros.*

@Actor
class MyActor {
    let x: Int64

    init(x: Int64) {
        this.x = x
    }

    @Receiver[mode: AskOnly]
    func foo(): Int64 {
        x
    }

    @Receiver[mode: AskOnly]
    func bar(y: Int64): Int64 {
        x + y
    }
}

@Actor
class NumberActor {
    private var isClosed = false
    public NumberActor(private var state: Int64) {}

    @Receiver[mode: AskAndTell]
    func add(x: Int64): Int64 {
        if (!isClosed) {
            state += x
        }
        return state
    }

    @Receiver[mode: TellOnly]
    func increment(): Unit {
        if (!isClosed) { state++ }
    }

    @Receiver[mode: TellOnly]
    func close(): Unit {
        isClosed = true
    }
}

@Test
public class ActorTest {
    @TestCase
    func testInit() {
        let a = MyActor(42)
        @Expect(a.x, 42)
    }

    @TestCase
    func testReceiver1() {
        let a = MyActor(42)
        let fut = a.foo()
        let res = fut.get()
        @Expect(res, 42)
    }

    @TestCase
    func testReceiver2() {
        let a = MyActor(21)
        let fut = a.bar(21)
        let res = fut.get()
        @Expect(res, 42)
    }

    @TestCase
    func testMessage1() {
        let n = NumberActor(13)
        n.increment(tell: True)
        n.close(tell: True)
        let fut = n.add(42)
        let res = fut.get()
        @Expect(res, 14)
    }

    @TestCase
    func testReceiverMirror1() {
        let n = NumberActor(42)
        n.add(103, tell: True)
        n.close(tell: True)
        let fut = n.add(0)
        let res = fut.get()
        @Expect(res, 145)
    }
}