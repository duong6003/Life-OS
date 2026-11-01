# Màn: Hôm nay

- Module: Nền · MVP · Frame: `design/reference/screens.html` → Hôm nay → iPhone / iPad / Mac → Có dữ liệu, Tối 20:15, Lần đầu, Máy mới, Cần xử lý đồng bộ
- BR: BR-TDY-01..04, BR-TSK-08, BR-JRN-03, BR-CAP-07 · TC: TC-TDY-*, TC-PERF-01

## Mục đích
Trả lời trong 2 giây: hôm nay làm gì, thói quen nào còn, đã chi bao nhiêu, cảm thấy thế nào.

## Bố cục theo thiết bị
| | iPhone | iPad | Mac |
|---|---|---|---|
| Điều hướng | Tab "Hôm nay" (đầu tiên); thanh "Ghi nhanh…" trong `.tabViewBottomAccessory` | Sidebar mục đầu | Sidebar, ⌘1 |
| Tiêu đề | Tiêu đề lớn "Hôm nay"; dưới là ngày đầy đủ + lời chào ("Thứ Sáu, 30 tháng 10 · Chào buổi tối, An") + `SyncStatusBadge` khi không phải `synced` | Như iPhone | Như iPhone; nút Ghi nhanh trên toolbar |
| Nội dung | `List` dạng inset: các `TodayCard` theo BR-TDY-02, chip Inbox ở đầu nếu có | 2 cột thẻ khi rộng ≥ 900 pt | 2 cột |

## Dữ liệu
```swift
struct TodaySnapshot: Sendable, Equatable {
  var dateLine: String            // "Thứ Sáu, 30 tháng 10"
  var greeting: String            // "Chào buổi tối, An"
  var inboxCount: Int
  var tasks: TodayTasksCard?      // nil = ẩn thẻ
  var habits: TodayHabitsCard?
  var spending: TodaySpendingCard?
  var checkIn: TodayCheckInCard?
}
```
`TodayQuery` gộp 4 truy vấn nhỏ trong một lần đọc (một `DatabasePool.read`), dùng index `task_open_due`, `habit_log_by_habit_day`, `txn_by_day`, `journal_by_day`. Chuỗi đã định dạng sẵn (BR-GEN-04).

## Trạng thái
| Trạng thái | Khi nào | Hiển thị |
|---|---|---|
| Có dữ liệu | Có ít nhất một thẻ | Các thẻ |
| Trống | Không thẻ nào | `ContentUnavailableView` "Hôm nay còn trống" + nút "Ghi nhanh" |
| Máy mới | Đang tải lần đầu trên máy mới (`SyncStatus.syncing` và DB rỗng) | Thẻ `.redacted(.placeholder)` |
| Cần mã | `needsRecoveryKey` | Badge dưới tiêu đề, chạm → Bảo mật và khôi phục |

## Tương tác
| Hành động | Kết quả | Haptic / animation | Hoàn tác |
|---|---|---|---|
| Chạm vòng tròn việc | Xong việc (BR-TSK-03) | success; `.lifeOSAnimation(.standard)` | Toast 4 giây |
| Chạm ô thói quen | Tick hôm nay | success; số chuỗi `contentTransition(.numericText())` | Chạm lại |
| Chạm thẻ Chi tiêu | Sang tab Thu chi tháng này | — | — |
| Chạm mặt tâm trạng trên thẻ Check-in | Lưu tâm trạng, mở sheet nửa màn Check-in | selection | Đổi lại |
| ⌘N / thanh Ghi nhanh | Sheet Ghi nhanh | — | — |

## Câu chữ
"Hôm nay", "Quá hạn", "và %d việc khác", "Thói quen hôm nay", "%d/%d", "Đã chi tháng này", "còn %@", "Vượt %@", "Hôm nay bạn thấy thế nào?", "Hôm nay còn trống", "Ghi nhanh…".

## Trợ năng
Mỗi thẻ là một nhóm (`accessibilityElement(children: .contain)`) có tiêu đề; thứ tự đọc theo thứ tự thẻ. AX5: thẻ một cột, ô thói quen xuống dòng.

## Hiệu năng
Khung hình đầu ≤ 400 ms (TC-PERF-01). Tick việc chỉ làm vẽ lại hàng đó và số trên thẻ. Kính: chỉ tab bar + thanh Ghi nhanh + toast (hệ thống).
