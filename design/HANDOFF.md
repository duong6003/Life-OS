# Life OS · Bàn giao design system (Apple)

Ngày cập nhật: Thứ Bảy, 31 tháng 10, 2026 · Nền tảng: **iPhone, iPad, Mac** bằng SwiftUI (iOS 26, macOS 26). Bản React + Tailwind giữ lại làm tham khảo cho web sau này (phụ lục D).

> **Ghi chú khi chuyển vào repo (01/11/2026):** đường dẫn trong file này là bản trước khi chuyển. Nay: `apple/design-tokens/` → `design/tokens/`, `apple/LifeOSDesignSystem/` → `Packages/LifeOSDesignSystem/`, `screens.html`/`component-library.html` → `design/reference/`, `code/` (web React) không chép vào repo (xem project files `life-os-design-system/code/`). Lệnh sinh token chạy ở gốc repo: `python3 design/tokens/generate.py`.

## Kết luận

Design system đã chuyển theo kiến trúc local-first: SwiftUI, SQLite/GRDB, đồng bộ qua CloudKit, mã hóa đầu cuối, không máy chủ. Đã làm 11 trên 12 mục của đề xuất; mục 12 (widget, Control Center) để giai đoạn sau.

Ba điều cần biết trước khi dựng app:

1. **Gói Swift chưa được biên dịch.** Môi trường làm việc không có Xcode hay Swift. Mã viết theo API iOS 26 / macOS 26 nhưng cần build thử. Các API dễ lệch nhất: `lineHeight(.multiple(factor:))`, `.glassEffect(_:in:)`, `.tabViewBottomAccessory`, `.tabBarMinimizeBehavior`, macro `@Entry`.
2. **Token có một nguồn duy nhất:** `apple/design-tokens/tokens.json`. Script `generate.py` sinh 30 colorset (Light, Dark, Increase Contrast), `Tokens.swift` và `tokens.css`. CSS sinh ra khớp với `globals.css` của bản web, trừ bo góc `lg` đã đổi 20 → 24 ngày 1/11 (bản web chưa đổi).
3. **Mục “đạt có điều kiện”** vẫn cần đo trên máy thật: thời gian ghi chi và check-in, VoiceOver, ngân sách khung hình.

## 1. Sản phẩm bàn giao

Mọi file nằm trong `/mnt/project-files/life-os-design-system/`.

| File | Nội dung |
|---|---|
| `HANDOFF.md` | Tài liệu này. |
| `apple/design-tokens/tokens.json` | Nguồn token v2, trung lập nền tảng: 30 màu (Light, Dark, Increase Contrast), độ mờ, chữ theo Dynamic Type, spacing, bố cục iPhone/iPad/Mac, bo góc, chất liệu, chuyển động, rung, icon. |
| `apple/design-tokens/generate.py` | `python3 design-tokens/generate.py` ghi file; `--check` trả lỗi nếu file sinh ra đã cũ (dùng trong CI). |
| `apple/design-tokens/hc.py`, `migrate.py` | Tính màu Increase Contrast; chuyển token v1 của web sang v2. Chỉ chạy lại khi đổi bảng màu gốc. |
| `apple/LifeOSDesignSystem/` | Swift package `DesignSystem`: token sinh tự động, nền tảng (chữ, chuyển động, bề mặt, icon), 13 component tự vẽ, Catalog xem trước. `README.md` có bảng ánh xạ 38 component và bảng icon. |
| `component-library.html` | Thư viện component, bản sao artifact Design System. |
| `screens.html` | 8 màn trên iPhone, iPad, Mac, bản sao artifact Screens. |
| `code/`, `tokens.css`, `tailwind.config.ts`, `tailwind-theme.css` | Bản web React + Tailwind, chỉ để tham khảo. |

Artifact: [Life OS Design System](https://claude.ai/artifact/9vcZ4fYJXbfKTGXoFgAfuM) · [Life OS Screens](https://claude.ai/artifact/U3Up5N6sL3U7WVyB2ZYjMD)

## 2. Gói Swift

```
apple/LifeOSDesignSystem/
  Package.swift                     swift-tools 6.2, iOS 26, macOS 26, thư viện DesignSystem
  Sources/DesignSystem/
    Generated/Tokens.swift          LifeOSColor, Space, Layout, Radius, TextToken, MotionToken, HapticToken
    Resources/Tokens.xcassets       30 colorset có biến thể Increase Contrast
    Foundation/Typography.swift     .lifeOSText(.title1): Dynamic Type + hệ số dòng
    Foundation/Motion.swift         .lifeOSAnimation, .lifeOSHaptic, tôn trọng Reduce Motion, Low Power Mode
    Foundation/Surfaces.swift       .lifeOSCard (đặc), .lifeOSField, LayoutClass compact/regular/mac
    Foundation/Icons.swift          tên SF Symbols cho mọi icon
    Components/                     TaskCheckbox, HabitTile, HabitHeatmap (Canvas), MoodPicker, EnergyPicker,
                                    GlanceRow, QuickCapture (ô, thanh Ghi nhanh, nút toolbar), Chips, UndoToast,
                                    SyncStatusBadge, RecoveryKeyView (+ nút Chép, bảng ký tự)
    Catalog.swift                   xem trước Light, Dark, chữ cỡ lớn
```

Ánh xạ 38 component của bản web: 24 dùng control hệ thống, 13 tự vẽ, 1 bỏ (`offline-banner`, thay bằng `SyncStatusBadge`). Bảng đầy đủ ở `README.md` của gói và mục SwiftUI trong thư viện.

## 3. Checklist nghiệm thu cho Apple

### Trải nghiệm

| Mục | Kết quả | Ghi chú |
|---|---|---|
| Ghi một khoản chi dưới 3 chạm, dưới 5 giây | Đạt có điều kiện | Thanh “Ghi nhanh…” trên tab bar (⌘N trên Mac, iPad có bàn phím) → gõ “cafe 45k” → Lưu: 2 chạm. Thời gian là ước tính, cần đo trên máy. |
| Tick việc và hoàn tác trong 4 giây | Đạt | `TaskCheckboxStyle` + `UndoToast`; trên Mac thêm ⌘Z. |
| Check-in tối dưới 30 giây | Đạt có điều kiện | Tâm trạng 1 chạm, năng lượng 1 chạm, một dòng tùy chọn. Chưa đo. |
| Mở app là có dữ liệu ngay | Đạt (thiết kế) | Dữ liệu đọc từ SQLite trong máy. Skeleton chỉ xuất hiện ở lần tải đầu trên máy mới (“Máy mới” trong Screens). |
| Mất mạng không phải lỗi | Đạt (thiết kế) | Không còn banner ngoại tuyến. Thay đổi chưa gửi hiện “Chờ đồng bộ · 3 thay đổi”, màu chữ thường. |
| Lỗi chỉ có ba loại, đều nói cách sửa | Đạt (thiết kế) | Chưa đăng nhập iCloud (chỉ báo dưới tiêu đề, nội dung giữ nguyên), thiếu khóa trên máy mới (nhập hoặc quét mã khôi phục), file dữ liệu trong máy hỏng (tải lại từ iCloud). |
| Không mất chữ khi sửa nhật ký trên hai máy | Đạt (thiết kế) | Nội dung nhật ký giữ cả hai bản, hiện trong bài, không chặn màn; “Bỏ bản này” có Hoàn tác. Các trường khác lấy bản sửa sau cùng theo từng trường. |
| Không đăng nhập, không mật khẩu | Đạt (thiết kế) | Bắt đầu → Cất giữ mã khôi phục → kiểm tra một nhóm → vào app. Có đường cho máy chưa bật iCloud và máy mới. Cảnh báo “Cất mã ở nơi khác với điện thoại” (kèm hậu quả nếu mất cả máy lẫn mã) hiện ở bước cất mã và trong Cài đặt. |
| Câu chữ không trách móc | Đạt | Giữ nguyên quy tắc của bản web. |

### Thị giác

| Mục | Kết quả | Ghi chú |
|---|---|---|
| Chỉ dùng token | Đạt (gói Swift) | Màu qua `LifeOSColor`, khoảng cách qua `Space`/`Layout`, chữ qua `.lifeOSText`. Vài kích thước riêng của component được ghi tường minh: vòng tick 22 pt trong vùng chạm 44, ô heatmap 12 pt cách 3 pt. |
| Chất liệu | Đạt (thiết kế, cập nhật 1/11) | Lớp điều hướng dùng Liquid Glass: tab bar dạng viên nổi, nút tiêu đề dạng viên, thanh bên iPad/Mac là tấm kính nổi, sheet nửa màn, menu, thanh Ghi nhanh trong `.tabViewBottomAccessory` (hệ thống tự có). Kính tự thêm: toast Hoàn tác (`.glassEffect`), tối đa 5 mỗi màn, chung một `GlassEffectContainer`. Lớp nội dung (card, hàng, heatmap, biểu đồ) nền đặc theo khuyến nghị của Apple và để giữ hiệu năng khi cuộn; card bo góc 24. Bản HTML chỉ mô phỏng lớp mờ, không có khúc xạ. |
| Chữ SF Pro, dấu tiếng Việt | Đạt | SF Pro của hệ thống (0 byte, có đủ dấu). Hệ số dòng 1,35–1,4 cho tiêu đề và nội dung, 1,6 cho nhật ký, 1,1 chỉ cho số lớn. Không đặt chữ trong khung cao cố định. `title-1` nay 1,35, nên mục còn treo về `title-1` đã xong. |
| Một accent, danger chỉ cho quá hạn, vượt ngân sách, xóa | Đạt | Như bản web. Trạng thái đồng bộ không dùng đỏ. |
| Số tabular | Đạt | `monospacedDigit` trong token chữ; số đổi dùng `contentTransition(.numericText())`. |

### Trợ năng

| Mục | Kết quả | Ghi chú |
|---|---|---|
| Dynamic Type đến cỡ trợ năng lớn nhất | Đạt (thiết kế) | Mọi token chữ gắn `TextStyle`; cỡ riêng dùng `ScaledMetric`. Tâm trạng và năng lượng chuyển sang danh sách dọc bằng `ViewThatFits`. Cần thử AX5 trên máy. |
| VoiceOver | Đạt có điều kiện | Component tự vẽ có nhãn, giá trị, trait (checkbox là toggle, heatmap có câu tóm tắt). Mã khôi phục đọc từng ký tự. Còn thiếu: chọn từng ngày trên heatmap bằng VoiceOver (nên thêm `accessibilityAdjustableAction`). Chưa thử thứ tự đọc trên máy. |
| Increase Contrast | Đạt | 7 màu có biến thể riêng trong colorset: text-2 7:1, text-3 5,5:1, border 3:1, accent và positive 6:1, warning 4,5:1, danger 6:1. Ví dụ Light: text-3 `#65605B`, border `#8D8C89`, accent `#0D6760`. |
| Tương phản thường | Đạt | 68/68 cặp như phụ lục B. Warning trên `surface-2` là 4,49:1 nên chỉ tô icon, chữ giữ `text`. |
| Vùng chạm 44 pt | Đạt (thiết kế) | Token `Layout.hit` 44; checkbox, chip, ô heatmap (cả lưới là một vùng chạm), nút trong chỉ báo đồng bộ. |
| Reduce Motion | Đạt | `MotionToken.reduced`: 0,09 giây, tuyến tính, chỉ opacity. Tắt ăn mừng cả khi bật Low Power Mode. |
| Reduce Transparency | Đạt | Kính hệ thống tự chuyển đặc; kính tự làm dùng API hệ thống nên theo cùng cài đặt. |
| Không chỉ dùng màu | Đạt | Như bản web; chỉ báo đồng bộ có icon và chữ. |

### Hiệu năng

| Chỉ số | Mục tiêu | Cách giữ |
|---|---|---|
| Thời gian mỗi khung | 8,3 ms ở 120 Hz, phần của app khoảng 4 ms | Danh sách dùng `List`/`LazyVStack`; heatmap vẽ một `Canvas`, không 365 view. |
| Giật hình | ≤ 10 ms/giây khi cuộn | Biểu đồ đọc số đã tổng hợp sẵn theo ngày, tuần, tháng; không tính lại trong `body`. |
| Treo | Không lần nào > 250 ms | Đọc ghi SQLite và giải mã ngoài main thread. |
| Mở app lạnh | ≤ 400 ms tới màn Hôm nay có dữ liệu | Không chờ mạng, không skeleton khi đã có dữ liệu. |
| Chuyển động | Chỉ chạy một lần | Không `repeatForever`, không `TimelineView(.animation)`, không blur động. Icon đồng bộ đứng yên. |

Đây là mục tiêu thiết kế; cần đo bằng Instruments khi có bản chạy.

### Thiết bị

| Mục | Kết quả | Ghi chú |
|---|---|---|
| iPhone | Đạt (thiết kế) | Khung 390×844, lề 16, tab bar hệ thống, thanh Ghi nhanh trên tab bar. |
| iPad | Đạt (thiết kế) | `NavigationSplitView`, thanh bên 240, lề 24; Screens có khung 1180×820. |
| Mac | Đạt (thiết kế) | Cửa sổ tối thiểu 760×560, lề 32. Menu Đi tới ⌘1–⌘6, Ghi nhanh ⌘N, Cài đặt ⌘,; chuột phải tương ứng thao tác vuốt; rê chuột có nền `overlay-hover`. Xem Screens → Hôm nay → Menu và phím tắt Mac. |
| [Mở rộng] ở frame riêng, có ghi chú dữ liệu | Đạt | Kiểm tự động: 0 phần tử [Mở rộng] lọt vào frame MVP (phụ lục C). |

## 4. Prototype các luồng

| Luồng | Xem ở đâu |
|---|---|
| Ghi nhanh một khoản chi | Screens: Thu chi → Thêm giao dịch. Hoặc chạm thanh “Ghi nhanh…” ở Hôm nay. Thư viện: mẫu Ghi nhanh. Swift: `QuickCaptureBar`, `QuickCaptureField`. |
| Tick việc và hoàn tác | Screens: Hôm nay, chạm vòng tròn trước một việc. Swift: `TaskCheckboxStyle`, `UndoToast`. |
| Check-in buổi tối | Screens: chọn “Tối 20:15”. Swift: `MoodPicker`, `EnergyPicker`. |
| Bắt đầu lần đầu | Screens: Bắt đầu và khôi phục → Chào mừng → Bắt đầu → Cất giữ mã khôi phục → Tôi đã cất giữ → Vào Life OS. |
| Khôi phục trên máy mới | Screens: Chào mừng → “Tôi đã dùng Life OS trên máy khác” → Mở khóa (bấm để thấy lỗi sai mã). |
| Đồng bộ cần xử lý | Screens: chọn “Cần xử lý đồng bộ” → chạm chỉ báo dưới tiêu đề → Bảo mật và khôi phục. |

## 5. Thay đổi ngày 31/10

- Token v2 trung lập nền tảng, có biến thể Increase Contrast; script sinh colorset, Swift, CSS.
- Chữ: SF Pro + Dynamic Type thay Inter trên Apple (Inter giữ cho web); hệ số dòng tương đối.
- Chuyển động: 4 preset SwiftUI, ngân sách hiệu ứng, xử lý Reduce Motion; 4 kiểu rung.
- Chất liệu: chỉ kính hệ thống, kính tự làm có giới hạn.
- Bố cục iPhone, iPad, Mac thay khung web 390/1440; menu, phím tắt, con trỏ cho Mac.
- Trạng thái: bỏ “ngoại tuyến”, thêm chỉ báo đồng bộ; lỗi còn ba loại.
- Nhật ký: giao diện giữ cả hai bản khi sửa trên hai máy.
- Bỏ Đăng nhập, Tạo tài khoản, Đăng xuất. Thêm Chào mừng, Chưa bật iCloud, Mã khôi phục, Kiểm tra mã, Máy mới, Lỗi dữ liệu trong máy, Bảo mật và khôi phục. Khóa PIN [Mở rộng] đổi thành Face ID.
- Nhắc nhở [Mở rộng] chuyển sang thông báo cục bộ vì không có máy chủ.

## 5b. Thay đổi ngày 1/11

- Vẽ lại lớp điều hướng theo Liquid Glass trong thư viện và Screens: tab bar viên nổi, nút tiêu đề viên kính, header cuộn mờ dần không viền, thanh bên kính nổi trên iPad và Mac, sheet nửa màn và toast bằng kính.
- Card và danh sách giữ nền đặc; bo góc `lg` 20 → 24.
- `UndoToast` dùng `.glassEffect`. Phím tắt Ghi nhanh thống nhất là ⌘N.

**Sau review Impeccable (1/11):**

- Mã khôi phục: bảng 23 ký tự không dễ nhầm (bỏ O, I, L, S, B, Z, U, V, 0, 1, 2, 5, 8), 28 ký tự ≈ 126 bit; nhập sai ký tự ngoài bảng thì báo ngay là đọc nhầm. Chép chỉ trong máy, tự xóa sau 2 phút (`RecoveryKeyCopyButton`). Đổi tên “Recovery Key” → “Mã khôi phục”; bước cất mã vẫn ở đầu, lời giải thích nhẹ hơn, nút “In hoặc lưu PDF”.
- iPhone: thanh “Ghi nhanh…” trên tab bar (`QuickCaptureBar` trong `.tabViewBottomAccessory`) thay nút + nổi; mở sheet Ghi nhanh. Bỏ nút + trùng ở Thói quen. Ẩn ở Review tuần và khi viết nhật ký. iPad và Mac: `QuickCaptureToolbarButton` trong toolbar.
- Tiêu đề kiểu hệ thống: Hôm nay có ngày và lời chào dưới tiêu đề; Thu chi đổi tháng bằng menu ở tiêu đề; Review tuần tiêu đề nhỏ trong thanh. Trên iPad và Mac, nút thao tác lên toolbar cửa sổ.
- Ô thói quen bỏ viền (nền phẳng); nhãn ngân sách trên biểu đồ cột không chồng cột; biểu tượng lớn ở Máy mới, Lỗi dữ liệu, Chưa bật iCloud bỏ khung tròn.
- Từ ngữ: “Mood” → “Tâm trạng”; tab và thanh bên đều là “Việc”; giữ Inbox, Check-in, Review tuần. Chỉ báo đồng bộ khi chưa đăng nhập: “Chưa đăng nhập iCloud · vẫn lưu trong máy”.

## 5c. Build lần đầu (LOS-002, 1/11)

Máy: macOS 27.2, Xcode 27.2 (27B52), Swift 6.4.2. Cả 5 gói build sạch cho iOS Simulator và macOS (0 lỗi, 0 cảnh báo); `swift test` xanh ở LifeOSCore, LifeOSData, LifeOSPlatform, LifeOSFeatures.

- **Không API nào phải sửa.** `lineHeight(.multiple(factor:))`, `glassEffect(_:in:)`, `@Entry` biên dịch đúng như đang viết. `tabViewBottomAccessory` và `tabBarMinimizeBehavior` hiện chỉ có trong doc comment của `QuickCaptureBar`; kiểm lại khi AppFeature dùng thật.
- **Macro của gói Point-Free** (swift-perception, swift-structured-queries) phải được tin cậy: trong Xcode bấm "Trust & Enable" lần đầu; dòng lệnh `xcodebuild` cần `-skipMacroValidation` (cần cho CI ở LOS-003). `swift build`/`swift test` không cần.
- Ghim trong `Package.resolved` (LifeOSData, LifeOSFeatures): sqlite-data 1.12.1, GRDB.swift 7.11.1.

## 6. Để giai đoạn sau

- Widget và Control Center (mục 12). Token đã có sẵn chỗ cho widget: nền đặc, không kính tự làm.
- Bản web và Android: dùng chung `tokens.json`; thêm bộ sinh cho Compose khi cần.

## Phụ lục A. Bảng token → giá trị (bản web)

Cùng giá trị với `apple/design-tokens/tokens.json`; tên biến là tên CSS. Trong Swift, `--text-3` là `LifeOSColor.text3`.

Bản máy đọc: `tokens.json`. Bảng dưới sinh tự động từ `globals.css`.

| Token | Light | Dark | Tailwind | Dùng cho |
|---|---|---|---|---|
| **Màu lõi** | | | | |
| `--bg` | `#FAF9F7` | `#0F0E0D` | `bg-bg` | Nền app |
| `--surface` | `#FFFFFF` | `#1A1917` | `bg-surface` | Card, list, sheet (Light) |
| `--surface-2` | `#F4F2EF` | `#242220` | `bg-surface-2` | Input, vùng lõm, chip, sheet (Dark) |
| `--border` | `#E7E5E1` | `#2E2B28` | `border-border / border` | Viền card (Light), divider. Chỉ trang trí, không mang thông tin |
| `--text` | `#1C1917` | `#F5F5F4` | `text-text` | Chữ chính |
| `--text-2` | `#57534E` | `#A8A29E` | `text-text-2` | Chữ phụ, meta |
| `--text-3` | `#6F6964` | `#958F89` | `text-text-3` | Placeholder, nhãn trục, tab chưa chọn |
| `--accent` | `#0F766E` | `#4FD1C5` | `bg-accent / text-accent` | Nút chính, đang chọn, hoàn thành. Accent duy nhất |
| `--on-accent` | `#FFFFFF` | `#04201D` | `text-on-accent` | Chữ, icon trên nền accent |
| `--accent-soft` | `#E6F4F1` | `#11302C` | `bg-accent-soft` | Chip đã chọn, thói quen đã tick, mục nav hiện tại |
| `--positive` | `#15803D` | `#4ADE80` | `text-positive` | Khoản thu, xu hướng tốt |
| `--warning` | `#B45309` | `#FBBF24` | `bg-warning / text-warning` | Ngân sách 80–100%, ưu tiên Cao |
| `--danger` | `#B91C1C` | `#F87171` | `bg-danger / text-danger` | Chỉ: quá hạn, vượt ngân sách, xóa |
| `--scrim` | `rgba(0, 0, 0, .40)` | `rgba(0, 0, 0, .60)` | `backdrop:bg-scrim` | Nền mờ sau sheet, dialog |
| `--segment-thumb` | `var(--surface)` | `var(--border)` | `bg-segment-thumb` | Viên trượt segmented control |
| `--field-on-sheet` | `var(--surface-2)` | `var(--border)` | `bg-field-on-sheet` | Ô nhập đặt trong sheet |
| **Màu dữ liệu** | | | | |
| `--data-blue` | `#4B7CBA` | `#85B4F1` | `bg-data-blue / --c` | Màu danh mục, dự án, thói quen; biểu đồ |
| `--data-orange` | `#AC6734` | `#E3A072` | `bg-data-orange / --c` | Màu danh mục, dự án, thói quen; biểu đồ |
| `--data-violet` | `#8A68AE` | `#C0A1E5` | `bg-data-violet / --c` | Màu danh mục, dự án, thói quen; biểu đồ |
| `--data-green` | `#528A54` | `#8CC18D` | `bg-data-green / --c` | Màu danh mục, dự án, thói quen; biểu đồ |
| `--data-pink` | `#AC5D7E` | `#E496B4` | `bg-data-pink / --c` | Màu danh mục, dự án, thói quen; biểu đồ |
| `--data-ochre` | `#95761A` | `#CCAE62` | `bg-data-ochre / --c` | Màu danh mục, dự án, thói quen; biểu đồ |
| `--data-sky` | `#1988A3` | `#68BFDA` | `bg-data-sky / --c` | Màu danh mục, dự án, thói quen; biểu đồ |
| `--data-slate` | `#6E7B90` | `#A5B2C6` | `bg-data-slate / --c` | Màu danh mục, dự án, thói quen; biểu đồ |
| `--data-tint` | `12%` | `16%` | `.tile` | Độ trộn màu dữ liệu cho nền ô icon |
| **Mood** | | | | |
| `--mood-1` | `#7B80BC` | `#878CC9` | `bg-mood-1` | Mood 1: Tệ |
| `--mood-2` | `#5F9ABC` | `#6BA7C9` | `bg-mood-2` | Mood 2: Không ổn |
| `--mood-3` | `#84AFA3` | `#90BCAF` | `bg-mood-3` | Mood 3: Bình thường |
| `--mood-4` | `#D4BD67` | `#E1CA74` | `bg-mood-4` | Mood 4: Tốt |
| `--mood-5` | `#E99E5E` | `#F6AB6B` | `bg-mood-5` | Mood 5: Tuyệt |
| `--mood-ink` | `#1C1917` | `#0F0E0D` | `text-mood-ink` | Nét mặt trên nền mood |
| **Lớp trạng thái** | | | | |
| `--overlay-hover` | `color-mix(in srgb, var(--text) 6%, transparent)` | `color-mix(in srgb, var(--text) 7%, transparent)` | `.state-layer` | Lớp phủ khi rê chuột |
| `--overlay-press` | `color-mix(in srgb, var(--text) 12%, transparent)` | `color-mix(in srgb, var(--text) 13%, transparent)` | `.state-layer` | Lớp phủ khi nhấn |
| **Chữ** | | | | |
| `--font-sans` | `var(--font-inter, "Inter"), "Be Vietnam Pro", system-ui, -apple-system, "Segoe UI", Roboto, sans-serif` | `var(--font-inter, "Inter"), "Be Vietnam Pro", system-ui, -apple-system, "Segoe UI", Roboto, sans-serif` | `font-sans` | Inter (next/font, có bộ vietnamese) |
| `--font-alt` | `"Be Vietnam Pro", "Inter", system-ui, sans-serif` | `"Be Vietnam Pro", "Inter", system-ui, sans-serif` | `font-alt` | Be Vietnam Pro cho nhật ký |
| **Khoảng cách, bố cục** | | | | |
| `--gutter` | `16px` · tablet 24px · desktop 32px | `16px` | `px-gutter` | Lề trang 16 / 24 / 32 |
| `--card-pad` | `16px` · desktop 20px | `16px` | `p-card-pad` | Padding card 16, desktop 20 |
| `--block-gap` | `24px` | `24px` | `gap-block-gap` | Khoảng giữa các khối |
| `--sidebar-w` | `15rem` | `15rem` | `w-sidebar` | Sidebar desktop |
| `--content-focus` | `45rem` | `45rem` | `max-w-focus` | Cột đọc, nhật ký, form |
| `--content-wide` | `67.5rem` | `67.5rem` | `max-w-wide` | Bento, bảng |
| `--tabbar-h` | `3.5rem` | `3.5rem` | `min-h-tabbar` | Tab bar (chưa gồm safe-area) |
| `--header-compact-h` | `2.75rem` | `2.75rem` | `h-header-compact` | Header gọn khi cuộn |
| `--fab-size` | `56px` | `56px` | `size-fab` | Nút Ghi nhanh |
| `--hit` | `44px` | `44px` | `size-hit / .hit` | Vùng chạm tối thiểu |
| **Bo góc** | | | | |
| `--r-xs` | `6px` | `6px` | `rounded-xs` | Ô heatmap (½), tooltip, kbd |
| `--r-sm` | `10px` | `10px` | `rounded-sm` | Ô icon, nút nhỏ, segmented |
| `--r-md` | `14px` | `14px` | `rounded-md` | Nút, input, toast |
| `--r-lg` | `20px` | `20px` | `rounded-lg` | Card, thẻ thói quen |
| `--r-xl` | `28px` | `28px` | `rounded-xl` | Sheet, dialog |
| `--r-full` | `9999px` | `9999px` | `rounded-full` | Chip, badge, switch, FAB |
| **Độ nổi** | | | | |
| `--elev-0-bg` | `var(--surface)` | `var(--surface)` | `.elev-0` | Cấp 0: card |
| `--elev-0-border` | `var(--border)` | `transparent` | `.elev-0` | Viền cấp 0 |
| `--elev-1-bg` | `color-mix(in srgb, var(--surface) 72%, transparent)` | `color-mix(in srgb, var(--surface) 72%, transparent)` | `.elev-1` | Cấp 1 kính: tab bar, header dính, (sheet nếu muốn) |
| `--elev-1-filter` | `blur(20px) saturate(180%)` | `blur(20px)` | `.elev-1` | Blur kính |
| `--elev-1-border` | `rgba(0, 0, 0, .06)` | `rgba(255, 255, 255, .08)` | `.elev-1` | Viền tóc cấp 1 |
| `--elev-1-shadow` | `0 8px 24px rgba(0, 0, 0, .08)` | `none` | `shadow-elev-1` | Bóng cấp 1 |
| `--elev-2-bg` | `var(--surface)` | `var(--surface-2)` | `.elev-2` | Cấp 2: sheet, dialog, toast, menu |
| `--elev-2-shadow` | `0 16px 48px rgba(0, 0, 0, .16)` | `none` | `shadow-elev-2` | Bóng cấp 2 |
| **Chuyển động** | | | | |
| `--dur-micro` | `120ms` · giảm chuyển động 80ms | `120ms` | `duration-micro` | Nhấn, đổi trạng thái nhỏ |
| `--dur-standard` | `200ms` · giảm chuyển động 80ms | `200ms` | `duration-standard` | Tick, toast, segmented |
| `--dur-emphasized` | `320ms` · giảm chuyển động 90ms | `320ms` | `duration-emphasized` | Sheet, dialog |
| `--dur-spring` | `420ms` · giảm chuyển động 90ms | `420ms` | `duration-spring` | Lò xo (mood chọn) |
| `--ease-enter` | `cubic-bezier(0.2, 0, 0, 1)` · giảm chuyển động linear | `cubic-bezier(0.2, 0, 0, 1)` | `ease-enter` | Vào, đổi trạng thái |
| `--ease-spring` | `linear(0, 0.009, 0.035 2.1%, 0.141 4.4%, 0.281 6.7%, 0.723 12.9%, 0.938 16.7%, 1.017 19.4%, 1.077 22.7%, 1.088 25%, 1.079 27.8%, 1.04 33.3%, 1.004 39.4%, 0.991 45.1%, 0.996 56.3%, 1)` · giảm chuyển động linear | `linear(0, 0.009, 0.035 2.1%, 0.141 4.4%, 0.281 6.7%, 0.723 12.9%, 0.938 16.7%, 1.017 19.4%, 1.077 22.7%, 1.088 25%, 1.079 27.8%, 1.04 33.3%, 1.004 39.4%, 0.991 45.1%, 0.996 56.3%, 1)` | `ease-spring` | Nảy nhẹ |
| **Icon** | | | | |
| `--icon-stroke` | `1.75` | `1.75` | `svg.lucide` | Nét icon Lucide |

| Kiểu chữ | Tailwind | rem | px |
|---|---|---|---|
| numeral-xl | `text-numeral-xl` | 2.5rem / 2.75rem · 600 | 40px / 44px |
| title-1 | `text-title-1` | 1.75rem / 2.25rem · 700 | 28px / 36px |
| title-2 | `text-title-2` | 1.375rem / 1.875rem · 600 | 22px / 30px |
| title-3 | `text-title-3` | 1.125rem / 1.625rem · 600 | 18px / 26px |
| body | `text-body` | 1rem / 1.5rem · 400 | 16px / 24px |
| body-strong | `text-body-strong` | 1rem / 1.5rem · 500 | 16px / 24px |
| callout | `text-callout` | 0.9375rem / 1.375rem · 400 | 15px / 22px |
| footnote | `text-footnote` | 0.8125rem / 1.125rem · 400 | 13px / 18px |
| caption | `text-caption` | 0.75rem / 1rem · 500 | 12px / 16px |
| journal | `text-journal` | 1.0625rem / 1.75rem (font-alt) | 17px / 28px |

## Phụ lục B. Tương phản (tính theo WCAG 2.x)

| Chế độ | Chữ / đồ họa | Trên nền | Tỉ lệ | Ngưỡng | Kết quả | Ghi chú |
|---|---|---|---|---|---|---|
| Light | `text` | `bg` | 16.62:1 | 4.5:1 | Đạt | chữ chính |
| Light | `text` | `surface` | 17.49:1 | 4.5:1 | Đạt |  |
| Light | `text` | `surface-2` | 15.65:1 | 4.5:1 | Đạt |  |
| Light | `text-2` | `bg` | 7.25:1 | 4.5:1 | Đạt | chữ phụ |
| Light | `text-2` | `surface` | 7.63:1 | 4.5:1 | Đạt |  |
| Light | `text-2` | `surface-2` | 6.83:1 | 4.5:1 | Đạt |  |
| Light | `text-3` | `bg` | 5.14:1 | 4.5:1 | Đạt | placeholder, nhãn trục |
| Light | `text-3` | `surface` | 5.41:1 | 4.5:1 | Đạt |  |
| Light | `text-3` | `surface-2` | 4.84:1 | 4.5:1 | Đạt | placeholder trong ô nhập |
| Light | `accent` | `bg` | 5.20:1 | 4.5:1 | Đạt | liên kết, nút ghost |
| Light | `accent` | `surface` | 5.47:1 | 4.5:1 | Đạt |  |
| Light | `accent` | `accent-soft` | 4.84:1 | 4.5:1 | Đạt | chip đã chọn |
| Light | `on-accent` | `accent` | 5.47:1 | 4.5:1 | Đạt | nút chính |
| Light | `text` | `accent-soft` | 15.47:1 | 4.5:1 | Đạt | thói quen đã tick |
| Light | `positive` | `surface` | 5.02:1 | 4.5:1 | Đạt | khoản thu |
| Light | `positive` | `surface-2` | 4.49:1 | 3.0:1 | Đạt | chỉ số tiền 40px, chữ lớn |
| Light | `positive` | `bg` | 4.77:1 | 4.5:1 | Đạt |  |
| Light | `warning` | `surface` | 5.02:1 | 3.0:1 | Đạt | thanh ngân sách, cờ Cao (đồ họa) |
| Light | `warning` | `surface-2` | 4.49:1 | 3.0:1 | Đạt |  |
| Light | `danger` | `surface` | 6.47:1 | 4.5:1 | Đạt | chữ quá hạn |
| Light | `danger` | `bg` | 6.15:1 | 4.5:1 | Đạt |  |
| Light | `surface` | `danger` | 6.47:1 | 4.5:1 | Đạt | nút Xóa |
| Light | `text-3` | `surface` | 5.41:1 | 3.0:1 | Đạt | viền checkbox (đồ họa) |
| Light | `accent` | `bg` | 5.20:1 | 3.0:1 | Đạt | focus ring |
| Light | `data-blue` | `surface` | 4.29:1 | 3.0:1 | Đạt | cờ Thấp |
| Light | `data-violet` | `surface` | 4.49:1 | 3.0:1 | Đạt | cờ Vừa, đường mood |
| Light | `data-orange` | `surface` | 4.43:1 | 3.0:1 | Đạt | đường năng lượng |
| Light | `border` | `surface` | 1.26:1 |  | — | viền card, divider (trang trí) |
| Light | `border` | `bg` | 1.20:1 |  | — |  |
| Light | `mood-ink` | `mood-1` | 4.71:1 | 4.0:1 | Đạt | nét mặt mood 1 |
| Light | `mood-ink` | `mood-2` | 5.69:1 | 4.0:1 | Đạt | nét mặt mood 2 |
| Light | `mood-ink` | `mood-3` | 7.20:1 | 4.0:1 | Đạt | nét mặt mood 3 |
| Light | `mood-ink` | `mood-4` | 9.39:1 | 4.0:1 | Đạt | nét mặt mood 4 |
| Light | `mood-ink` | `mood-5` | 7.93:1 | 4.0:1 | Đạt | nét mặt mood 5 |
| Dark | `text` | `bg` | 17.68:1 | 4.5:1 | Đạt | chữ chính |
| Dark | `text` | `surface` | 16.10:1 | 4.5:1 | Đạt |  |
| Dark | `text` | `surface-2` | 14.53:1 | 4.5:1 | Đạt |  |
| Dark | `text-2` | `bg` | 7.65:1 | 4.5:1 | Đạt | chữ phụ |
| Dark | `text-2` | `surface` | 6.97:1 | 4.5:1 | Đạt |  |
| Dark | `text-2` | `surface-2` | 6.29:1 | 4.5:1 | Đạt |  |
| Dark | `text-3` | `bg` | 6.03:1 | 4.5:1 | Đạt | placeholder, nhãn trục |
| Dark | `text-3` | `surface` | 5.49:1 | 4.5:1 | Đạt |  |
| Dark | `text-3` | `surface-2` | 4.96:1 | 4.5:1 | Đạt | placeholder trong ô nhập |
| Dark | `accent` | `bg` | 10.34:1 | 4.5:1 | Đạt | liên kết, nút ghost |
| Dark | `accent` | `surface` | 9.42:1 | 4.5:1 | Đạt |  |
| Dark | `accent` | `accent-soft` | 7.59:1 | 4.5:1 | Đạt | chip đã chọn |
| Dark | `on-accent` | `accent` | 9.16:1 | 4.5:1 | Đạt | nút chính |
| Dark | `text` | `accent-soft` | 12.98:1 | 4.5:1 | Đạt | thói quen đã tick |
| Dark | `positive` | `surface` | 10.08:1 | 4.5:1 | Đạt | khoản thu |
| Dark | `positive` | `surface-2` | 9.10:1 | 3.0:1 | Đạt | chỉ số tiền 40px, chữ lớn |
| Dark | `positive` | `bg` | 11.07:1 | 4.5:1 | Đạt |  |
| Dark | `warning` | `surface` | 10.52:1 | 3.0:1 | Đạt | thanh ngân sách, cờ Cao (đồ họa) |
| Dark | `warning` | `surface-2` | 9.50:1 | 3.0:1 | Đạt |  |
| Dark | `danger` | `surface` | 6.35:1 | 4.5:1 | Đạt | chữ quá hạn |
| Dark | `danger` | `bg` | 6.97:1 | 4.5:1 | Đạt |  |
| Dark | `surface` | `danger` | 6.35:1 | 4.5:1 | Đạt | nút Xóa |
| Dark | `text-3` | `surface` | 5.49:1 | 3.0:1 | Đạt | viền checkbox (đồ họa) |
| Dark | `accent` | `bg` | 10.34:1 | 3.0:1 | Đạt | focus ring |
| Dark | `data-blue` | `surface` | 8.20:1 | 3.0:1 | Đạt | cờ Thấp |
| Dark | `data-violet` | `surface` | 7.92:1 | 3.0:1 | Đạt | cờ Vừa, đường mood |
| Dark | `data-orange` | `surface` | 7.98:1 | 3.0:1 | Đạt | đường năng lượng |
| Dark | `border` | `surface` | 1.25:1 |  | — | viền card, divider (trang trí) |
| Dark | `border` | `bg` | 1.37:1 |  | — |  |
| Dark | `mood-ink` | `mood-1` | 6.08:1 | 4.0:1 | Đạt | nét mặt mood 1 |
| Dark | `mood-ink` | `mood-2` | 7.34:1 | 4.0:1 | Đạt | nét mặt mood 2 |
| Dark | `mood-ink` | `mood-3` | 9.18:1 | 4.0:1 | Đạt | nét mặt mood 3 |
| Dark | `mood-ink` | `mood-4` | 11.85:1 | 4.0:1 | Đạt | nét mặt mood 4 |
| Dark | `mood-ink` | `mood-5` | 10.06:1 | 4.0:1 | Đạt | nét mặt mood 5 |

## Phụ lục C. Frame [Mở rộng] và dữ liệu cần

Frame MVP không chứa phần tử [Mở rộng] nào. Mỗi frame dưới đây là view riêng trong artifact Screens (chip có nhãn “Mở rộng”); phần tử [Mở rộng] trong frame được viền đứt.

| Màn · frame | Nội dung | Dữ liệu cần |
|---|---|---|
| Hôm nay · Sắp xếp thẻ | Bật tắt và đổi thứ tự thẻ, có nút lên/xuống thay cho kéo | `profiles.settings.today_cards = [{ id, visible }]`; không cần bảng mới |
| Việc · Kéo thả để dời | Desktop kéo việc sang ngày khác | Chỉ cập nhật `tasks.due_date`; giữ giá trị cũ 4 giây cho Hoàn tác |
| Thói quen · Chi tiết, chuỗi dài nhất | Ô “Chuỗi dài nhất 21 ngày” | Tính từ `habit_logs` đủ lịch sử, hoặc lưu `habits.best_streak`, `best_streak_at` khi tick hoặc tick bù |
| Thói quen · Thêm, giờ nhắc và mục tiêu đếm | Giờ nhắc riêng, mục tiêu “8 ly” | `habits.reminder_time`, `habits.target_count`, `habit_logs.count`; nhắc bằng thông báo cục bộ như frame Nhắc nhở |
| Thói quen · Heatmap ngày nghỉ (thư viện) | Ô sọc “Nghỉ có chủ đích” | `habit_logs.status`: done hoặc rest |
| Nhật ký · Hoạt động, lịch năm, ảnh | Chip hoạt động, lịch tâm trạng 2026, ảnh đính kèm | Bảng `activities` + `journal_entry_activities`; lịch năm đọc `journal_entries.mood`; ảnh cần kho file + `journal_photos (entry_id, path, size)` |
| Thu chi · Tìm kiếm | Ô tìm, lọc tháng, danh mục, loại; trống “Không tìm thấy “abc”. Thử từ khóa khác.” | Chỉ mục tìm trên `transactions.note` có bỏ dấu (“pho” khớp “phở”); lọc `category_id`, `kind`, `occurred_at` |
| Thu chi · Khoản định kỳ | Tiền điện, internet, học phí, lương; tự ghi và có Hoàn tác | Bảng `recurring_transactions (amount, kind, category_id, note, quy tắc lặp, next_date, auto_create, paused)`; tạo khoản khi mở app hoặc trong tác vụ nền, theo múi giờ máy; `transactions.recurring_id`. Hai máy cùng tạo một kỳ thì gộp theo `(recurring_id, next_date)` |
| Review · Hoàn thành, tuần trước | Trọng tâm tuần tới hiện trên Hôm nay; danh sách tuần trước | `weekly_reviews (week_start, điểm tự chấm, ba câu suy ngẫm, focus[])` |
| Cài đặt · Giao diện, Face ID | Sáng, Tối, Theo hệ thống; khóa bằng Face ID (thay mã PIN) | `settings.theme` (đồng bộ); `app_lock.enabled`, `app_lock.after_minutes` lưu riêng từng máy, không đồng bộ. Mở bằng LocalAuthentication, dự phòng mật mã máy; app không lưu mã nào |
| Bắt đầu · Khóa Face ID | Màn khóa khi mở lại app sau thời gian tự khóa | Như dòng trên |
| Cài đặt · Nhắc nhở | Nhắc thói quen 21:00, nhắc review Chủ nhật 20:00; tối đa 1 nhắc tối và 1 nhắc review mỗi tuần | Không có máy chủ nên dùng thông báo cục bộ (`UNUserNotificationCenter`), lên lịch lại mỗi khi tick hoặc đồng bộ xong; tắt nhắc tối nếu đã tick đủ. `settings.reminders` đồng bộ; quyền thông báo xin riêng từng máy |
| Bắt đầu · Lần đầu dùng | 3 bước bỏ qua được sau bước mã khôi phục: thói quen mẫu, ngân sách tháng, thử Ghi nhanh | `settings.onboarded_at`; danh sách mẫu cố định trong app; `budgets.monthly_total` |

## Phụ lục D. Nghiệm thu bản web (30/10, tham khảo)

Bản React + Tailwind đã qua checklist ngày 30/10. Giữ lại để làm web sau; một số mục (lỗi mạng, Đăng nhập, Đăng xuất, khóa PIN) không còn đúng với bản Apple.

### D.1 Gói code

```
code/
  package.json            next 15, react 19, lucide-react; không thư viện UI nào khác
  tailwind.config.ts      theme đã khóa: chỉ màu token, thang chữ rem, spacing 4pt
  src/app/globals.css     CSS variables Light/Dark (tokens:start … tokens:end) + lớp vật liệu
  src/app/layout.tsx      Inter có bộ vietnamese, theme-color cho 2 chế độ, viewport-fit=cover
  src/app/manifest.ts     manifest PWA, icon maskable
  src/app/page.tsx        trang / dựng màn Hôm nay mẫu (today-demo.tsx) từ các component
  public/icons/           icon 192, 512, maskable 512, apple-touch 180
  src/lib/                format.ts (tiền, ngày, giờ), quick-capture.ts (bộ hiểu “cafe 45k”), hooks.ts
  src/components/ui/      38 component .tsx + icon.ts, nav-items.ts, index.ts
  preview/                trang xem thử để kiểm 320px, chữ 200%, Dark, 6 trạng thái
  scripts/check-classes.js  báo mọi class không sinh ra CSS (tức là nằm ngoài token)
  tokens.json
```

Component: Button, IconButton, Chip, Badge, Card, ListRow, TextField, AmountInput, JournalTextarea, SegmentedControl, Switch, WeekdayPicker, DatePicker, BottomSheet, ConfirmDialog, Toast (provider + `useToast`), TaskCheckbox, TaskRow, SwipeRow, HabitTile + HabitGrid, HabitHeatmap, MoodPicker + MoodFace, EnergyPicker, ProgressBar, StatTile, GlanceRow, BarChart, LineChart, Skeleton, EmptyState, OfflineBanner, InlineError, TabBar, Sidebar, ScreenHeader, Fab, QuickCapture, Spinner.

Chạy:

```
npm install
npm run typecheck      # TypeScript strict
npm run check:tokens   # mọi class phải ra CSS từ theme đã khóa
npm run preview        # dựng preview/index.html, mở bằng trình duyệt (?state=data|first|loading|error|offline|capture|date)
npm run dev            # Next.js, trang / là màn Hôm nay mẫu
```

Đã cài mới từ đầu (next 15.5, react 19.3, tailwindcss 3.4) và chạy `typecheck`, `check:tokens`, `preview` đều sạch. Chưa chạy `next build` vì môi trường kiểm thử chặn tải Google Fonts mà `next/font` cần lúc build.

Quy ước đơn vị: chữ và chiều cao điều khiển có chữ dùng rem, nên to lên khi người dùng phóng chữ. Lề trang (`--gutter`), padding card, khoảng giữa khối, vùng chạm icon (`--hit` 44px), FAB và ô icon 36px dùng px. Lý do: ở màn 320px và chữ 200%, lề không phình ra chiếm chỗ của nội dung, giống cách iOS xử lý Dynamic Type.

### D.2 Checklist từng mục

#### Trải nghiệm

| Mục | Kết quả | Bằng chứng, ghi chú |
|---|---|---|
| Ghi một khoản chi dưới 3 chạm, dưới 5 giây | Đạt có điều kiện | FAB → gõ “cafe 45k” → Enter hoặc “Lưu khoản chi”: 2 chạm. Chip xem trước cho thấy 45.000₫ · Ăn uống · Hôm nay trước khi lưu. Sheet vẫn mở, ô trống, focus giữ nguyên để ghi tiếp. Thời gian là ước tính. |
| Tick việc và hoàn tác trong 4 giây | Đạt | `TaskRow` chờ 600 ms rồi mới chuyển dòng (bấm lại trong lúc đó là hủy). Toast 4 giây “Đã xong “Nộp báo cáo”” có Hoàn tác, dừng đếm khi rê chuột hoặc focus. |
| Check-in tối dưới 30 giây | Đạt có điều kiện | Từ 18h thẻ Check-in lên đầu Hôm nay. Mood 1 chạm, năng lượng 1 chạm, một dòng biết ơn tùy chọn, tự lưu. Thời gian là ước tính. |
| Hôm nay trên mobile trả lời “làm gì, thói quen, chi tiêu” không cần cuộn (trước 18h) | Đạt | Mới thêm dải tóm tắt 3 ô dưới lời chào: “8 việc · 2 quá hạn”, “3/5 thói quen”, “185k đã chi”. Chạm một ô để tới thẻ đó. Ở 390×844 cả dải và đầu thẻ Việc nằm trong màn đầu. Bản trước chưa đạt vì thẻ Việc 7 dòng đẩy Thói quen và Chi tiêu xuống dưới. |
| Mọi con số có ngữ cảnh | Đạt | Thẻ số có dòng so sánh (“23/28 lần”, “▼ 8% so với tuần trước”); ngân sách “6,6tr / 9tr”, “Còn 2,4tr cho 2 ngày”; chuỗi “Chuỗi 12 ngày”; biểu đồ có đường trung bình và dòng tóm tắt. |
| Không câu chữ trách móc | Đạt | Chuỗi đứt: “Bắt đầu lại hôm nay”. Lỗi: “Chưa kết nối được. Dữ liệu vẫn an toàn, thử lại sau ít phút.” Nhập sai: “Chưa hiểu số tiền. Thử “45k” hoặc “45.000”.” Mood thấp không có màu đỏ. |
| Mỗi màn có dữ liệu, trống lần đầu, đã dọn sạch, đang tải, lỗi | Đạt | Mới thêm trạng thái **Lỗi** (thanh trên cùng của artifact Screens). 7 màn có dữ liệu thay khối nội dung bằng thẻ lỗi tại chỗ có nút Thử lại; kiểm tự động thấy mỗi frame có đúng 1 thẻ lỗi. Đăng nhập dùng màn “Đăng nhập · lỗi” riêng và không có trạng thái “đã dọn sạch” vì chưa có dữ liệu. |
| Hành động chính trong vùng ngón cái | Đạt | FAB phải dưới trên tab bar, nút chính của sheet cố định ở đáy, tab bar. Nút “+” trên header Thói quen và Dự án là hành động phụ; tick và ghi nhanh nằm trong vùng ngón cái. |

#### Thị giác

| Mục | Kết quả | Bằng chứng, ghi chú |
|---|---|---|
| Chỉ dùng token | Đạt (gói code) | `tailwind.config.ts` thay hẳn bảng màu, thang chữ, spacing mặc định, nên `p-7`, `text-xl`, `bg-red-500` không tồn tại. `npm run check:tokens` xác nhận mọi class đều ra CSS. Vài giá trị riêng của component được viết tường minh: switch 51×31, vòng tick 22px, ô heatmap bo `r-xs/2`. Bản vẽ HTML còn vài khoảng nội bộ 3/6/10px; đó là hình minh họa, không dùng làm code. |
| Một accent | Đạt | Chỉ `--accent` teal. 8 màu dữ liệu chỉ dùng cho danh mục, dự án, thói quen và biểu đồ. |
| Danger chỉ cho quá hạn, vượt ngân sách, xóa | Đạt (đã sửa) | Lần rà này phát hiện 4 chỗ dùng sai và đã sửa ở cả thư viện, màn và code: ưu tiên Cao (đỏ → `--warning`; Vừa → `--data-violet`), lỗi nhập liệu (viền đỏ → viền `--text` + icon), icon lỗi tải (đỏ → `--text-2`), nút Đăng xuất (đỏ → accent). Còn lại: nhãn và ngày quá hạn, badge quá hạn, thanh và chữ vượt ngân sách, nút và menu Xóa. |
| Kính mờ chỉ ở tab bar, header dính, bottom sheet | Đạt (đã sửa) | `.elev-1` chỉ còn ở TabBar và header gọn khi cuộn. Sheet và dialog dùng cấp 2 đặc. Lần rà này đổi thanh nút đáy của luồng Suy ngẫm và khung xem trước thông báo sang nền đặc. |
| Dark thiết kế riêng, không đen tuyệt đối | Đạt | Nền `#0F0E0D`; độ nổi bằng bề mặt sáng dần thay cho bóng; accent `#4FD1C5`; bảng dữ liệu chỉnh riêng ở OKLCH L 0,76; `--segment-thumb` và `--field-on-sheet` riêng cho Dark. |
| Số tabular, canh phải | Đạt | Số tiền trong danh sách canh phải, `tabular-nums`. Khi chữ phóng to không đủ chỗ, số tiền xuống dòng nhưng vẫn canh phải. Số lớn đơn lẻ trong thẻ canh trái theo thẻ. |
| Dấu tiếng Việt nguyên vẹn | Đạt | Inter tải bộ `vietnamese` qua `next/font`, font dự phòng hệ thống đều có dấu. Dữ liệu và mẫu chữ có “Nguyễn Minh An”, “Hưởng”, “Ước tính chi tiêu”. Ô icon và vòng tick đổi sang px nên chữ có chỗ, “Hưởng” không còn bị ngắt giữa từ ở chữ 200%. |
| Không nhãn viết hoa toàn bộ | Đạt | Không có `uppercase` hay `text-transform` trong code và bản vẽ. |

#### Trợ năng

| Mục | Kết quả | Bằng chứng, ghi chú |
|---|---|---|
| Tương phản 4,5:1 chữ, 3:1 đồ họa, ở cả hai chế độ | Đạt (đã sửa 30/10) | 68 cặp, 68 đạt (phụ lục B). `--text-3` trên `--surface-2` trước là 4,29:1, nay 4,84:1 (Light) và 4,96:1 (Dark) sau khi đổi màu. `--positive` trên `--surface-2` Light 4,49:1 chỉ gặp ở số tiền 40px, là chữ lớn với ngưỡng 3:1. |
| Vùng chạm 44px, cách nhau 8px | Đạt | Kiểm tự động mọi nút, liên kết, radio, switch, checkbox ở 320, 390, 1440, chữ 100% và 200%: không vùng chạm nào dưới 44. Chip và lựa chọn cách 8px; chip xuống dòng cách 12px để vùng chạm 44 không chồng nhau. Ngoại lệ có chủ đích: segmented, tab bar, ô lịch và dòng danh sách nằm liền nhau không có khe (như iOS), mỗi ô vẫn ≥ 44. Ô heatmap 12px và cột biểu đồ: cả biểu đồ là một vùng chạm, chạm đâu chọn ô gần nhất, nút “Tick bù” 44px. |
| Focus ring ở mọi nơi | Đạt | `:focus-visible` viền 2px `--accent`, cách 2px, cho mọi phần tử. Mood, năng lượng, segmented, heatmap, lịch, biểu đồ đi được bằng phím mũi tên. |
| Không chỉ dùng màu | Đạt | Ưu tiên có cờ và chữ; quá hạn có icon và chữ “Quá hạn” cho trình đọc màn hình; vượt ngân sách có vạch sọc và chữ “vượt 300k”; mood có khuôn mặt và nhãn; mood và năng lượng khác hình điểm (tròn, vuông); ngày không phải mục tiêu viền đứt. |
| Không vỡ ở chữ 200% và màn 320px | Đạt | 42 tổ hợp (320/390/1440 × chữ 100%/200% × Light/Dark × dữ liệu, trống, đang tải, lỗi, ngoại tuyến, sheet): không cuộn ngang, không phần tử tràn màn. Ở chữ 200%: mood và năng lượng tự thành danh sách dọc, nhãn tab xuống 2 dòng thay vì bị cắt, lưới thói quen về 1 cột, ngày trong tuần xuống hàng. Bản vẽ HTML là khung cố định 390/1440 nên kiểm trên gói code. |
| Giảm chuyển động, giảm trong suốt | Đạt | Giảm chuyển động: mọi thời lượng còn 80–90ms, tuyến tính; tắt shimmer, pop, confetti. Giảm trong suốt hoặc trình duyệt không có `backdrop-filter`: cấp 1 thành nền đặc. |
| Nhãn thật cho ô nhập, chữ từ 16px | Đạt | Mọi ô có `<label>`. Ba ô dùng nhãn ẩn vì tiêu đề nhìn thấy ngay cạnh: tìm kiếm có icon kính lúp, số tiền dưới tiêu đề sheet, Ghi nhanh dưới tiêu đề “Ghi nhanh”. CSS gốc ép ô nhập tối thiểu 16px. |
| Biểu đồ có tóm tắt bằng chữ | Đạt | BarChart và LineChart có `figcaption`; heatmap có câu tóm tắt; thanh ngân sách có nhãn “Ăn uống: 2,6tr trên 3tr, 87%” và chữ hiển thị “2,6tr / 3tr”. |

#### Kỹ thuật

| Mục | Kết quả | Bằng chứng, ghi chú |
|---|---|---|
| Safe-area | Đạt có điều kiện | `viewport-fit=cover`; tab bar, FAB, toast, đáy sheet, header cộng `env(safe-area-inset-*)`. Chưa thử trên máy thật. |
| Chuyển động chỉ transform/opacity, dùng token thời lượng | Đạt (đã sửa) | Code chỉ có `transition-transform`, `transition-opacity`, `transition-[transform,opacity]` với `duration-micro/standard/emphasized`. Lần rà này bỏ 10 chỗ chuyển màu nền, viền, `stroke-dashoffset` trong bản vẽ HTML; dấu tích hiện bằng scale + opacity. |
| Icon maskable, theme-color cho cả hai chế độ | Đạt | `layout.tsx`: `themeColor` Light `#FAF9F7`, Dark `#0F0E0D` theo `prefers-color-scheme`. `manifest.ts` có icon maskable 512 (biểu tượng nằm trong vùng an toàn 80%); đã xuất 4 PNG trong `public/icons/`. Manifest chỉ nhận một `theme_color` nên dùng màu Light; thẻ meta lo phần Dark. |
| [Mở rộng] ở frame riêng, có ghi chú dữ liệu cần | Đạt (đã sửa) | Trước đây 8 phần tử [Mở rộng] nằm lẫn trong frame MVP. Nay frame MVP không còn phần tử nào (kiểm tự động: 0 lọt), 11 frame [Mở rộng] riêng, mỗi frame có ghi chú dữ liệu (phụ lục C). |

### D.3 Prototype 3 luồng

| Luồng | Xem ở đâu |
|---|---|
| Ghi nhanh một khoản chi | Screens: Thu chi → Thêm giao dịch (sheet, “Lưu khoản chi” ra toast). Design System: mẫu Ghi nhanh với bộ hiểu cú pháp chạy thật. Code: `QuickCapture` (preview `?state=capture`). |
| Tick việc và hoàn tác | Screens: Hôm nay, chạm vòng tròn trước một việc → dòng mờ đi rồi chuyển xuống “Đã xong”, toast “Đã xong “…”” có Hoàn tác. Code: `TaskRow` + `useToast`. |
| Check-in buổi tối | Screens: chọn “Tối 20:15” trên thanh trên cùng → Check-in lên thẻ đầu, chọn mood và năng lượng, viết một dòng. Code: `MoodPicker`, `EnergyPicker`, `JournalTextarea` (tự lưu sau 1 giây). |

### D.4 Thay đổi trong lần rà này

- `--text-3`: Light `#78716C` → `#6F6964`, Dark `#8A847E` → `#958F89` (anh/chị chọn ngày 30/10). Chỉ đổi giá trị token, không sửa component.
- Màu ưu tiên: Không `--text-3`, Thấp `--data-blue`, Vừa `--data-violet`, Cao `--warning`.
- Lỗi nhập liệu: viền 2px `--text`, icon và câu hướng dẫn, không đỏ. Icon lỗi tải: `--text-2`.
- Đăng xuất: chữ accent, nút xác nhận primary.
- Hôm nay mobile: thêm dải tóm tắt 3 ô. Đây là cách trình bày lại số liệu đã có để đạt mục “không cần cuộn”, không phải tính năng mới.
- Trạng thái Lỗi cho mọi màn; màn “Thêm · lỗi số tiền”; frame [Mở rộng] Tìm kiếm có câu trống “Không tìm thấy “abc”. Thử từ khóa khác.”
- Frame [Mở rộng] mới: Kéo thả để dời, Chuỗi dài nhất, Giờ nhắc và mục tiêu đếm, Tuần trước, Giao diện và khóa PIN, Nhắc nhở (“Còn 2 thói quen cho hôm nay. Vẫn kịp đấy.”), Khoản định kỳ, Tìm kiếm.
- Token bố cục: `--gutter`, `--card-pad`, `--block-gap`, `--hit`, `--fab-size` chuyển sang px; `--elev-0-border` nay là màu (Light `--border`, Dark trong suốt), dùng `border: 1px solid var(--elev-0-border)`.
- Chữ dưới 12px trong bản vẽ (nhãn heatmap 10px, nhãn dải 7 ngày, tag Mở rộng 11px) nâng lên 12px.
