# Test case phi chức năng

Đo trên **bản Release, thiết bị thật cũ nhất được hỗ trợ**, DB seed 3 năm (`reference/seed.py`). Ghi kết quả vào `docs/engineering/perf-log.md` mỗi lần chạy (ngày, máy, commit, số đo).

## PERF
| ID | Chỉ số | Cách đo | Ngưỡng đạt | Covers | Mức |
|---|---|---|---|---|---|
| TC-PERF-01 | Khởi động lạnh tới Hôm nay có dữ liệu | `XCTApplicationLaunchMetric` + signpost `today.firstFrame`; Organizer p50 | p50 ≤ 400 ms, p90 ≤ 600 ms | BR-TDY-04 | UI, M |
| TC-PERF-02 | Cuộn danh sách Việc (4.000 việc) | `XCTOSSignpostMetric.scrollDraggingMetric`, Instruments Hitches | hitch ≤ 10 ms/s (mục tiêu 5) | perf budget | UI |
| TC-PERF-03 | Heatmap 26 tuần × 6 thói quen | SwiftUI instrument: body updates; Hitches khi cuộn Thói quen | ≤ 1 lần body mỗi heatmap mỗi thay đổi; hitch ≤ 10 ms/s | BR-HAB-06 | M |
| TC-PERF-04 | Đổi tháng Thu chi | Signpost `spending.monthSwitch` | ≤ 100 ms tới khung đầu; truy vấn SQL ≤ 10 ms | BR-SPD-06 | I, M |
| TC-PERF-05 | Ghi khoản chi | Thời gian từ chạm thanh Ghi nhanh tới toast | ≤ 3 chạm, ≤ 5 giây (người thật) ; phần app ≤ 50 ms | BR-CAP-06 | M |
| TC-PERF-06 | Đồng bộ không chặn | Instruments Time Profiler khi nhận 5.000 bản ghi | Main thread không bị chặn > 16 ms; không hang > 250 ms | BR-SYNC-04 | M |
| TC-PERF-07 | RAM rảnh | Memory gauge sau 1 phút ở Hôm nay | Ghi số đo (giả thuyết 20–40 MB); cảnh báo nếu tăng > 10% so với lần trước | perf budget | M |
| TC-PERF-08 | Dung lượng tải | App Thinning Size Report | Ghi số đo; CI chặn PR làm tăng > 500 KB | perf budget | CI |
| TC-PERF-09 | Pin đồng bộ | Instruments Energy 30 phút dùng thường + 2 máy | Ghi số đo; so sánh 2 cách đóng gói ở spike LOS-030 | ADR-0005 | M |
| TC-PERF-10 | Truy vấn có index | `EXPLAIN QUERY PLAN` mọi Query trong test | Không `SCAN` trên bảng > 1.000 hàng | conventions §6 | I |

## A11Y
| ID | Kiểm | Mong đợi | Mức |
|---|---|---|---|
| TC-A11Y-01 | Dynamic Type AX5 trên mọi màn MVP | Không cắt chữ, không chồng; tâm trạng/năng lượng chuyển dọc | UI (snapshot), M |
| TC-A11Y-02 | VoiceOver luồng ghi chi, tick việc, check-in, nhập mã | Đọc đủ nhãn, giá trị, trait; thứ tự hợp lý; mã đọc từng ký tự | M |
| TC-A11Y-03 | Increase Contrast | Dùng biến thể colorset riêng; tương phản đạt bảng HANDOFF | UI (snapshot) |
| TC-A11Y-04 | Reduce Motion / Transparency | Chuyển động chỉ opacity 0,09 giây; kính thành đặc | M |
| TC-A11Y-05 | Vùng chạm | Mọi control ≥ 44 pt | UI (audit `performAccessibilityAudit`) |

## DEV
| ID | Kiểm | Mong đợi | Mức |
|---|---|---|---|
| TC-DEV-01 | iPhone 390 pt | Tab bar hệ thống + thanh Ghi nhanh | M |
| TC-DEV-02 | iPad 1180×820 | NavigationSplitView, sidebar 240, ⌘N | M |
| TC-DEV-03 | Mac cửa sổ tối thiểu 760×560 | Menu Đi tới ⌘1–⌘6, ⌘N, ⌘,; chuột phải = vuốt | M |
