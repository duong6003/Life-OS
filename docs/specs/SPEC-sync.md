# SPEC-sync · Life OS Sync Spec v1

- Version: **1.0-draft** (01/11/2026)
- Trạng thái: bản nháp để code LOS-012 (HLC), LOS-014 (merge), LOS-023 (SyncWriter), LOS-031 (coordinator); khoá thành 1.0 khi harness LOS-033 xanh.
- Kiểm bằng: `TestVectors/hlc/*.json`, `TestVectors/merge/*.json`, code tham chiếu `reference/lifeos_ref/sync.py`.
- Phạm vi: định dạng và thuật toán **trung lập nền tảng**. Bản Swift và bản Kotlin phải cho cùng kết quả trên mọi test vector.

Từ khoá PHẢI / KHÔNG ĐƯỢC / NÊN theo nghĩa RFC 2119.

## 1. Mô hình

- Mỗi thiết bị có SQLite riêng là nguồn sự thật cục bộ.
- Mỗi **trường** (bảng, id hàng, cột) mang một nhãn HLC. Hợp nhất từng trường độc lập.
- Kênh chuyên chở (`SyncTransport`) chỉ thấy **RowPayload đã mã hoá** (SPEC-crypto §4).
- Mô hình mượn từ Actual Budget (HLC + LWW theo ô + tombstone). Khác Actual: không có op-log vĩnh viễn; trạng thái trên cloud là "một bản ghi mỗi hàng" (ADR-0005).

## 2. HLC (Hybrid Logical Clock)

### 2.1 Định dạng chuỗi

```
<ISO-8601 UTC, mili-giây, 24 ký tự>-<counter 4 hex HOA>-<node 16 hex thường>
2026-11-01T06:52:10.123Z-0000-a1b2c3d4e5f60718
```

- Tổng 46 ký tự. So sánh hai HLC **PHẢI** bằng so sánh chuỗi theo byte (thứ tự từ điển). Định dạng cố định độ rộng nên đúng thứ tự thời gian, rồi counter, rồi node.
- `node`: 64 bit ngẫu nhiên, sinh một lần khi cài app, lưu `sync_state.node_id`. Không gắn với danh tính người dùng.

### 2.2 Thuật toán (giống Actual)

Trạng thái cục bộ: `(millis, counter, node)`. `phys` = đồng hồ hệ thống (ms). `MAX_DRIFT = 300000` (5 phút). `MAX_COUNTER = 0xFFFF`.

**tick()** — trước mỗi lần ghi cục bộ:
```
l' = max(l, phys)
c' = (l' == l) ? c + 1 : 0
nếu c' > MAX_COUNTER → lỗi CounterOverflow (không ghi)
lưu (l', c'); trả HLC(l', c', node)
```

**receive(remote)** — khi áp một trường từ máy khác:
```
nếu remote.node == node và remote > last_issued → lỗi DuplicateNode (§2.3)
nếu remote.millis - phys > MAX_DRIFT → KHÔNG cập nhật đồng hồ, vẫn hợp nhất dữ liệu bình thường, phát cảnh báo ClockDrift
ngược lại:
  l' = max(l, phys, remote.millis)
  c' = (l' == l == remote.millis) ? max(c, remote.counter) + 1
     : (l' == l)                  ? c + 1
     : (l' == remote.millis)      ? remote.counter + 1
     : 0
  nếu c' > MAX_COUNTER → lỗi CounterOverflow
  lưu (l', c')
```
Khác Actual: Actual ném lỗi khi lệch đồng hồ; Life OS **không chặn đồng bộ** vì một máy đặt sai giờ không được làm kẹt dữ liệu của người dùng (ghi trong BR-SYNC-06).

### 2.3 Trùng node
Xảy ra khi khôi phục cùng một bản sao lưu lên hai máy. Phát hiện ở receive → sinh `node` mới, lưu, tiếp tục. Không mất dữ liệu.

## 3. Định danh

### 3.1 UUIDv7 cho bản ghi thường
RFC 9562, chữ thường, có gạch.

### 3.2 UUIDv5 cho khoá tự nhiên
`UUIDv5(NS_LIFEOS, name)` với `NS_LIFEOS = 6f1c0a52-3c1e-4d55-9b0e-2f7d8a1b9c40` và `name` là UTF-8 của:

| Bảng | name |
|---|---|
| habit_log | `habit_log:<habit_id>:<YYYY-MM-DD>` |
| journal_entry | `journal_entry:<YYYY-MM-DD>` |
| journal_conflict | `journal_conflict:<entry_id>:<loser_hlc>` |
| budget | `budget:<YYYY-MM>:<category_id hoặc total>` |
| weekly_review | `weekly_review:<YYYY-MM-DD thứ Hai>` |
| setting | `setting:<key>` |
| dữ liệu mẫu | `seed:<bảng>:<khoá mẫu>` (vd. `seed:category:expense.food`) |

Vector: `TestVectors/merge/ids.json`.

### 3.3 Tên bản ghi trên cloud
`recordName = hex(HMAC-SHA256(K_name, "<tbl>:<row_id>"))[0:32]` (K_name ở SPEC-crypto §3). Cloud không thấy tên bảng hay ID thật.

### 3.4 Thứ tự sắp xếp (`sort_key`)
Fractional index dạng chuỗi base-62 (`0-9A-Za-z`), so sánh từ điển. Chèn giữa a và b = chuỗi ngắn nhất nằm giữa. Hai máy chèn cùng chỗ có thể trùng `sort_key` → hoà thì xếp theo `id`. Là trường `lww` bình thường.

## 4. Trạng thái trường và RowPayload

### 4.1 Lưu cục bộ
Giá trị nằm trong bảng thường. Nhãn nằm trong `sync_field_clock(tbl, row_id, col, hlc, base)`. Trường chưa có nhãn coi như HLC rỗng `""` (nhỏ hơn mọi HLC).

### 4.2 RowPayload (bản rõ trước khi mã hoá)
JSON UTF-8, khoá sắp xếp tăng dần, không khoảng trắng thừa (canonical, để băm/so sánh ổn định):
```json
{"f":{"deleted_at":{"h":"…","v":null},"due_on":{"h":"…","v":"2026-11-02"},"title":{"h":"…","v":"Mua sữa"}},
 "id":"0192…","sv":1,"t":"task","v":1}
```
| Khoá | Ý nghĩa |
|---|---|
| `v` | Phiên bản định dạng payload = 1 |
| `sv` | Schema version của máy gửi (số migration lớn nhất) |
| `t`, `id` | Bảng, khoá chính |
| `f` | Map cột → `{v: giá trị, h: HLC, b?: base}`. Chỉ có `b` với trường `keepBoth` |

Kiểu giá trị: TEXT → chuỗi; INTEGER → số nguyên JSON (an toàn trong ±2^53); NULL → `null`; BLOB → `{"b64":"…"}`. `journal_entry.body_sealed` gửi dạng **bản rõ đã giải mã** dưới khoá ảo `body` (chuỗi) vì cả payload đã được mã hoá; máy nhận mã hoá lại mức trường bằng khoá của mình. Payload PHẢI chứa **mọi trường** của hàng (row-state), không chỉ trường đổi.

## 5. Ghi cục bộ (SyncWriter)

Trong **một** transaction:
1. `h = clock.tick()`
2. Ghi giá trị vào bảng.
3. Với mỗi cột thay đổi: `sync_field_clock.hlc = h`. Với `keepBoth`: `base` = (nếu hàng đang trong outbox và nhãn hiện tại do chính máy này tạo) ? giữ `base` cũ : nhãn hiện tại trước khi sửa.
4. `updated_at = now`. UPSERT `sync_outbox(tbl,row_id,enqueued_at=h)`.

Không được có đường ghi bảng đồng bộ nào không qua SyncWriter (kiểm bằng test TC-SYNC-03 + review).

## 6. Hợp nhất (Merger — hàm thuần)

### 6.1 Hợp nhất một hàng
```
merge(localRow?, remotePayload, localDirty: Set<col>) -> (row, conflicts[], changedCols)
```
Với mỗi cột `c` trong hợp `local.f ∪ remote.f`:
- Chỉ có một bên → lấy bên đó.
- Chính sách `lww`: `remote.h > local.h` → lấy remote; ngược lại giữ local. Bằng nhau → giữ (cùng một thay đổi).
- Chính sách `keepBoth`: xem §6.3.

Sau đó `clock.receive(h)` cho mọi `h` nhận được.

### 6.2 Tombstone
`deleted_at` là trường `lww` bình thường. Hàng có `deleted_at != null` bị ẩn khỏi mọi truy vấn. Sửa trường khác của hàng đã xoá vẫn hợp nhất (không "hồi sinh" hàng). Khôi phục = ghi `deleted_at = null` với HLC mới hơn. Không bao giờ xoá vật lý hàng đồng bộ trong v1 (dọn rác: §9).

### 6.3 keepBoth (nội dung nhật ký)
Cho trường `c` có local `L{v,h,b}` và remote `R{v,h,b}`:
```
nếu R.h == L.h                → không đổi
nếu c ∉ localDirty            → LWW thường (R.h > L.h thì lấy R)
nếu R.h <= L.b                → R cũ hơn gốc của L: bỏ qua
ngược lại (xung đột thật):
  winner = (R.h > L.h) ? R : L ; loser = bên còn lại
  body = winner
  thêm journal_conflict{ id = v5("journal_conflict:<entry_id>:<loser.h>"), entry_id, body = loser.v, loser_hlc = loser.h }
```
`localDirty` = các cột `keepBoth` của hàng đang trong outbox có nhãn do máy này tạo. Cả hai máy đều đi tới cùng `body` (HLC lớn hơn) và cùng ID xung đột → hội tụ.

### 6.4 Bất biến sau hợp nhất
Không giả định ràng buộc giữa các trường. Ví dụ `status='open'` mà `completed_at != null` là hợp lệ sau hợp nhất; code đọc PHẢI coi `status` là nguồn duy nhất (BR-SYNC-05).

### 6.5 Bảng, cột lạ
- Bảng không có trong schema của máy → lưu nguyên payload vào `sync_unknown`, không lỗi.
- Cột lạ trong bảng đã biết → bỏ qua cột đó, lưu payload vào `sync_unknown` để áp lại khi app được nâng cấp (migration xong → `reapplyUnknown()`).
- `sv` lớn hơn của mình → vẫn xử lý như trên. `v` (định dạng payload) lớn hơn → không giải được → giữ trong `sync_unknown`, trạng thái đồng bộ "Cần cập nhật app".

## 7. Kênh CloudKit (adapter)

- Container `iCloud.<bundle-id>`, private DB, zone `LifeOS`.
- `recordType = "Row"`, `recordName` theo §3.3, trường: `payload` (Bytes, envelope), `kid` (String), `pv` (Int64 = 1). Không có trường nào khác.
- `recordType = "KeyBundle"`, `recordName = "keybundle"` (SPEC-crypto §6).
- Gửi: CKSyncEngine `nextRecordZoneChangeBatch` lấy từ `sync_outbox` theo lô ≤ 250 hàng hoặc ≤ ~800 KB.
- Gửi xong (`savedRecords`): xoá khỏi outbox **chỉ khi** `enqueued_at` chưa đổi (nếu đổi tức là có sửa mới trong lúc gửi → giữ).
- `serverRecordChanged`: giải mã bản server → §6 với `localDirty` hiện tại → ghi → xếp gửi lại.
- Nhận (`fetchedRecordZoneChanges`): giải mã từng bản ghi → §6 → ghi dữ liệu, field clock, và **state serialization của CKSyncEngine trong cùng một transaction**.
- Xoá vật lý bản ghi CloudKit chỉ xảy ra khi dọn rác (§9).
- `zoneDeleted` / tài khoản đổi / `userDidResetEncryptedDataKey`: không xoá dữ liệu cục bộ; trạng thái "Chưa đồng bộ được", đưa mọi hàng vào outbox để gửi lại khi zone có lại.

## 8. Lỗi và trạng thái người dùng thấy

| Tình huống | `SyncStatus` | Người dùng thấy (SyncStatusBadge) | Hành động |
|---|---|---|---|
| Mọi thứ đã gửi/nhận | `synced` | Đã đồng bộ | — |
| Có hàng trong outbox, không mạng | `pending(n)` | Chờ đồng bộ · n thay đổi | Tự thử lại |
| Chưa đăng nhập iCloud | `iCloudSignedOut` | Chưa đăng nhập iCloud · vẫn lưu trong máy | Mở Cài đặt hệ thống |
| `quotaExceeded` | `iCloudFull` | iCloud đã đầy | Hướng dẫn giải phóng |
| Envelope có `kid` lạ / không có MK | `needsRecoveryKey` | Cần mã khôi phục | Mở màn nhập mã |
| Lỗi khác sau thử lại | `failed` | Chưa đồng bộ được | Tự thử lại theo CKSyncEngine |
| `pv`/`v` lớn hơn | `failed` + cờ `needsUpdate` | Cần cập nhật app để đồng bộ | App Store |

Không có trạng thái nào chặn việc dùng app.

## 9. Dọn rác (sau MVP)
Tombstone giữ ≥ 90 ngày. Sau đó máy có `primary` có thể xoá vật lý hàng + bản ghi CloudKit. Máy ngoại tuyến > 90 ngày khi quay lại phải tải toàn bộ (không áp thay đổi cũ đè lên). Chi tiết trong SPEC-sync 1.1.

## 10. Harness kiểm thử tất định (LOS-033)
`FakeTransport` + nhiều `Device` ảo trong một process, đồng hồ giả, seed ngẫu nhiên cố định. Mỗi vòng: các máy sửa ngẫu nhiên ngoại tuyến, lệch đồng hồ ±10 phút, mạng rớt giữa lô, gửi lặp, nhận sai thứ tự. Điều kiện xanh: sau khi mọi máy đồng bộ xong, **mọi bảng của mọi máy giống hệt nhau** và không mất bản nhật ký nào (tổng bản body + conflict chứa mọi bản đã viết). Chạy 10.000 vòng trong CI Linux (< 2 phút).
