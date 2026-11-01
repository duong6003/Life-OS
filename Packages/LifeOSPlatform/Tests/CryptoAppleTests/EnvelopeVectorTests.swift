import CryptoApple
import Testing
import TestSupport

/// TC-CRY-01: HKDF ra đúng khoá như TestVectors/envelope/keys.json. LOS-050 thêm seal/open và mã khôi phục.
@Test func test_TC_CRY_01_keyDerivationMatchesVectors() throws {
    struct Keys: Decodable { let mk: String; let kid: String; let k_row: String }
    let v = try VectorLoader.decode(Keys.self, "envelope/keys.json")
    let p = CryptoKitProvider()
    let mk = hex(v.mk)
    let salt = [UInt8](repeating: 0, count: 32)
    #expect(p.hkdfSHA256(ikm: mk, salt: salt, info: Array("lifeos/v1/kid".utf8), outputLength: 16) == hex(v.kid))
    #expect(p.hkdfSHA256(ikm: mk, salt: salt, info: Array("lifeos/v1/row".utf8), outputLength: 32) == hex(v.k_row))
}

private func hex(_ s: String) -> [UInt8] {
    var out: [UInt8] = []
    var i = s.startIndex
    while i < s.endIndex {
        let j = s.index(i, offsetBy: 2)
        out.append(UInt8(s[i..<j], radix: 16) ?? 0)
        i = j
    }
    return out
}
