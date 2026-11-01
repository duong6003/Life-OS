import Persistence
import SQLiteData

/// ADR-0016: target DUY NHẤT được nhắc tới `SyncEngine`. AppFeature gọi `CloudSync.makeEngine` đúng một lần.
/// LOS-026 cài thật: `SyncEngine(for: database.writer, tables: <mọi bảng có deleted_at>)`
/// theo danh sách trong `SyncTables` (khớp schema/0001_initial.sql, bỏ `local_setting`).
public enum CloudSync {
    public enum SetupError: Error, Sendable {
        case notConfigured
    }

    public static func makeEngine(for database: AppDatabase) throws -> SyncEngine {
        _ = database
        throw SetupError.notConfigured
    }
}

/// Bảng đồng bộ trong MVP (data-model §2). Đổi danh sách này = đổi data-model.md và TC-SYNC-15.
public enum SyncTables {
    public static let names: [String] = [
        "area", "task", "habit", "habit_log", "journal_entry",
        "category", "txn", "budget", "weekly_review", "setting",
    ]
}
