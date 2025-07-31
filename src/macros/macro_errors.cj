macro package actors.macros

import std.collection.*

class MacroErrors {
    private let errors = HashSet<String>()

    func add(): Unit {
        errors.add("placeholder")
    }

    func report(): Unit {
        if (!errors.isEmpty()) {
            doThrow()
        }
    }

    func doThrow(): Nothing {
        throw MacroException(String.join(errors.toArray(), delimiter: "\n"))
    }
}