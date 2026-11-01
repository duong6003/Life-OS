# Business rules

Mỗi quy tắc có mã `BR-<MODULE>-<NN>`, phạm vi (MVP / Mở rộng) và test case kiểm nó. Code thực hiện quy tắc ghi comment `// BR-…`. Quy tắc ghi **(mặc định)** là lựa chọn tôi đặt khi chưa có quyết định của bạn; đổi được, đổi thì sửa ở đây trước.

## Chung (GEN)
| Mã | Quy tắc | Phạm vi | Test |
|---|---|---|---|
| BR-GEN-01 | Mọi thao tác ghi xong là có trong máy ngay; không thao tác nào chờ mạng. | MVP | TC-GEN-01 |
| BR-GEN-02 | "Hôm nay" là ngày lịch theo múi giờ thiết bị lúc đó, đổi lúc 00:00. Đi du lịch không dời ngày đã ghi. **(mặc định: 00:00; có thể thêm "ngày bắt đầu lúc 4:00" sau)** | MVP | TC-GEN-02 |
| BR-GEN-03 | Tuần bắt đầu thứ Hai. | MVP | TC-REV-01 |
| BR-GEN-04 | Tiền VND hiển thị `1.250.000₫`; rút gọn `45k`, `1,2tr`, `2,5 tỷ`. Phần trăm số nguyên `82%`. Ngày `T5, 29/10`, đầy đủ `Thứ Năm, 29 tháng 10`, giờ `21:30`. | MVP | TC-GEN-04 |
| BR-GEN-05 | File dữ liệu hỏng hoặc migration lỗi: không crash; hiện màn "Lỗi dữ liệu trong máy" với lựa chọn tải lại từ iCloud; giữ file hỏng để xuất gửi hỗ trợ. | MVP | TC-GEN-03 |
| BR-GEN-06 | Xoá luôn là xoá mềm và có Hoàn tác 4 giây; không có hộp thoại "Bạn có chắc" trừ khi xoá cả danh mục/thói quen có lịch sử. | MVP | TC-GEN-05 |
| BR-GEN-07 | Câu chữ không trách móc ("Quá hạn 2 ngày", không "Bạn đã trễ"). | MVP | review |
| BR-GEN-08 | Chỉ ba loại lỗi người dùng thấy: chưa đăng nhập iCloud, thiếu khoá trên máy mới, dữ liệu trong máy hỏng. Mọi lỗi khác tự thử lại và chỉ hiện ở chỉ báo đồng bộ. | MVP | TC-SYNC-08 |

## Ghi nhanh (CAP)
| Mã | Quy tắc | Phạm vi | Test |
|---|---|---|---|
| BR-CAP-01 | Cú pháp theo SPEC-quick-capture v1; kết quả xem trước đổi theo từng phím. | MVP | TC-CAP-01, vector |
| BR-CAP-02 | Có số tiền → khoản chi; số tiền có `+` → khoản thu; ngày mặc định hôm nay. | MVP | vector |
| BR-CAP-03 | Không có số tiền, có `@ngày` → việc có hạn ngày đó, không vào Inbox. | MVP | vector |
| BR-CAP-04 | Không số tiền, không ngày → việc trong **Inbox** (`inbox=1`, không danh mục). | MVP | TC-CAP-02 |
| BR-CAP-05 | Lưu xong hiện toast "Đã ghi … · Hoàn tác" 4 giây; ô nhập giữ mở để ghi tiếp. | MVP | TC-CAP-03 |
| BR-CAP-06 | Ghi một khoản chi ≤ 3 chạm và ≤ 5 giây từ màn Hôm nay. | MVP | TC-PERF-05 |
| BR-CAP-07 | Thanh Ghi nhanh ẩn ở Review tuần và khi đang viết nhật ký (iPhone). ⌘N mọi nơi trên iPad có bàn phím và Mac. | MVP | TC-CAP-04 |

## Việc (TSK)
| Mã | Quy tắc | Phạm vi | Test |
|---|---|---|---|
| BR-TSK-01 | Kho mới có 4 danh mục mẫu: Công việc, Cá nhân, Sức khỏe, Nhà (ID tất định `seed:`). | MVP | TC-TSK-01 |
| BR-TSK-02 | Nhóm: **Quá hạn** (`due_on < hôm nay`, chưa xong), **Hôm nay** (`due_on = hôm nay`), **Sắp tới** (`> hôm nay`, nhóm theo ngày, nhãn `T7, 31/10 · Ngày mai`), **Inbox**, **Không hạn**. | MVP | TC-TSK-02 |
| BR-TSK-03 | Tick xong: `status=done`, `completed_at=now`, haptic success, toast Hoàn tác 4 giây; Mac thêm ⌘Z. Việc xong hôm nay vẫn hiện (gạch, mờ) tới hết ngày rồi ẩn. | MVP | TC-TSK-03 |
| BR-TSK-04 | Hoàn tác = ghi lại `status=open`, `completed_at=null` bằng thay đổi mới (không rollback). | MVP | TC-TSK-04 |
| BR-TSK-05 | Ưu tiên: không / Thấp (data-blue) / Vừa (data-violet) / Cao (warning). Chỉ cờ được tô màu. Danger chỉ cho "Quá hạn". | MVP | TC-TSK-05 |
| BR-TSK-06 | Sắp xếp trong nhóm: ưu tiên giảm dần, rồi `sort_key`, rồi `created_at`. | MVP | TC-TSK-06 |
| BR-TSK-07 | Tiêu đề không rỗng sau khi cắt khoảng trắng; tối đa 500 ký tự. | MVP | TC-TSK-07 |
| BR-TSK-08 | Thẻ Hôm nay hiện tối đa 5 việc: quá hạn trước, rồi hôm nay; còn lại "và N việc khác". | MVP | TC-TDY-02 |

## Thói quen (HAB)
| Mã | Quy tắc | Phạm vi | Test |
|---|---|---|---|
| BR-HAB-01 | Thói quen có lịch theo thứ (`weekdays`); ngày không nằm trong lịch không tính vào chuỗi và không hiện ở Hôm nay. | MVP | TC-HAB-01 |
| BR-HAB-02 | Tick hôm nay = tạo/khôi phục `habit_log` ngày đó; bỏ tick = đặt `deleted_at`. | MVP | TC-HAB-02 |
| BR-HAB-03 | Hai máy tick cùng thói quen cùng ngày → một `habit_log` (ID v5). | MVP | TC-SYNC-04 |
| BR-HAB-04 | **Chuỗi hiện tại** = số ngày theo lịch liên tiếp có log, tính lùi từ hôm nay; nếu hôm nay chưa tick thì tính từ hôm qua (chưa tick hôm nay không làm đứt chuỗi). | MVP | TC-HAB-03 |
| BR-HAB-05 | Tick bù được tối đa 7 ngày trước (chạm ô trên heatmap); xa hơn chỉ xem. **(mặc định)** | MVP | TC-HAB-04 |
| BR-HAB-06 | Heatmap: 1 ô = 1 ngày, 12 tuần trên iPhone, 26 tuần trên iPad/Mac; vẽ bằng một `Canvas`. | MVP | TC-PERF-03 |
| BR-HAB-07 | Lưu trữ thói quen giữ lịch sử, ẩn khỏi Hôm nay. Xoá thói quen hỏi xác nhận (có lịch sử). | MVP | TC-HAB-05 |
| BR-HAB-08 | Mỗi màn tối đa một khoảnh khắc ăn mừng (mốc chuỗi 7, 30, 100); tắt khi Reduce Motion hoặc Low Power. | MVP | TC-HAB-06 |

## Nhật ký và tâm trạng (JRN)
| Mã | Quy tắc | Phạm vi | Test |
|---|---|---|---|
| BR-JRN-01 | Một mục nhật ký mỗi ngày (ID v5 theo ngày); check-in tối và bài viết cùng một mục. **(mặc định)** | MVP | TC-JRN-01 |
| BR-JRN-02 | Check-in: tâm trạng 1 chạm, năng lượng 1 chạm, một dòng tuỳ chọn; ≤ 30 giây. Có thể ghi lại nhiều lần, lần sau ghi đè. | MVP | TC-JRN-02 |
| BR-JRN-03 | Thẻ Check-in trên Hôm nay hiện từ 18:00 nếu chưa có tâm trạng hôm nay. **(mặc định)** | MVP | TC-TDY-04 |
| BR-JRN-04 | Nội dung bài mã hoá mức trường; danh sách chỉ hiện ngày + tâm trạng, giải mã khi mở bài. | MVP | TC-JRN-03 |
| BR-JRN-05 | Hai máy cùng sửa một bài → giữ cả hai (ADR-0012): bản mới hơn ở trên, bản kia hiện ngay dưới với nhãn "Bản từ thiết bị khác", nút "Bỏ bản này" có Hoàn tác. Không chặn màn. | MVP | TC-JRN-04, vector |
| BR-JRN-06 | Lưu tự động khi gõ (debounce 800 ms) và khi rời màn; không có nút Lưu. | MVP | TC-JRN-05 |

## Thu chi (SPD)
| Mã | Quy tắc | Phạm vi | Test |
|---|---|---|---|
| BR-SPD-01 | Số tiền nguyên dương; tối đa 999.999.999.999. Dấu do loại. | MVP | TC-SPD-01 |
| BR-SPD-02 | Mỗi giao dịch có đúng một danh mục cùng loại; không chọn thì dùng "Khác". | MVP | TC-SPD-02 |
| BR-SPD-03 | Tháng theo lịch (`occurred_on`). Màn Thu chi mặc định tháng hiện tại; đổi tháng bằng menu ở tiêu đề. | MVP | TC-SPD-03 |
| BR-SPD-04 | Đã chi tháng = tổng `expense` của tháng; còn lại = ngân sách − đã chi. Vượt ngân sách → chữ và thanh dùng danger + sọc (không chỉ màu). | MVP | TC-SPD-04 |
| BR-SPD-05 | Tháng chưa đặt ngân sách thì dùng ngân sách của tháng gần nhất trước đó; chưa có bao giờ thì không hiện thanh ngân sách. | MVP | TC-SPD-05 |
| BR-SPD-06 | Biểu đồ đọc số đã gộp sẵn bằng SQL theo ngày/danh mục; không tính trong `body`. | MVP | TC-PERF-04 |
| BR-SPD-07 | Xoá danh mục có giao dịch: chuyển giao dịch sang "Khác" cùng loại. Không xoá được "Khác". | MVP | TC-SPD-06 |

## Hôm nay (TDY)
| Mã | Quy tắc | Phạm vi | Test |
|---|---|---|---|
| BR-TDY-01 | Mỗi module góp tối đa một thẻ, chỉ khi có việc cần làm hôm nay; thẻ dựng từ mẫu chung `TodayCard`. | MVP | TC-TDY-01 |
| BR-TDY-02 | Thứ tự thẻ: Việc, Thói quen, Chi tiêu, Check-in. | MVP | TC-TDY-03 |
| BR-TDY-03 | Không có gì cho hôm nay → một trạng thái trống thân thiện, có nút Ghi nhanh. | MVP | TC-TDY-05 |
| BR-TDY-04 | Hiển thị khung hình đầu có dữ liệu ≤ 400 ms (khởi động lạnh, DB seed 3 năm). | MVP | TC-PERF-01 |

## Review tuần (REV)
| Mã | Quy tắc | Phạm vi | Test |
|---|---|---|---|
| BR-REV-01 | Tuần thứ Hai → Chủ nhật; mặc định tuần hiện tại, từ thứ Sáu gợi ý làm review. | MVP | TC-REV-01 |
| BR-REV-02 | Tổng hợp: việc xong, tỉ lệ thói quen theo lịch, tổng chi so ngân sách, tâm trạng trung bình. Mỗi module một khối cùng mẫu; module không có dữ liệu thì không có khối. | MVP | TC-REV-02 |
| BR-REV-03 | Tối đa 3 trọng tâm; trọng tâm tuần tới hiện trên Hôm nay tuần sau [Mở rộng]. | MVP / Mở rộng | TC-REV-03 |

## Bắt đầu, khoá và khôi phục (ONB)
| Mã | Quy tắc | Phạm vi | Test |
|---|---|---|---|
| BR-ONB-01 | Không tài khoản, không mật khẩu, không đăng xuất. | MVP | review |
| BR-ONB-02 | Lần đầu: Chào mừng → Cất giữ mã khôi phục → kiểm tra **một nhóm 4 ký tự** chọn ngẫu nhiên → vào app. | MVP | TC-ONB-01 |
| BR-ONB-03 | Mã khôi phục không chọn được dạng chữ; chép chỉ trong máy (không Universal Clipboard), tự xoá sau 2 phút; có "In hoặc lưu PDF". | MVP | TC-ONB-02 |
| BR-ONB-04 | Cảnh báo rõ: "Cất mã ở nơi khác với điện thoại. Mất cả máy lẫn mã thì không ai mở lại được dữ liệu, kể cả Life OS." ở bước cất mã và trong Cài đặt. | MVP | review |
| BR-ONB-05 | Máy mới có Keychain chứa khoá → vào thẳng, chỉ hiện "Đang tải dữ liệu từ iCloud" (skeleton) lần đầu. | MVP | TC-ONB-03 |
| BR-ONB-06 | Nhập mã: ký tự ngoài bảng báo ngay ("Có ký tự đọc nhầm: O"); sai mã báo "Mã chưa đúng", không giới hạn số lần (khoá entropy cao, thử offline không có ích). | MVP | TC-ONB-04 |
| BR-ONB-07 | Chưa bật iCloud vẫn dùng đầy đủ trong máy; badge "Chưa đăng nhập iCloud · vẫn lưu trong máy". | MVP | TC-ONB-05 |
| BR-ONB-08 | Không bao giờ tự sinh khoá chủ thứ hai khi cloud đã có kho (SPEC-crypto §6.3). | MVP | TC-CRY-05 |
| BR-ONB-09 | Đổi mã khôi phục trong Cài đặt: mã cũ hết hiệu lực ngay khi mã mới đã kiểm tra xong. | MVP | TC-CRY-06 |

## Đồng bộ (SYNC)
| Mã | Quy tắc | Phạm vi | Test |
|---|---|---|---|
| BR-SYNC-01 | Ngoại tuyến không phải lỗi; badge "Chờ đồng bộ · n thay đổi", màu chữ thường. | MVP | TC-SYNC-07 |
| BR-SYNC-02 | Trường sửa sau cùng (HLC) thắng, theo **từng trường**. | MVP | vector |
| BR-SYNC-03 | Xoá thắng sửa cũ hơn; sửa trên hàng đã xoá không hồi sinh hàng. | MVP | vector |
| BR-SYNC-04 | Đồng bộ chạy sau khung hình đầu, theo lịch hệ thống; không polling. | MVP | TC-PERF-06 |
| BR-SYNC-05 | Code đọc không giả định bất biến giữa các trường sau hợp nhất (vd. `status` là nguồn duy nhất cho "đã xong"). | MVP | TC-SYNC-05 |
| BR-SYNC-06 | Máy đặt sai giờ không làm kẹt đồng bộ (SPEC-sync §2.2). | MVP | vector |
| BR-SYNC-07 | Dữ liệu từ phiên bản app mới hơn được giữ, không mất, áp lại sau khi cập nhật. | MVP | TC-SYNC-06 |

## Nhắc nhở (REM) — Mở rộng
| Mã | Quy tắc | Phạm vi | Test |
|---|---|---|---|
| BR-REM-01 | Nhắc bằng thông báo cục bộ, chỉ trên **một máy nhắc chính** (mặc định iPhone), đổi được theo từng nhắc. | Mở rộng | TC-REM-01 |
| BR-REM-02 | Tối đa 1 nhắc tối và 1 nhắc review mỗi tuần; tắt nhắc tối nếu đã tick đủ thói quen hôm đó. | Mở rộng | TC-REM-02 |
