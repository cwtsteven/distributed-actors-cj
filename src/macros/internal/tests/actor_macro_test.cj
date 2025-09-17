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
            abstract class AbstractActor <: Supervisable {
                func test(): Unit {}
            }
        )
        let exn = @AssertThrows[MacroException](GenerateActorClass.Run(Tokens(), tokens))
        @Expect(exn.message.contains(ActorMacroInvalidClassModifier.toString()), true)
    }

    @TestCase
    func testOpenClass() {
        let tokens = quote(
            open class OpenActor <: Supervisable {
                func test(): Unit {}
            }
        )
        let exn = @AssertThrows[MacroException](GenerateActorClass.Run(Tokens(), tokens))
        @Expect(exn.message.contains(ActorMacroInvalidClassModifier.toString()), true)
    }

    @TestCase
    func testSealedClass() {
        let tokens = quote(
            sealed class SealedActor <: Supervisable {
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
            class ValidActor <: Supervisable {
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
            class ValidActor <: Supervisable {
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
            class ValidActor <: Supervisable {
                func test(): Unit {}
            }
        )
        let exn = @AssertThrows[MacroException](GenerateActorClass.Run(attrs, tokens))
        @Expect(exn.message.contains(MacroOptionEnableReceiverPriorityIllegalArgument.toString()), true)
    }

    @TestCase
    func testInvalidMissingSupervisableSupertype() {
        let attrs = quote()
        let tokens1 = quote(
            class ValidActor {
                func test(): Unit {}
            }
        )
        let exn1 = @AssertThrows[MacroException](GenerateActorClass.Run(attrs, tokens1))
        @Expect(exn1.message.contains(ActorMacroMissingSuperType.toString()))

        let tokens2 = quote(
            class ValidActor <: _S1 & _S2 & _S3 {
                func test(): Unit {}
            }
        )
        let exn2 = @AssertThrows[MacroException](GenerateActorClass.Run(attrs, tokens2))
        @Expect(exn2.message.contains(ActorMacroMissingSuperType.toString()))
    }

    @TestCase
    func testValidMultipleSuperTypes() {
        let attrs = quote()
        let tokens = quote(
            class ValidActor <: S1 & Supervisable & S2 & S3 {
                func test(): Unit {}
            }
        )
        // This should not throw an exception
        let result = GenerateActorClass.Run(attrs, tokens)
        @Expect(result.size > 0, true)
    }

    @TestCase
    func testValidEnableReceiverPriorityTrue() {
        let attrs = quote(enableReceiverPriority: true)
        let tokens = quote(
            class ValidActor <: Supervisable {
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
            class ValidActor <: Supervisable {
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
            class ValidActor <: Supervisable {
                func test(): Unit {}
            }
        )
        // This should not throw an exception
        let result = GenerateActorClass.Run(Tokens(), tokens)
        @Expect(result.size > 0, true)
    }

    @TestCase
    func testValidClassWithReceiver() {
        let tokens = createDeclWithReceivers(
            quote(class ValidActor <: Supervisable),
            [(quote(), quote(func test(): Int64 { 42 }))],
            [])
        // This should not throw an exception
        let result = GenerateActorClass.Run(Tokens(), tokens)
        @Expect(result.size > 0, true)
    }

    @TestCase
    func testValidClassWithMultipleReceivers() {
        let tokens = createDeclWithReceivers(
            quote(class ValidActor <: Supervisable),
            [(quote(), quote(func test1(): Int64 { 1 })),
            (quote([mode: AskOnly]), quote(func test2(): Int64 { 2 })),
            (quote([mode: TellOnly]), quote(func test3(): Unit { () }))
            ], [])
        // This should not throw an exception
        let result = GenerateActorClass.Run(Tokens(), tokens)
        @Expect(result.size > 0, true)
    }

    @TestCase
    func testValidClassWithPriorityEnabled() {
        let attrs = quote(enableReceiverPriority: true)
        let tokens = createDeclWithReceivers(
            quote(class ValidActor <: Supervisable),
            [(quote([priority: 5]),
            quote(func test(): Int64 { 42 }))], [])
        // This should not throw an exception
        let result = GenerateActorClass.Run(attrs, tokens)
        @Expect(result.size > 0, true)
    }

    @TestCase
    func testUnexpectedTokenInOptions() {
        let attrs = quote(enableReceiverPriority true) // Missing colon
        let tokens = quote(
            class ValidActor <: Supervisable {
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
            class ValidActor <: Supervisable {
                func test(): Unit {}
            }
        )
        let exn = @AssertThrows[MacroException](GenerateActorClass.Run(attrs, tokens))
        @Expect(exn.message.contains(MacroOptionInvalidFormat.toString()), true)
    }
}
