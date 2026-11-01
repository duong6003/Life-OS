---
id: LOS-075
title: "Đồng bộ mã hoá đầu-cuối: thay CloudSync bằng lớp tự làm"
milestone: "M6 Sau MVP"
labels: [type:feature, area:sync, area:crypto]
depends_on: [LOS-032, LOS-033, LOS-053]
size: L
---
## Mục tiêu
Giữ lời hứa E2EE mặc định và mở đường cho Android. Thay target `CloudSync` (SQLiteData SyncEngine) bằng lớp tự làm theo SPEC-sync và SPEC-crypto, mà không sửa repository hay màn hình (ADR-0016).

## Việc cần làm
- [ ] Migration thêm `journal_entry.body_sealed` và bảng `journal_conflict` (giữ cả hai bản, ADR-0012); mã hoá mức trường cho nội dung nhật ký
- [ ] Luồng Bắt đầu thêm bước mã khôi phục (BR-ONB-02..04, 06, 08)
- [ ] Chuyển dữ liệu một lần: đọc toàn bộ bảng, gửi lên zone mới dạng envelope, rồi xoá zone cũ của SQLiteData sau khi mọi máy đã chuyển
- [ ] Gỡ SyncEngine khỏi AppFeature; `check-core-imports.sh` đổi luật tương ứng

## Tiêu chí nghiệm thu
- [ ] TC-SYNC-00..04, 09..11, mọi TC-CRY, TC-ONB-01, 02, 04, 06, TC-JRN-03, 04 xanh
- [ ] Chuyển dữ liệu trên 2 thiết bị thật không mất hàng

## Tham chiếu
- ADR-0016
- SPEC-sync, SPEC-crypto
- docs/architecture/system-design-post-mvp.md

## Phụ thuộc
LOS-032, LOS-033, LOS-053
