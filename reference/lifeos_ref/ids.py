"""SPEC-sync §3 — ID tất định."""
import uuid

NS_LIFEOS = uuid.UUID("6f1c0a52-3c1e-4d55-9b0e-2f7d8a1b9c40")


def v5(name: str) -> str:
    return str(uuid.uuid5(NS_LIFEOS, name))
