package actors.tests.end2end

import std.unittest.*
import std.unittest.testmacro.*

import actors.*
import actors.macros.*

// Simple priority actor
@Actor[enableReceiverPriority: true]
class PriorityActor <: Supervisable {
    private var counter: Int64 = 0

    @Receiver[priority: 10, mode: AskOnly]
    func highPriorityTask(): String {
        counter++
        "high_priority_${counter}"
    }

    @Receiver[priority: 5, mode: AskOnly]
    func mediumPriorityTask(): String {
        counter++
        "medium_priority_${counter}"
    }

    @Receiver[priority: 1, mode: AskOnly]
    func lowPriorityTask(): String {
        counter++
        "low_priority_${counter}"
    }

    @Receiver[mode: AskOnly]
    func getCounter(): Int64 {
        counter
    }
}

@Test
public class PriorityTest {
    @TestCase
    func testBasicPriorityOperations() {
        let actor = PriorityActor()

        // Test high priority task
        let highResult = actor.highPriorityTask().get()
        @Expect(highResult.contains("high_priority"), true)
        @Expect(actor.getCounter().get(), 1)

        // Test medium priority task
        let mediumResult = actor.mediumPriorityTask().get()
        @Expect(mediumResult.contains("medium_priority"), true)
        @Expect(actor.getCounter().get(), 2)

        // Test low priority task
        let lowResult = actor.lowPriorityTask().get()
        @Expect(lowResult.contains("low_priority"), true)
        @Expect(actor.getCounter().get(), 3)
    }

}
