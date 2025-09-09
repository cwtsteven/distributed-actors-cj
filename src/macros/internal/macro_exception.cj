package actors.macros.internal

class MacroException <: Exception {
    public init(message: String) {
        super("macro failed to expand. \n" + message)
    }

    protected override func getClassName(): String {
        "Actor framework"
    }
}