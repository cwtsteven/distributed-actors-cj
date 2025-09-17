package actors

public interface Supervisable {
    func onException(_: Exception): ControlAction { Continue }

    func onError(_: Error): ControlAction { Continue }
}