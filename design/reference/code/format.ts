/* Định dạng theo phần E của brief. Mọi chữ hiển thị số, tiền, ngày đi qua file này. */

const dec1 = (x: number) => (Math.round(x * 10) / 10).toString().replace(".", ",");

/** Tiền đầy đủ: 1.250.000₫ */
export function vnd(n: number): string {
  return `${Math.round(n).toLocaleString("vi-VN")}₫`;
}

/** Tiền rút gọn cho biểu đồ, thẻ nhỏ: 45k · 1,2tr · 2,5 tỷ */
export function vndShort(n: number): string {
  const a = Math.abs(n);
  const s = a >= 1e9 ? `${dec1(a / 1e9)} tỷ` : a >= 1e6 ? `${dec1(a / 1e6)}tr` : a >= 1e3 ? `${Math.round(a / 1e3)}k` : `${a}₫`;
  return n < 0 ? `-${s}` : s;
}

/** Khoản thu có dấu +, khoản chi không dấu. Màu do component quyết định (positive / text). */
export function signedAmount(n: number, kind: "income" | "expense", short = false): string {
  const s = short ? vndShort(Math.abs(n)) : vnd(Math.abs(n));
  return kind === "income" ? `+${s}` : s;
}

/** Phần trăm: số nguyên, không khoảng trắng: 82% */
export const percent = (ratio: number) => `${Math.round(ratio * 100)}%`;

export const WEEKDAY_SHORT = ["CN", "T2", "T3", "T4", "T5", "T6", "T7"] as const;
export const WEEKDAY_LONG = ["Chủ nhật", "Thứ Hai", "Thứ Ba", "Thứ Tư", "Thứ Năm", "Thứ Sáu", "Thứ Bảy"] as const;
/** Thứ tự hiển thị, tuần bắt đầu thứ Hai */
export const WEEK_ORDER = [1, 2, 3, 4, 5, 6, 0] as const;

export const startOfDay = (d: Date) => new Date(d.getFullYear(), d.getMonth(), d.getDate());
export const addDays = (d: Date, n: number) => new Date(d.getFullYear(), d.getMonth(), d.getDate() + n);
export const sameDay = (a: Date | null | undefined, b: Date | null | undefined) =>
  !!a && !!b && startOfDay(a).getTime() === startOfDay(b).getTime();
export const startOfWeek = (d: Date) => addDays(startOfDay(d), -((d.getDay() + 6) % 7));
const dayDiff = (a: Date, b: Date) => Math.round((startOfDay(a).getTime() - startOfDay(b).getTime()) / 864e5);

/** Ngày ngắn: T5, 29/10 */
export const shortDate = (d: Date) => `${WEEKDAY_SHORT[d.getDay()]}, ${d.getDate()}/${d.getMonth() + 1}`;

/** Ngày đầy đủ: Thứ Năm, 29 tháng 10 */
export const fullDate = (d: Date) => `${WEEKDAY_LONG[d.getDay()]}, ${d.getDate()} tháng ${d.getMonth() + 1}`;

/** Giờ 24h: 21:30 */
export const time24 = (d: Date) => `${d.getHours()}:${String(d.getMinutes()).padStart(2, "0")}`;

/** Ngày tương đối cho 7 ngày quanh hôm nay, ngoài khoảng đó dùng ngày ngắn. */
export function relativeDate(d: Date, today = new Date()): string {
  const diff = dayDiff(d, today);
  if (diff === 0) return "Hôm nay";
  if (diff === 1) return "Ngày mai";
  if (diff === -1) return "Hôm qua";
  if (diff > 1 && diff < 7) {
    const sameWeek = startOfWeek(d).getTime() === startOfWeek(today).getTime();
    return sameWeek ? WEEKDAY_LONG[d.getDay()] : `${WEEKDAY_LONG[d.getDay()]} tới`;
  }
  return shortDate(d);
}

/** Tiêu đề nhóm trong Sắp tới: “T7, 31/10 · Ngày mai” */
export function dayGroupLabel(d: Date, today = new Date()): string {
  const rel = relativeDate(d, today);
  const add = rel === "Hôm nay" || rel === "Ngày mai" || rel === "Hôm qua" || rel.endsWith(" tới");
  return add ? `${shortDate(d)} · ${rel}` : shortDate(d);
}

/** Tuần 26/10 – 1/11 */
export function weekLabel(anyDay: Date): string {
  const s = startOfWeek(anyDay), e = addDays(s, 6);
  return `Tuần ${s.getDate()}/${s.getMonth() + 1} – ${e.getDate()}/${e.getMonth() + 1}`;
}

/** Tháng 10, 2026 */
export const monthLabel = (d: Date) => `Tháng ${d.getMonth() + 1}, ${d.getFullYear()}`;

/** Lời chào theo buổi */
export function greeting(name: string, now = new Date()): string {
  const h = now.getHours();
  const part = h < 11 ? "sáng" : h < 14 ? "trưa" : h < 18 ? "chiều" : "tối";
  return `Chào buổi ${part}, ${name}`;
}
