package actors.macros.internal

import std.collection.*

protected class MacroErrors {
    private let errors = HashSet<String>()

    func add(e: MacroError): Unit {
        errors.add(e.toString())
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

enum MacroError {
    ActorMacroInvalidDecl
    | ActorMacroInvalidClassModifier
    | ActorMacroInternalError

    | ActorInterfaceMacroInvalidDecl

    | ReceiverMacroInsideActor
    | ReceiverMacroInvalidDecl
    | ReceiverMacroInvalidModifier(String)
    | ReceiverMacroInvalidReturnType(String)
    | ReceiverMacroPriorityInsideActor
    | ReceiverMacroTellNameParameter
    | ReceiverMacroConfigNameParameter

    | ReceiverMacroInsideActorInterface

    | MacroOptionNotAllowed(MacroOption, String)
    | MacroOptionInvalidOption(String)
    | MacroOptionInvalidFormat
    | MacroOptionUnexpectedToken(String)
    | MacroOptionEnableReceiverPriorityIllegalArgument
    | MacroOptionPriorityIllegalArgument
    | MacroOptionModeIllegalArgument
    | MacroOptionDistributedIllegalArgument
    | MacroOptionCustomInfosInvalidFormat
    | MacroOptionDuplicatedOption(MacroOption)
    | MacroReceiverInfoUnsupportedType
}

extend MacroError <: ToString {
    public func toString(): String {
        match (this) {
            case ActorMacroInvalidDecl => "${ACTOR_MACRO} macro: must be a class declaration."
            case ActorMacroInvalidClassModifier => "${ACTOR_MACRO} macro: class declaration cannot be abstract nor open nor sealed."
            case ActorMacroInternalError => "${ACTOR_MACRO} macro: actor macro framework internal error."

            case ActorInterfaceMacroInvalidDecl => "${ACTOR_INTERFACE_MACRO} macro: must be an interface declaration."

            case ReceiverMacroInsideActor => "${RECEIVER_MACRO} macro: must be used inside an ${ACTOR_MACRO} macro or ${ACTOR_INTERFACE_MACRO} macro."
            case ReceiverMacroInvalidDecl => "${RECEIVER_MACRO} macro: must be used on a function declaration."
            case ReceiverMacroInvalidModifier(name) => "${RECEIVER_MACRO} macro: receiver method '${name}' cannot be static nor open nor overriding another function."
            case ReceiverMacroInvalidReturnType(name) => "${RECEIVER_MACRO} macro: receiver method '${name}' must have explicit return type."
            case ReceiverMacroPriorityInsideActor => "${RECEIVER_MACRO} macro: priority option can only be used inside ${ACTOR_MACRO}[enableReceiverPriority: true]."
            case ReceiverMacroTellNameParameter => "${RECEIVER_MACRO} macro: the name tell cannot be used as a named parameter."
            case ReceiverMacroConfigNameParameter => "${RECEIVER_MACRO} macro: the name config cannot be used as a named parameter."
            case ReceiverMacroInsideActorInterface => "${RECEIVER_MACRO} macro: receivers inside ${ACTOR_INTERFACE_MACRO} must be empty."

            case MacroOptionNotAllowed(opt, name) => "${name} macro: option '${opt.getKeyString()}' not allowed."
            case MacroOptionInvalidOption(name) => "Macro options: invalid option '${name}'."
            case MacroOptionInvalidFormat => "Macro options: an option must be in the form of 'option1: value1, option2: value2'."
            case MacroOptionUnexpectedToken(name) => "Macro options: unexpected token '${name}'."
            case MacroOptionEnableReceiverPriorityIllegalArgument => "Macro options: enableReceiverPriority must take a boolean literal."
            case MacroOptionPriorityIllegalArgument => "Macro options: priority must be an integer literal inside the range [1..10]."
            case MacroOptionModeIllegalArgument => "Macro options: mode must be either AskOnly, TellOnly, or AskAndTell."
            case MacroOptionDistributedIllegalArgument => "Macro options: distributed must must take a boolean literal."
            case MacroOptionCustomInfosInvalidFormat => "Macro options: customInfo must be a valid JSON array of objects with string key-value pairs."
            case MacroOptionDuplicatedOption(opt) => "Macro options: duplicated option '${opt.getKeyString()}'."
            case MacroReceiverInfoUnsupportedType => "Receiver info: unsupported type for parameter schema generation."
        }
    }
}