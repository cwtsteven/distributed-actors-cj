package actors_tests

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

    @Receiver
    func foo(): Int64 {
        x
    }

    @Receiver
    func bar(y: Int64): Int64 {
        x + y
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
}