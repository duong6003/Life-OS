import Testing

@testable import Domain

@Test func test_TC_GEN_04_localDateFormatsAsISO() {
    #expect(LocalDate(year: 2026, month: 10, day: 30).description == "2026-10-30")
    #expect(LocalDate(year: 2026, month: 1, day: 5).description == "2026-01-05")
    #expect(LocalDate(year: 2026, month: 10, day: 29) < LocalDate(year: 2026, month: 10, day: 30))
}
