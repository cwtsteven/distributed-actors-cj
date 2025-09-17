package actors

public interface Supervisable {
    func onException(e: Exception): ControlAction { throw e }

    func onError(e: Error): ControlAction { throw e }
}