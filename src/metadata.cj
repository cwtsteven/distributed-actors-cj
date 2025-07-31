package actors

public struct Metadata {
    public Metadata(
        private let actorName: String,
        private let receivers: Array<ReceiverInfo>,
        private let description: String,
        private let customInfo: Array<CustomInfo>
    ) {}
}

public struct ReceiverInfo {

}