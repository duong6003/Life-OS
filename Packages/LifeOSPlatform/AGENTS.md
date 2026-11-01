# AGENTS.md — LifeOSPlatform
Luật riêng của gói, bổ sung cho AGENTS.md ở gốc repo.
Adapter chỉ có trên Apple. Mỗi adapter cài một protocol đã có trong LifeOSCore; không thêm logic nghiệp vụ ở đây.
- `CryptoApple` phải qua `TestVectors/envelope` và `recovery-code` byte-chính-xác.
- `CloudKitTransport`: tuân SPEC-sync §7; change token chỉ lưu sau khi dữ liệu đã ghi.
