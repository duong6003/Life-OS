# Agent: dùng chung cho Codex, Claude Code và công cụ khác

Repo không phụ thuộc một công cụ nào. Luật nằm trong **AGENTS.md**, quy trình nằm trong `docs/agents/workflows/`, prompt dán sẵn nằm trong [prompts.md](prompts.md). Công cụ nào cũng chỉ cần đọc các file này.

## Cấu trúc

```
AGENTS.md                          Luật gốc (mọi agent đọc)
CLAUDE.md                          Chỉ có "@AGENTS.md" + vài dòng riêng Claude Code
Packages/<Gói>/AGENTS.md           Luật riêng của gói
Packages/<Gói>/CLAUDE.md           Chỉ có "@AGENTS.md"
docs/agents/workflows/*.md         Quy trình: implement-issue, screen-spec
docs/agents/prompts.md             Prompt dán sẵn cho từng việc
.claude/commands/*.md              Lối tắt cho Claude Code, chỉ trỏ tới workflows/
```

## Vì sao làm như vậy (nguồn)

| Điều | Nguồn |
|---|---|
| AGENTS.md là "README cho agent", đặt ở gốc repo; mỗi gói có thể có AGENTS.md riêng, file gần nhất được ưu tiên; prompt của người dùng thắng tất cả | [agents.md](https://agents.md/): "Agents automatically read the nearest file in the directory tree, so the closest one takes precedence." |
| Codex đọc AGENTS.md từ gốc Git xuống tới thư mục đang chạy, nối lại, file gần hơn đứng sau nên được ưu tiên; tổng tối đa 32 KiB (`project_doc_max_bytes`) | [Codex: Custom instructions with AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md) |
| Claude Code mặc định chỉ đọc AGENTS.md khi **không có** CLAUDE.md; CLAUDE.md import được file khác bằng `@path` | [Claude Code: memory](https://code.claude.com/docs/en/memory): "By default, Claude reads AGENTS.md only when you have no CLAUDE.md…"; "CLAUDE.md files can import additional files using `@path/to/import` syntax." |
| CLAUDE.md trong thư mục con được nạp khi Claude đọc hoặc sửa file trong thư mục đó | Như trên: "Claude Code loads each one once Claude reads, writes, or edits another file in that subdirectory." |
| Prompt tuỳ chỉnh của Codex chỉ ở `~/.codex/prompts` của từng máy, không chia sẻ qua repo, và đã bị đánh dấu deprecated | [Codex: Custom Prompts](https://learn.chatgpt.com/docs/custom-prompts) |
| `.claude/commands/<tên>.md` tạo lệnh `/<tên>`; `$ARGUMENTS` là phần chữ gõ sau lệnh | [Claude Code: skills](https://code.claude.com/docs/en/slash-commands) |

Hệ quả: quy trình viết thành file Markdown thường trong repo. Với Codex, bạn dán một câu trong prompts.md ("Làm theo docs/agents/workflows/implement-issue.md cho LOS-002"). Với Claude Code, gõ `/implement-issue LOS-002` cũng ra đúng quy trình đó.

## Luật giữ cho đồng bộ
- Chỉ sửa luật trong `AGENTS.md`. `CLAUDE.md` không chứa luật riêng (trừ phần "Riêng cho Claude Code").
- AGENTS.md gốc cộng các AGENTS.md của gói phải dưới 32 KiB (giới hạn mặc định của Codex). Hiện khoảng 12 KB.
- Codex chạy ở gốc repo sẽ **không** tự nạp `Packages/<Gói>/AGENTS.md` (nó chỉ đi từ gốc xuống thư mục đang chạy). Vì vậy AGENTS.md gốc yêu cầu đọc file của gói trước khi sửa trong gói đó.

## Dùng Codex
```sh
cd ~/workspaces/life-os
codex            # tự đọc AGENTS.md
```
Sau đó dán prompt từ [prompts.md](prompts.md).

## Dùng Claude Code
```sh
cd ~/workspaces/life-os
claude           # đọc CLAUDE.md → @AGENTS.md
```
Gõ `/implement-issue LOS-002`, hoặc dán prompt giống hệt bên Codex.

## Hai agent cùng làm
Mỗi agent một issue, một nhánh `los-<số>-<slug>`, một PR. Không cho hai agent sửa cùng nhánh. Muốn chạy song song trên một máy thì dùng `git worktree add ../life-os-los-020 -b los-020-…` để mỗi agent có thư mục riêng.
