# Life OS

App quản lý cuộc sống cá nhân, **local-first**: dữ liệu nằm trong máy, đồng bộ qua iCloud của chính người dùng, mã hoá đầu-cuối, không có máy chủ riêng. Bản đầu tiên cho iPhone, iPad, Mac (SwiftUI). Android làm sau theo spec và test vector trong repo này.

Thứ tự ưu tiên cho mọi quyết định: **(1) mượt và tiết kiệm tài nguyên (RAM, pin, dung lượng), (2) đẹp và hiệu ứng tốt.**

## Bắt đầu nhanh (máy Mac)

```sh
# 1. Lõi thuần Swift: build & test không cần simulator
cd Packages/LifeOSCore && swift test

# 2. Kiểm tra token design còn khớp với file sinh ra
python3 design/tokens/generate.py --check

# 3. Test vector có khớp với code tham chiếu không
python3 -I reference/run_all.py --check

# 4. App: mở App/LifeOS.xcodeproj (tạo ở issue LOS-003) rồi Run
```

Yêu cầu: Xcode 26.x trở lên (Swift 6.2+), macOS 26, Python 3.11+ (chỉ để chạy script và code tham chiếu), `gh` CLI để tạo issue.

## Đọc gì trước

| Bạn là | Đọc |
|---|---|
| Người mới (hoặc agent) | [`CLAUDE.md`](CLAUDE.md) → [`docs/README.md`](docs/README.md) |
| Viết tính năng | [`docs/architecture/module-structure.md`](docs/architecture/module-structure.md), [`docs/engineering/conventions.md`](docs/engineering/conventions.md), [`docs/product/business-rules.md`](docs/product/business-rules.md) |
| Đụng tới dữ liệu / đồng bộ / mã hoá | [`docs/architecture/data-model.md`](docs/architecture/data-model.md), [`docs/specs/SPEC-sync.md`](docs/specs/SPEC-sync.md), [`docs/specs/SPEC-crypto.md`](docs/specs/SPEC-crypto.md) |
| Làm giao diện | [`docs/design/design-workflow.md`](docs/design/design-workflow.md), [`design/README.md`](design/README.md) |
| Lập kế hoạch | [`docs/plan/roadmap-graph.md`](docs/plan/roadmap-graph.md), [`docs/plan/issues/`](docs/plan/issues) |

## Cấu trúc thư mục

```
life-os/
├── CLAUDE.md                 Luật cho agent code (đọc trước khi sửa gì)
├── App/                      Xcode project mỏng: chỉ @main, Info.plist, entitlements, asset icon
├── Packages/
│   ├── LifeOSCore/           Swift thuần, build được trên Linux/Android: Domain, Capture, SyncCore, CryptoCore, Persistence
│   ├── LifeOSPlatform/       Adapter chỉ có trên Apple: CryptoKit, Keychain, CloudKit, thông báo, tác vụ nền
│   ├── LifeOSDesignSystem/   Token + component SwiftUI (sinh từ design/tokens)
│   └── LifeOSFeatures/       Màn hình theo tính năng + AppFeature ghép mọi thứ
├── design/                   Nguồn sự thật về thiết kế: tokens.json, bản tham chiếu Screens/Library
├── docs/                     Kiến trúc, ADR, spec, business rule, test case, plan
├── TestVectors/              JSON trung lập ngôn ngữ: Swift và Kotlin đều phải qua
├── reference/                Code tham chiếu (Python) sinh và kiểm test vector
├── scripts/                  Tạo issue GitHub, kiểm ranh giới module, vẽ graph plan
└── .github/                  CI (Linux), mẫu issue, mẫu PR
```

## Trạng thái

Repo này là **bộ khung + tài liệu** (ngày 01/11/2026). Code Swift trong `Packages/` là khung rỗng có chủ đích, **chưa được build** vì máy soạn không có Swift; build đầu tiên là issue LOS-002. Gói `LifeOSDesignSystem` đã có code nhưng cũng chưa build lần nào.
