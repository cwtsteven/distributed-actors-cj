package actors.macros.internal.tests

import std.ast.*
import std.unittest.*
import std.unittest.testmacro.*

import actors.macros.internal.*

@Test
public class ReceiverMacroTest {

    @TestCase
    func testReceiverOutsideActor() {
        let tokens = quote(
            func test(): Int64 {
                42
            }
        )
        let exn = @AssertThrows[MacroException](ReceiverMacro.Run(Tokens(), tokens))
        @Expect(exn.message.contains(ReceiverMacroInsideActor.toString()), true)
    }

    @TestCase
    func testInvalidOptionFormat() {
        let attrs = quote(invalidFormat)
        let tokens = quote(
            func test(): Int64 {
                42
            }
        )
        let exn = @AssertThrows[MacroException](ReceiverMacro.Run(attrs, tokens, bypassParentContextCheck: true))
        @Expect(exn.message.contains(MacroOptionInvalidFormat.toString()), true)
    }

    @TestCase
    func testInvalidOptionName() {
        let attrs = quote(invalidOption: true)
        let tokens = quote(
            func test(): Int64 {
                42
            }
        )
        let exn = @AssertThrows[MacroException](ReceiverMacro.Run(attrs, tokens, bypassParentContextCheck: true))
        @Expect(exn.message.contains(MacroOptionInvalidOption("invalidOption").toString()), true)
    }

    @TestCase
    func testInvalidPriorityValue() {
        let attrs = quote(priority: 15) // Priority must be 1-10
        let tokens = quote(
            func test(): Int64 {
                42
            }
        )
        let exn = @AssertThrows[MacroException](ReceiverMacro.Run(attrs, tokens, bypassParentContextCheck: true))
        @Expect(exn.message.contains(MacroOptionPriorityIllegalArgument.toString()), true)
    }

    @TestCase
    func testInvalidPriorityValueLow() {
        let attrs = quote(priority: 0) // Priority must be 1-10
        let tokens = quote(
            func test(): Int64 {
                42
            }
        )
        let exn = @AssertThrows[MacroException](ReceiverMacro.Run(attrs, tokens, bypassParentContextCheck: true))
        @Expect(exn.message.contains(MacroOptionPriorityIllegalArgument.toString()), true)
    }

    @TestCase
    func testInvalidPriorityValueNegative() {
        let attrs = quote(priority: -1) // Priority must be 1-10
        let tokens = quote(
            func test(): Int64 {
                42
            }
        )
        let exn = @AssertThrows[MacroException](ReceiverMacro.Run(attrs, tokens, bypassParentContextCheck: true))
        @Expect(exn.message.contains(MacroOptionPriorityIllegalArgument.toString()), true)
    }

    @TestCase
    func testInvalidModeValue() {
        let attrs = quote(mode: InvalidMode)
        let tokens = quote(
            func test(): Int64 {
                42
            }
        )
        let exn = @AssertThrows[MacroException](ReceiverMacro.Run(attrs, tokens, bypassParentContextCheck: true))
        @Expect(exn.message.contains(MacroOptionModeIllegalArgument.toString()), true)
    }

    @TestCase
    func testInvalidPriorityFormat() {
        let attrs = quote(priority: invalid)
        let tokens = quote(
            func test(): Int64 {
                42
            }
        )
        let exn = @AssertThrows[MacroException](ReceiverMacro.Run(attrs, tokens, bypassParentContextCheck: true))
        @Expect(exn.message.contains(MacroOptionPriorityIllegalArgument.toString()), true)
    }

    @TestCase
    func testUnexpectedTokenInOptions() {
        let attrs = quote(priority 5) // Missing colon
        let tokens = quote(
            func test(): Int64 {
                42
            }
        )
        let exn = @AssertThrows[MacroException](ReceiverMacro.Run(attrs, tokens, bypassParentContextCheck: true))
        @Expect(exn.message.contains(MacroOptionUnexpectedToken("5").toString()), true)
    }

    @TestCase
    func testIncompleteOptionFormat() {
        let attrs = quote(priority:) // Missing value
        let tokens = quote(
            func test(): Int64 {
                42
            }
        )
        let exn = @AssertThrows[MacroException](ReceiverMacro.Run(attrs, tokens, bypassParentContextCheck: true))
        @Expect(exn.message.contains(MacroOptionInvalidFormat.toString()), true)
    }

    // Function Declaration Validation Tests
    @TestCase
    func testNonFunctionDeclaration() {
        let tokens = quote(
            class TestClass {
                let value: Int64 = 42
            }
        )
        let exn = @AssertThrows[MacroException](ReceiverMacro.Run(Tokens(), tokens, bypassParentContextCheck: true))
        @Expect(exn.message.contains(ReceiverMacroInvalidDecl.toString()), true)
    }

    @TestCase
    func testStaticFunction() {
        let tokens = quote(
            static func test(): Int64 {
                42
            }
        )
        let exn = @AssertThrows[MacroException](ReceiverMacro.Run(Tokens(), tokens, bypassParentContextCheck: true))
        @Expect(exn.message.contains(ReceiverMacroInvalidModifier("test").toString()), true)
    }

    @TestCase
    func testOpenFunction() {
        let tokens = quote(
            open func test(): Int64 {
                42
            }
        )
        let exn = @AssertThrows[MacroException](ReceiverMacro.Run(Tokens(), tokens, bypassParentContextCheck: true))
        @Expect(exn.message.contains(ReceiverMacroInvalidModifier("test").toString()), true)
    }

    @TestCase
    func testOverrideFunction() {
        let tokens = quote(
            override func test(): Int64 {
                42
            }
        )
        let exn = @AssertThrows[MacroException](ReceiverMacro.Run(Tokens(), tokens, bypassParentContextCheck: true))
        @Expect(exn.message.contains(ReceiverMacroInvalidModifier("test").toString()), true)
    }

    @TestCase
    func testFunctionWithoutReturnType() {
        let tokens = quote(
            func test() {
                // No return type specified
            }
        )
        let exn = @AssertThrows[MacroException](ReceiverMacro.Run(Tokens(), tokens, bypassParentContextCheck: true))
        @Expect(exn.message.contains(ReceiverMacroInvalidReturnType("test").toString()), true)
    }

    // Valid Option Tests
    @TestCase
    func testValidReceiverWithoutOptions() {
        let tokens = quote(
            func test(): Int64 {
                42
            }
        )
        // This should not throw an exception
        let result = ReceiverMacro.Run(Tokens(), tokens, bypassParentContextCheck: true)
        @Expect(result.size > 0, true)
    }

    @TestCase
    func testValidReceiverWithPriority() {
        let attrs = quote(priority: 5)
        let tokens = quote(
            func test(): Int64 {
                42
            }
        )
        // This should not throw an exception
        let result = ReceiverMacro.Run(attrs, tokens, bypassParentContextCheck: true)
        @Expect(result.size > 0, true)
    }

    @TestCase
    func testValidReceiverWithModeAskOnly() {
        let attrs = quote(mode: AskOnly)
        let tokens = quote(
            func test(): Int64 {
                42
            }
        )
        // This should not throw an exception
        let result = ReceiverMacro.Run(attrs, tokens, bypassParentContextCheck: true)
        @Expect(result.size > 0, true)
    }

    @TestCase
    func testValidReceiverWithModeTellOnly() {
        let attrs = quote(mode: TellOnly)
        let tokens = quote(
            func test(): Unit {
                // empty
            }
        )
        // This should not throw an exception
        let result = ReceiverMacro.Run(attrs, tokens, bypassParentContextCheck: true)
        @Expect(result.size > 0, true)
    }

    @TestCase
    func testValidReceiverWithModeAskAndTell() {
        let attrs = quote(mode: AskAndTell)
        let tokens = quote(
            func test(): Int64 {
                42
            }
        )
        // This should not throw an exception
        let result = ReceiverMacro.Run(attrs, tokens, bypassParentContextCheck: true)
        @Expect(result.size > 0, true)
    }

    @TestCase
    func testValidReceiverWithMultipleOptions() {
        let attrs = quote(priority: 3, mode: AskOnly)
        let tokens = quote(
            func test(): Int64 {
                42
            }
        )
        // This should not throw an exception
        let result = ReceiverMacro.Run(attrs, tokens, bypassParentContextCheck: true)
        @Expect(result.size > 0, true)
    }

    // Edge Cases
    @TestCase
    func testDuplicatedOptions() {
        let attrs = quote(priority: 5, priority: 7) // Duplicated priority
        let tokens = quote(
            func test(): Int64 {
                42
            }
        )
        let exn = @AssertThrows[MacroException](ReceiverMacro.Run(attrs, tokens, bypassParentContextCheck: true))
        @Expect(exn.message.contains(MacroOptionDuplicatedOption(Priority(7)).toString()), true)
    }

    @TestCase
    func testValidPriorityBoundaryMin() {
        let attrs = quote(priority: 1) // Minimum valid priority
        let tokens = quote(
            func test(): Int64 {
                42
            }
        )
        // This should not throw an exception
        let result = ReceiverMacro.Run(attrs, tokens, bypassParentContextCheck: true)
        @Expect(result.size > 0, true)
    }

    @TestCase
    func testValidPriorityBoundaryMax() {
        let attrs = quote(priority: 10) // Maximum valid priority
        let tokens = quote(
            func test(): Int64 {
                42
            }
        )
        // This should not throw an exception
        let result = ReceiverMacro.Run(attrs, tokens, bypassParentContextCheck: true)
        @Expect(result.size > 0, true)
    }

    // Option Not Allowed Tests
    @TestCase
    func testEnableReceiverPriorityNotAllowed() {
        let attrs = quote(enableReceiverPriority: true)
        let tokens = quote(
            func test(): Int64 {
                42
            }
        )
        let exn = @AssertThrows[MacroException](ReceiverMacro.Run(attrs, tokens, bypassParentContextCheck: true))
        @Expect(exn.message.contains(MacroOptionNotAllowed(EnableReceiverPriority(true), RECEIVER_MACRO).toString()), true)
    }

    @TestCase
    func testDistributedNotAllowed() {
        let attrs = quote(distributed: true)
        let tokens = quote(
            func test(): Int64 {
                42
            }
        )
        let exn = @AssertThrows[MacroException](ReceiverMacro.Run(attrs, tokens, bypassParentContextCheck: true))
        @Expect(exn.message.contains(MacroOptionNotAllowed(Distributed(true), RECEIVER_MACRO).toString()), true)
    }

    // Boolean Option Validation
    @TestCase
    func testInvalidDistributedValue() {
        let attrs = quote(distributed: invalid)
        let tokens = quote(
            func test(): Int64 {
                42
            }
        )
        let exn = @AssertThrows[MacroException](ReceiverMacro.Run(attrs, tokens, bypassParentContextCheck: true))
        @Expect(exn.message.contains(MacroOptionDistributedIllegalArgument.toString()), true)
    }

    // Additional Edge Cases
    @TestCase
    func testValidReceiverWithComplexReturnType() {
        let tokens = quote(
            func test(): ArrayList<Int64> {
                ArrayList<Int64>()
            }
        )
        // This should not throw an exception
        let result = ReceiverMacro.Run(Tokens(), tokens, bypassParentContextCheck: true)
        @Expect(result.size > 0, true)
    }

    @TestCase
    func testValidReceiverWithParameters() {
        let tokens = quote(
            func test(x: Int64, y: String): Int64 {
                x
            }
        )
        // This should not throw an exception
        let result = ReceiverMacro.Run(Tokens(), tokens, bypassParentContextCheck: true)
        @Expect(result.size > 0, true)
    }

    @TestCase
    func testValidReceiverWithUnitReturnType() {
        let tokens = quote(
            func test(): Unit {
                // empty
            }
        )
        // This should not throw an exception
        let result = ReceiverMacro.Run(Tokens(), tokens, bypassParentContextCheck: true)
        @Expect(result.size > 0, true)
    }

    @TestCase
    func testValidReceiverWithBoolReturnType() {
        let tokens = quote(
            func test(): Bool {
                true
            }
        )
        // This should not throw an exception
        let result = ReceiverMacro.Run(Tokens(), tokens, bypassParentContextCheck: true)
        @Expect(result.size > 0, true)
    }

    @TestCase
    func testValidReceiverWithStringReturnType() {
        let tokens = quote(
            func test(): String {
                "hello"
            }
        )
        // This should not throw an exception
        let result = ReceiverMacro.Run(Tokens(), tokens, bypassParentContextCheck: true)
        @Expect(result.size > 0, true)
    }
}