#!/usr/bin/env python3
"""ストア用スクリーンショットを作る（国・アプリを問わない共通ツール）。

実機（またはエミュレータ）で撮った「アプリそのままの画面」に、シリーズの背景と
短い見出しを付けて、Google Play / App Store に出せる縦長画像（既定 1080x1920、
アルファなしの 24bit PNG）にする。画面の中身には手を加えない（ストアの方針:
アプリの UI だけを見せる／実際の機能と一致させる）。

使い方:
  python3 tools/compose_store_screenshots.py \
      --raw store/screenshots/raw --captions store/screenshots/captions.json \
      --out store/screenshots/out --brand-color "#E63946" \
      --series "Showglobe Japan" --lang all

入力の置き方:  <raw>/<言語コード>/<番号>_<名前>.png   例: raw/ja/01_home.png
              言語ごとに、その言語に切り替えたアプリで撮ること。
見出し:       captions.json = { "01_home": { "ja": "…", "en": "…" }, ... }
出力:         <out>/<言語コード>/<番号>_<名前>.png と、一覧 <out>/<言語コード>/_sheet.png

必要なもの: Python 3 + Pillow、Chrome / Chromium（見出しの描画に使う。日本語・韓国語・
中国語・タイ語・ヒンディー語・アラビア語を出すには、その文字のフォント
（Noto Sans CJK / Thai / Devanagari / Arabic など）が入っていること）。
"""
from __future__ import annotations

import argparse
import html
import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

from PIL import Image

LANGS = ["ja", "en", "zh", "zh-TW", "ko", "es", "fr", "pt", "id", "vi", "th", "hi", "ar"]
RTL = {"ar"}
CHROME_CANDIDATES = [
    "chromium", "chromium-browser", "google-chrome", "google-chrome-stable", "chrome",
    "/opt/pw-browsers/chromium",
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
]
FONT_STACK = (
    '"Noto Sans CJK JP","Noto Sans JP","Hiragino Sans","Yu Gothic","Noto Sans KR",'
    '"Noto Sans SC","Noto Sans TC","Noto Sans Thai","Noto Sans Devanagari",'
    '"Noto Sans Arabic","Segoe UI","Helvetica Neue",Arial,sans-serif'
)


def find_chrome(explicit: str | None) -> str:
    for c in ([explicit] if explicit else []) + CHROME_CANDIDATES:
        path = shutil.which(c) or (c if os.path.exists(c) else None)
        if path:
            return path
    sys.exit("Chrome / Chromium が見つかりません。--chrome で指定してください。")


def shade(hex_color: str, delta: float) -> str:
    """色を明るく(+)／暗く(-)する。delta は -1..1。"""
    h = hex_color.lstrip("#")
    r, g, b = (int(h[i:i + 2], 16) for i in (0, 2, 4))
    f = (lambda v: round(v + (255 - v) * delta)) if delta >= 0 else (lambda v: round(v * (1 + delta)))
    return "#%02X%02X%02X" % (f(r), f(g), f(b))


def globe_svg() -> str:
    """地球儀の柄（経線・緯線）。シリーズ共通の背景モチーフ。"""
    lines = []
    cx, cy, r = 820, 520, 640
    for k in (0.35, 0.7, 1.0):
        lines.append(f'<ellipse cx="{cx}" cy="{cy}" rx="{r * k * 0.55}" ry="{r * k}" />')
    for y in (-0.55, 0.0, 0.55):
        w = (1 - y * y) ** 0.5 * r
        lines.append(f'<ellipse cx="{cx}" cy="{cy + y * r}" rx="{w}" ry="{w * 0.13}" />')
    lines.append(f'<circle cx="{cx}" cy="{cy}" r="{r}" />')
    return ('<svg class="globe" viewBox="0 0 1080 1920" xmlns="http://www.w3.org/2000/svg">'
            '<g fill="none" stroke="white" stroke-opacity="0.16" stroke-width="3">'
            + "".join(lines) + "</g></svg>")


def page_html(*, w: int, h: int, color: str, series: str, caption: str, shot: Path,
              lang: str) -> str:
    top, bottom = shade(color, 0.12), shade(color, -0.35)
    direction = "rtl" if lang in RTL else "ltr"
    shot_uri = shot.resolve().as_uri()
    # 画面は幅の 80% で、下端は見切れさせる（上は見出し用に 26% あける）。
    img_w = round(w * 0.80)
    img_top = round(h * 0.26)
    return f"""<!doctype html><html lang="{lang}" dir="{direction}"><head><meta charset="utf-8">
<style>
html,body{{margin:0;width:{w}px;height:{h}px;overflow:hidden;font-family:{FONT_STACK};}}
.bg{{position:absolute;inset:0;background:linear-gradient(160deg,{top},{bottom});}}
.globe{{position:absolute;inset:0;width:{w}px;height:{h}px;}}
.series{{position:absolute;top:70px;left:0;right:0;text-align:center;color:rgba(255,255,255,.75);
  font-size:34px;letter-spacing:2px;}}
.caption{{position:absolute;top:130px;left:70px;right:70px;height:{img_top - 150}px;display:flex;
  align-items:center;justify-content:center;text-align:center;color:#fff;font-weight:800;
  font-size:84px;line-height:1.2;text-wrap:balance;text-shadow:0 4px 18px rgba(0,0,0,.25);}}
.shot{{position:absolute;top:{img_top}px;left:{(w - img_w) // 2}px;width:{img_w}px;
  border-radius:56px 56px 0 0;box-shadow:0 30px 80px rgba(0,0,0,.45);display:block;}}
</style></head><body>
<div class="bg"></div>{globe_svg()}
<div class="series">{html.escape(series)}</div>
<div class="caption"><span>{html.escape(caption)}</span></div>
<img class="shot" src="{shot_uri}">
</body></html>"""


def render(chrome: str, page: Path, out_png: Path, w: int, h: int) -> None:
    cmd = [chrome, "--headless=new", "--no-sandbox", "--disable-gpu", "--hide-scrollbars",
           # 画面下に余白が出るので、大きめに撮って flatten() で切り抜く
           f"--window-size={w},{h + 240}", "--force-device-scale-factor=1",
           f"--screenshot={out_png}", page.resolve().as_uri()]
    subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def flatten(png: Path, w: int, h: int) -> None:
    """左上から w x h を切り抜き、アルファを外して 24bit RGB の PNG にする（ストアの要件）。"""
    im = Image.open(png).crop((0, 0, w, h))
    if im.mode != "RGB":
        bg = Image.new("RGB", im.size, (255, 255, 255))
        bg.paste(im, mask=im.getchannel("A") if "A" in im.getbands() else None)
        im = bg
    im.save(png, "PNG", optimize=True)


def contact_sheet(files: list[Path], out: Path, thumb_w: int = 270) -> None:
    if not files:
        return
    thumbs = []
    for f in files:
        im = Image.open(f).convert("RGB")
        thumbs.append(im.resize((thumb_w, round(im.height * thumb_w / im.width))))
    gap = 16
    sheet = Image.new("RGB", (gap + len(thumbs) * (thumb_w + gap),
                               gap * 2 + max(t.height for t in thumbs)), (240, 240, 240))
    x = gap
    for t in thumbs:
        sheet.paste(t, (x, gap))
        x += thumb_w + gap
    sheet.save(out, "PNG")


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--raw", required=True, type=Path)
    ap.add_argument("--captions", required=True, type=Path)
    ap.add_argument("--out", required=True, type=Path)
    ap.add_argument("--brand-color", default="#E63946")
    ap.add_argument("--series", default="Showglobe")
    ap.add_argument("--lang", default="all", help="all か、カンマ区切りの言語コード")
    ap.add_argument("--width", type=int, default=1080)
    ap.add_argument("--height", type=int, default=1920)
    ap.add_argument("--chrome")
    args = ap.parse_args()

    chrome = find_chrome(args.chrome)
    captions = json.loads(args.captions.read_text(encoding="utf-8"))
    langs = LANGS if args.lang == "all" else [l.strip() for l in args.lang.split(",")]
    made = 0
    for lang in langs:
        shots = sorted((args.raw / lang).glob("*.png")) if (args.raw / lang).is_dir() else []
        if not shots:
            print(f"- {lang}: 元の画面が無いので飛ばします（{args.raw / lang}）")
            continue
        out_dir = args.out / lang
        out_dir.mkdir(parents=True, exist_ok=True)
        outputs = []
        for shot in shots:
            key = shot.stem
            caption = captions.get(key, {}).get(lang) or captions.get(key, {}).get("en")
            if not caption:
                print(f"- {lang}/{key}: 見出しが無いので飛ばします")
                continue
            with tempfile.TemporaryDirectory() as tmp:
                page = Path(tmp) / "p.html"
                page.write_text(page_html(w=args.width, h=args.height, color=args.brand_color,
                                          series=args.series, caption=caption, shot=shot,
                                          lang=lang), encoding="utf-8")
                out_png = out_dir / f"{key}.png"
                render(chrome, page, out_png, args.width, args.height)
            flatten(out_png, args.width, args.height)
            outputs.append(out_png)
            made += 1
        contact_sheet(outputs, out_dir / "_sheet.png")
        print(f"- {lang}: {len(outputs)} 枚")
    print(f"できた枚数: {made}")


if __name__ == "__main__":
    main()
