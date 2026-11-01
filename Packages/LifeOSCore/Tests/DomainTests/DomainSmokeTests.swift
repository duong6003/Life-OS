import TestSupport
import Testing

@testable import Domain

/// Kiểm khung build được và tìm thấy TestVectors. Thay bằng test thật trong các issue LOS-01x/02x.
@Test func vectorsFolderIsReachable() throws {
    let data = try VectorLoader.data("merge/schema.json")
    #expect(!data.isEmpty)
}
