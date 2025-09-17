package actors.tests.end2end

import std.math.abs
import std.unittest.*
import std.unittest.testmacro.*

import actors.*
import actors.macros.*

func loop(n: Int64): Int64 {
    match (n) {
        case 1 => loop(-1) + loop(1)
        case -1 => loop(1) + loop(-1)
        case _ => 0
    }
}

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

    @Receiver[mode: AskOnly]
    func overflow(): Int64 {
        loop(1)
    }

    override public func onException(_: Exception): ControlAction {
        failed = true
        Poison(5)
    }

    override public func onError(e: Error): ControlAction {
        match (e) {
            case _: OutOfMemoryError | _: StackOverflowError => Stop
            case _ => Continue
        }
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

    @TestCase
    func testOverflow() {
        let c = Computer()
        let fut = c.overflow()
        let receiverOverflowed = try {
            fut.get()
            false
        } catch (e: StackOverflowError) {
            true
        }
        let newReceiverFailed = try {
            let fut = c.divide(1.0, 1.0)
            fut.get()
            false
        } catch (e: FutureCancelledException) {
            true
        }
        let res = receiverOverflowed && newReceiverFailed
        @Expect(res, true)
    }
}