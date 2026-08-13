from PIL import Image, ImageDraw, ImageFont
import math, os

SIZE = 1024
cx, cy = SIZE // 2, SIZE // 2

img = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))

# ── Gradient background ───────────────────────────────────────────────────────
bg = Image.new('RGBA', (SIZE, SIZE))
bd = ImageDraw.Draw(bg)
for y in range(SIZE):
    t = y / SIZE
    r = int(255 + (210 - 255) * t)
    g = int(100 + (60  - 100) * t)
    b = int(0)
    bd.line([(0, y), (SIZE - 1, y)], fill=(r, g, b, 255))

# Rounded square mask
mask = Image.new('L', (SIZE, SIZE), 0)
ImageDraw.Draw(mask).rounded_rectangle([0, 0, SIZE-1, SIZE-1], radius=200, fill=255)
img.paste(bg, (0, 0), mask)

draw = ImageDraw.Draw(img)

# ── Outer decorative ring ─────────────────────────────────────────────────────
R = 370
draw.ellipse([cx-R, cy-R-30, cx+R, cy+R-30], outline=(255,255,255,80), width=6)

# ── TRISHUL (Trident) ─────────────────────────────────────────────────────────
W = 22   # shaft width
gold = (255, 235, 120, 255)
white = (255, 255, 255, 255)

def filled_polygon(draw, points, color):
    draw.polygon(points, fill=color)

# --- Shaft ---
shaft_top = cy - 60
shaft_bot = cy + 320
draw.rounded_rectangle([cx - W//2, shaft_top, cx + W//2, shaft_bot],
                        radius=10, fill=white)

# --- Damaru (hourglass drum) in center of shaft ---
dm_cy = cy + 100
dm_w, dm_h = 80, 36
for yy in range(dm_cy - dm_h, dm_cy + dm_h):
    t = abs(yy - dm_cy) / dm_h
    hw = int(dm_w * t + 8 * (1 - t))
    alpha = 255
    draw.line([(cx - hw, yy), (cx + hw, yy)], fill=(255, 220, 100, alpha))
# outline
draw.ellipse([cx - dm_w - 2, dm_cy - dm_h - 2, cx + dm_w + 2, dm_cy - dm_h + 14],
             outline=white, width=3)
draw.ellipse([cx - dm_w - 2, dm_cy + dm_h - 14, cx + dm_w + 2, dm_cy + dm_h + 2],
             outline=white, width=3)

# --- Center prong ---
prong_base_y = cy - 60
prong_tip_y  = cy - 340
prong_w      = 28
draw.rounded_rectangle([cx - prong_w//2, prong_tip_y,
                         cx + prong_w//2, prong_base_y],
                        radius=8, fill=white)
# tip point
filled_polygon(draw, [
    (cx,              prong_tip_y - 70),
    (cx - prong_w,    prong_tip_y + 20),
    (cx + prong_w,    prong_tip_y + 20),
], white)

# --- Left prong ---
lx = cx - 140
lprong_top = cy - 290
lprong_bot = cy - 100
draw.rounded_rectangle([lx - 14, lprong_top, lx + 14, lprong_bot],
                        radius=7, fill=white)
filled_polygon(draw, [
    (lx,        lprong_top - 55),
    (lx - 20,   lprong_top + 15),
    (lx + 20,   lprong_top + 15),
], white)
# curve connecting left prong to shaft
for i in range(20):
    t = i / 20
    px = int(lx + (cx - lx) * t)
    py = int((lprong_bot) + 30 * math.sin(t * math.pi))
    draw.ellipse([px-11, py-11, px+11, py+11], fill=white)

# --- Right prong ---
rx = cx + 140
draw.rounded_rectangle([rx - 14, lprong_top, rx + 14, lprong_bot],
                        radius=7, fill=white)
filled_polygon(draw, [
    (rx,        lprong_top - 55),
    (rx - 20,   lprong_top + 15),
    (rx + 20,   lprong_top + 15),
], white)
for i in range(20):
    t = i / 20
    px = int(rx - (rx - cx) * t)
    py = int((lprong_bot) + 30 * math.sin(t * math.pi))
    draw.ellipse([px-11, py-11, px+11, py+11], fill=white)

# --- Horizontal cross-bar ---
bar_y = cy - 110
draw.rounded_rectangle([cx - 165, bar_y - 11, cx + 165, bar_y + 11],
                        radius=10, fill=white)

# --- Base spike ---
filled_polygon(draw, [
    (cx,          shaft_bot + 55),
    (cx - 18,     shaft_bot),
    (cx + 18,     shaft_bot),
], white)

# ── Decorative dots on ring ───────────────────────────────────────────────────
for i in range(12):
    angle = math.radians(i * 30 - 90)
    dx = cx + int((R + 18) * math.cos(angle))
    dy = (cy - 30) + int((R + 18) * math.sin(angle))
    r2 = 10 if i % 3 == 0 else 6
    draw.ellipse([dx-r2, dy-r2, dx+r2, dy+r2], fill=(255,255,255,160))

# ── Bottom label ──────────────────────────────────────────────────────────────
label = 'TRIMBAKESHWAR'
font_candidates = [
    '/System/Library/Fonts/Supplemental/Georgia.ttf',
    '/System/Library/Fonts/Helvetica.ttc',
    '/System/Library/Fonts/Supplemental/Arial Narrow.ttf',
]
lbl_font = None
for fp in font_candidates:
    if os.path.exists(fp):
        try:
            lbl_font = ImageFont.truetype(fp, 54)
            break
        except:
            pass
if lbl_font is None:
    lbl_font = ImageFont.load_default()

bbox = draw.textbbox((0, 0), label, font=lbl_font)
tw = bbox[2] - bbox[0]
tx = cx - tw // 2 - bbox[0]
ty = cy + 355
draw.text((tx+2, ty+2), label, font=lbl_font, fill=(0,0,0,100))
draw.text((tx,   ty),   label, font=lbl_font, fill=(255,255,255,240))

# ── Save ──────────────────────────────────────────────────────────────────────
os.makedirs('assets/icon', exist_ok=True)
img.save('assets/icon/app_icon.png')
print('Saved assets/icon/app_icon.png')
