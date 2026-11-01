/* Bộ hiểu cú pháp Ghi nhanh.
   cafe 45k → khoản chi · +15tr lương → khoản thu · nộp báo cáo @mai → việc hạn ngày mai · câu khác → việc trong Inbox. */
import { addDays, startOfDay } from "./format";

export type CaptureCategory = { id: string; name: string; kind: "expense" | "income"; keywords: string[]; color: string; icon: string };

export type ParsedMoney = { kind: "expense" | "income"; amount: number; note: string; categoryId: string | null; date: Date };
export type ParsedTask = { kind: "task"; title: string; due: Date | null };
export type Parsed = ParsedMoney | ParsedTask;

/** Bỏ dấu để so từ khóa: “Phở” → “pho” */
export const normalize = (s: string) =>
  s.normalize("NFD").replace(/[̀-ͯ]/g, "").replace(/đ/g, "d").replace(/Đ/g, "D").toLowerCase();

/** 45k · 45.000 · 45000 · 15tr · 1tr2 · 1,5tr · 2 triệu · 45.000₫ */
export function parseAmount(token: string): number | null {
  const t = normalize(token).replace(/[d₫]$/, "");
  let m = t.match(/^(\d+(?:[.,]\d+)?)(k|tr|trieu|m)(\d{1,3})?$/);
  if (m) {
    const base = parseFloat(m[1].replace(",", "."));
    if (m[2] === "k") return m[3] ? null : Math.round(base * 1000);
    let v = base * 1e6;
    if (m[3]) v += (parseInt(m[3], 10) / 10 ** m[3].length) * 1e6;
    return Math.round(v);
  }
  if (/^\d{1,3}(\.\d{3})+$/.test(t)) return parseInt(t.replace(/\./g, ""), 10);
  if (/^\d{4,}$/.test(t)) return parseInt(t, 10);
  return null;
}

const nextWeekday = (today: Date, dow: number, strict = true) => {
  let d = addDays(today, strict ? 1 : 0);
  while (d.getDay() !== dow) d = addDays(d, 1);
  return d;
};

/** @mai · @nay · @kia · @t2…@t7 · @cn · @cuoituan · @tuansau · @15/11 */
export function parseDateToken(token: string, today: Date): Date | undefined {
  const t = normalize(token).replace(/\s/g, "");
  const rel: Record<string, number> = { mai: 1, ngaymai: 1, nay: 0, homnay: 0, kia: 2 };
  if (t in rel) return addDays(today, rel[t]);
  const wd: Record<string, number> = { cn: 0, t2: 1, t3: 2, t4: 3, t5: 4, t6: 5, t7: 6 };
  if (t in wd) return nextWeekday(today, wd[t]);
  if (t === "cuoituan") return nextWeekday(today, 6, false);
  if (t === "tuansau") return nextWeekday(today, 1);
  const m = t.match(/^(\d{1,2})\/(\d{1,2})$/);
  if (m) {
    const d = new Date(today.getFullYear(), +m[2] - 1, +m[1]);
    if (d < today) d.setFullYear(d.getFullYear() + 1);
    return d;
  }
  return undefined;
}

export function guessCategory(note: string, kind: "expense" | "income", categories: CaptureCategory[]): string | null {
  const s = ` ${normalize(note)} `;
  const pool = categories.filter(c => c.kind === kind);
  for (const c of pool) for (const k of c.keywords) if (s.includes(` ${normalize(k)} `)) return c.id;
  return pool.at(-1)?.id ?? null;
}

export function parseQuickCapture(raw: string, opts: { categories: CaptureCategory[]; today?: Date }): Parsed | null {
  const s = raw.trim();
  if (!s) return null;
  const today = startOfDay(opts.today ?? new Date());
  let amount: number | null = null, income = false, date: Date | undefined;
  const rest: string[] = [];
  for (const tk of s.split(/\s+/)) {
    if (amount === null) {
      const inc = tk.startsWith("+");
      const a = parseAmount(inc ? tk.slice(1) : tk);
      if (a) { amount = a; income = inc; continue; }
    }
    if (tk.startsWith("@") && tk.length > 1) {
      const d = parseDateToken(tk.slice(1), today);
      if (d) { date = d; continue; }
    }
    rest.push(tk);
  }
  const text = rest.join(" ");
  if (amount) {
    const kind = income ? "income" : "expense";
    return { kind, amount, note: text, categoryId: guessCategory(text, kind, opts.categories), date: date ?? today };
  }
  if (!text) return null;
  return { kind: "task", title: text, due: date ?? null };
}

/** Gợi ý sửa khi có vẻ người dùng định ghi số tiền nhưng chưa hiểu được (“cafe 45kk”). */
export function amountHint(raw: string): string | null {
  const looksLikeMoney = /(^|\s)\+?\d[\d.,]*\s*(k{2,}|tr\D|[a-zđ]{1,2})(\s|$)/i.test(raw) || /\d+[.,]\d{1,2}(\s|$)/.test(raw);
  const parsed = parseQuickCapture(raw, { categories: [] });
  if (looksLikeMoney && parsed?.kind === "task") return "Chưa hiểu số tiền. Thử “45k” hoặc “45.000”.";
  return null;
}
