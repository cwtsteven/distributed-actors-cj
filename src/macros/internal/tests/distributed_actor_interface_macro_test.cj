package actors.macros.internal.tests

import std.ast.*
import std.unittest.*
import std.unittest.testmacro.*

import actors.macros.internal.*

@Test
public class DistributedActorInterfaceMacroTest {

    // ============================================================================
    // BASIC FUNCTIONALITY TESTS
    // ============================================================================

    @TestCase
    func testNonInterfaceDeclaration() {
        let tokens = quote(
            class NonInterface {
                func test(): Unit {}
            }
        )
        let exn = @AssertThrows[MacroException](GenerateActorInterface.Run(Tokens(), tokens))
        @Expect(exn.message.contains(ActorInterfaceMacroInvalidDecl.toString()), true)
    }

    @TestCase
    func testValidDistributedInterfaceWithoutOptions() {
        let tokens = quote(
            interface ValidDistributedInterface {
                func test(): Unit {}
            }
        )
        let result = GenerateActorInterface.Run(Tokens(), tokens)
        @Expect(result.size > 0, true)
    }

    @TestCase
    func testEmptyInterface() {
        let tokens = quote(interface EmptyInterface {})
        let options = quote(distributed: true)
        let result = GenerateActorInterface.Run(options, tokens)
        @Expect(result.size > 0, true)
    }

    @TestCase
    func testInterfaceWithOnlyNonReceivers() {
        let tokens = quote(
            interface TestInterface {
                func regularMethod(): Unit {}
                func anotherMethod(): String {}
                func thirdMethod(input: Int64): Bool {}
            }
        )
        let options = quote(distributed: true)
        let result = GenerateActorInterface.Run(options, tokens)
        @Expect(result.size > 0, true)
    }

    // ============================================================================
    // DISTRIBUTED OPTION TESTS
    // ============================================================================

    @TestCase
    func testDistributedTrue() {
        let tokens = quote(
            interface ValidDistributedInterface {
                func test(): Unit {}
            }
        )
        let options = quote(distributed: true)
        let result = GenerateActorInterface.Run(options, tokens)
        @Expect(result.size > 0, true)
    }

    @TestCase
    func testDistributedFalse() {
        let tokens = quote(
            interface ValidDistributedInterface {
                func test(): Unit {}
            }
        )
        let options = quote(distributed: false)
        let result = GenerateActorInterface.Run(options, tokens)
        @Expect(result.size > 0, true)
    }

    @TestCase
    func testInvalidDistributedValue() {
        let tokens = quote(
            interface ValidDistributedInterface {
                func test(): Unit {}
            }
        )
        let options = quote(distributed: "invalid")
        let exn = @AssertThrows[MacroException](GenerateActorInterface.Run(options, tokens))
        @Expect(exn.message.contains(MacroOptionDistributedIllegalArgument.toString()), true)
    }

    @TestCase
    func testDistributedWithNonBooleanValue() {
        let tokens = quote(
            interface ValidDistributedInterface {
                func test(): Unit {}
            }
        )
        let options = quote(distributed: 123)
        let exn = @AssertThrows[MacroException](GenerateActorInterface.Run(options, tokens))
        @Expect(exn.message.contains(MacroOptionDistributedIllegalArgument.toString()), true)
    }

    // ============================================================================
    // DESCRIPTION OPTION TESTS
    // ============================================================================

    @TestCase
    func testValidDescription() {
        let tokens = quote(
            interface ValidDistributedInterface {
                func test(): Unit {}
            }
        )
        let options = quote(
            distributed: true,
            description: "Test distributed service"
        )
        let result = GenerateActorInterface.Run(options, tokens)
        @Expect(result.size > 0, true)
    }

    // ============================================================================
    // CUSTOM INFO OPTION TESTS
    // ============================================================================

    @TestCase
    func testValidCustomInfoObject() {
        let tokens = quote(
            interface ValidDistributedInterface {
                func test(): Unit {}
            }
        )
        let options = quote(
            distributed: true,
            customInfo: """
            { "service": "test", "version": "1.0" }
            """
        )
        let result = GenerateActorInterface.Run(options, tokens)
        @Expect(result.size > 0, true)
    }

    @TestCase
    func testInvalidCustomInfoFormat() {
        let tokens = quote(
            interface ValidDistributedInterface {
                func test(): Unit {}
            }
        )
        let options = quote(distributed: true, customInfo: "not valid json at all")
        let exn = @AssertThrows[MacroException](GenerateActorInterface.Run(options, tokens))
        @Expect(exn.message.contains(MacroOptionCustomInfosInvalidFormat.toString()), true)
    }

    // ============================================================================
    // ENABLE RECEIVER PRIORITY OPTION TESTS
    // ============================================================================

    @TestCase
    func testEnableReceiverPriorityTrue() {
        let tokens = createDeclWithReceivers(
            quote(interface TestInterface),
            [(quote([priority: 5]), quote(func test(): Unit))], [])
        let options = quote(distributed: true, enableReceiverPriority: true)
        let exn = @AssertThrows[MacroException](GenerateActorInterface.Run(options, tokens))
        @Expect(exn.message.contains(MacroOptionNotAllowed(Priority(5), ACTOR_DISTRIBUTED_INTERFACE_MACRO).toString()), true)
    }

    @TestCase
    func testEnableReceiverPriorityFalse() {
        let tokens = createDeclWithReceivers(
            quote(interface TestInterface),
            [(quote([priority: 5]), quote(func test(): Unit))], [])
        let options = quote(distributed: true, enableReceiverPriority: false)
        let exn = @AssertThrows[MacroException](GenerateActorInterface.Run(options, tokens))
        @Expect(exn.message.contains(MacroOptionNotAllowed(Priority(5), ACTOR_DISTRIBUTED_INTERFACE_MACRO).toString()), true)
    }

    @TestCase
    func testInvalidEnableReceiverPriorityValue() {
        let tokens = createDeclWithReceivers(
            quote(interface TestInterface),
            [(quote([priority: 5]), quote(func test(): Unit))], [])
        let options = quote(distributed: true, enableReceiverPriority: "invalid")
        let exn = @AssertThrows[MacroException](GenerateActorInterface.Run(options, tokens))
        @Expect(exn.message.contains(MacroOptionEnableReceiverPriorityIllegalArgument.toString()), true)
    }


    // ============================================================================
    // RECEIVER TESTS
    // ============================================================================

    @TestCase
    func testSingleReceiver() {
        let tokens = createDeclWithReceivers(
            quote(interface TestInterface),
            [(quote(), quote(func test(): Unit))], [])
        let options = quote(distributed: true)
        let result = GenerateActorInterface.Run(options, tokens)
        @Expect(result.size > 0, true)
    }

    @TestCase
    func testMultipleReceivers() {
        let tokens = createDeclWithReceivers(
            quote(interface TestInterface),
            [(quote(), quote(func test1(): Unit)),
            (quote(), quote(func test2(): String)),
            (quote(), quote(func test3(input: Int64): Bool))],
            [])
        let options = quote(distributed: true)
        let result = GenerateActorInterface.Run(options, tokens)
        @Expect(result.size > 0, true)
    }

    @TestCase
    func testMixedReceiversAndNonReceivers() {
        let tokens = createDeclWithReceivers(
            quote(interface TestInterface),
            [(quote(), quote(func receiverMethod(): Unit)),
            (quote(), quote(func anotherReceiver(input: String): String))],
            [quote(func nonReceiverMethod(): Unit)])
        let options = quote(distributed: true)
        let result = GenerateActorInterface.Run(options, tokens)
        @Expect(result.size > 0, true)
    }

    // ============================================================================
    // RECEIVER MODE TESTS
    // ============================================================================

    @TestCase
    func testReceiverWithAskOnlyMode() {
        let tokens = createDeclWithReceivers(
            quote(interface TestInterface),
            [(quote([mode: AskOnly]), quote(func askOnly(): String))], [])
        let options = quote(distributed: true)
        let exn = @AssertThrows[MacroException](GenerateActorInterface.Run(options, tokens))
        println(exn.message)
        @Expect(exn.message.contains(MacroOptionNotAllowed(Mode(AskOnly), ACTOR_DISTRIBUTED_INTERFACE_MACRO).toString()), true)
    }

    @TestCase
    func testReceiverWithTellOnlyMode() {
        let tokens = createDeclWithReceivers(
            quote(interface TestInterface),
            [(quote([mode: TellOnly]), quote(func tellOnly(message: String): Unit))], [])
        let options = quote(distributed: true)
        let exn = @AssertThrows[MacroException](GenerateActorInterface.Run(options, tokens))
        @Expect(exn.message.contains(MacroOptionNotAllowed(Mode(TellOnly), ACTOR_DISTRIBUTED_INTERFACE_MACRO).toString()), true)
    }

    @TestCase
    func testReceiverWithAskAndTellMode() {
        let tokens = createDeclWithReceivers(
            quote(interface TestInterface),
            [(quote([mode: AskAndTell]), quote(func askAndTell(input: String): String))], [])
        let options = quote(distributed: true)
        let exn = @AssertThrows[MacroException](GenerateActorInterface.Run(options, tokens))
        @Expect(exn.message.contains(MacroOptionNotAllowed(Mode(AskAndTell), ACTOR_DISTRIBUTED_INTERFACE_MACRO).toString()), true)
    }


    @TestCase
    func testInvalidReceiverMode() {
        let tokens = createDeclWithReceivers(
            quote(interface TestInterface),
            [(quote([mode: "InvalidMode"]), quote(func test(): Unit))], [])
        let options = quote(distributed: true)
        let exn = @AssertThrows[MacroException](GenerateActorInterface.Run(options, tokens))
        @Expect(exn.message.contains(MacroOptionModeIllegalArgument.toString()), true)
    }

    // ============================================================================
    // RECEIVER PRIORITY TESTS
    // ============================================================================

    @TestCase
    func testReceiverWithValidPriority() {
        let tokens = createDeclWithReceivers(
            quote(interface ValidDistributedInterface),
            [(quote([priority: 5]), quote(func test(): Unit))], [])
        let options = quote(distributed: true, enableReceiverPriority: true)
        let exn = @AssertThrows[MacroException](GenerateActorInterface.Run(options, tokens))
        @Expect(exn.message.contains(MacroOptionNotAllowed(Priority(5), ACTOR_DISTRIBUTED_INTERFACE_MACRO).toString()), true)
    }


    // // ============================================================================
    // // RECEIVER CUSTOM INFO TESTS
    // // ============================================================================

    @TestCase
    func testReceiverWithCustomInfo() {
        let tokens = createDeclWithReceivers(
            quote(interface ValidDistributedInterface),
            [(quote([customInfo: """
                { "test": "value", "priority": "high" }
                """]), quote(func test(): Unit))], [])
        let options = quote(distributed: true)
        let result = GenerateActorInterface.Run(options, tokens)
        @Expect(result.size > 0, true)
    }

    @TestCase
    func testReceiverWithInvalidCustomInfo() {
        let tokens = createDeclWithReceivers(
            quote(interface ValidDistributedInterface),
            [(quote([customInfo: "invalid json"]), quote(func test(): Unit))], [])
        let options = quote(distributed: true)
        let exn = @AssertThrows[MacroException](GenerateActorInterface.Run(options, tokens))
        @Expect(exn.message.contains(MacroOptionCustomInfosInvalidFormat.toString()), true)
    }

    // // ============================================================================
    // // RECEIVER COMBINED OPTIONS TESTS
    // // ============================================================================

    @TestCase
    func testReceiverWithAllOptions() {
        let tokens = createDeclWithReceivers(
            quote(interface ValidDistributedInterface),
            [(quote([description: "High priority ask and tell method", customInfo: """
                { "priority": "high", "mode": "ask_and_tell" }
                """]), quote(func test(): String))], [])
        let options = quote(distributed: true, enableReceiverPriority: true)
        let result = GenerateActorInterface.Run(options, tokens)
        @Expect(result.size > 0, true)
    }


    // ============================================================================
    // FUNCTION SIGNATURE TESTS
    // ============================================================================

    @TestCase
    func testFunctionWithNoParameters() {
        let tokens = createDeclWithReceivers(
            quote(interface ValidDistributedInterface),
            [(quote(), quote(func noParams(): String))], [])
        let options = quote(distributed: true)
        let result = GenerateActorInterface.Run(options, tokens)
        @Expect(result.size > 0, true)
    }

    @TestCase
    func testFunctionWithParameters() {
        let tokens = createDeclWithReceivers(
            quote(interface ValidDistributedInterface),
            [(quote(), quote(func singleParam(input: String): String)),
            (quote(), quote(func multipleParams(a: Int64, b: String, c: Bool): String))], [])
        let options = quote(distributed: true)
        let result = GenerateActorInterface.Run(options, tokens)
        @Expect(result.size > 0, true)
    }

    // ============================================================================
    // OPTION VALIDATION TESTS
    // ============================================================================

    @TestCase
    func testInvalidOptionFormat() {
        let tokens = createDeclWithReceivers(
            quote(interface ValidDistributedInterface), [], [])
        let options = quote(distributed true) // Missing colon
        let exn = @AssertThrows[MacroException](GenerateActorInterface.Run(options, tokens))
        @Expect(exn.message.contains(MacroOptionUnexpectedToken("true").toString()), true)
    }

    @TestCase
    func testInvalidOptionName() {
        let tokens = createDeclWithReceivers(
            quote(interface ValidDistributedInterface), [], [])
        let options = quote(invalidOption: true)
        let exn = @AssertThrows[MacroException](GenerateActorInterface.Run(options, tokens))
        @Expect(exn.message.contains(MacroOptionInvalidOption("invalidOption").toString()), true)
    }

    @TestCase
    func testUnexpectedTokenInOptions() {
        let tokens = createDeclWithReceivers(
            quote(interface ValidDistributedInterface), [], [])
        let options = quote(distributed: true, unexpected)
        let exn = @AssertThrows[MacroException](GenerateActorInterface.Run(options, tokens))
        @Expect(exn.message.contains(MacroOptionInvalidFormat.toString()), true)
    }

    @TestCase
    func testIncompleteOptionFormat() {
        let tokens = createDeclWithReceivers(
            quote(interface ValidDistributedInterface), [], [])
        let options = quote(distributed:)
        let exn = @AssertThrows[MacroException](GenerateActorInterface.Run(options, tokens))
        @Expect(exn.message.contains(MacroOptionInvalidFormat.toString()), true)
    }

    @TestCase
    func testDuplicatedOptions() {
        let tokens = createDeclWithReceivers(
            quote(interface ValidDistributedInterface), [], [])
        let options = quote(distributed: true, distributed: false)
        let exn = @AssertThrows[MacroException](GenerateActorInterface.Run(options, tokens))
        @Expect(exn.message.contains(MacroOptionDuplicatedOption(Distributed(true)).toString()), true)
    }

    // ============================================================================
    // INTERFACE TYPE TESTS
    // ============================================================================

    @TestCase
    func testGenericInterface() {
        let tokens = createDeclWithReceivers(
            quote(interface GenericInterface<T>), [], [])
        let options = quote(distributed: true)
        let exn = @AssertThrows[MacroException](GenerateActorInterface.Run(options, tokens))
        @Expect(exn.message.contains(ActorInterfaceMacroInvalidDecl.toString()), true)
    }


    // ============================================================================
    // COMPREHENSIVE SCENARIO TESTS
    // ============================================================================

    @TestCase
    func testDistributedInterfaceWithAllOptions() {
        let tokens = createDeclWithReceivers(
            quote(interface AllOptionsDistributedInterface),
            [(quote([description: "Test receiver", customInfo: """
                { "test": "value" }
                """]), quote(func test(): String))], [])
        let options = quote(
            distributed: true,
            enableReceiverPriority: true,
            description: "Service with all options",
            customInfo: """
            { "service": "all_options" }
            """
        )
        let result = GenerateActorInterface.Run(options, tokens)
        @Expect(result.size > 0, true)
    }
}