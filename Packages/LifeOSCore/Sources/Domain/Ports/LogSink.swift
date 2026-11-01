/// Lõi không import `os`; Apple tiêm cài đặt dùng `os.Logger` (conventions §8). Không bao giờ log nội dung người dùng.
public protocol LogSink: Sendable {
    func log(_ level: LogLevel, _ category: String, _ message: String)
}

public enum LogLevel: Sendable { case debug, info, warning, error }
