package actors.tests.end2end

import std.math.abs
import std.unittest.*
import std.unittest.testmacro.*

import actors.*
import actors.macros.*

@Actor
class Computer <: Supervisable {
    var failed = false
    @Receiver[mode: AskOnly]
    func divide(x: Float64, y: Float64): Float64 {
        if (abs(y) < 1e-10) {
            controlEffect(Stop)
        }
        return x / y
    }

    override public func onException(_: Exception): ControlAction {
        failed = true
        Poison(5)
    }
}

@Test
class TestHandlers {
    @TestCase
    func testControlEffect() {
        let c = Computer()
        let fut = c.divide(10.0, 1e-11)
        let correctEffect = try {
            fut.get()
            false
        } catch (e: InterruptedReceiverException) {
            match (e.action) {
                case Stop => true
                case _ => false
            }
        }
        let res = correctEffect && c.failed == false
        @Expect(res, true)
    }

    @TestCase
    func testStoppedMailbox() {
        let c = Computer()
        let correctEffect = try {
            let fut = c.divide(10.0, 1e-11)
            fut.get()
            false
        } catch (e: InterruptedReceiverException) {
            match (e.action) {
                case Stop => true
                case _ => false
            }
        }
        let newReceiverFailed = try {
            let fut = c.divide(1.0, 1.0)
            fut.get()
            false
        } catch (e: FutureCancelledException) {
            true
        }
        let res = correctEffect && c.failed == false && newReceiverFailed
        @Expect(res, true)
    }
}