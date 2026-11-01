// Sinh TestVectors/quick-capture/cases.json bằng CHÍNH bộ hiểu TypeScript đã duyệt (design/reference/code/quick-capture.ts).
// Chạy: TZ=Asia/Ho_Chi_Minh node --experimental-strip-types reference/gen_quick_capture.mjs [--check]
import { readFileSync, writeFileSync, mkdtempSync, copyFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const work = mkdtempSync(join(tmpdir(), "qc-"));
copyFileSync(join(root, "design/reference/code/format.ts"), join(work, "format.ts"));
const src = readFileSync(join(root, "design/reference/code/quick-capture.ts"), "utf8").replace('from "./format"', 'from "./format.ts"');
writeFileSync(join(work, "quick-capture.ts"), src);
const qc = await import(join(work, "quick-capture.ts"));

const categories = [
  { id: "food", name: "Ăn uống", kind: "expense", keywords: ["cafe", "cà phê", "phở", "bún", "cơm", "ăn", "trà sữa"], color: "", icon: "" },
  { id: "transport", name: "Đi lại", kind: "expense", keywords: ["grab", "xăng", "taxi", "gửi xe"], color: "", icon: "" },
  { id: "bills", name: "Hoá đơn", kind: "expense", keywords: ["điện", "nước", "internet"], color: "", icon: "" },
  { id: "other-expense", name: "Khác", kind: "expense", keywords: [], color: "", icon: "" },
  { id: "salary", name: "Lương", kind: "income", keywords: ["lương"], color: "", icon: "" },
  { id: "other-income", name: "Khác", kind: "income", keywords: [], color: "", icon: "" },
];
const today = new Date(2026, 9, 30); // Thứ Sáu 30/10/2026
const ymd = d => `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;

const inputs = [
  "cafe 45k", "Cà phê 45k", "phở bò 60.000", "grab 32k @hôm qua", "+15tr lương", "+15tr", "45000 tiền điện",
  "trà sữa 1,5k", "xăng 1tr2", "học phí 2tr05 @15/11", "mua sách 120k @1/10", "1k5 bánh", "cafe 45", "cafe 45kk",
  "nộp báo cáo @mai", "nộp báo cáo @nay", "gọi mẹ @kia", "họp nhóm @t2", "đi chợ @t6", "dọn nhà @cn", "đi chơi @cuoituan",
  "lên kế hoạch @tuansau", "khám răng @15/11", "trả sách @1/10", "viết @abc", "@mai", "45k", "   ", "", "2 triệu tiền nhà",
  "mua 2 vé 300k @t7", "nạp điện thoại 100.000đ", "tiền nước 85.000₫", "thưởng +2tr", "+500k bán đồ cũ", "1.250.000 internet",
  "cafe 45k cafe 50k", "a @mai @t2", "Phở 50K", "ĐI GRAB 20K", "điện 1,2tr", "đọc 20 trang sách", "chạy 5km", "uống 2l nước",
];
const cases = inputs.map(input => {
  const p = qc.parseQuickCapture(input, { categories, today });
  let expect = null;
  if (p) expect = p.kind === "task" ? { kind: "task", title: p.title, due: p.due ? ymd(p.due) : null }
    : { kind: p.kind, amount: p.amount, note: p.note, categoryId: p.categoryId, date: ymd(p.date) };
  return { input, expect, hint: qc.amountHint(input) };
});
const amounts = ["45k", "45K", "1,5k", "15tr", "1tr2", "2tr05", "1,5tr", "2m", "2trieu", "45.000", "1.250.000", "45000", "45", "1k5", "45.000đ", "45.000₫", "12.34", "abc"]
  .map(token => ({ token, expect: qc.parseAmount(token) }));
const normalize = ["Phở", "Đi GRAB", "Trà Sữa", "Ể Ặ Ỗ", "đường"].map(input => ({ input, expect: qc.normalize(input) }));
const out = JSON.stringify({
  spec: "SPEC-quick-capture v1", source: "design/reference/code/quick-capture.ts", today: ymd(today), timezone: "local",
  categories: categories.map(({ color, icon, ...c }) => c), parse: cases, parseAmount: amounts, normalize,
}, null, 2) + "\n";
const target = join(root, "TestVectors/quick-capture/cases.json");
if (process.argv.includes("--check")) {
  const cur = readFileSync(target, "utf8");
  if (cur !== out) { console.error("quick-capture vectors are stale"); process.exit(1); }
  console.log("quick-capture vectors OK");
} else { writeFileSync(target, out); console.log("wrote quick-capture/cases.json"); }
