package actors.tests.end2end

import std.unittest.*
import std.unittest.testmacro.*
import std.collection.*

import actors.*
import actors.macros.*

@Actor
class Bag <: Supervisable {
    private let items = ArrayList<Int64>()

    @Receiver[mode: AskAndTell]
    func add(x: Int64): Int64 {
        items.add(x)
        items.size
    }

    @Receiver[mode: AskOnly]
    func size(): Int64 { items.size }

    @Receiver[mode: TellOnly]
    func failing(): Unit { throw Exception("boom") }

    override public func onException(_: Exception): ControlAction {
        Continue
    }
}

@Test
public class LocalRuntimeTest {
    @TestCase
    func testTryGetBeforeExecution() {
        let b = Bag()
        let fut = b.size()
        let hasBefore = match (fut.tryGet()) { case Some(_) => true case None => false }
        @Expect(hasBefore, false)
        @Expect(fut.get(), 0)
        let hasAfter = match (fut.tryGet()) { case Some(_) => true case None => false }
        @Expect(hasAfter, true)
    }

    @TestCase
    func testTellOnlyExceptionIsSwallowed() {
        let b = Bag()
        b.failing(tell: True)
        let res = b.add(42).get()
        @Expect(res, 1)
    }

    @TestCase
    func testSequentialOrderingWithTell() {
        let b = Bag()
        b.add(1, tell: True)
        b.add(2, tell: True)
        let sz = b.size().get()
        @Expect(sz, 2)
    }
}