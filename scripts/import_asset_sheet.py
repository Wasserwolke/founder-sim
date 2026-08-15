#!/usr/bin/env python3
"""Import Founder Sim 2048x2048 object production sheets.

Preferred workflow:
  sheet_desk_objects_001_2048.png
  sheet_desk_objects_001_2048.json

The JSON sidecar defines category and row -> asset_id mapping. Names are deliberately
NOT embedded in the image. The object may sit anywhere inside its fixed cell; the
importer trims background margins and centers it on a normalized transparent canvas.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
from PIL import Image

SHEET_SIZE = (2048, 2048)
ROW_HEIGHT = 512
COLUMNS = {"world": (0, 896), "spot": (896, 1664), "icon": (1664, 2048)}
OUTPUT_CANVAS = {"world": (896, 512), "spot": (768, 512), "icon": (384, 512)}
BORDER_PAD = 6
BG_TOLERANCE = 24


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--sheet", required=True, type=Path)
    parser.add_argument("--spec", type=Path, help="Optional JSON sidecar; defaults to same filename with .json")
    parser.add_argument("--category", help="Fallback category when using --ids")
    parser.add_argument("--ids", help="Fallback comma-separated asset IDs in top-to-bottom row order")
    parser.add_argument("--output-root", type=Path, default=Path("app/web/assets"))
    return parser.parse_args()


def load_mapping(args):
    spec_path = args.spec or args.sheet.with_suffix(".json")
    if spec_path.exists():
        data = json.loads(spec_path.read_text(encoding="utf-8"))
        category = data["category"]
        rows = data.get("rows", [])
        ids = []
        for row in rows:
            if isinstance(row, str):
                ids.append(row)
            else:
                ids.append(row.get("asset_id"))
        ids = [asset_id for asset_id in ids if asset_id]
        if not 1 <= len(ids) <= 4:
            raise SystemExit("Sidecar rows must contain between 1 and 4 asset IDs")
        return category, ids, spec_path

    if args.ids and args.category:
        ids = [value.strip() for value in args.ids.split(",") if value.strip()]
        if not 1 <= len(ids) <= 4:
            raise SystemExit("--ids must contain between 1 and 4 asset IDs")
        return args.category, ids, None

    raise SystemExit(
        f"No sheet metadata found. Create {spec_path} or provide both --category and --ids."
    )


def color_distance(a, b):
    return max(abs(int(a[i]) - int(b[i])) for i in range(3))


def guess_background(image):
    rgba = image.convert("RGBA")
    points = [
        rgba.getpixel((0, 0)),
        rgba.getpixel((rgba.width - 1, 0)),
        rgba.getpixel((0, rgba.height - 1)),
        rgba.getpixel((rgba.width - 1, rgba.height - 1)),
    ]
    best = min(
        ((i, j) for i in range(4) for j in range(i + 1, 4)),
        key=lambda pair: color_distance(points[pair[0]], points[pair[1]]),
    )
    a, b = points[best[0]], points[best[1]]
    return tuple((int(a[i]) + int(b[i])) // 2 for i in range(4))


def make_foreground_alpha(image):
    rgba = image.convert("RGBA")
    existing = rgba.getchannel("A")
    if existing.getextrema()[0] < 250:
        return rgba
    background = guess_background(rgba)
    pixels = rgba.load()
    alpha = Image.new("L", rgba.size, 0)
    alpha_pixels = alpha.load()
    for y in range(rgba.height):
        for x in range(rgba.width):
            pixel = pixels[x, y]
            distance = max(abs(pixel[i] - background[i]) for i in range(3))
            if distance > BG_TOLERANCE:
                alpha_pixels[x, y] = min(255, (distance - BG_TOLERANCE) * 8)
    rgba.putalpha(alpha)
    return rgba


def normalize_cell(cell, kind):
    cell = cell.crop((BORDER_PAD, BORDER_PAD, cell.width - BORDER_PAD, cell.height - BORDER_PAD))
    rgba = make_foreground_alpha(cell)
    bbox = rgba.getchannel("A").getbbox()
    canvas = Image.new("RGBA", OUTPUT_CANVAS[kind], (0, 0, 0, 0))
    if not bbox:
        return canvas

    obj = rgba.crop(bbox)
    max_width, max_height = canvas.width - 24, canvas.height - 24
    scale = min(1.0, max_width / obj.width, max_height / obj.height)
    if scale < 1.0:
        obj = obj.resize(
            (max(1, round(obj.width * scale)), max(1, round(obj.height * scale))),
            Image.Resampling.NEAREST,
        )

    x = (canvas.width - obj.width) // 2
    y = (canvas.height - obj.height) // 2
    canvas.alpha_composite(obj, (x, y))
    return canvas


def main():
    args = parse_args()
    category, asset_ids, spec_path = load_mapping(args)
    sheet = Image.open(args.sheet).convert("RGBA")
    if sheet.size != SHEET_SIZE:
        raise SystemExit(f"Expected 2048x2048, got {sheet.width}x{sheet.height}")

    output_dir = args.output_root / category
    output_dir.mkdir(parents=True, exist_ok=True)

    if spec_path:
        print(f"Using metadata: {spec_path}")
    for row_index, asset_id in enumerate(asset_ids):
        y0 = row_index * ROW_HEIGHT
        y1 = y0 + ROW_HEIGHT
        for kind, (x0, x1) in COLUMNS.items():
            cell = sheet.crop((x0, y0, x1, y1))
            normalized = normalize_cell(cell, kind)
            output = output_dir / f"{asset_id}_{kind}.png"
            normalized.save(output)
            print(output)


if __name__ == "__main__":
    main()
