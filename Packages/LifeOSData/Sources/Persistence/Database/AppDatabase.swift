import Domain
import GRDB

/// Điểm vào DB (ADR-0003, ADR-0016). Khung: LOS-020 cài DatabasePool (WAL), App Group,
/// migration M0001 từ Migrations/sql, và `attachMetadatabase()` của SQLiteData trong `prepareDatabase`
/// để SyncEngine dùng được (CloudSync tạo SyncEngine, Persistence không biết tới nó).
public final class AppDatabase: Sendable {
    public let writer: any DatabaseWriter

    public init(writer: any DatabaseWriter) {
        self.writer = writer
    }
}
