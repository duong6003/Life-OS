import CryptoCore
import CryptoKit
import Foundation

/// CryptoProvider bằng CryptoKit (SPEC-crypto §1). Khung: LOS-050 hoàn thiện và chạy TestVectors/envelope.
public struct CryptoKitProvider: CryptoProvider {
    public init() {}

    public func randomBytes(_ count: Int) -> [UInt8] {
        SymmetricKey(size: .init(bitCount: count * 8)).withUnsafeBytes { Array($0) }
    }

    public func hkdfSHA256(ikm: [UInt8], salt: [UInt8], info: [UInt8], outputLength: Int) -> [UInt8] {
        let key = HKDF<SHA256>.deriveKey(
            inputKeyMaterial: SymmetricKey(data: ikm), salt: salt, info: info, outputByteCount: outputLength)
        return key.withUnsafeBytes { Array($0) }
    }

    public func hmacSHA256(key: [UInt8], message: [UInt8]) -> [UInt8] {
        Array(HMAC<SHA256>.authenticationCode(for: message, using: SymmetricKey(data: key)))
    }

    public func chaChaPolySeal(key: [UInt8], nonce: [UInt8], plaintext: [UInt8], aad: [UInt8]) throws -> [UInt8] {
        let box = try ChaChaPoly.seal(
            plaintext, using: SymmetricKey(data: key), nonce: ChaChaPoly.Nonce(data: nonce), authenticating: aad)
        return Array(box.ciphertext) + Array(box.tag)
    }

    public func chaChaPolyOpen(key: [UInt8], nonce: [UInt8], ciphertextAndTag: [UInt8], aad: [UInt8]) throws -> [UInt8]
    {
        guard ciphertextAndTag.count >= 16 else { throw CryptoError.tampered }
        do {
            let box = try ChaChaPoly.SealedBox(
                nonce: ChaChaPoly.Nonce(data: nonce),
                ciphertext: ciphertextAndTag.dropLast(16),
                tag: ciphertextAndTag.suffix(16))
            return Array(try ChaChaPoly.open(box, using: SymmetricKey(data: key), authenticating: aad))
        } catch {
            throw CryptoError.tampered
        }
    }
}
