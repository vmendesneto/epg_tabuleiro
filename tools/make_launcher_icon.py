"""Build the Android launcher and store icon from the puppy artwork."""

from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
source = Image.open(ROOT / "art/source/cachorro.png").convert("RGBA")
source = source.crop(source.getchannel("A").getbbox())

canvas = Image.new("RGBA", (512, 512), "#258b53")
draw = ImageDraw.Draw(canvas)
draw.ellipse((16, 16, 496, 496), fill="#43a65b", outline="#fff5ca", width=15)
draw.ellipse((52, 62, 460, 470), fill="#80cf70")
source.thumbnail((405, 390), Image.Resampling.LANCZOS)
canvas.alpha_composite(source, ((512 - source.width) // 2, 75))

store_icon = ROOT / "art/play_store_icon.png"
canvas.convert("RGB").save(store_icon)

sizes = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}
for density, size in sizes.items():
    folder = ROOT / f"android/app/src/main/res/mipmap-{density}"
    folder.mkdir(parents=True, exist_ok=True)
    canvas.resize((size, size), Image.Resampling.LANCZOS).save(folder / "ic_launcher.png")
    print(f"Created {density} launcher icon")
