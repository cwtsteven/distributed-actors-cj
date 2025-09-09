package actors.macros.internal.tests

import std.ast.*
import std.unittest.*
import std.unittest.testmacro.*

import actors.macros.internal.*

@Test
public class ActorMacroTest {
    @TestCase
    func testNonClass() {
        let tokens = quote(
            func nonClass() {
                // This should cause a compilation error
            }
        )
        let exn = @AssertThrows[MacroException](GenerateActorClass.Run(Tokens(), tokens))
        @Expect(exn.message.contains(ActorMacroInvalidDecl.toString()), true)
    }

    @TestCase
    func testAbstractClass() {
        let tokens = quote(
            abstract class AbstractActor {
                func test(): Unit {}
            }
        )
        let exn = @AssertThrows[MacroException](GenerateActorClass.Run(Tokens(), tokens))
        @Expect(exn.message.contains(ActorMacroInvalidClassModifier.toString()), true)
    }

    @TestCase
    func testOpenClass() {
        let tokens = quote(
            open class OpenActor {
                func test(): Unit {}
            }
        )
        let exn = @AssertThrows[MacroException](GenerateActorClass.Run(Tokens(), tokens))
        @Expect(exn.message.contains(ActorMacroInvalidClassModifier.toString()), true)
    }

    @TestCase
    func testSealedClass() {
        let tokens = quote(
            sealed class SealedActor {
                func test(): Unit {}
            }
        )
        let exn = @AssertThrows[MacroException](GenerateActorClass.Run(Tokens(), tokens))
        @Expect(exn.message.contains(ActorMacroInvalidClassModifier.toString()), true)
    }

    @TestCase
    func testInvalidOptionFormat() {
        let attrs = quote(invalidFormat)
        let tokens = quote(
            class ValidActor {
                func test(): Unit {}
            }
        )
        let exn = @AssertThrows[MacroException](GenerateActorClass.Run(attrs, tokens))
        @Expect(exn.message.contains(MacroOptionInvalidFormat.toString()), true)
    }

    @TestCase
    func testInvalidOptionName() {
        let attrs = quote(invalidOption: true)
        let tokens = quote(
            class ValidActor {
                func test(): Unit {}
            }
        )
        let exn = @AssertThrows[MacroException](GenerateActorClass.Run(attrs, tokens))
        @Expect(exn.message.contains(MacroOptionInvalidOption("invalidOption").toString()), true)
    }

    @TestCase
    func testInvalidEnableReceiverPriorityValue() {
        let attrs = quote(enableReceiverPriority: invalid)
        let tokens = quote(
            class ValidActor {
                func test(): Unit {}
            }
        )
        let exn = @AssertThrows[MacroException](GenerateActorClass.Run(attrs, tokens))
        @Expect(exn.message.contains(MacroOptionEnableReceiverPriorityIllegalArgument.toString()), true)
    }

    @TestCase
    func testValidEnableReceiverPriorityTrue() {
        let attrs = quote(enableReceiverPriority: true)
        let tokens = quote(
            class ValidActor {
                func test(): Unit {}
            }
        )
        // This should not throw an exception
        let result = GenerateActorClass.Run(attrs, tokens)
        @Expect(result.size > 0, true)
    }

    @TestCase
    func testValidEnableReceiverPriorityFalse() {
        let attrs = quote(enableReceiverPriority: false)
        let tokens = quote(
            class ValidActor {
                func test(): Unit {}
            }
        )
        // This should not throw an exception
        let result = GenerateActorClass.Run(attrs, tokens)
        @Expect(result.size > 0, true)
    }

    @TestCase
    func testValidClassWithoutOptions() {
        let tokens = quote(
            class ValidActor {
                func test(): Unit {}
            }
        )
        // This should not throw an exception
        let result = GenerateActorClass.Run(Tokens(), tokens)
        @Expect(result.size > 0, true)
    }

    @TestCase
    func testValidClassWithReceiver() {
        let tokens = quote(
            class ValidActor {
                @Receiver
                func test(): Int64 {
                    42
                }
            }
        )
        // This should not throw an exception
        let result = GenerateActorClass.Run(Tokens(), tokens)
        @Expect(result.size > 0, true)
    }

    @TestCase
    func testValidClassWithMultipleReceivers() {
        let tokens = quote(
            class ValidActor {
                @Receiver
                func test1(): Int64 {
                    1
                }

                @Receiver[mode: AskOnly]
                func test2(): Int64 {
                    2
                }

                @Receiver[mode: TellOnly]
                func test3(): Unit {
                    // empty
                }
            }
        )
        // This should not throw an exception
        let result = GenerateActorClass.Run(Tokens(), tokens)
        @Expect(result.size > 0, true)
    }

    @TestCase
    func testValidClassWithPriorityEnabled() {
        let attrs = quote(enableReceiverPriority: true)
        let tokens = quote(
            class ValidActor {
                @Receiver[priority: 5]
                func test(): Int64 {
                    42
                }
            }
        )
        // This should not throw an exception
        let result = GenerateActorClass.Run(attrs, tokens)
        @Expect(result.size > 0, true)
    }

    @TestCase
    func testUnexpectedTokenInOptions() {
        let attrs = quote(enableReceiverPriority true) // Missing colon
        let tokens = quote(
            class ValidActor {
                func test(): Unit {}
            }
        )
        let exn = @AssertThrows[MacroException](GenerateActorClass.Run(attrs, tokens))
        @Expect(exn.message.contains(MacroOptionUnexpectedToken("true").toString()), true)
    }

    @TestCase
    func testIncompleteOptionFormat() {
        let attrs = quote(enableReceiverPriority:) // Missing value
        let tokens = quote(
            class ValidActor {
                func test(): Unit {}
            }
        )
        let exn = @AssertThrows[MacroException](GenerateActorClass.Run(attrs, tokens))
        @Expect(exn.message.contains(MacroOptionInvalidFormat.toString()), true)
    }
}