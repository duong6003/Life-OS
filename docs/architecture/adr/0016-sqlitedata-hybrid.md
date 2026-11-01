# ADR-0016: MVP dùng SQLiteData (GRDB + SyncEngine), lớp đồng bộ tự làm để sau MVP

- Trạng thái: Chấp nhận (người dùng chọn "Lai: SQLiteData ngay, mã hoá sau", 01/11/2026)
- Ngày: 2026-11-01
- Sửa đổi: ADR-0003, ADR-0007, ADR-0008. Hoãn tới sau MVP: ADR-0004, ADR-0005, ADR-0006, ADR-0012.
- Liên quan: LOS-021, LOS-026, LOS-030, LOS-075, decisions-open D2

## Bối cảnh
Bộ khởi tạo ban đầu tự làm toàn bộ đồng bộ: HLC, merger, outbox, transport CKSyncEngine và mã hoá envelope. Phần này chiếm khoảng 8 issue, là phần rủi ro nhất và chưa được build lần nào. Người dùng muốn dùng lại thứ đã được build sẵn và kiểm chứng thay vì làm lại.

[SQLiteData](https://github.com/pointfreeco/sqlite-data) của Point-Free (MIT, bản 1.12.x tháng 10/2026) cung cấp những thứ sau, đều dựng trên GRDB:
- truy vấn có kiểu;
- theo dõi dữ liệu cho SwiftUI;
- `SyncEngine` đồng bộ qua CloudKit bằng CKSyncEngine;
- chia sẻ dữ liệu giữa nhiều người.

Theo tài liệu cộng đồng, cách hợp nhất của nó là LWW theo từng trường. Cách này cùng hướng với ADR-0004, nhưng chưa được kiểm trên tài liệu gốc (xem LOS-021).

## Quyết định
Trong MVP, Life OS dùng SQLiteData cho lưu trữ, theo dõi dữ liệu và đồng bộ iCloud. Không tự làm HLC, outbox hay envelope trong MVP. Để sau này đổi được, có bốn ranh giới cứng:

1. **Schema vẫn là SQL trung lập** ở `schema/`. Không có cột hay bảng riêng của CloudKit trong bảng nghiệp vụ. Siêu dữ liệu đồng bộ nằm trong metadatabase riêng của SQLiteData.
2. **Chỉ target `CloudSync`** (gói `LifeOSData`) được nhắc tới `SyncEngine`. `AppFeature` gọi nó đúng một chỗ. Persistence, Feature và Domain không biết đồng bộ là gì.
3. **Feature đọc và ghi qua protocol repository** (port trong `Domain/Ports`, sửa bởi ADR-0017), không dùng `@FetchAll` trực tiếp trong View. Lý do: test store bằng repository giả, và giữ một chỗ duy nhất để thay cách theo dõi.
4. **Lõi `LifeOSCore` vẫn build trên Linux**, gồm Domain, Capture, và SyncCore/CryptoCore cho giai đoạn sau. SQLiteData chỉ có ở gói `LifeOSData` dành cho Apple.

Sau MVP (LOS-075), nếu cần mã hoá đầu-cuối mặc định hoặc làm Android, ta thay `CloudSync` bằng lớp tự làm theo SPEC-sync và SPEC-crypto. Lớp mới đọc cùng các bảng, rồi chuyển dữ liệu một lần sang zone mới. Đọc và ghi của các màn không phải sửa.

## Lựa chọn đã cân nhắc
| Lựa chọn | Hiệu năng & tài nguyên | Công làm | Rủi ro 5 năm | Khoá chặt | Đổi về sau tốn | Ghi chú |
|---|---|---|---|---|---|---|
| Tự làm toàn bộ (ADR-0004/5/6) | Tốt (GRDB) | Cao, khoảng 8 issue | Tự bảo trì mọi thứ | Thấp | — | Có E2EE, port Android dễ |
| **Lai: SQLiteData cho MVP, ranh giới để thay** | Tốt (GRDB, CKSyncEngine) | Thấp | Phụ thuộc Point-Free (đang hoạt động, MIT) | Vừa: dữ liệu trên iCloud theo dạng bản ghi của SQLiteData | Vừa: viết CloudSync mới và chuyển dữ liệu một lần | **Chọn** |
| Dùng hẳn SQLiteData, bỏ ranh giới | Tốt | Thấp nhất | Như trên | Cao: Feature dính `@FetchAll` và SyncEngine | Cao | Nhanh hơn một chút lúc đầu |
| SwiftData + CloudKit | Kém hơn với dữ liệu lớn | Thấp | Apple đổi API | Cao | Cao | Đã loại ngày 31/10 |

## Hệ quả
- **Lời hứa bảo mật trong MVP đổi.** Dữ liệu trên iCloud được bảo vệ theo chuẩn iCloud. Nó chỉ được mã hoá đầu-cuối nếu người dùng bật Advanced Data Protection. Màn Bắt đầu và trang Cài đặt phải nói đúng điều này (BR-ONB-01 sửa theo). Mã khôi phục và khoá chủ hoãn tới LOS-075.
- **Nhật ký xung đột:** MVP dùng LWW theo trường, nên khi hai máy cùng sửa ngoại tuyến thì bản sửa sau thắng. Hành vi "Giữ cả hai bản" (ADR-0012, BR-JRN-05) hoãn lại. Rủi ro thấp vì đây là app một người dùng; ghi nhận trong lần dùng thử LOS-064.
- **Ràng buộc schema của SyncEngine** (theo tài liệu cộng đồng, LOS-021 phải xác minh trên tài liệu gốc):
  - khoá chính đơn là UUID dạng TEXT;
  - không có `UNIQUE` ngoài khoá chính;
  - cột `NOT NULL` phải có `ON CONFLICT REPLACE` và giá trị mặc định;
  - khoá ngoại chỉ dùng `CASCADE`, `SET NULL` hoặc `SET DEFAULT`;
  - schema chỉ được thêm, không đổi tên hay xoá cột;
  - không đặt tên cột trùng với tên dành riêng của CKRecord.

  Schema 0001 đã được chỉnh theo các ràng buộc này.
- **Phụ thuộc mới được phép:** `sqlite-data`, kéo theo `swift-dependencies`, `swift-sharing`, `swift-structured-queries`. ADR-0007 sửa như sau: chỉ `defaultDatabase` và `defaultSyncEngine` đi qua `prepareDependencies`; dịch vụ của ta vẫn tiêm qua init.
- **Kích thước app tăng** do các gói Point-Free. LOS-021 đo con số này; ngưỡng ở performance-budget.md.
- **Tín hiệu để xem lại quyết định:**
  - SyncEngine gây mất hoặc phân kỳ dữ liệu trong TC-SYNC-12;
  - binary tăng quá 3 MB;
  - Point-Free ngừng bảo trì;
  - người dùng cần E2EE mặc định sớm hơn dự kiến.
