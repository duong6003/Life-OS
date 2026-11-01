# ADR-0005: Kênh đồng bộ CKSyncEngine sau protocol SyncTransport

- Trạng thái: Hoãn tới sau MVP bởi ADR-0016 (LOS-075)
- Liên quan: SPEC-sync §7, ADR-0006

## Bối cảnh
Cần kênh tiết kiệm pin nhất có thể với app bên thứ ba, không máy chủ, chở được dữ liệu đã tự mã hoá, và sau này thay được bằng Google Drive/Dropbox/WebDAV.

## Quyết định
Dùng **CKSyncEngine** trên private database của người dùng, trong một zone `LifeOS`. Mỗi bản ghi CloudKit chỉ chứa trường `payload: Data` (envelope đã mã hoá, SPEC-crypto §4) và vài trường kỹ thuật không nhạy cảm (`v`, `kid`). Toàn bộ nằm sau protocol `SyncTransport` trong `SyncCore`; adapter CloudKit ở `LifeOSPlatform/CloudKitTransport`.

Mặc định đóng gói **"một hàng = một CKRecord"** (row-state): payload chứa giá trị + HLC từng trường; dung lượng cloud tỉ lệ với dữ liệu đang sống. Spike LOS-030 so với "changeset bất biến theo thiết bị" về pin/RAM/dung lượng; nếu kết quả ngược lại thì viết ADR thay thế.

## Lựa chọn đã cân nhắc
| Kênh | Pin & độ trễ | E2EE của mình | Rủi ro mất dữ liệu | Đường cho cloud khác |
|---|---|---|---|---|
| **CKSyncEngine + payload tự mã hoá** | Tốt nhất (push + lịch hệ thống) | Có | Thấp | Cùng spec, adapter khác |
| SQLiteData SyncEngine | Như trên | Không (khoá Apple) | Còn issue phân kỳ | Không |
| iCloud Drive file bất biến | Không cam kết | Có | Thấp | Rất gần Google Drive |
| iCloud Drive đồng bộ file SQLite | — | — | **Cao** | **Cấm** |

## Hệ quả
- Change token của CKSyncEngine chỉ lưu **sau** khi đã ghi cục bộ trong cùng transaction.
- Xử lý `serverRecordChanged` = giải mã bản server, hợp nhất theo HLC, lưu lại, xếp gửi lại.
- iCloud Drive chỉ dùng cho file xuất/sao lưu người dùng nhìn thấy.
