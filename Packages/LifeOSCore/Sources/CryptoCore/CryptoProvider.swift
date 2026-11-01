/// Primitive mật mã (SPEC-crypto §1). CryptoKit cài ở LifeOSPlatform/CryptoApple; lõi không import CryptoKit.
public protocol CryptoProvider: Sendable {
    func randomBytes(_ count: Int) -> [UInt8]
    func hkdfSHA256(ikm: [UInt8], salt: [UInt8], info: [UInt8], outputLength: Int) -> [UInt8]
    func hmacSHA256(key: [UInt8], message: [UInt8]) -> [UInt8]
    /// ChaCha20-Poly1305. Trả ciphertext || tag (16 byte).
    func chaChaPolySeal(key: [UInt8], nonce: [UInt8], plaintext: [UInt8], aad: [UInt8]) throws -> [UInt8]
    func chaChaPolyOpen(key: [UInt8], nonce: [UInt8], ciphertextAndTag: [UInt8], aad: [UInt8]) throws -> [UInt8]
}

public enum CryptoError: Error, Equatable, Sendable {
    case unsupportedVersion, unknownKey, tampered, invalidRecoveryCode
}
