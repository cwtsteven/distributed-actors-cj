macro package actors.macros

import std.ast.*
import std.collection.*
import std.convert.*

enum MacroOption <: Hashable & Equatable<MacroOption> & ToString {
    EnableReceiverPriority(Bool)
    | Priority(Int64)

    public override func hashCode(): Int64 {
        match (this) {
            case EnableReceiverPriority(_) => 0
            case Priority(_) => 1
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
                errors.add()
                break
            }
            // colon
            match (it.next()) {
                case Some(c) where c.kind == TokenKind.COLON => ()
                case Some(c) =>
                    errors.add()
                    break
                case None =>
                    errors.add()
                    break
            }
            // value
            it.next()
            if (let None <- it.peek()) {
                errors.add()
                break
            }

            parseOption(t, it.peek().getOrThrow())

            // next token must be a COMMA or nothing
            match (it.next()) {
                case Some(n) where n.kind == TokenKind.COMMA =>
                    continue
                case Some(_) =>
                    errors.add()
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
                    errors.add()
                    return
                }
                addOption(EnableReceiverPriority(res))
            case "prirotiy" =>
                let res: Int64 = try {
                    Int64.parse(val.value)
                } catch (_: IllegalArgumentException) {
                    errors.add()
                    return
                }
                if (res < 1 || res > 10) {
                    errors.add()
                    return
                }
                addOption(Priority(res))
            case _ =>
                errors.add()
        }
    }

    private func addOption(opt: MacroOption): Unit {
        if (opts.contains(opt)) {
            errors.add()
            return
        }
        opts.add(opt)
    }
}