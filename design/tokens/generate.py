#!/usr/bin/env python3
"""Sinh token cho SwiftUI và web từ design/tokens/tokens.json.

  python3 design/tokens/generate.py            # ghi file
  python3 design/tokens/generate.py --check    # chỉ kiểm, báo lỗi nếu file sinh ra đã cũ

Đầu ra:
  LifeOSDesignSystem/Sources/DesignSystem/Resources/Tokens.xcassets/<tên>.colorset
  LifeOSDesignSystem/Sources/DesignSystem/Generated/Tokens.swift
  design/tokens/build/tokens.css
"""
import json, os, re, sys, shutil

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))  # gốc repo
T = json.load(open(os.path.join(ROOT, 'design', 'tokens', 'tokens.json')))
PKG = os.path.join(ROOT, 'Packages', 'LifeOSDesignSystem', 'Sources', 'DesignSystem')
files = {}

def camel(k):
    k = k.replace('.', '_')
    parts = re.split(r'-', k)
    s = parts[0] + ''.join(p[:1].upper() + p[1:] for p in parts[1:])
    return 'x' + s if s[0].isdigit() else s

def components(v):
    """'#RRGGBB' hoặc 'rgba(r, g, b, a)' → (r, g, b, a) dạng chuỗi thập phân cho colorset."""
    if v.startswith('#'):
        h = v.lstrip('#'); r, g, b = (int(h[i:i + 2], 16) for i in (0, 2, 4)); a = 1.0
    else:
        r, g, b, a = (float(x) for x in re.findall(r'[\d.]+', v)); r, g, b = int(r), int(g), int(b)
    return {'red': f'0x{r:02X}', 'green': f'0x{g:02X}', 'blue': f'0x{b:02X}', 'alpha': f'{a:.3f}'}

# ---- colorset
xc = os.path.join(PKG, 'Resources', 'Tokens.xcassets')
files[os.path.join(xc, 'Contents.json')] = json.dumps({'info': {'author': 'xcode', 'version': 1}}, indent=2) + '\n'
for k, c in T['color'].items():
    entries = []
    for mode, appearance, contrast in (('light', None, None), ('dark', 'dark', None), ('lightHC', None, 'high'), ('darkHC', 'dark', 'high')):
        if mode not in c: continue
        e = {'color': {'color-space': 'srgb', 'components': components(c[mode])}, 'idiom': 'universal'}
        app = []
        if appearance: app.append({'appearance': 'luminosity', 'value': appearance})
        if contrast: app.append({'appearance': 'contrast', 'value': contrast})
        if app: e['appearances'] = app
        entries.append(e)
    files[os.path.join(xc, camel(k) + '.colorset', 'Contents.json')] = json.dumps({'colors': entries, 'info': {'author': 'xcode', 'version': 1}}, indent=2) + '\n'

# ---- Swift
L = ['// swift-format-ignore-file', '// Sinh tự động từ design-tokens/tokens.json bởi design-tokens/generate.py. Đừng sửa tay.', '// swift-format bỏ qua file này: tên token (s0_5…) theo tokens.json, và định dạng lại sẽ làm --check báo cũ.', '', 'import SwiftUI', '']
L += ['/// Màu token. Mỗi màu là một colorset có biến thể Light, Dark và (nếu có) Increase Contrast,', '/// nên hệ thống tự đổi theo giao diện mà không cần rẽ nhánh lúc chạy.', 'public enum LifeOSColor {']
for k, c in T['color'].items():
    L.append(f'    /// {c["usage"]}')
    L.append(f'    public static let {camel(k)} = Color("{camel(k)}", bundle: .module)')
L += ['}', '']
L += ['/// Độ đậm dùng chung (Light / Dark).', 'public enum LifeOSOpacity {']
for k, o in T['opacity'].items():
    L.append(f'    /// {o["usage"]}')
    L.append(f'    public static func {camel(k)}(_ scheme: ColorScheme) -> Double {{ scheme == .dark ? {o["dark"]} : {o["light"]} }}')
L += ['}', '']
L += ['/// Lưới 4pt.', 'public enum Space {']
for k, v in T['spacing'].items():
    L.append(f'    public static let {"s" + k.replace(".", "_")}: CGFloat = {v}')
L += ['}', '']
lay = T['layout']
L += ['/// Lớp bố cục: iPhone (compact), iPad (regular), Mac.', 'public enum LayoutClass: Sendable { case compact, regular, mac }', '',
      '/// Bố cục theo nền tảng.', 'public enum Layout {',
      f'    /// {lay["gutter"]["usage"]}',
      f'    public static func gutter(_ c: LayoutClass) -> CGFloat {{ switch c {{ case .compact: {lay["gutter"]["compact"]}; case .regular: {lay["gutter"]["regular"]}; case .mac: {lay["gutter"]["mac"]} }} }}',
      f'    /// {lay["card-pad"]["usage"]}',
      f'    public static func cardPadding(_ c: LayoutClass) -> CGFloat {{ switch c {{ case .compact: {lay["card-pad"]["compact"]}; case .regular: {lay["card-pad"]["regular"]}; case .mac: {lay["card-pad"]["mac"]} }} }}',
      f'    public static let blockGap: CGFloat = {lay["block-gap"]["all"]}',
      f'    public static let hit: CGFloat = {lay["hit"]["all"]}',
      f'    public static let sidebarWidth: CGFloat = {lay["sidebar-width"]["regular"]}',
      f'    public static let contentFocus: CGFloat = {lay["content-focus"]["all"]}',
      f'    public static let contentWide: CGFloat = {lay["content-wide"]["all"]}',
      f'    public static let macWindowMin = CGSize(width: {lay["mac-window-min"]["width"]}, height: {lay["mac-window-min"]["height"]})',
      '}', '']
L += ['/// Bo góc, luôn dùng kiểu .continuous.', 'public enum Radius {']
for k, v in T['radius'].items():
    if isinstance(v, int): L.append(f'    public static let {k}: CGFloat = {v}')
L += ['}', '']
# typography
L += ['/// Thang chữ ánh xạ sang Dynamic Type. Chiều cao dòng là hệ số (≥ 1,35 cho chữ có dấu tiếng Việt).', 'public enum TextToken: CaseIterable, Sendable {']
L.append('    case ' + ', '.join(camel(k) for k in T['typography']))
L += ['', '    public var textStyle: Font.TextStyle {', '        switch self {']
for k, t in T['typography'].items(): L.append(f'        case .{camel(k)}: .{t["apple"]["textStyle"]}')
L += ['        }', '    }', '', '    public var weight: Font.Weight {', '        switch self {']
for k, t in T['typography'].items(): L.append(f'        case .{camel(k)}: .{t["apple"]["weight"]}')
L += ['        }', '    }', '', '    /// Cỡ riêng (pt ở cỡ chữ mặc định), co giãn theo textStyle. nil = dùng cỡ của textStyle.', '    public var customSize: CGFloat? {', '        switch self {']
for k, t in T['typography'].items():
    if 'size' in t['apple']: L.append(f'        case .{camel(k)}: {t["apple"]["size"]}')
L += ['        default: nil', '        }', '    }', '', '    public var lineHeightMultiple: CGFloat {', '        switch self {']
for k, t in T['typography'].items(): L.append(f'        case .{camel(k)}: {t["lineHeightMultiple"]}')
L += ['        }', '    }', '', '    public var monospacedDigit: Bool { ' + ' || '.join(f'self == .{camel(k)}' for k, t in T['typography'].items() if t['apple'].get('monospacedDigit')) + ' }', '}', '']
# motion
mo = T['motion']
L += ['/// Chuyển động. Dùng qua .lifeOSAnimation(_:value:) để tự đổi sang mờ dần khi bật Reduce Motion.', 'public enum MotionToken: Sendable {']
L.append('    case ' + ', '.join(k for k in mo if k not in ('reduced', 'budget')))
L += ['', '    public var animation: Animation {', '        switch self {']
for k, m in mo.items():
    if k in ('reduced', 'budget'): continue
    a = m['apple']
    if a['animation'] == 'spring': L.append(f'        case .{k}: .spring(duration: {a["duration"]}, bounce: {a["bounce"]})')
    else: L.append(f'        case .{k}: .{a["animation"]}(duration: {a["duration"]})')
L += ['        }', '    }', '', f'    /// {mo["reduced"]["usage"]}', f'    public static let reduced: Animation = .{mo["reduced"]["apple"]["animation"]}(duration: {mo["reduced"]["apple"]["duration"]})', '}', '']
# haptics
L += ['/// Rung phản hồi. ' + T['haptics']['rule'], 'public enum HapticToken: Sendable {']
hk = [k for k in T['haptics'] if k != 'rule']
L.append('    case ' + ', '.join(hk))
L += ['', '    public var feedback: SensoryFeedback {', '        switch self {']
for k in hk:
    a = T['haptics'][k]['apple']
    L.append(f'        case .{k}: ' + ('.impact(weight: .light)' if a == 'impact.light' else '.' + a))
L += ['        }', '    }', '}', '']
files[os.path.join(PKG, 'Generated', 'Tokens.swift')] = '\n'.join(L)

# ---- CSS (web): chỉ màu, kèm Increase Contrast qua prefers-contrast
def block(sel, mode, keys):
    return [f'{sel} {{'] + [f'  --{k}: {T["color"][k].get("webAlias", {}).get(mode.replace("HC", ""), T["color"][k][mode]) if mode in ("light", "dark") else T["color"][k][mode]};' for k in keys] + ['}']
allk = list(T['color']); hck = [k for k in allk if 'lightHC' in T['color'][k]]
C = ['/* Sinh tự động từ design-tokens/tokens.json. Đừng sửa tay. */']
C += block(':root', 'light', allk)
C += ['@media (prefers-color-scheme: dark) {'] + ['  ' + l for l in block(':root:not([data-theme="light"])', 'dark', allk)] + ['}']
C += block(':root[data-theme="dark"]', 'dark', allk)
C += ['@media (prefers-contrast: more) {'] + ['  ' + l for l in block(':root', 'lightHC', hck)]
C += ['  ' + l for l in block(':root[data-theme="dark"]', 'darkHC', hck)] + ['}']
C += ['@media (prefers-contrast: more) and (prefers-color-scheme: dark) {'] + ['  ' + l for l in block(':root:not([data-theme="light"])', 'darkHC', hck)] + ['}']
files[os.path.join(ROOT, 'design', 'tokens', 'build', 'tokens.css')] = '\n'.join(C) + '\n'

check = '--check' in sys.argv
stale = [p for p, s in files.items() if not os.path.exists(p) or open(p).read() != s]
if check:
    if stale: print('Token sinh ra đã cũ:', *[os.path.relpath(p, ROOT) for p in stale], sep='\n  '); sys.exit(1)
    print('Token sinh ra khớp tokens.json.'); sys.exit(0)
if os.path.isdir(xc): shutil.rmtree(xc)
for p, s in files.items():
    os.makedirs(os.path.dirname(p), exist_ok=True); open(p, 'w').write(s)
print(f'Đã ghi {len(files)} file ({len(T["color"])} colorset).')
