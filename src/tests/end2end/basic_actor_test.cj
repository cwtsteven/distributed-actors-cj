package actors.tests.end2end

import std.unittest.*
import std.unittest.testmacro.*

import actors.*
import actors.macros.*

// Simple counter actor
@Actor
class CounterActor {
    private var count: Int64 = 0

    @Receiver[mode: AskOnly]
    func getCount(): Int64 {
        count
    }

    @Receiver[mode: AskAndTell]
    func increment(): Int64 {
        count++
        count
    }

    @Receiver[mode: TellOnly]
    func reset(): Unit {
        count = 0
    }
}

// Simple calculator actor
@Actor
class CalculatorActor {
    @Receiver[mode: AskOnly]
    func add(a: Int64, b: Int64): Int64 {
        a + b
    }

    @Receiver[mode: AskOnly]
    func multiply(a: Int64, b: Int64): Int64 {
        a * b
    }
}

@Test
public class BasicActorTest {
    @TestCase
    func testCounterActorBasicOperations() {
        let counter = CounterActor()

        // Test initial state
        @Expect(counter.getCount().get(), 0)

        // Test increment
        @Expect(counter.increment().get(), 1)
        @Expect(counter.increment().get(), 2)
        @Expect(counter.getCount().get(), 2)

        // Test reset
        counter.reset(tell: True)
        @Expect(counter.getCount().get(), 0)
    }

    @TestCase
    func testCounterActorWithTellMode() {
        let counter = CounterActor()

        // Use tell mode for increment
        counter.increment(tell: True)
        counter.increment(tell: True)

        // Check final count
        @Expect(counter.getCount().get(), 2)
    }

    @TestCase
    func testCalculatorActorOperations() {
        let calculator = CalculatorActor()

        // Test addition
        @Expect(calculator.add(5, 3).get(), 8)
        @Expect(calculator.add(10, 20).get(), 30)

        // Test multiplication
        @Expect(calculator.multiply(4, 5).get(), 20)
        @Expect(calculator.multiply(7, 8).get(), 56)
    }

    @TestCase
    func testMultipleActorsIndependence() {
        let counter1 = CounterActor()
        let counter2 = CounterActor()

        // Each actor should maintain its own state
        counter1.increment(tell: True)
        counter1.increment(tell: True)

        counter2.increment(tell: True)

        @Expect(counter1.getCount().get(), 2)
        @Expect(counter2.getCount().get(), 1)
    }
}
