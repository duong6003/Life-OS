# LifeOSDesignSystem

Gói Swift chứa token và component dùng chung cho app iPhone, iPad, Mac và widget của Life OS.
Yêu cầu iOS 26 / macOS 26 (Liquid Glass, `lineHeight`), Swift 6.2.

> Gói này được viết trên máy không có Xcode nên **chưa được build**. Lần build đầu có thể cần sửa vài chỗ nhỏ;
> các API dễ lệch nhất: `lineHeight(.multiple(factor:))`, `.glassEffect(_:in:)`, `.tabViewBottomAccessory`, `.tabBarMinimizeBehavior`, `@Entry`. Ẩn thanh Ghi nhanh ở Review tuần và khi đang viết: dùng cách ẩn theo màn nếu SDK có; không có thì để thanh hiện, không tự vẽ thanh riêng.

## Token

Nguồn sự thật là `design/tokens/tokens.json` ở gốc repo. Không sửa file trong `Sources/DesignSystem/Generated` hay `Resources/Tokens.xcassets`.

```sh
python3 design/tokens/generate.py          # (chạy ở gốc repo) sinh lại colorset, Tokens.swift, tokens.css
python3 design/tokens/generate.py --check  # dùng trong CI: báo lỗi nếu file sinh ra đã cũ
```

| Nhóm | Swift | Ghi chú |
|---|---|---|
| Màu | `LifeOSColor.text2` | 30 colorset, mỗi cái có Light, Dark; 7 màu có thêm biến thể Increase Contrast |
| Độ đậm | `LifeOSOpacity.dataTint(scheme)` | Nền ô icon, lớp phủ hover và nhấn |
| Khoảng cách | `Space.s4` (16pt) | Lưới 4pt |
| Bố cục | `Layout.gutter(.regular)`, `Layout.hit` | `LayoutClass`: compact (iPhone), regular (iPad), mac |
| Bo góc | `Radius.lg` | Luôn `style: .continuous` |
| Chữ | `.lifeOSText(.title1)` | SF Pro theo Dynamic Type; chiều cao dòng là hệ số |
| Chuyển động | `.lifeOSAnimation(.standard, value:)` | Tự đổi sang mờ dần khi Reduce Motion |
| Rung | `.lifeOSHaptic(.success, trigger:)` | Chỉ ở sự kiện có ý nghĩa |
| Icon | `LifeOSIcon.today` | SF Symbols |

## Quy tắc hiệu năng (ưu tiên số 1)

1. **Kính:** lớp điều hướng nổi trên nội dung dùng Liquid Glass: TabView, toolbar, thanh bên NavigationSplitView, sheet nửa màn, menu (hệ thống tự có), thanh Ghi nhanh `QuickCaptureBar` (nằm trong `.tabViewBottomAccessory`, kính do hệ thống vẽ), cộng một phần tử tự thêm là `UndoToast` (`.glassEffect`). Kính tự thêm tối đa 5 phần tử mỗi màn, chung một `GlassEffectContainer`, đứng yên. Lớp nội dung (hàng danh sách, ô heatmap, thẻ, biểu đồ, widget) luôn nền đặc.
2. **Chuyển động:** chỉ hiệu ứng chạy một lần trên opacity, scale, offset. Không `repeatForever`, `TimelineView(.animation)`, shader lấy mẫu hay blur động. Mỗi màn tối đa một khoảnh khắc ăn mừng (`Celebration.isAllowed`).
3. **Danh sách:** dùng `List` với hàng chuẩn; không bóng hay blur riêng từng hàng.
4. **Heatmap:** một `Canvas` (`HabitHeatmap`), chạm theo tọa độ.
5. **Biểu đồ:** Swift Charts với số liệu đã gộp sẵn bằng SQL.
6. **Chữ:** không đặt chữ trong khung cao cố định; không `.clipped()` quanh chữ.
7. **Mục tiêu đo:** hitch ≤ 10 ms/s, không hang > 250 ms, khung hình đầu ≤ 400 ms, công việc app ~4 ms mỗi khung hình.

## Ánh xạ 38 component từ bản React

**Hệ thống** = dùng control có sẵn của SwiftUI, chỉ đặt màu token. **Tự vẽ** = có trong gói này. **Bỏ** = không còn cần.

| React | SwiftUI | Loại |
|---|---|---|
| amount-input | `TextField` + `.keyboardType(.decimalPad)` + `FormatStyle` tiền tệ | Hệ thống |
| badge | `.badge()` cho tab và hàng list; nhãn tự do dùng `Text` + `.capsule` | Hệ thống |
| bar-chart | Swift Charts `BarMark` | Hệ thống |
| bottom-sheet | `.sheet` + `presentationDetents` | Hệ thống |
| button | `Button` + `.borderedProminent` / `.bordered` / `.glass` | Hệ thống |
| card | `.lifeOSCard()` | Tự vẽ |
| chip | `ChipToggleStyle` | Tự vẽ |
| date-picker | `DatePicker` (`.graphical` trong sheet, `.compact` trong form) | Hệ thống |
| dialog | `.confirmationDialog` / `.alert` | Hệ thống |
| empty-state | `ContentUnavailableView` | Hệ thống |
| energy-picker | `EnergyPicker` | Tự vẽ |
| fab | `QuickCaptureBar` trong `.tabViewBottomAccessory` trên iPhone; `QuickCaptureToolbarButton` (⌘N) trên iPad, Mac | Hệ thống |
| glance-row | `GlanceRow` | Tự vẽ |
| habit-heatmap | `HabitHeatmap` (Canvas) | Tự vẽ |
| habit-tile | `HabitTile` | Tự vẽ |
| icon-button | `Button` + `Label(…).labelStyle(.iconOnly)` | Hệ thống |
| inline-error | `InlineError` + `.lifeOSField(isInvalid:)` | Tự vẽ |
| journal-textarea | `TextEditor`; chuyển TextKit 2 nếu profiler thấy lag | Hệ thống |
| line-chart | Swift Charts `LineMark` | Hệ thống |
| list-row | Hàng `List` + `LabeledContent` | Hệ thống |
| mood-picker | `MoodPicker`, `MoodFace` | Tự vẽ |
| offline-banner | Thay bằng `SyncStatusBadge`: ngoại tuyến không còn là lỗi | Bỏ |
| progress-bar | `ProgressView(value:)` / `Gauge` | Hệ thống |
| quick-capture | `QuickCaptureField` | Tự vẽ |
| screen-header | `navigationTitle` + `toolbar` (tiêu đề lớn) | Hệ thống |
| segmented-control | `Picker` + `.pickerStyle(.segmented)` | Hệ thống |
| sidebar | `NavigationSplitView` | Hệ thống |
| skeleton | `.redacted(reason: .placeholder)`, chỉ cho lần đồng bộ đầu trên máy mới | Hệ thống |
| spinner | `ProgressView` | Hệ thống |
| stat-tile | `StatTile` | Tự vẽ |
| swipe-row | `.swipeActions` | Hệ thống |
| switch | `Toggle` | Hệ thống |
| tab-bar | `TabView` (Liquid Glass) | Hệ thống |
| task-checkbox | `TaskCheckboxStyle` | Tự vẽ |
| task-row | Hàng `List` + `TaskCheckboxStyle` + `.swipeActions` | Hệ thống |
| text-field | `TextField` + `.lifeOSField()` | Hệ thống |
| toast | `UndoToast` | Tự vẽ |
| weekday-picker | `WeekdayPicker` | Tự vẽ |

Tổng: 24 hệ thống, 13 tự vẽ, 1 bỏ. Thêm mới cho kiến trúc local-first: `SyncStatusBadge`, `RecoveryKeyView` + `RecoveryKeyCopyButton` + `RecoveryKeyAlphabet`, `IconTile`.

## Icon: Lucide → SF Symbols

| Lucide | SF Symbols | | Lucide | SF Symbols |
|---|---|---|---|---|
| sun | sun.max | | trash-2 | trash |
| circle-check | checkmark.circle | | refresh-cw | arrow.clockwise |
| repeat | repeat | | search | magnifyingglass |
| notebook-pen | square.and.pencil | | bell | bell |
| wallet | wallet.bifold | | archive | archivebox |
| calendar-range | calendar | | folder / folder-plus | folder / folder.badge.plus |
| settings | gearshape | | grip-vertical | line.3.horizontal |
| inbox | tray | | hash | number |
| plus | plus | | image-plus | photo.badge.plus |
| check | checkmark | | pencil / pen-line | pencil / pencil.line |
| x | xmark | | receipt | receipt |
| chevron-left / right | chevron.left / chevron.right | | smile | face.smiling |
| ellipsis | ellipsis | | sprout | leaf |
| flag | flag | | utensils | fork.knife |
| circle-alert | exclamationmark.circle | | bike | bicycle |
| clock-alert | clock.badge.exclamationmark | | droplets | drop |
| calendar-clock | calendar.badge.clock | | footprints | figure.walk |
| gauge | gauge.with.dots.needle.50percent | | book-open | book |
| cloud-off / wifi-off | icloud.slash | | lightbulb | lightbulb |
