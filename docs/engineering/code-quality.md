# Chất lượng code: công cụ kiểm và skill cho agent

Người dùng chọn ngày 01/11/2026: dùng SwiftLint, Periphery, skill cho agent và hook trước commit. Tất cả đều miễn phí và chạy được với repo private. SonarQube Cloud thêm sau, khi repo chuyển sang public hoặc khi cần SAST (xem §4).

Mỗi công cụ lo một việc riêng, không chồng nhau:

| Lớp | Công cụ | Bắt gì | Chạy ở đâu | Cấu hình |
|---|---|---|---|---|
| Định dạng | `swift format` (đi kèm toolchain) | Thụt lề, xuống dòng, thứ tự import, cấm `!` và `try!` | lefthook, CI | `.swift-format` |
| Luật code | [SwiftLint](https://github.com/realm/SwiftLint) 0.65.1 | Hơn 30 luật bật thêm (an toàn, hiệu năng, trợ năng) và 11 luật riêng của Life OS | lefthook, CI job `lint` (Linux) | `.swiftlint.yml` |
| Code thừa | [Periphery](https://github.com/peripheryapp/periphery) | Hàm, thuộc tính, tham số, `public` và import không ai dùng | macOS, Xcode Cloud (LOS-060) | `.periphery.yml` |
| Kiến trúc | `scripts/check-core-imports.sh` | Ranh giới module, `SyncEngine` chỉ ở CloudSync | lefthook, CI | trong script |
| Hợp đồng | `reference/run_all.py`, `generate.py --check`, `plan_graph.py --check`, so schema | Test vector, token, graph issue, bản sao schema | lefthook, CI | — |
| Commit | lefthook `commit-msg` | Đúng mẫu `type(scope): mô tả (LOS-xxx)` | lefthook | `lefthook.yml` |

## 1. Cài một lần trên Mac

```sh
brew install swiftlint periphery lefthook
lefthook install            # gắn hook vào .git/hooks
swiftlint lint --strict     # lần chạy đầu: sửa hết lỗi trước khi mở PR đầu tiên (LOS-004)
```

Lần đầu chạy, SwiftLint có thể báo lỗi ở code design system cũ, vì phần đó viết trước khi có luật. Sửa các lỗi này trong LOS-004. Không được hạ luật xuống cho vừa với code cũ.

## 2. Luật riêng của Life OS trong `.swiftlint.yml`

Các luật này lấy từ `CLAUDE.md` và ADR. Nhờ có chúng, agent bị chặn tự động thay vì phải chờ người review nhắc.

| Luật | Cấm | Vì sao |
|---|---|---|
| `no_any_view` | `AnyView` | Hiệu năng, CLAUDE.md luật 9 |
| `no_try_force` | `try!` ngoài test | Lỗi phải có kiểu |
| `no_repeat_forever`, `no_timeline_animation` | Animation chạy mãi | Pin, performance-budget.md |
| `no_formatter_in_body` | `DateFormatter()`… tạo tại chỗ | Dùng `FormatterCache` |
| `no_shared_singleton` | `static let shared` | Tiêm qua init, ADR-0007 |
| `no_print` | `print`, `dump` | Dùng Logger, không log nội dung người dùng |
| `no_user_defaults_for_data` | `UserDefaults.standard` | Dữ liệu nằm trong SQLite (cảnh báo) |
| `no_sync_engine_outside_cloudsync` | `SyncEngine` ngoài CloudSync/AppFeature | ADR-0016 |
| `no_fetch_all_in_features` | `@FetchAll`/`@FetchOne` trong Feature | ADR-0016 |
| `todo_needs_issue` | `TODO` không kèm `(LOS-xxx)` | Không để việc treo (cảnh báo) |

Ngưỡng độ lớn:
- hàm tối đa 40 dòng (cảnh báo) và 80 dòng (lỗi);
- type tối đa 200 và 300 dòng;
- file tối đa 300 và 500 dòng;
- độ phức tạp tối đa 10 và 15;
- tối đa 5 tham số.

Tắt một luật phải dùng `// swiftlint:disable:next <luật>` và ghi lý do ngay cạnh. Không được tắt cả file.

## 3. Skill cho agent

Skill là hướng dẫn mà agent tự nạp khi làm đúng loại việc. Có bốn skill được chọn:

- **`mattpocock-skills`** ([mattpocock/skills](https://github.com/mattpocock/skills)): quy trình phỏng vấn → spec → ticket → TDD → review. Bắt đầu thẳng từ `implement` với issue LOS có sẵn. Khi chạy `/setup-matt-pocock-skills`, trỏ ADR về `docs/architecture/adr` và glossary về `docs/product/glossary.md`.
- **`swiftui-pro`** ([twostraws/SwiftUI-Agent-Skill](https://github.com/twostraws/SwiftUI-Agent-Skill), Paul Hudson): viết SwiftUI hiện đại, tránh API cũ, hiệu năng `@Observable`, trợ năng.
- **Swift Concurrency Pro** ([twostraws/Swift-Concurrency-Agent-Skill](https://github.com/twostraws/Swift-Concurrency-Agent-Skill)): Swift 6 strict concurrency, actor, `Sendable`.
- **Swift Testing Pro** ([twostraws/Swift-Testing-Agent-Skill](https://github.com/twostraws/Swift-Testing-Agent-Skill)): `import Testing`, `#expect`, test tham số hoá.

Danh sách đầy đủ do cộng đồng giữ: [twostraws/Swift-Agent-Skills](https://github.com/twostraws/Swift-Agent-Skills). Không cài skill SwiftData, vì Life OS không dùng SwiftData.

Lệnh cài (gõ trong Claude Code, ở thư mục repo):

```
claude plugin install mattpocock-skills@claude-plugins-official
/plugin marketplace add twostraws/SwiftUI-Agent-Skill
/plugin install swiftui-pro@swiftui-agent-skill
```

Hai skill Concurrency và Testing cài theo README của từng repo, theo cùng mẫu `/plugin marketplace add twostraws/<repo>`. Hoặc cài cho mọi agent bằng `npx skills add https://github.com/twostraws/<repo>`. Tôi mới kiểm chính xác lệnh cài của `swiftui-pro`; lệnh của các skill khác cần xem lại README trước khi chạy.

Ba quy tắc khi dùng skill:
1. **Đọc SKILL.md trước khi cài.** Skill là nội dung bên thứ ba, chạy với quyền của agent.
2. **Khi skill nói khác `CLAUDE.md` hay ADR, repo thắng.** Ví dụ: skill gợi ý dùng `@FetchAll` trong View thì vẫn theo ADR-0016.
3. **Không commit skill vào repo.** Mỗi người tự cài. Danh sách skill được chọn nằm ở file này.

## 4. Để sau: SonarQube Cloud

[Analyzer Swift mới](https://docs.sonarsource.com/sonarqube-cloud/analyzing-source-code/languages/swift) hỗ trợ Swift 6.2 và SwiftUI, có 22 luật SAST, bắt code trùng, và đặt cổng chất lượng trên PR. Miễn phí cho repo public. Thêm khi repo public hoặc trước beta (LOS-065), nếu muốn có quét bảo mật.
