# Tính biến thể Increase Contrast: trộn dần màu về phía chữ chính (Light) hoặc trắng (Dark)
# cho tới khi đạt ngưỡng trên mọi nền bg / surface / surface-2.
import json, sys
T = {}
for g in json.load(open('code/tokens.json'))['tokens'].values():
    for k, e in g.items(): T[k] = e
def rgb(h): h = h.lstrip('#'); return [int(h[i:i+2], 16) / 255 for i in (0, 2, 4)]
def lum(h): return sum(w * (c / 12.92 if c <= .04045 else ((c + .055) / 1.055) ** 2.4) for w, c in zip((.2126, .7152, .0722), rgb(h)))
def cr(a, b): la, lb = sorted((lum(a), lum(b)), reverse=True); return (la + .05) / (lb + .05)
def mix(a, b, p): return '#' + ''.join(f'{round((x*p + y*(1-p))*255):02X}' for x, y in zip(rgb(a), rgb(b)))
TARGET = {'text-2': 7.0, 'text-3': 5.5, 'border': 3.0, 'accent': 6.0, 'positive': 6.0, 'warning': 4.5, 'danger': 6.0}
out = {}
for mode, pole in (('light', '#000000'), ('dark', '#FFFFFF')):
    bgs = [T[b][mode] for b in ('bg', 'surface', 'surface-2')]
    for k, t in TARGET.items():
        base = T[k][mode]; c = base; p = 0
        while min(cr(c, b) for b in bgs) < t and p < 1:
            p += .01; c = mix(pole, base, p)
        out.setdefault(k, {})[mode + 'HC'] = c
        print(mode, k, base, '->', c, round(min(cr(c, b) for b in bgs), 2))
# on-accent trên accent HC
for mode in ('light', 'dark'):
    print(mode, 'on-accent/accentHC', round(cr(T['on-accent'][mode], out['accent'][mode + 'HC']), 2))
json.dump(out, open('apple/design-tokens/hc.json', 'w'), indent=1)
