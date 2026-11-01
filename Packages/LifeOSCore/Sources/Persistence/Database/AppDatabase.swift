import Domain
import GRDB
import SyncCore

/// Điểm vào DB (ADR-0003). Khung: LOS-020 cài DatabasePool (WAL), App Group, migration M0001 từ Migrations/sql.
public final class AppDatabase: Sendable {
    public let writer: any DatabaseWriter

    public init(writer: any DatabaseWriter) {
        self.writer = writer
    }
}
