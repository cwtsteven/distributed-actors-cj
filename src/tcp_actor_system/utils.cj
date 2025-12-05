package actors.tcp_actor_system

import encoding.json.*

extend<T> Array<T> {
    /*
    * Fills the array with the same value
    * @param x - the value to fill the array with
    */
    func fill(x: T) {
        for (i in 0..size) {
            this[i] = x
        }
    }
}

/*
* Converts a stack trace to a string
* @param msg - the message to wrap
* @param traceElementArray - the stack trace elements
* @return the stack trace as a string
*/
func stackTraceToString(msg: String, traceElementArray: Array<StackTraceElement>): String {
    var res = "A non-serializable exception or error has been thrown from the receiver execution, below shows its stack trace in the remote machine:\n"
    res += "\t" + msg + "\n"
    for (element in traceElementArray) {
        if (element.declaringClass.isEmpty() && element.methodName.isEmpty()) { // simple stack trace format
            res += "\t at ${element.fileName}:${element.lineNumber}"
        } else {
            let packageDelimiter: String = if (element.declaringClass.isEmpty()) { "" } else { "." }
            res += "\t at ${element.declaringClass}${packageDelimiter}${element.methodName}(${element.fileName}:${element.lineNumber})"
        }
    }
    res
}