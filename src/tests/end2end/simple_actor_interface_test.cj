package actors.tests.end2end

import std.unittest.*
import std.unittest.testmacro.*

import actors.*
import actors.macros.*

// Simple actor interface test
@ActorInterface
interface SimpleService {
    @Receiver
    func getValue(): Int64

    @Receiver
    func addValue(x: Int64): Int64
}

@Actor
class SimpleServiceImpl <: SimpleService {
    private var value: Int64 = 0

    @Receiver
    public func getValue(): Int64 {
        value
    }

    @Receiver
    public func addValue(x: Int64): Int64 {
        value += x
        value
    }
}

@Test
public class SimpleActorInterfaceTest {
    @TestCase
    func testSimpleServiceInterface() {
        let actor = SimpleServiceImpl()
        let service: SimpleService = actor

        // Test basic functionality
        let future1 = service.getValue(config: ReceiverConfig.default)
        @Expect(future1.get(), 0)

        let future2 = service.addValue(10, config: ReceiverConfig.default)
        @Expect(future2.get(), 10)

        let future3 = service.getValue(config: ReceiverConfig.default)
        @Expect(future3.get(), 10)
    }
}
