import Foundation

/// Đọc TestVectors/ ở gốc repo. Đường dẫn tính từ file này nên chạy được cả `swift test` lẫn Xcode.
public enum VectorLoader {
    public static var root: URL {
        URL(fileURLWithPath: #filePath)            // …/Packages/LifeOSCore/Sources/TestSupport/VectorLoader.swift
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("TestVectors")
    }

    public static func data(_ relativePath: String) throws -> Data {
        try Data(contentsOf: root.appendingPathComponent(relativePath))
    }

    public static func decode<T: Decodable>(_ type: T.Type, _ relativePath: String) throws -> T {
        try JSONDecoder().decode(T.self, from: data(relativePath))
    }
}
