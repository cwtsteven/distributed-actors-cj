macro package actors.macros

import std.ast.*
import std.collection.*
import std.convert.*

enum MacroOption <: Hashable & Equatable<MacroOption> & ToString {
    EnableReceiverPriority(Bool)
    | Priority(Int64)
    | Distributed(Bool)
    | Mode(ReceiverMode)

    public override func hashCode(): Int64 {
        match (this) {
            case EnableReceiverPriority(_) => 0
            case Priority(_) => 1
            case Distributed(_) => 2
            case Mode(_) => 3
        }
    }

    public override operator func ==(other: MacroOption): Bool {
        this.hashCode() == other.hashCode()
    }

    public override operator func !=(other: MacroOption): Bool {
        !(this == other)
    }

    public override func toString(): String {
        match (this) {
            case EnableReceiverPriority(b) => "enableReceiverPriority: ${b}"
            case Priority(p) => "priority: ${p}"
            case Distributed(b) => "distributed: ${b}"
            case Mode(m) => "mode: ${m}"
        }
    }
}

class MacroOptionSet {
    private let opts = HashSet<MacroOption>()

    func add(opt: MacroOption): Unit {
        opts.add(opt)
    }

    func contains(opt: MacroOption): Bool {
        opts.contains(opt)
    }

    func iterate(f: (MacroOption) -> Bool): Unit {
        for (opt in opts) {
            if (!f(opt)) {
                break
            }
        }
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