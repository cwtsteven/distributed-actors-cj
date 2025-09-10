package actors.macros.internal.tests

import std.ast.*
import std.unittest.*
import std.unittest.testmacro.*

import actors.macros.internal.*

func createDeclWithReceivers(
        decl: Tokens,
        receivers: Array<(Tokens, Tokens)>,
        otherDecls: Array<Tokens>): Tokens {
    var tokens = decl
    tokens += quote({)
    for ((attr, receiver) in receivers) {
        tokens += Tokens([Token(TokenKind.AT), Token(TokenKind.IDENTIFIER, RECEIVER_MARKER_NAME)])
        tokens += attr
        tokens += receiver
        tokens += Token(TokenKind.NL)
    }
    for (otherDecl in otherDecls) {
        tokens += otherDecl
    }
    tokens += quote(})
    tokens
}

@Test
public class ActorInterfaceMacroTest {
    @TestCase
    func testNonInterface() {
        let tokens = quote(
            class NonInterface {
                func test(): Unit {}
            }
        )
        let exn = @AssertThrows[MacroException](GenerateActorInterface.Run(Tokens(), tokens))
        @Expect(exn.message.contains(ActorInterfaceMacroInvalidDecl.toString()), true)
    }

    @TestCase
    func testValidInterfaceWithoutOptions() {
        let tokens = quote(
            interface ValidInterface {
                func test(): Unit
            }
        )
        // This should not throw an exception
        let result = GenerateActorInterface.Run(Tokens(), tokens)
        @Expect(result.size > 0, true)
    }

    @TestCase
    func testValidInterfaceWithReceiver() {
        let tokens = createDeclWithReceivers(quote(interface TestInterface), [(quote(), quote(func test(): Int64))], [])
        // This should not throw an exception
        let result = GenerateActorInterface.Run(Tokens(), tokens)
        @Expect(result.size > 0, true)
    }


    @TestCase
    func testValidInterfaceWithPriorityEnabled() {
        let attrs = quote(enableReceiverPriority: true)
        let tokens = createDeclWithReceivers(quote(interface TestInterface), [(quote([priority: 5]), quote(func test(): Int64))], [])
        // This should not throw an exception
        let result = GenerateActorInterface.Run(attrs, tokens)
        @Expect(result.size > 0, true)
    }

    @TestCase
    func testValidReceiverWithModes() {
        let tokens = createDeclWithReceivers(quote(interface TestInterface),
            [(quote([mode: AskOnly]), quote(func askOnly(): Int64)),
            (quote([mode: TellOnly]), quote(func tellOnly(): Unit)),
            (quote([mode: AskAndTell]), quote(func askAndTell(): Int64))], [])
        // This should not throw an exception
        let result = GenerateActorInterface.Run(Tokens(), tokens)
        @Expect(result.size > 0, true)
    }

    @TestCase
    func testInterfaceWithMixedReceiversAndNonReceivers() {
        let tokens = createDeclWithReceivers(quote(interface TestInterface),
            [(quote(), quote(func regularMethod(): Unit)),
            (quote([mode: AskOnly]), quote(func anotherReceiverMethod(): String))],
            [quote(func regularMethod(): Unit),
            quote(func anotherRegularMethod(): String)])
        // This should not throw an exception
        let result = GenerateActorInterface.Run(Tokens(), tokens)
        @Expect(result.size > 0, true)
    }


    @TestCase
    func testInvalidOptionFormat() {
        let attrs = quote(invalidFormat)
        let tokens = quote(
            interface ValidInterface {
                func test(): Unit
            }
        )
        let exn = @AssertThrows[MacroException](GenerateActorInterface.Run(attrs, tokens))
        @Expect(exn.message.contains(MacroOptionInvalidFormat.toString()), true)
    }

    @TestCase
    func testInvalidOptionName() {
        let attrs = quote(invalidOption: true)
        let tokens = quote(
            interface ValidInterface {
                func test(): Unit
            }
        )
        let exn = @AssertThrows[MacroException](GenerateActorInterface.Run(attrs, tokens))
        @Expect(exn.message.contains(MacroOptionInvalidOption("invalidOption").toString()), true)
    }

    @TestCase
    func testInvalidEnableReceiverPriorityValue() {
        let attrs = quote(enableReceiverPriority: invalid)
        let tokens = quote(
            interface ValidInterface {
                func test(): Unit
            }
        )
        let exn = @AssertThrows[MacroException](GenerateActorInterface.Run(attrs, tokens))
        @Expect(exn.message.contains(MacroOptionEnableReceiverPriorityIllegalArgument.toString()), true)
    }

    @TestCase
    func testUnexpectedTokenInOptions() {
        let attrs = quote(enableReceiverPriority true) // Missing colon
        let tokens = quote(
            interface ValidInterface {
                func test(): Unit
            }
        )
        let exn = @AssertThrows[MacroException](GenerateActorInterface.Run(attrs, tokens))
        @Expect(exn.message.contains(MacroOptionUnexpectedToken("true").toString()), true)
    }

    @TestCase
    func testIncompleteOptionFormat() {
        let attrs = quote(enableReceiverPriority:) // Missing value
        let tokens = quote(
            interface ValidInterface {
                func test(): Unit
            }
        )
        let exn = @AssertThrows[MacroException](GenerateActorInterface.Run(attrs, tokens))
        @Expect(exn.message.contains(MacroOptionInvalidFormat.toString()), true)
    }

    @TestCase
    func testGenericInterface() {
        let tokens = quote(
            interface GenericInterface<T> {
                func test(): Unit
            }
        )
        // Regular actor interfaces can be generic
        let result = GenerateActorInterface.Run(Tokens(), tokens)
        @Expect(result.size > 0, true)
    }

}
