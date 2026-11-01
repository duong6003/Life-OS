import Domain

/// Kênh chuyên chở trung lập (ADR-0005). CloudKit là một cài đặt trong LifeOSPlatform; Google Drive/WebDAV sau này cũng vậy.
/// Transport chỉ thấy bản ghi đã mã hoá (`opaquePayload`), không bao giờ thấy RowPayload rõ (threat-model T10).
public protocol SyncTransport: Sendable {
    func start(delegate: any SyncTransportDelegate) async
    func enqueue(_ changes: [PendingRecordChange]) async
}

public protocol SyncTransportDelegate: AnyObject, Sendable {
    /// Transport xin nội dung cho các bản ghi sắp gửi (CKSyncEngine `nextRecordZoneChangeBatch`).
    func recordsToSend(_ names: [String]) async -> [OpaqueRecord]
    func didSave(_ names: [String]) async
    func didFetch(_ records: [OpaqueRecord], deletions: [String]) async
    func serverHasNewer(_ record: OpaqueRecord) async
    func statusChanged(_ status: TransportStatus) async
}

public struct OpaqueRecord: Sendable, Hashable {
    public let name: String          // SPEC-sync §3.3 (HMAC)
    public let keyID: String         // hex kid
    public let payloadVersion: Int   // pv
    public let opaquePayload: [UInt8]

    public init(name: String, keyID: String, payloadVersion: Int, opaquePayload: [UInt8]) {
        self.name = name
        self.keyID = keyID
        self.payloadVersion = payloadVersion
        self.opaquePayload = opaquePayload
    }
}

public enum PendingRecordChange: Sendable, Hashable {
    case save(name: String)
    case delete(name: String)
}

public enum TransportStatus: Sendable, Equatable {
    case available, signedOut, quotaExceeded, temporarilyUnavailable, accountChanged
}
