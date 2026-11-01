# SPEC-quick-capture · Bộ hiểu Ghi nhanh v1

- Version: **1.0** (theo `design/reference/code/quick-capture.ts`, bản web đã duyệt 30/10/2026)
- Kiểm bằng: `TestVectors/quick-capture/cases.json` — **sinh bằng chính file TypeScript gốc**, nên bản Swift phải cho đúng từng kết quả.
- Target Swift: `LifeOSCore/Capture`, hàm thuần, không I/O, < 1 ms cho chuỗi 200 ký tự.

## 1. Đầu vào, đầu ra
```
parse(raw: String, today: LocalDate, categories: [CaptureCategory]) -> Parsed?
Parsed = expense{amount, note, categoryId?, date} | income{…} | task{title, due?}
```
`nil` khi chuỗi rỗng sau khi cắt khoảng trắng, hoặc chỉ có số tiền/ngày mà không còn chữ cho việc.

## 2. Thuật toán
1. Cắt khoảng trắng hai đầu; tách token theo khoảng trắng.
2. Duyệt token từ trái sang phải:
   - Chưa có số tiền và token (bỏ `+` ở đầu nếu có) là số tiền (§3) → ghi nhận; có `+` thì là **khoản thu**.
   - Token bắt đầu bằng `@` dài > 1 và là ngày (§4) → ghi nhận ngày (token sau ghi đè token trước).
   - Còn lại → thuộc phần chữ.
3. Có số tiền → khoản thu/chi: `note` = phần chữ nối bằng một dấu cách; `date` = ngày đã ghi nhận hoặc `today`; danh mục đoán theo §5.
4. Không có số tiền: phần chữ rỗng → `nil`; ngược lại → việc, `due` = ngày đã ghi nhận hoặc không có.

## 3. Số tiền
So khớp trên token đã bỏ dấu, viết thường, bỏ một ký tự `đ`/`d`/`₫` ở cuối:
| Dạng | Ví dụ | Giá trị |
|---|---|---|
| `<số>k` | `45k`, `1,5k` | ×1.000, làm tròn |
| `<số>(tr|trieu|m)` | `15tr`, `1,5tr`, `2m` | ×1.000.000 |
| `<số>tr<1–3 chữ số>` | `1tr2`, `2tr05` | 1,2tr; 2,05tr |
| Nhóm nghìn bằng dấu chấm | `45.000`, `1.250.000` | số nguyên |
| ≥ 4 chữ số liền | `45000` | số nguyên |
| `<số>k<chữ số>` | `1k5` | **không** phải số tiền |
Số thập phân dùng `,` hoặc `.`. Token 1–3 chữ số không có đơn vị (`45`) **không** phải số tiền.

## 4. Ngày (`@token`, bỏ dấu, bỏ khoảng trắng)
| Token | Nghĩa |
|---|---|
| `nay`, `homnay` | hôm nay |
| `mai`, `ngaymai` | +1 ngày |
| `kia` | +2 ngày |
| `t2`…`t7`, `cn` | thứ đó **gần nhất sau hôm nay** (không tính hôm nay) |
| `cuoituan` | thứ Bảy gần nhất, **tính cả hôm nay** |
| `tuansau` | thứ Hai gần nhất sau hôm nay |
| `d/m` (1–2 chữ số) | ngày đó năm nay; nếu đã qua thì năm sau |
Token `@` không hiểu được giữ lại trong phần chữ (vd. `@abc`).

## 5. Đoán danh mục
Bỏ dấu + viết thường `note`, bao bằng dấu cách; danh mục cùng loại (chi/thu) đầu tiên có một từ khoá (đã bỏ dấu) xuất hiện dạng ` từ ` → chọn. Không khớp → danh mục **cuối cùng** của loại đó (quy ước: fallback "Khác" xếp cuối). Không có danh mục nào → `null`.

Bỏ dấu: Unicode NFD, bỏ dấu kết hợp U+0300–U+036F, `đ→d`, `Đ→D`, viết thường.

## 6. Gợi ý khi chưa hiểu số tiền
`amountHint(raw)` trả "Chưa hiểu số tiền. Thử “45k” hoặc “45.000”." khi chuỗi **trông như** có tiền (số theo sau `kk`, `tr` + ký tự khác, hoặc 1–2 chữ cái; hoặc số có phần thập phân 1–2 chữ số) nhưng kết quả parse là việc.

## 7. Lỗi đã biết của v1 (lộ ra khi sinh test vector 01/11/2026) → sửa ở v1.1 (LOS-016)
Bản Swift đầu tiên làm **đúng y v1** (qua hết vector), rồi LOS-016 sửa cả bản TS tham chiếu + vector + Swift trong một PR.

| Đầu vào | v1 cho ra | Nên là (đề xuất v1.1) |
|---|---|---|
| `mua sách 120k @1/10` (hôm nay 30/10) | Khoản chi ngày **01/10/2027** | Khoản thu/chi: ngày đã qua giữ năm nay (01/10/2026). Việc: giữ quy tắc "đã qua thì năm sau" |
| `chạy 5km`, `uống 2l nước` | Việc đúng, nhưng hiện gợi ý "Chưa hiểu số tiền" | Không gợi ý khi chữ sau số là đơn vị thường gặp (km, m, l, kg, trang, phút, lần, ly) |
| `grab 32k @hôm qua` | Ghi chú "grab @hôm qua", ngày hôm nay | Hiểu `@homqua` / `@hôm qua` = −1 ngày (gộp `@hôm` + `qua`) |
| `2 triệu tiền nhà` | Việc "2 triệu tiền nhà" | Gộp token số + đơn vị (`2 triệu`, `45 k`) thành số tiền |

## 8. Để v2
- Không hiểu giờ (`@20h`), không hiểu `@thu6`.
- Mỗi module sau MVP đăng ký cú pháp riêng (roadmap "Mở đường"); kết quả đã có trường loại nên chỉ thêm nhánh.
