import CryptoApple
import TestSupport
import Testing

/// TC-CRY-01: HKDF ra đúng khoá như TestVectors/envelope/keys.json. LOS-050 thêm seal/open và mã khôi phục.
@Test func test_TC_CRY_01_keyDerivationMatchesVectors() throws {
    struct Keys: Decodable {
        let mk: String
        let kid: String
        let kRow: String
        enum CodingKeys: String, CodingKey {
            case mk, kid
            case kRow = "k_row"
        }
    }
    let vectors = try VectorLoader.decode(Keys.self, "envelope/keys.json")
    let provider = CryptoKitProvider()
    let mk = hex(vectors.mk)
    let salt = [UInt8](repeating: 0, count: 32)
    #expect(
        provider.hkdfSHA256(ikm: mk, salt: salt, info: Array("lifeos/v1/kid".utf8), outputLength: 16)
            == hex(vectors.kid))
    #expect(
        provider.hkdfSHA256(ikm: mk, salt: salt, info: Array("lifeos/v1/row".utf8), outputLength: 32)
            == hex(vectors.kRow))
}

private func hex(_ text: String) -> [UInt8] {
    var out: [UInt8] = []
    var index = text.startIndex
    while index < text.endIndex {
        let next = text.index(index, offsetBy: 2)
        out.append(UInt8(text[index..<next], radix: 16) ?? 0)
        index = next
    }
    return out
}
