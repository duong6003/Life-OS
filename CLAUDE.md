# CLAUDE.md

Luật chung cho mọi agent nằm trong AGENTS.md (chuẩn agents.md, Codex và các công cụ khác cùng đọc). File này chỉ import nó, theo cú pháp `@path` của Claude Code.

@AGENTS.md

## Riêng cho Claude Code
- Lệnh `/implement-issue <LOS-xxx>` và `/screen-spec <màn>` (trong `.claude/commands/`) chỉ là lối tắt tới `docs/agents/workflows/`.
- MCP cho Xcode: docs/engineering/code-quality.md §5.
- Không thêm luật vào file này. Luật mới viết vào AGENTS.md để Codex cũng thấy.
