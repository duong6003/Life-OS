# Test case chức năng

## GEN
| ID | Kiểm | Bước / dữ liệu | Mong đợi | Covers | Mức |
|---|---|---|---|---|---|
| TC-GEN-01 | Ghi không chờ mạng | Tắt mạng, thêm việc | Việc hiện ngay < 100 ms, badge "Chờ đồng bộ · 1 thay đổi" | BR-GEN-01, BR-SYNC-01 | I, M |
| TC-GEN-02 | Đổi ngày lúc 00:00 | FixedClock 23:59:59 → 00:00:00 | Thẻ Hôm nay đổi nhóm; việc hạn hôm qua thành Quá hạn | BR-GEN-02 | S |
| TC-GEN-03 | DB hỏng | Ghi rác vào file DB rồi mở | Không crash; màn "Lỗi dữ liệu trong máy"; file cũ được đổi tên giữ lại | BR-GEN-05 | I |
| TC-GEN-04 | Định dạng | 1250000, 45000, 1200000, 2500000000, 0.823, ngày 29/10/2026 | `1.250.000₫`, `45k`, `1,2tr`, `2,5 tỷ`, `82%`, `T5, 29/10`, `Thứ Năm, 29 tháng 10` | BR-GEN-04 | U |
| TC-GEN-05 | Xoá mềm + hoàn tác | Xoá việc, bấm Hoàn tác trong 4 giây | Việc trở lại, `deleted_at=null`, có 2 thay đổi trong outbox lịch sử HLC | BR-GEN-06 | S |

## CAP — Ghi nhanh
| ID | Kiểm | Bước / dữ liệu | Mong đợi | Covers | Mức |
|---|---|---|---|---|---|
| TC-CAP-00 | Bộ hiểu = vector | Chạy toàn bộ `TestVectors/quick-capture/cases.json` | 100% khớp (parse, parseAmount, normalize, hint) | BR-CAP-01..04 | V |
| TC-CAP-01 | Xem trước theo phím | Gõ từng ký tự "cafe 45k" | Xem trước chuyển việc → khoản chi ở ký tự "k"; mỗi lần parse < 1 ms | BR-CAP-01 | U, S |
| TC-CAP-02 | Vào Inbox | "gọi điện cho ngân hàng" | Việc `inbox=1`, không danh mục, chip Inbox +1 | BR-CAP-04 | S |
| TC-CAP-03 | Toast + ghi tiếp | Lưu "cafe 45k" | Toast "Đã ghi 45k · Ăn uống · Hoàn tác"; ô trống, vẫn mở, focus giữ | BR-CAP-05 | S, UI |
| TC-CAP-04 | Ẩn thanh | Mở Review tuần; mở trình soạn nhật ký | Thanh Ghi nhanh không hiện (iPhone); ⌘N vẫn mở sheet trên Mac | BR-CAP-07 | UI |
| TC-CAP-05 | Gợi ý số tiền | "cafe 45kk" | Hiện gợi ý "Chưa hiểu số tiền…"; vẫn lưu được thành việc | SPEC §6 | S |

## TSK — Việc
| ID | Kiểm | Bước / dữ liệu | Mong đợi | Covers | Mức |
|---|---|---|---|---|---|
| TC-TSK-01 | Danh mục mẫu | Tạo kho mới trên 2 máy rồi đồng bộ | Đúng 4 danh mục, không trùng | BR-TSK-01, ADR-0014 | I |
| TC-TSK-02 | Nhóm | Việc hạn 29/10, 30/10, 31/10, 3/11, không hạn, inbox | Quá hạn(1), Hôm nay(1), Sắp tới: "T7, 31/10 · Ngày mai", "T3, 3/11 · Thứ Ba tới", Không hạn(1), Inbox(1) | BR-TSK-02 | I |
| TC-TSK-03 | Tick | Tick việc hôm nay | `done`, `completed_at`, haptic, toast 4 giây; sau 00:00 việc ẩn khỏi Hôm nay | BR-TSK-03 | S |
| TC-TSK-04 | Hoàn tác là thay đổi mới | Tick rồi Hoàn tác; đồng bộ với máy B đã nhận "done" | Cả hai máy `open`; HLC của `status` lần hoàn tác > lần tick | BR-TSK-04 | I, V |
| TC-TSK-05 | Màu ưu tiên | Snapshot view 4 mức | Chỉ cờ có màu đúng token; "Quá hạn" danger | BR-TSK-05 | UI (snapshot) |
| TC-TSK-06 | Thứ tự | 3 việc cùng ngày: Cao, không, Vừa | Cao, Vừa, không | BR-TSK-06 | I |
| TC-TSK-07 | Kiểm tiêu đề | "   ", 501 ký tự | Không lưu được; lỗi inline | BR-TSK-07 | U |

## HAB — Thói quen
| ID | Kiểm | Bước / dữ liệu | Mong đợi | Covers | Mức |
|---|---|---|---|---|---|
| TC-HAB-01 | Lịch theo thứ | Thói quen T2–T6, hôm nay T7 | Không hiện ở Hôm nay; T7 không làm đứt chuỗi | BR-HAB-01 | U |
| TC-HAB-02 | Tick / bỏ tick | Tick, bỏ tick, tick lại | Một hàng log, `deleted_at` lần lượt null → có → null | BR-HAB-02 | I |
| TC-HAB-03 | Chuỗi | Log 26–29/10, hôm nay 30/10 chưa tick | Chuỗi = 4; tick hôm nay → 5; 28/10 thiếu → 2 (29, 30) | BR-HAB-04 | U |
| TC-HAB-04 | Tick bù | Chạm ô 23/10 (7 ngày trước), 22/10 | 23/10 tick được; 22/10 chỉ xem | BR-HAB-05 | S |
| TC-HAB-05 | Lưu trữ | Lưu trữ thói quen có 100 log | Ẩn khỏi Hôm nay và danh sách; log còn; bỏ lưu trữ thấy lại chuỗi | BR-HAB-07 | I |
| TC-HAB-06 | Ăn mừng | Đạt chuỗi 7 với Reduce Motion bật / tắt | Bật: không hiệu ứng; tắt: một lần duy nhất | BR-HAB-08 | S |

## JRN — Nhật ký và tâm trạng
| ID | Kiểm | Bước / dữ liệu | Mong đợi | Covers | Mức |
|---|---|---|---|---|---|
| TC-JRN-01 | Một mục mỗi ngày | Check-in rồi viết bài cùng ngày | Một hàng `journal_entry` ID v5 ngày đó | BR-JRN-01 | I |
| TC-JRN-02 | Check-in nhanh | Chạm tâm trạng 4, năng lượng 3, gõ một dòng | Lưu ngay mỗi chạm; ghi lại lần 2 ghi đè | BR-JRN-02 | S, M (≤30 giây) |
| TC-JRN-03 | Mã hoá mức trường | Viết "bí mật", đọc DB thô | `body_sealed` bắt đầu `LOS\x01`, không chứa chuỗi rõ | BR-JRN-04 | I |
| TC-JRN-04 | Giữ cả hai | Máy A, B cùng sửa từ một bản, đồng bộ | Cả hai máy: body = bản HLC lớn, 1 `journal_conflict` cùng ID; "Bỏ bản này" + Hoàn tác | BR-JRN-05 | V, I, UI |
| TC-JRN-05 | Lưu tự động | Gõ, dừng 800 ms; gõ rồi thoát màn ngay | Cả hai trường hợp đều lưu; không ghi mỗi phím | BR-JRN-06 | S |

## SPD — Thu chi
| ID | Kiểm | Bước / dữ liệu | Mong đợi | Covers | Mức |
|---|---|---|---|---|---|
| TC-SPD-01 | Số tiền | 0, -5, 1.000.000.000.000 | Không lưu được | BR-SPD-01 | U |
| TC-SPD-02 | Danh mục mặc định | Thêm khoản chi không chọn danh mục | Danh mục "Khác" chi | BR-SPD-02 | S |
| TC-SPD-03 | Đổi tháng | Menu tiêu đề → Tháng 9, 2026 | Danh sách, tổng, biểu đồ của tháng 9 | BR-SPD-03 | S |
| TC-SPD-04 | Vượt ngân sách | Ngân sách 5tr, chi 5,2tr | "Vượt 200k" danger + sọc; VoiceOver đọc "vượt ngân sách" | BR-SPD-04 | S, UI |
| TC-SPD-05 | Kế thừa ngân sách | Đặt tháng 9 = 6tr, xem tháng 11 | Dùng 6tr; tháng 8 (trước mọi ngân sách) không có thanh | BR-SPD-05 | U |
| TC-SPD-06 | Xoá danh mục | Xoá "Đi lại" có 12 giao dịch | 12 giao dịch sang "Khác"; không có nút xoá ở "Khác" | BR-SPD-07 | I |

## TDY — Hôm nay
| ID | Kiểm | Bước / dữ liệu | Mong đợi | Covers | Mức |
|---|---|---|---|---|---|
| TC-TDY-01 | Thẻ theo dữ liệu | Không có việc hôm nay | Không có thẻ Việc | BR-TDY-01 | S |
| TC-TDY-02 | Tối đa 5 việc | 2 quá hạn + 6 hôm nay | 2 quá hạn + 3 hôm nay + "và 3 việc khác" | BR-TSK-08 | S |
| TC-TDY-03 | Thứ tự thẻ | Có đủ dữ liệu | Việc, Thói quen, Chi tiêu, Check-in | BR-TDY-02 | S |
| TC-TDY-04 | Check-in từ 18:00 | 17:59 / 18:00, chưa có tâm trạng | Ẩn / hiện | BR-JRN-03 | S |
| TC-TDY-05 | Trống | Kho mới | Trạng thái trống + nút Ghi nhanh | BR-TDY-03 | UI |

## REV — Review tuần
| ID | Kiểm | Bước / dữ liệu | Mong đợi | Covers | Mức |
|---|---|---|---|---|---|
| TC-REV-01 | Ranh giới tuần | Chủ nhật 1/11/2026 23:59 và thứ Hai 2/11 00:00 | Tuần 26/10 – 1/11 rồi tuần 2/11 – 8/11 | BR-GEN-03, BR-REV-01 | U |
| TC-REV-02 | Tổng hợp | Seed tuần có 12 việc xong, thói quen 80%, chi 3,1tr/5tr, tâm trạng TB 3,6 | Đúng 4 khối, số khớp truy vấn SQL kiểm | BR-REV-02 | I |
| TC-REV-03 | Tối đa 3 trọng tâm | Thêm trọng tâm thứ 4 | Nút thêm bị tắt, có lời giải thích | BR-REV-03 | S |

## REM — Nhắc nhở (Mở rộng, LOS-071)
| ID | Kiểm | Bước / dữ liệu | Mong đợi | Covers | Mức |
|---|---|---|---|---|---|
| TC-REM-01 | Chỉ máy nhắc chính | iPhone là máy chính, iPad cùng dữ liệu | Thông báo chỉ lên lịch trên iPhone; iPad không có thông báo chờ | BR-REM-01 | S, M |
| TC-REM-02 | Giới hạn và tự tắt | Tick đủ thói quen trước 21:00 | Nhắc tối hôm đó bị huỷ; mỗi tuần ≤ 1 nhắc review | BR-REM-02 | S |
