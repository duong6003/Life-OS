// Kiểm mọi khối ```mermaid trong docs/ parse được. Chạy tay (cần: npm i mermaid@11 playwright):
//   node scripts/check_mermaid.mjs
import { readFileSync, readdirSync, statSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { createRequire } from "node:module";
const require = createRequire(import.meta.url);
const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const walk = d => readdirSync(d).flatMap(f => { const p = join(d, f); return statSync(p).isDirectory() ? walk(p) : p.endsWith(".md") ? [p] : []; });
const blocks = [];
for (const f of walk(join(root, "docs"))) {
  const re = /```mermaid\n([\s\S]*?)```/g; let m;
  const t = readFileSync(f, "utf8");
  while ((m = re.exec(t))) blocks.push({ file: f.slice(root.length + 1), code: m[1] });
}
const { chromium } = require("playwright");
const mermaidPath = require.resolve("mermaid/dist/mermaid.min.js");
const browser = await chromium.launch();
const page = await browser.newPage();
await page.setContent("<html><body></body></html>");
await page.addScriptTag({ path: mermaidPath });
let bad = 0;
for (const [i, b] of blocks.entries()) {
  const err = await page.evaluate(async ([code, id]) => {
    try { mermaid.initialize({ startOnLoad: false }); await mermaid.render("m" + id, code); return null; } catch (e) { return String(e.message || e); }
  }, [b.code, i]);
  if (err) { bad++; console.log(`LỖI ${b.file}: ${err.split("\n").slice(0, 3).join(" | ")}`); }
}
await browser.close();
console.log(`${blocks.length - bad}/${blocks.length} sơ đồ OK`);
process.exit(bad ? 1 : 0);
