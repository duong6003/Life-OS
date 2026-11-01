"""Sinh TestVectors/{hlc,merge,recovery-code,envelope}. Tất định: không dùng ngẫu nhiên thật."""
from __future__ import annotations
import json, sqlite3, sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))
from lifeos_ref.hlc import HLC, Clock, CounterOverflow, DuplicateNode
from lifeos_ref import ids, merge, crypto

ROOT = Path(__file__).resolve().parent.parent
T0 = 1793516400000  # 2026-11-01T07:00:00.000Z
NA, NB = "aaaaaaaaaaaaaaaa", "bbbbbbbbbbbbbbbb"


def h(ms, c, n): return str(HLC(ms, c, n))


def hlc_vectors():
    fmt = [{"millis": m, "counter": c, "node": n, "string": h(m, c, n)}
           for m, c, n in [(T0, 0, NA), (T0 + 123, 1, NB), (0, 0, "0123456789abcdef"),
                           (253402300799999, 65535, "ffffffffffffffff")]]
    order = sorted([h(T0, 1, NA), h(T0, 0, NB), h(T0 + 1, 0, NA), h(T0, 0, NA), h(T0 - 1, 9, NB)])
    seq_ops = [("tick", T0, None), ("tick", T0, None), ("tick", T0 - 5000, None),
               ("receive", T0 + 10, HLC(T0 + 50, 3, NB)), ("tick", T0 + 20, None),
               ("receive", T0 + 100, HLC(T0 + 100, 7, NB)), ("tick", T0 + 200, None),
               ("receive", T0 + 300, HLC(T0 + 300 + 400000, 0, NB)), ("tick", T0 + 301, None),
               ("receive", T0 + 302, HLC(T0 + 1, 0, NB)), ("tick", T0 + 302, None)]
    c = Clock(NA); steps = []
    for op, phys, rem in seq_ops:
        st = {"op": op, "phys": phys}
        if op == "tick":
            st["expect"] = str(c.tick(phys))
        else:
            st["remote"] = str(rem); before = len(c.warnings); c.receive(rem, phys)
            st["expectWarning"] = c.warnings[-1] if len(c.warnings) > before else None
        st["stateAfter"] = {"millis": c.millis, "counter": c.counter}
        steps.append(st)
    errs = []
    c2 = Clock(NA, T0, 0xFFFF)
    try: c2.tick(T0)
    except CounterOverflow: errs.append({"name": "counter overflow on tick", "clock": {"node": NA, "millis": T0, "counter": 65535}, "op": "tick", "phys": T0, "expectError": "CounterOverflow"})
    c3 = Clock(NA, T0, 0)
    try: c3.receive(HLC(T0 + 5, 0, NA), T0)
    except DuplicateNode: errs.append({"name": "same node from the future", "clock": {"node": NA, "millis": T0, "counter": 0}, "op": "receive", "remote": h(T0 + 5, 0, NA), "phys": T0, "expectError": "DuplicateNode"})
    return {"format.json": {"spec": "SPEC-sync §2.1", "cases": fmt},
            "order.json": {"spec": "SPEC-sync §2.1", "sortedAscending": order},
            "sequence.json": {"spec": "SPEC-sync §2.2", "node": NA, "initial": {"millis": 0, "counter": 0},
                              "maxDriftMs": 300000, "steps": steps},
            "errors.json": {"spec": "SPEC-sync §2.2–2.3", "cases": errs}}


def merge_vectors():
    names = ["habit_log:0192f3a0-0000-7000-8000-000000000001:2026-10-30", "journal_entry:2026-10-30",
             "budget:2026-11:total", "weekly_review:2026-10-26", "setting:theme", "seed:category:expense.food"]
    idv = {"namespace": str(ids.NS_LIFEOS), "cases": [{"name": n, "uuid": ids.v5(n)} for n in names]}
    a0, a1, b1, a2 = h(T0, 0, NA), h(T0 + 1000, 0, NA), h(T0 + 2000, 0, NB), h(T0 + 3000, 0, NA)
    F = lambda v, hh, b=None: ({"v": v, "h": hh, **({"b": b} if b else {})})
    scen = [
        ("remote newer wins (lww)", "task", {"title": F("Mua sữa", a1)}, {"title": F("Mua sữa tươi", b1)}, []),
        ("local newer kept (lww)", "task", {"title": F("A", a2)}, {"title": F("B", b1)}, []),
        ("different fields both kept", "task", {"title": F("A", a2), "due_on": F(None, a0)},
         {"title": F("A", a0), "due_on": F("2026-11-02", b1)}, []),
        ("delete then edit elsewhere: stays deleted", "task",
         {"deleted_at": F(T0 + 1000, a1), "title": F("A", a0)}, {"deleted_at": F(None, a0), "title": F("A2", b1)}, []),
        ("restore beats older delete", "task", {"deleted_at": F(T0, a1)}, {"deleted_at": F(None, b1)}, []),
        ("new row from remote", "task", None, {"title": F("Mới", b1), "deleted_at": F(None, b1)}, []),
        ("same change echoed", "task", {"title": F("A", a1)}, {"title": F("A", a1)}, []),
        ("journal body, local clean: lww", "journal_entry", {"body": F("sáng nay…", a1, a0)},
         {"body": F("sáng nay mưa", b1, a1)}, []),
        ("journal body, both edited from same base: keep both (remote wins)", "journal_entry",
         {"body": F("bản máy A", a1, a0)}, {"body": F("bản máy B", b1, a0)}, ["body"]),
        ("journal body, both edited: keep both (local wins)", "journal_entry",
         {"body": F("bản máy A mới", a2, a0)}, {"body": F("bản máy B", b1, a0)}, ["body"]),
        ("journal body, remote older than local base: ignore", "journal_entry",
         {"body": F("A sửa tiếp", a2, b1)}, {"body": F("B", b1, a0)}, ["body"]),
        ("journal mood is lww even when dirty", "journal_entry",
         {"mood": F(2, a1), "body": F("x", a0)}, {"mood": F(4, b1), "body": F("x", a0)}, ["body", "mood"]),
    ]
    row = "0192f3a0-0000-7000-8000-00000000abcd"
    cases = []
    for name, tbl, L, Rm, dirty in scen:
        out, conf, ch = merge.merge_row(tbl, row, L, Rm, set(dirty))
        cases.append({"name": name, "table": tbl, "rowId": row, "local": L, "remote": Rm, "localDirty": dirty,
                      "expect": {"fields": out, "conflicts": conf, "changed": ch}})
    con = sqlite3.connect(":memory:")
    con.executescript((ROOT / "schema/0001_initial.sql").read_text())
    tables = {}
    for (t,) in con.execute("select name from sqlite_master where type='table' order by name"):
        cols = [r[1] for r in con.execute(f"pragma table_info({t})")]
        if "deleted_at" not in cols:
            continue
        fields = {}
        for c in cols:
            if c in ("id", "updated_at"): continue
            if t == "journal_entry" and c in ("body", "body_sealed"):
                fields["body"] = "keepBoth"; continue
            fields[c] = "lww"
        tables[t] = fields
    # Bảng của lớp đồng bộ tự làm (sau MVP, ADR-0016/LOS-075): migration thêm vào, chưa có trong schema MVP.
    tables.setdefault("journal_conflict", {c: "lww" for c in ("body_sealed", "created_at", "deleted_at", "entry_id", "loser_hlc")})
    tables = dict(sorted(tables.items()))
    return {"ids.json": {"spec": "SPEC-sync §3.2", **idv},
            "cases.json": {"spec": "SPEC-sync §6", "note": "fields: giá trị + nhãn sau hợp nhất; changed: cột lấy từ remote", "cases": cases},
            "schema.json": {"spec": "data-model.md §3", "schemaVersion": 1, "tables": tables}}


def crypto_vectors():
    mk = bytes(range(32))
    kid = crypto.mk_kid(mk)
    keys = {"mk": mk.hex(), "kid": kid.hex(), "k_row": crypto.k_row(mk).hex(),
            "k_field": crypto.k_field(mk).hex(), "k_name": crypto.k_name(mk).hex()}
    names = [{"table": t, "rowId": r, "recordName": crypto.record_name(mk, t, r)}
             for t, r in [("task", "0192f3a0-0000-7000-8000-000000000001"), ("journal_entry", ids.v5("journal_entry:2026-10-30"))]]
    seals = []
    for i, (key_name, ctx, pt) in enumerate([
        ("k_row", "row|" + names[0]["recordName"], '{"f":{"title":{"h":"%s","v":"Mua sữa"}},"id":"0192f3a0-0000-7000-8000-000000000001","sv":1,"t":"task","v":1}' % h(T0, 0, NA)),
        ("k_field", "field|journal_entry|" + names[1]["rowId"] + "|body", "Hôm nay trời mưa, đi bộ 30 phút. Ể Ặ Ỗ."),
        ("k_row", "row|empty", ""),
    ]):
        nonce = bytes([i + 1] * 12)
        env = crypto.seal(bytes.fromhex(keys[key_name]), kid, nonce, pt.encode(), ctx)
        seals.append({"key": key_name, "context": ctx, "nonce": nonce.hex(), "plaintextUtf8": pt, "envelope": env.hex()})
    good = bytes.fromhex(seals[0]["envelope"])
    tampered = good[:-1] + bytes([good[-1] ^ 1])
    wrong_kid = good[:4] + b"\xff" * 16 + good[20:]
    bad_magic = b"LOS\x02" + good[4:]
    neg = [{"name": "tampered tag", "envelope": tampered.hex(), "context": seals[0]["context"], "expectError": "Tampered"},
           {"name": "wrong context", "envelope": good.hex(), "context": "row|other", "expectError": "Tampered"},
           {"name": "unknown kid", "envelope": wrong_kid.hex(), "context": seals[0]["context"], "expectError": "UnknownKey"},
           {"name": "unsupported version", "envelope": bad_magic.hex(), "context": seals[0]["context"], "expectError": "UnsupportedVersion"}]
    for n in neg:
        try:
            crypto.open_({kid: crypto.k_row(mk)}, bytes.fromhex(n["envelope"]), n["context"]); raise SystemExit("negative case opened: " + n["name"])
        except crypto.EnvelopeError as e:
            assert str(e) == n["expectError"], (n["name"], e)
    for s in seals:
        assert crypto.open_({kid: bytes.fromhex(keys[s["key"]])}, bytes.fromhex(s["envelope"]), s["context"]).decode() == s["plaintextUtf8"]
    stream = bytes((i * 37 + 11) % 256 for i in range(64))
    rc = crypto.rc_from_bytes(stream)
    kek, rk = crypto.kek(rc), crypto.rkid(rc)
    wrap = crypto.seal(kek, rk, bytes([9] * 12), mk, "mkwrap|" + kid.hex())
    rcv = {"spec": "SPEC-crypto §3, §6.1", "alphabet": crypto.ALPHABET, "length": 28,
           "generate": {"randomBytes": stream.hex(), "expect": rc, "display": crypto.format_rc(rc)},
           "normalize": [{"input": i, "normalized": crypto.normalize_rc(i), "invalid": crypto.invalid_rc_chars(i)} for i in
                         [crypto.format_rc(rc).lower(), "k7qp-3mxr 9rta", "K7QO 3MXR", "  ", "ABCD0158"]],
           "derive": {"rc": rc, "kek": kek.hex(), "rkid": rk.hex()},
           "keyBundle": {"mk": mk.hex(), "mkid": kid.hex(), "nonce": "09" * 12, "context": "mkwrap|" + kid.hex(), "wrapped": wrap.hex()}}
    return {"envelope": {"keys.json": {"spec": "SPEC-crypto §2", **keys}, "record-names.json": {"spec": "SPEC-sync §3.3", "cases": names},
                         "seal.json": {"spec": "SPEC-crypto §4", "kid": kid.hex(), "cases": seals}, "open-errors.json": {"spec": "SPEC-crypto §4", "cases": neg}},
            "recovery-code": {"cases.json": rcv}}


def build() -> dict[str, str]:
    out = {}
    for f, d in hlc_vectors().items(): out[f"hlc/{f}"] = d
    for f, d in merge_vectors().items(): out[f"merge/{f}"] = d
    for folder, files in crypto_vectors().items():
        for f, d in files.items(): out[f"{folder}/{f}"] = d
    return {k: json.dumps(v, ensure_ascii=False, indent=2, sort_keys=True) + "\n" for k, v in out.items()}


if __name__ == "__main__":
    for k, v in build().items():
        p = ROOT / "TestVectors" / k; p.parent.mkdir(parents=True, exist_ok=True); p.write_text(v)
        print("wrote", k)
