# Chạy một lần: chuyển code/tokens.json (dạng web) sang design-tokens/tokens.json (trung lập nền tảng).
import json, re
src = json.load(open('code/tokens.json'))
hc = json.load(open('apple/design-tokens/hc.json'))
T = {k: e for g in src['tokens'].values() for k, e in g.items()}
GROUP = {k: g for g, v in src['tokens'].items() for k in v}

def resolve(v, mode):
    m = re.fullmatch(r'var\(--([\w-]+)\)', v)
    return resolve(T[m.group(1)][mode], mode) if m else v

color = {}
for k, e in T.items():
    if GROUP[k] not in ('Màu lõi', 'Màu dữ liệu', 'Mood') or k == 'data-tint': continue
    c = {'group': GROUP[k], 'usage': e['usage'], 'light': resolve(e['light'], 'light'), 'dark': resolve(e['dark'], 'dark')}
    if k in hc: c.update(hc[k])
    if e['light'].startswith('var('): c['webAlias'] = {'light': e['light'], 'dark': e['dark']}
    color[k] = c

out = {
 '$description': 'Life OS design tokens v2, trung lập nền tảng. Nguồn sự thật cho SwiftUI (sinh .colorset + Swift) và web (sinh CSS). Sửa file này rồi chạy generate.py; không sửa file sinh ra.',
 'version': 2,
 'units': 'pt cho Apple; px/rem cho web (1rem = 16px = 16pt)',
 'color': color,
 'opacity': {
   'data-tint': {'light': .12, 'dark': .16, 'usage': 'Độ đậm màu dữ liệu làm nền ô icon'},
   'overlay-hover': {'light': .06, 'dark': .07, 'usage': 'Lớp phủ khi rê chuột (Mac, iPad có con trỏ)'},
   'overlay-press': {'light': .12, 'dark': .13, 'usage': 'Lớp phủ khi nhấn'},
 },
 'typography': {
   'numeral-xl': {'apple': {'textStyle': 'largeTitle', 'size': 40, 'weight': 'semibold', 'monospacedDigit': True}, 'lineHeightMultiple': 1.1, 'web': {'size': '2.5rem', 'lineHeight': '2.75rem', 'weight': 600}, 'usage': 'Số tiền, số lớn (chỉ chữ số)'},
   'title-1': {'apple': {'textStyle': 'title', 'weight': 'bold'}, 'lineHeightMultiple': 1.35, 'web': {'size': '1.75rem', 'lineHeight': '2.25rem', 'weight': 700}, 'usage': 'Tiêu đề màn'},
   'title-2': {'apple': {'textStyle': 'title2', 'weight': 'semibold'}, 'lineHeightMultiple': 1.35, 'web': {'size': '1.375rem', 'lineHeight': '1.875rem', 'weight': 600}, 'usage': 'Tiêu đề khối lớn'},
   'title-3': {'apple': {'textStyle': 'title3', 'weight': 'semibold'}, 'lineHeightMultiple': 1.4, 'web': {'size': '1.125rem', 'lineHeight': '1.625rem', 'weight': 600}, 'usage': 'Tiêu đề card'},
   'body': {'apple': {'textStyle': 'body', 'weight': 'regular'}, 'lineHeightMultiple': 1.4, 'web': {'size': '1rem', 'lineHeight': '1.5rem', 'weight': 400}, 'usage': 'Nội dung'},
   'body-strong': {'apple': {'textStyle': 'body', 'weight': 'medium'}, 'lineHeightMultiple': 1.4, 'web': {'size': '1rem', 'lineHeight': '1.5rem', 'weight': 500}, 'usage': 'Tên việc, tên thói quen'},
   'callout': {'apple': {'textStyle': 'subheadline', 'weight': 'regular'}, 'lineHeightMultiple': 1.4, 'web': {'size': '0.9375rem', 'lineHeight': '1.375rem', 'weight': 400}, 'usage': 'Mô tả, câu hướng dẫn'},
   'footnote': {'apple': {'textStyle': 'footnote', 'weight': 'regular'}, 'lineHeightMultiple': 1.4, 'web': {'size': '0.8125rem', 'lineHeight': '1.125rem', 'weight': 400}, 'usage': 'Meta, ngày, danh mục'},
   'caption': {'apple': {'textStyle': 'caption', 'weight': 'medium'}, 'lineHeightMultiple': 1.35, 'web': {'size': '0.75rem', 'lineHeight': '1rem', 'weight': 500}, 'usage': 'Nhãn nhỏ, nhãn trục. Không nhỏ hơn cỡ này'},
   'journal': {'apple': {'textStyle': 'body', 'weight': 'regular'}, 'lineHeightMultiple': 1.6, 'web': {'size': '1.0625rem', 'lineHeight': '1.75rem', 'weight': 400, 'family': 'font-alt'}, 'usage': 'Nội dung nhật ký'},
 },
 'fontFamily': {'apple': 'SF Pro (hệ thống, 0 byte, Dynamic Type sẵn)', 'web': T['font-sans']['light'], 'webAlt': T['font-alt']['light']},
 'spacing': {'0.5': 2, '1': 4, '2': 8, '3': 12, '4': 16, '5': 20, '6': 24, '8': 32, '10': 40, '12': 48, '16': 64},
 'layout': {
   'gutter': {'compact': 16, 'regular': 24, 'mac': 32, 'usage': 'Lề trang: iPhone / iPad / Mac'},
   'card-pad': {'compact': 16, 'regular': 20, 'mac': 20, 'usage': 'Padding card'},
   'block-gap': {'all': 24, 'usage': 'Khoảng giữa các khối'},
   'hit': {'all': 44, 'usage': 'Vùng chạm tối thiểu (Apple HIG 44pt)'},
   'sidebar-width': {'regular': 240, 'mac': 240, 'usage': 'Cột sidebar iPad và Mac'},
   'content-focus': {'all': 720, 'usage': 'Bề rộng tối đa cột đọc, nhật ký, form'},
   'content-wide': {'all': 1080, 'usage': 'Bề rộng tối đa bento, bảng'},
   'mac-window-min': {'width': 760, 'height': 560, 'usage': 'Cửa sổ Mac nhỏ nhất'},
   'web-only': {'tabbar-h': '3.5rem', 'header-compact-h': '2.75rem', 'fab-size': '56px', 'breakpoints': src['breakpoints'], 'usage': 'Trên Apple do TabView, toolbar và nút hệ thống quyết định'},
 },
 'radius': {k[2:]: int(T[k]['light'].rstrip('px')) for k in ('r-xs', 'r-sm', 'r-md', 'r-lg', 'r-xl')} | {'full': 'capsule'},
 'radiusStyle': 'continuous (RoundedRectangle style .continuous trên Apple)',
 'material': {
   'card': {'apple': 'nền đục surface; viền border 1pt chỉ ở Light; không bóng', 'web': '.elev-0'},
   'navigation': {'apple': 'Liquid Glass của hệ thống: TabView, toolbar, sheet, menu', 'web': '.elev-1 (kính tự vẽ, chỉ tab bar và header gọn)'},
   'floating': {'apple': 'sheet và dialog hệ thống', 'web': '.elev-2'},
   'customGlass': {'apple': 'Tối đa 5 phần tử mỗi màn, đặt chung một GlassEffectContainer, đứng yên (không xoay, không lặp). Chỉ cho: nút Ghi nhanh, viên chọn tâm trạng, bộ lọc nổi.', 'never': 'hàng danh sách, ô heatmap, thẻ, biểu đồ, widget'},
   'webValues': {k: {'light': T[k]['light'], 'dark': T[k]['dark']} for k in T if k.startswith('elev-')},
 },
 'motion': {
   'micro': {'apple': {'animation': 'snappy', 'duration': .12}, 'web': {'duration': '120ms', 'easing': T['ease-enter']['light']}, 'usage': 'Nhấn, đổi trạng thái nhỏ'},
   'standard': {'apple': {'animation': 'smooth', 'duration': .2}, 'web': {'duration': '200ms', 'easing': T['ease-enter']['light']}, 'usage': 'Tick việc, toast, segmented'},
   'emphasized': {'apple': {'animation': 'smooth', 'duration': .32}, 'web': {'duration': '320ms', 'easing': T['ease-enter']['light']}, 'usage': 'Mở rộng thẻ, chuyển khối (sheet dùng chuyển động hệ thống)'},
   'spring': {'apple': {'animation': 'spring', 'duration': .42, 'bounce': .2}, 'web': {'duration': '420ms', 'easing': T['ease-spring']['light']}, 'usage': 'Chọn tâm trạng, mốc chuỗi'},
   'reduced': {'apple': {'animation': 'linear', 'duration': .09, 'transition': 'opacity'}, 'web': {'duration': '80–90ms', 'easing': 'linear'}, 'usage': 'Thay mọi chuyển động khi bật Reduce Motion: chỉ mờ dần, không trượt, không phóng to'},
   'budget': [
     'Chỉ hiệu ứng chạy một lần, trên opacity, scale, offset; số thay đổi dùng numericText.',
     'Không repeatForever, TimelineView(.animation), shader lấy mẫu điểm ảnh hay blur động.',
     'Mỗi màn tối đa một khoảnh khắc ăn mừng (mốc chuỗi thói quen), tắt khi Reduce Motion hoặc Low Power Mode.',
     'Công việc của app mỗi khung hình khoảng 4 ms trong ngân sách 8,3 ms (120 Hz); hitch ≤ 10 ms/s.',
   ],
 },
 'haptics': {
   'success': {'apple': 'success', 'usage': 'Xong một việc, tick thói quen, lưu khoản chi'},
   'selection': {'apple': 'selection', 'usage': 'Chọn tâm trạng, năng lượng, segmented, ngày'},
   'warning': {'apple': 'warning', 'usage': 'Mở hộp xác nhận xóa'},
   'light': {'apple': 'impact.light', 'usage': 'Vuốt qua ngưỡng swipe action'},
   'rule': 'Chỉ rung ở sự kiện có ý nghĩa; không rung khi cuộn hay gõ.',
 },
 'icon': {'apple': 'SF Symbols, weight theo chữ đi kèm, scale .medium', 'web': 'Lucide nét 1,75', 'sizes': {'inline': 16, 'ui': 20, 'tab': 24}},
}
json.dump(out, open('apple/design-tokens/tokens.json', 'w'), ensure_ascii=False, indent=2)
print(len(color), 'colors')
