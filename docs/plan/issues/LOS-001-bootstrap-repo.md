---
id: LOS-001
title: "Đưa bộ khung lên GitHub và tạo issue"
milestone: "M0 Nền móng"
labels: [type:chore, area:ci]
depends_on: []
size: S
---

## Mục tiêu
Repo private trên GitHub có toàn bộ bộ khung, issue và milestone.

## Việc cần làm
- [ ] Chép thư mục sang ~/Developer/life-os (decisions-open D11)
- [ ] git init, commit đầu, push lên repo private
- [ ] `python3 scripts/bootstrap_github.py --repo <user>/life-os --apply`
- [ ] Bật branch protection cho main (cần PR + check `checks` và `core-swift`)

## Tiêu chí nghiệm thu
- [ ] Repo có đủ thư mục như README
- [ ] Có 7 milestone, đủ nhãn, ~45 issue có quan hệ blocked-by
- [ ] `scripts/.issue-map.json` được commit

## Tham chiếu
- docs/engineering/workflow.md §1

## Phụ thuộc
Không có
