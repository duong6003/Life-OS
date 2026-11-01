# Màn: <Tên>

- Module: … · Giai đoạn: MVP | GĐ2 · Frame tham chiếu: `design/reference/screens.html` → <màn> → <thiết bị> → <trạng thái>
- BR: BR-… · TC: TC-…

## Mục đích
Một câu: người dùng vào đây để làm gì.

## Bố cục theo thiết bị
| | iPhone (compact) | iPad (regular) | Mac |
|---|---|---|---|
| Điều hướng | | | |
| Nội dung | | | |
| Thao tác chính | | | |

## Dữ liệu (snapshot)
```swift
struct <Name>Snapshot: Sendable, Equatable { … }
```
Truy vấn: `<Name>Query` — bảng, điều kiện, index dùng.

## Trạng thái
| Trạng thái | Khi nào | Hiển thị |
|---|---|---|
| Có dữ liệu | | |
| Trống | | |
| Máy mới (đang tải lần đầu) | | `.redacted(.placeholder)` |
| Lỗi (3 loại BR-GEN-08) | | |

## Tương tác
| Hành động | Kết quả | Haptic / animation | Hoàn tác |
|---|---|---|---|

## Câu chữ
Mọi chuỗi hiển thị, đúng như sẽ vào `.xcstrings`.

## Trợ năng
Nhãn VoiceOver, thứ tự đọc, AX5, Reduce Motion.

## Hiệu năng
Số `body` cập nhật mong đợi mỗi thao tác; kính/hiệu ứng dùng (≤ 5 kính).
