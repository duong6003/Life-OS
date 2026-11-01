# Prompt dán sẵn

Dùng được cho cả Codex và Claude Code. Mở công cụ ở gốc repo (`cd ~/workspaces/life-os`), rồi dán nguyên khối prompt. Agent tự đọc AGENTS.md trước.

Làm theo thứ tự P1 → P2 → P3 → P4, sau đó lặp P5 cho từng issue.

---

## P1. Hoàn tất commit đang dở và đẩy lên GitHub

```text
Trong repo này có thay đổi đã stage nhưng chưa commit (hướng dẫn kiến trúc ADR-0017, chuyển sang AGENTS.md, bộ prompt).
0. Nếu có thư mục _setup/ ở gốc repo thì chạy `sh _setup/install.sh` trước (chép .claude/ và .github/, rồi tự xoá _setup).
1. Chạy `git status` và tóm tắt cho tôi những gì sắp commit. Không commit file .env*, .next/, .DS_Store.
2. `git add -A` rồi commit với message: "docs: add sourced architecture guidance and tool-neutral AGENTS.md (ADR-0017)".
3. Nếu hook lefthook báo lỗi:
   - swift-format: chạy `swift format format -i <file>` cho đúng file bị báo rồi commit lại.
   - swiftlint không tải được sourcekitd (máy chưa chọn Xcode): commit lại với `LEFTHOOK_EXCLUDE=swiftlint` và ghi chú cho tôi; không sửa .swiftlint.yml.
   - Lỗi khác: dừng và báo, không dùng --no-verify.
4. `git push -u origin main`.
5. Báo lại: hash commit, kết quả push, và còn hook nào bị bỏ qua.
```

## P2. Kiểm và chuẩn bị môi trường máy Mac

Cần làm trước: cài Xcode 26 từ App Store (agent không cài được).

```text
Kiểm môi trường để code Life OS, theo README.md (mục Yêu cầu) và docs/engineering/code-quality.md. Không dùng sudo; lệnh nào cần sudo thì in ra để tôi tự chạy.
1. `xcode-select -p` và `xcodebuild -version`. Nếu đang trỏ CommandLineTools mà có /Applications/Xcode.app thì in lệnh `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer` cho tôi chạy, rồi đợi tôi báo xong.
2. `swift --version` (cần Swift 6.2+), `python3 --version` (3.11+), `gh auth status`.
3. Cài công cụ nếu thiếu: `brew install swiftlint periphery lefthook`, rồi `lefthook install`.
4. Chạy lần lượt và báo kết quả từng lệnh: swiftlint lint --strict; swift format lint -r Packages; bash scripts/check-core-imports.sh; python3 -I scripts/check_structure.py; python3 -I scripts/inventory.py --check; python3 -I design/tokens/generate.py --check; python3 -I reference/run_all.py --check; python3 -I scripts/plan_graph.py --check.
5. Đây là lần đầu SwiftLint chạy thật với .swiftlint.yml. Nếu có lỗi cấu hình (luật không tồn tại, regex sai) thì sửa cấu hình cho đúng ý luật, không hạ luật. Nếu có vi phạm trong code hiện có thì liệt kê, chưa sửa.
6. Tóm tắt bằng tiếng Việt: cái gì đã sẵn sàng, cái gì tôi cần làm tay. Nếu có sửa file thì tạo nhánh chore/env-setup và mở PR.
```

## P3. Duyệt các quyết định mặc định D1–D12 cùng tôi

```text
Mở docs/decisions-open.md. Mỗi mục D1–D12 đang có một mặc định đã chọn sẵn. Duyệt cùng tôi từng mục một, đừng gộp:
1. Với mỗi mục: tóm tắt trong 3 dòng (đang chọn gì, vì sao, ảnh hưởng tới issue nào), rồi đưa bảng so sánh các lựa chọn theo tiêu chí: công sức, rủi ro, chi phí đổi về sau, hợp với ưu tiên "mượt và tiết kiệm trước, đẹp sau". Trích nguồn chính thức nếu có (theo luật trong docs/architecture/references.md).
2. Hỏi tôi: giữ mặc định hay đổi. Chờ tôi trả lời rồi mới sang mục sau.
3. Mục đã chốt: ghi "ĐÃ CHỐT <ngày>: <lựa chọn>" vào decisions-open.md; nếu đổi so với mặc định thì sửa ADR, issue và tài liệu liên quan cho khớp, và chạy python3 -I scripts/plan_graph.py --check.
4. Xong hết: tạo nhánh docs/decisions-d1-d12, commit, mở PR, tóm tắt các mục đã đổi.
D2 đã chốt (ADR-0016), bỏ qua. D10 là LOS-016, để P4 làm.
```

## P4. LOS-016: sửa 4 lỗi của bộ Ghi nhanh

```text
Đọc docs/specs/SPEC-quick-capture.md §7 và docs/plan/issues/LOS-016-*.md. Giải thích cho tôi 4 lỗi bằng ví dụ cụ thể (câu gõ vào → kết quả hiện tại → kết quả đúng), rồi hỏi tôi đồng ý sửa cả 4 hay chỉ một phần.
Sau khi tôi đồng ý: làm theo docs/agents/workflows/implement-issue.md cho LOS-016. Thứ tự bắt buộc: sửa code tham chiếu (design/reference/code/quick-capture.ts và reference/) → nâng SPEC lên 1.1 → chạy python3 reference/run_all.py để sinh lại vector → rồi mới sửa Swift. Không sửa vector bằng tay. Nếu LOS-015 chưa xong thì chỉ làm phần spec, tham chiếu và vector, và ghi rõ trong PR.
```

## P5. Làm một issue (lặp lại cho mỗi issue)

```text
Làm theo docs/agents/workflows/implement-issue.md cho LOS-002.
```

Thứ tự gợi ý trong `docs/plan/roadmap-graph.md`:
- Tuần 1: LOS-002 → 003 → 004.
- Tuần 2–3: 010 → 011, 015 → 021 (spike: đối chiếu luật CloudKit của SQLiteData với bài gốc) → 020 → 024, 022 → cổng 025.
- Sau đó là các màn MVP: 035 → 040–047.

Với Claude Code có thể gõ ngắn: `/implement-issue LOS-002`.

Mẹo: mỗi issue một phiên mới, để agent không mang ngữ cảnh cũ sang.

## P6. Viết spec một màn

```text
Làm theo docs/agents/workflows/screen-spec.md cho màn tasks.
```

## P7. Xem lại một PR do agent khác làm

```text
Xem PR #<số> (gh pr view <số> --comments; gh pr diff <số>). Đối chiếu với AGENTS.md, ADR liên quan, docs/architecture/overview.md và tiêu chí nghiệm thu của issue. Liệt kê vấn đề theo mức nặng (chặn merge / nên sửa / gợi ý), mỗi vấn đề có file:dòng và lý do kèm nguồn. Không tự sửa; hỏi tôi trước.
```

Dùng P7 khi một agent làm (ví dụ Codex) và agent kia xem lại (ví dụ Claude Code), để hai công cụ soát chéo nhau.
