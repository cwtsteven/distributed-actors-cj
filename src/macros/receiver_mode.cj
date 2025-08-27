macro package actors.macros

import std.convert.Parsable

enum ReceiverMode {
    | AskOnly
    | TellOnly
    | AskAndTell
}

extend ReceiverMode <: Parsable<ReceiverMode> {
    public static func tryParse(value: String): Option<ReceiverMode> {
        match(value) {
            case "AskOnly" => AskOnly
            case "TellOnly" => TellOnly
            case "AskAndTell" => AskAndTell
            case _ => None
        }
    }
    public static func parse(value: String): ReceiverMode {
        tryParse(value).getOrThrow {
            IllegalArgumentException("${value} cannot be parsed as ReceiverMode")
        }
    }
}

extend ReceiverMode <: ToString {
    public func toString(): String {
        match (this) {
            case AskOnly => "AskOnly"
            case TellOnly => "TellOnly"
            case AskAndTell => "AskAndTell"
        }
    }
}