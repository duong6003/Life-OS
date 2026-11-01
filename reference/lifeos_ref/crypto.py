"""SPEC-crypto — envelope LOS1, cây khoá, mã khôi phục. Oracle dùng thư viện `cryptography`."""
from __future__ import annotations
import hashlib, hmac
from cryptography.hazmat.primitives.ciphers.aead import ChaCha20Poly1305
from cryptography.hazmat.primitives.kdf.hkdf import HKDF
from cryptography.hazmat.primitives import hashes

ALPHABET = "ACDEFGHJKMNPQRTWXY34679"
RC_LEN = 28
ZERO_SALT = b"\x00" * 32
MAGIC = b"LOS\x01"


def hkdf(ikm: bytes, info: str, length: int = 32, salt: bytes = ZERO_SALT) -> bytes:
    return HKDF(algorithm=hashes.SHA256(), length=length, salt=salt, info=info.encode()).derive(ikm)


def mk_kid(mk: bytes) -> bytes: return hkdf(mk, "lifeos/v1/kid", 16)
def k_row(mk: bytes) -> bytes: return hkdf(mk, "lifeos/v1/row")
def k_field(mk: bytes) -> bytes: return hkdf(mk, "lifeos/v1/field")
def k_name(mk: bytes) -> bytes: return hkdf(mk, "lifeos/v1/record-name")


def record_name(mk: bytes, tbl: str, row_id: str) -> str:
    return hmac.new(k_name(mk), f"{tbl}:{row_id}".encode(), hashlib.sha256).hexdigest()[:32]


def normalize_rc(s: str) -> str:
    return "".join(ch for ch in s.upper() if ch.isalnum())


def invalid_rc_chars(s: str) -> list[str]:
    return sorted({ch for ch in normalize_rc(s) if ch not in ALPHABET})


def rc_from_bytes(stream: bytes) -> str:
    out = []
    for b in stream:
        if b < 230:
            out.append(ALPHABET[b % 23])
            if len(out) == RC_LEN:
                return "".join(out)
    raise ValueError("not enough bytes")


def format_rc(rc: str) -> str:
    return " ".join(rc[i:i + 4] for i in range(0, len(rc), 4))


def kek(rc: str) -> bytes: return hkdf(normalize_rc(rc).encode(), "lifeos/v1/kek", 32, b"lifeos/v1/recovery")
def rkid(rc: str) -> bytes: return hkdf(normalize_rc(rc).encode(), "lifeos/v1/rkid", 16, b"lifeos/v1/recovery")


def seal(key: bytes, kid: bytes, nonce: bytes, plaintext: bytes, context: str) -> bytes:
    assert len(kid) == 16 and len(nonce) == 12
    header = MAGIC + kid
    aad = header + ("lifeos/v1|" + context).encode()
    return header + nonce + ChaCha20Poly1305(key).encrypt(nonce, plaintext, aad)


class EnvelopeError(Exception): ...


def open_(keys: dict[bytes, bytes], env: bytes, context: str) -> bytes:
    if env[:4] != MAGIC:
        raise EnvelopeError("UnsupportedVersion")
    kid, nonce, ct = env[4:20], env[20:32], env[32:]
    if kid not in keys:
        raise EnvelopeError("UnknownKey")
    aad = env[:20] + ("lifeos/v1|" + context).encode()
    try:
        return ChaCha20Poly1305(keys[kid]).decrypt(nonce, ct, aad)
    except Exception:
        raise EnvelopeError("Tampered")
