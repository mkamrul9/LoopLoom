"""Export the LoopLoom name lockup for the web and Android launchers.

The two pairs of o letters each share one continuous infinity-shaped stroke.
Run from the repository root with: python scripts/generate-looploom-brand.py
"""

from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent.parent
WEB = ROOT / "apps" / "solveit" / "web"
RES = ROOT / "apps" / "solveit" / "android" / "app" / "src" / "main" / "res"
PAPER = "#F7F4EF"
INK = "#262B2D"
MUTED = "#5F6466"
CLAY = "#914B36"
TAGLINE = "THINK · TRACE · CODE"
FONT_PATH = next(
    path for path in (
        Path("C:/Windows/Fonts/segoeuib.ttf"),
        Path("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"),
    ) if path.exists()
)
REGULAR_PATH = next(
    path for path in (
        Path("C:/Windows/Fonts/segoeui.ttf"),
        Path("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"),
    ) if path.exists()
)


def loop_path(left, right, center_y, half_height):
    middle = (left + right) / 2
    control_y = half_height * 1.32
    shoulder = (right - left) * .18
    return [
        ((middle, center_y), (middle - shoulder, center_y - control_y),
         (left, center_y - control_y), (left, center_y)),
        ((left, center_y), (left, center_y + control_y),
         (middle - shoulder, center_y + control_y), (middle, center_y)),
        ((middle, center_y), (middle + shoulder, center_y - control_y),
         (right, center_y - control_y), (right, center_y)),
        ((right, center_y), (right, center_y + control_y),
         (middle + shoulder, center_y + control_y), (middle, center_y)),
    ]


def svg_loop(left, right, center_y, half_height):
    sections = loop_path(left, right, center_y, half_height)
    first = sections[0][0]
    commands = [f"M {first[0]:.2f} {first[1]:.2f}"]
    for _, a, b, end in sections:
        commands.append(
            f"C {a[0]:.2f} {a[1]:.2f} {b[0]:.2f} {b[1]:.2f} "
            f"{end[0]:.2f} {end[1]:.2f}"
        )
    return " ".join(commands)


def draw_loop(draw, left, right, center_y, half_height, width, scale):
    points = []
    for start, a, b, end in loop_path(left, right, center_y, half_height):
        for step in range(61):
            t = step / 60
            u = 1 - t
            x = u**3 * start[0] + 3*u*u*t*a[0] + 3*u*t*t*b[0] + t**3*end[0]
            y = u**3 * start[1] + 3*u*u*t*a[1] + 3*u*t*t*b[1] + t**3*end[1]
            points.append((round(x*scale), round(y*scale)))
    draw.line(points, fill=CLAY, width=round(width*scale), joint="curve")


def draw_lockup(size, square):
    scale = 4
    canvas = Image.new("RGB", (size[0]*scale, size[1]*scale), PAPER)
    draw = ImageDraw.Draw(canvas)
    if square:
        pair_width, gap, baseline = 92, 6, 272
        bold = ImageFont.truetype(FONT_PATH, 95*scale)
        regular = ImageFont.truetype(REGULAR_PATH, 21*scale)
        letter_l = bold.getlength("L") / scale
        letter_pl = bold.getlength("pL") / scale
        letter_m = bold.getlength("m") / scale
        width = letter_l + letter_pl + letter_m + 2*pair_width + 4*gap
        left = (512-width)/2
        draw.text((left*scale, baseline*scale), "L", font=bold, fill=INK, anchor="ls")
        pair1 = left+letter_l+gap
        draw_loop(draw, pair1, pair1+pair_width, baseline-24, 24, 8, scale)
        middle = pair1+pair_width+gap
        draw.text((middle*scale, baseline*scale), "pL", font=bold, fill=INK, anchor="ls")
        pair2 = middle+letter_pl+gap
        draw_loop(draw, pair2, pair2+pair_width, baseline-24, 24, 8, scale)
        draw.text(((pair2+pair_width+gap)*scale, baseline*scale),
                  "m", font=bold, fill=INK, anchor="ls")
        draw.text((256*scale, 338*scale), TAGLINE, font=regular,
                  fill=MUTED, anchor="ms", stroke_width=0)
    else:
        bold = ImageFont.truetype(FONT_PATH, 130*scale)
        regular = ImageFont.truetype(REGULAR_PATH, 23*scale)
        letter_l = bold.getlength("L") / scale
        letter_pl = bold.getlength("pL") / scale
        letter_m = bold.getlength("m") / scale
        pair_width, gap, baseline = 118, 7, 168
        full_width = letter_l + letter_pl + letter_m + 2*pair_width + 4*gap
        left = (900-full_width)/2
        draw.text((left*scale, baseline*scale), "L", font=bold, fill=INK, anchor="ls")
        pair1 = left + letter_l + gap
        draw_loop(draw, pair1, pair1+pair_width, baseline-33, 33, 10, scale)
        middle = pair1 + pair_width + gap
        draw.text((middle*scale, baseline*scale), "pL", font=bold, fill=INK, anchor="ls")
        pair2 = middle + letter_pl + gap
        draw_loop(draw, pair2, pair2+pair_width, baseline-33, 33, 10, scale)
        draw.text(((pair2+pair_width+gap)*scale, baseline*scale),
                  "m", font=bold, fill=INK, anchor="ls")
        draw.text((450*scale, 239*scale), TAGLINE, font=regular,
                  fill=MUTED, anchor="ms")
    return canvas.resize(size, Image.Resampling.LANCZOS)


def export_svg():
    font = ImageFont.truetype(FONT_PATH, 130)
    l, pl = font.getlength("L"), font.getlength("pL")
    m = font.getlength("m")
    pair_width, gap = 118, 7
    left = (900-(l+pl+m+2*pair_width+4*gap))/2
    pair1 = left+l+gap
    middle = pair1+pair_width+gap
    pair2 = middle+pl+gap
    end = pair2+pair_width+gap
    wordmark = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 900 278" role="img" aria-label="LoopLoom — Think, Trace, Code">
  <g fill="{INK}" font-family="Segoe UI, Arial, sans-serif" font-size="130" font-weight="700">
    <text x="{left:.2f}" y="168">L</text><text x="{middle:.2f}" y="168">pL</text><text x="{end:.2f}" y="168">m</text>
  </g>
  <g fill="none" stroke="{CLAY}" stroke-width="10" stroke-linecap="round" stroke-linejoin="round">
    <path d="{svg_loop(pair1, pair1+pair_width, 135, 33)}"/>
    <path d="{svg_loop(pair2, pair2+pair_width, 135, 33)}"/>
  </g>
  <text x="450" y="239" text-anchor="middle" fill="{MUTED}" font-family="Segoe UI, Arial, sans-serif" font-size="23" letter-spacing="4">{TAGLINE}</text>
</svg>
'''
    (WEB / "looploom-wordmark.svg").write_text(wordmark, encoding="utf-8")
    icon_font = ImageFont.truetype(FONT_PATH, 95)
    icon_l = icon_font.getlength("L")
    icon_pl = icon_font.getlength("pL")
    icon_m = icon_font.getlength("m")
    icon_width = icon_l+icon_pl+icon_m+2*92+4*6
    icon_left = (512-icon_width)/2
    icon_pair1 = icon_left+icon_l+6
    icon_middle = icon_pair1+92+6
    icon_pair2 = icon_middle+icon_pl+6
    icon_end = icon_pair2+92+6
    favicon = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" role="img" aria-label="LoopLoom — Think, Trace, Code">
  <rect width="512" height="512" fill="{PAPER}"/>
  <g fill="{INK}" font-family="Segoe UI, Arial, sans-serif" font-size="95" font-weight="700">
    <text x="{icon_left:.2f}" y="272">L</text><text x="{icon_middle:.2f}" y="272">pL</text><text x="{icon_end:.2f}" y="272">m</text>
  </g>
  <g fill="none" stroke="{CLAY}" stroke-width="8" stroke-linecap="round" stroke-linejoin="round">
    <path d="{svg_loop(icon_pair1, icon_pair1+92, 248, 24)}"/>
    <path d="{svg_loop(icon_pair2, icon_pair2+92, 248, 24)}"/>
  </g>
  <text x="256" y="338" text-anchor="middle" fill="{MUTED}" font-family="Segoe UI, Arial, sans-serif" font-size="21">{TAGLINE}</text>
</svg>
'''
    (WEB / "favicon.svg").write_text(favicon, encoding="utf-8")


def main():
    export_svg()
    preview = draw_lockup((900, 278), square=False)
    preview.save(ROOT / "docs" / "looploom-logo-preview.png")
    icon = draw_lockup((512, 512), square=True)
    icon.save(WEB / "icons" / "Icon-512.png")
    icon.resize((192, 192), Image.Resampling.LANCZOS).save(WEB / "icons" / "Icon-192.png")
    icon.save(WEB / "icons" / "Icon-maskable-512.png")
    icon.resize((192, 192), Image.Resampling.LANCZOS).save(WEB / "icons" / "Icon-maskable-192.png")
    icon.resize((32, 32), Image.Resampling.LANCZOS).save(WEB / "favicon.png")
    for density, pixels in (("mdpi", 48), ("hdpi", 72), ("xhdpi", 96),
                            ("xxhdpi", 144), ("xxxhdpi", 192)):
        target = RES / f"mipmap-{density}" / "ic_launcher.png"
        icon.resize((pixels, pixels), Image.Resampling.LANCZOS).save(target)


if __name__ == "__main__":
    main()
