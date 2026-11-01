# Quyết định còn mở

Mỗi mục có **gợi ý mặc định**: repo đã viết theo mặc định đó để bạn bắt đầu được ngay. Bạn chốt khác thì sửa ADR/BR tương ứng (ghi ở cột "Ảnh hưởng"). Tiêu chí theo thứ tự ưu tiên của bạn: hiệu năng/tài nguyên trước, đẹp sau.

## D1. Thiết kế làm bằng gì, lưu ở đâu (ADR-0015)
| Lựa chọn | Hiệu năng app | Công | Rủi ro 5 năm | Khoá chặt | Ghi chú |
|---|---|---|---|---|---|
| **A. Repo là nguồn; Claude (artifact Design + Design System) để khám phá** | Không ảnh hưởng | Thấp | Thấp | Không: HTML/MD trong repo | **Gợi ý mặc định** |
| B. Figma là nguồn | Không ảnh hưởng | Vừa (thêm công cụ, đồng bộ) | Thấp | Figma | Chỉ khi có designer |
| C. claude.ai/design bản riêng | — | — | **Đóng 14/12/2026** | — | Loại |
| D. Chỉ SwiftUI Preview | Không ảnh hưởng | Thấp | Thấp | Không | Khám phá phương án chậm |
Ảnh hưởng: `docs/design/design-workflow.md`, issue LOS-005.

## D2. UI đọc dữ liệu bằng gì — **ĐÃ CHỐT 01/11 (ADR-0016)**: dùng SQLiteData; Store đọc qua repository (bên trong dùng theo dõi của SQLiteData/GRDB), không `@FetchAll` trong View.
| Lựa chọn | Hiệu năng | Phụ thuộc thêm | Agent quen | Ghi chú |
|---|---|---|---|---|
| **A. `ValueObservation` của GRDB → snapshot → Store** | Rất tốt, kiểm soát hoàn toàn | 0 | Vừa | **Gợi ý mặc định** |
| B. `@FetchAll`/`@FetchOne` của SQLiteData | Rất tốt (cache statement) | +SQLiteData + vài gói Point-Free | Cao (có skill) | Phải chạy được không cần SyncEngine CloudKit — spike LOS-021 |
Ảnh hưởng: ADR-0003, ADR-0007.

## D3. Phiên bản OS tối thiểu (ADR-0010)
| Lựa chọn | Người dùng phủ | Công | Liquid Glass | Ghi chú |
|---|---|---|---|---|
| **A. iOS/macOS 26** | Máy chạy được 26 | Thấp: design đã viết cho 26 | Có | **Gợi ý mặc định** |
| B. iOS/macOS 27 | Ít hơn | Thấp nhất (API mới nhất) | Có | Chỉ khi cần API 27 |
| C. iOS 18 | Nhiều nhất | Cao: phải có nhánh không kính | Không | Đi ngược design |

## D4. Tiêm phụ thuộc (ADR-0007)
| Lựa chọn | Runtime | Phụ thuộc | Agent quen | Ghi chú |
|---|---|---|---|---|
| **A. Qua `init` + một `AppEnvironment`** | 0 | 0 | Cao (Swift thuần) | **Gợi ý mặc định** |
| B. `swift-dependencies` (Point-Free) | ~0 | +1 gói | Cao | Tiện khi số phụ thuộc lớn |

## D5. CI (ADR-0011)
| Lựa chọn | Chi phí/tháng | Phủ | Ghi chú |
|---|---|---|---|
| **A. GitHub Actions Linux (lõi) + Xcode Cloud (app)** | 0 (25 giờ Xcode Cloud có trong gói 99 USD/năm) | Đủ | **Gợi ý mặc định**; cần tài khoản Apple Developer cho phần app |
| B. Chỉ GitHub Actions (cả macOS) | Có thể vượt miễn phí nhanh (phút macOS ×10) | Đủ | |
| C. Chỉ Linux + chạy test app trên máy bạn | 0 | Thiếu kiểm UI tự động | Tạm được cho tới M2 |

## D6. Xcode project
| Lựa chọn | Công cụ thêm | Agent sửa | Xung đột merge | Ghi chú |
|---|---|---|---|---|
| **A. `.xcodeproj` tạo tay, gần như không đổi (mọi code ở gói SPM)** | 0 | Ít khi cần | Hiếm | **Gợi ý mặc định** |
| B. XcodeGen (`project.yml`) | 1 | Dễ | Không | Khi thêm widget/extension làm project hay đổi |
| C. Tuist | 1 | Vừa | Không | Khi build chậm |

## D7. Bốn câu hỏi còn chờ của roadmap
| Câu hỏi | Mặc định repo đang dùng |
|---|---|
| 17 module và phạm vi "Làm gì" | Giữ nguyên; chỉ MVP (5 module + nền) được đặc tả chi tiết |
| Mục tiêu + Dự án lên GĐ2 | Đồng ý; schema đã có `project_id`, `goal_id` |
| Điều hướng: MVP 5 tab, từ GĐ2 tab cuối thành "Thêm" + 3 module ghim | Đồng ý; chỉ ghi trong spec, chưa code |
| Làm 6 hạng mục "mở đường" ngay trong MVP | Đồng ý (scope-mvp.md) |
| 3 điểm học cho màn Hôm nay (việc chính lên đầu, chi tiêu theo số còn lại, câu quá hạn nhẹ hơn) | **Chưa áp dụng**; chờ bạn chọn |

## D8. Giờ đổi ngày (BR-GEN-02)
| Lựa chọn | Đúng với người hay thức khuya | Đơn giản | Ghi chú |
|---|---|---|---|
| **A. 00:00** | Kém (check-in lúc 1 giờ sáng tính sang ngày mới) | Nhất | **Mặc định** |
| B. Mặc định 04:00, chỉnh được | Tốt | Thêm một cài đặt, mọi truy vấn "hôm nay" dùng ngày lệch | Nhiều app thói quen làm vậy |

## D9. Nhật ký: một mục mỗi ngày hay nhiều (BR-JRN-01)
| Lựa chọn | Đồng bộ | UX | Ghi chú |
|---|---|---|---|
| **A. Một mục mỗi ngày (ID theo ngày)** | Hội tụ tự nhiên | Đơn giản, khớp check-in | **Mặc định** |
| B. Nhiều mục mỗi ngày | ID v7, không vấn đề | Linh hoạt hơn | Check-in tâm trạng phải tách bảng riêng |

## D10. Sửa 4 lỗi nhỏ của bộ Ghi nhanh (SPEC-quick-capture §7)
Gợi ý: **sửa cả 4 ở v1.1** (LOS-016) sau khi bản Swift khớp v1. Lỗi đáng kể nhất: "mua sách 120k @1/10" ghi thành khoản chi năm 2027.

## D11. Đặt thư mục code ở đâu trên Mac
| Lựa chọn | Tốc độ build | Rủi ro | Ghi chú |
|---|---|---|---|
| **A. `~/Developer/life-os`** | Tốt | Thấp | **Gợi ý**; Spotlight/Time Machine bình thường |
| B. `~/Downloads/life-os` | Tốt | Dễ bị dọn nhầm | Bộ khung được giao ở đây; nên chuyển sang A |
| C. Trong iCloud Drive / Desktop đồng bộ | **Chậm** (đồng bộ `.build`, `DerivedData`) | Xung đột file | Không nên |

## D12. Repo GitHub
Tên gợi ý `life-os`, **private**. Cần bạn tạo repo (tôi không tạo repo được), rồi chạy `scripts/bootstrap_github.py` hoặc báo tôi tên repo để tôi gắn và tạo issue.
