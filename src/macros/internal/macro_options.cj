package actors.macros.internal

import std.ast.*
import std.collection.*
import std.convert.*

import encoding.json.*

enum MacroOption <: Hashable & Equatable<MacroOption> {
    EnableReceiverPriority(Bool)
    | Priority(Int64)
    | Distributed(Bool)
    | Mode(ReceiverMode)
    | Description(String)
    | CustomInfos(JsonObject)

    public override func hashCode(): Int64 {
        match (this) {
            case EnableReceiverPriority(_) => 0
            case Priority(_) => 1
            case Distributed(_) => 2
            case Mode(_) => 3
            case Description(_) => 4
            case CustomInfos(_) => 5
        }
    }

    public override operator func ==(other: MacroOption): Bool {
        this.hashCode() == other.hashCode()
    }

    public override operator func !=(other: MacroOption): Bool {
        !(this == other)
    }

    public func getKeyString(): String {
        match (this) {
            case EnableReceiverPriority(_) => "enableReceiverPriority"
            case Priority(_) => "priority"
            case Distributed(_) => "distributed"
            case Mode(_) => "mode"
            case Description(_) => "description"
            case CustomInfos(_) => "customInfo"
        }
    }
}

protected class MacroOptionSet {
    private let opts = HashSet<MacroOption>()

    func add(opt: MacroOption): Unit {
        opts.put(opt)
    }

    func contains(opt: MacroOption): Bool {
        opts.contains(opt)
    }

    func hasEnabledReceiverPriority(): Bool {
        for (opt in opts) {
            match (opt) {
                case EnableReceiverPriority(t) where t == true => return true
                case _ => continue
            }
        }
        false
    }

    func shouldTell(): Bool {
        for (opt in opts) {
            match (opt) {
                case Mode(AskOnly) => return false
                case Mode(_) => return true
                case _ => continue
            }
        }
        true
    }

    func shouldAsk(): Bool {
        for (opt in opts) {
            match (opt) {
                case Mode(TellOnly) => return false
                case Mode(_) => return true
                case _ => continue
            }
        }
        true
    }

    func getMode(): ReceiverMode {
        for (opt in opts) {
            match (opt) {
                case Mode(m) => return m
                case _ => continue
            }
        }
        AskAndTell
    }

    func isDistributed(): Bool {
        for (opt in opts) {
            match (opt) {
                case Distributed(b) where b == true => return true
                case _ => continue
            }
        }
        false
    }

    func checkOptions(allowed: Array<MacroOption>, errors: MacroErrors, name: String): Unit {
        for (opt in opts) {
            if (!allowed.contains(opt)) {
                errors.add(MacroOptionNotAllowed(opt, name))
            }
        }
    }

    func getDescription(): String {
        for (opt in opts) {
            match (opt) {
                case Description(d) => return d
                case _ => continue
            }
        }
        "_"
    }

    func getCustomInfos(): JsonObject {
        for (opt in opts) {
            match (opt) {
                case CustomInfos(c) => return c
                case _ => continue
            }
        }
        JsonObject()
    }

    func getPriority(): Int64 {
        let defaultPriorityBox: Box<Int64> = Box(DEFAULT_PRIORITY)
        for (opt in opts) {
            match (opt) {
                case Priority(p) => defaultPriorityBox.value = Int64(p)
                case _ => continue
            }
        }
        defaultPriorityBox.value
    }
}

class MacroOptionParser {
    private let it: TokensIterator
    private let opts = MacroOptionSet()
    private let errors: MacroErrors

    static func Run(tokens: Tokens, errors: MacroErrors): MacroOptionSet {
        if (tokens.size == 0) {
            return MacroOptionSet()
        }

        let parser = MacroOptionParser(tokens, errors)
        parser.parse()
        parser.opts
    }

    private init(tokens: Tokens, errors: MacroErrors) {
        this.it = tokens.iterator()
        this.errors = errors
    }

    private func parse(): Unit {
        while (let Some(t) <- it.next()) {
            if (t.kind == TokenKind.NL) {
                continue
            }
            if (t.kind != TokenKind.IDENTIFIER) {
                errors.add(MacroOptionUnexpectedToken(t.value))
                break
            }
            // colon
            match (it.next()) {
                case Some(c) where c.kind == TokenKind.COLON => ()
                case Some(c) =>
                    errors.add(MacroOptionUnexpectedToken(c.value))
                    break
                case None =>
                    errors.add(MacroOptionInvalidFormat)
                    break
            }
            // value
            it.next()
            if (let None <- it.peek()) {
                errors.add(MacroOptionInvalidFormat)
                break
            }

            parseOption(t, it.peek().getOrThrow())

            // next token must be a COMMA or nothing
            match (it.next()) {
                case Some(n) where n.kind == TokenKind.COMMA =>
                    continue
                case Some(n) where n.kind == TokenKind.NL =>
                    continue
                case Some(_) =>
                    errors.add(MacroOptionInvalidFormat)
                    break
                case None =>
                    break // we are done
            }
        }
    }

    private func parseOption(key: Token, val: Token): Unit {
        match (key.value) {
            case "enableReceiverPriority" =>
                let res: Bool = try {
                    Bool.parse(val.value)
                } catch (_: IllegalArgumentException) {
                    errors.add(MacroOptionEnableReceiverPriorityIllegalArgument)
                    return
                }
                addOption(EnableReceiverPriority(res))
            case "priority" =>
                let res: Int64 = try {
                    Int64.parse(val.value)
                } catch (_: IllegalArgumentException) {
                    errors.add(MacroOptionPriorityIllegalArgument)
                    return
                }
                if (res < 1 || res > 10) {
                    errors.add(MacroOptionPriorityIllegalArgument)
                    return
                }
                addOption(Priority(res))
            case "mode" =>
                let res: ReceiverMode = try {
                    ReceiverMode.parse(val.value)
                } catch (_: IllegalArgumentException) {
                    errors.add(MacroOptionModeIllegalArgument)
                    return
                }
                addOption(Mode(res))
            case "distributed" =>
                let res: Bool = try {
                    Bool.parse(val.value)
                } catch (_: IllegalArgumentException) {
                    errors.add(MacroOptionDistributedIllegalArgument)
                    return
                }
                addOption(Distributed(res))
            case "description" =>
                addOption(Description(val.value))
            case "customInfo" =>
                let jsonValue: JsonObject = try {
                    JsonValue.fromStr(val.value).asObject()
                } catch (_: JsonException) {
                    errors.add(MacroOptionCustomInfosInvalidFormat)
                    return
                }
                addOption(CustomInfos(jsonValue))
            case _ =>
                errors.add(MacroOptionInvalidOption(key.value))
        }
    }

    private func addOption(opt: MacroOption): Unit {
        if (opts.contains(opt)) {
            errors.add(MacroOptionDuplicatedOption(opt))
            return
        }
        opts.add(opt)
    }
}