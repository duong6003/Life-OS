import Foundation
import Testing
import TestSupport
@testable import Persistence

/// Kiểm khung build được và bản schema đóng gói có mặt. Thay bằng test thật trong LOS-020/024.
@Test func bundledSchemaIsPresent() throws {
    let url = try #require(Bundle.module.url(forResource: "sql/0001_initial", withExtension: "sql"))
    let sql = try String(contentsOf: url, encoding: .utf8)
    #expect(sql.contains("CREATE TABLE task"))
}
