"""Create short, transparent walking GIFs from the original animal art.

Usage: python3 tools/make_gifs.py
Each paw gets its own swing and lift. The torso and head stay in place.
"""

from pathlib import Path
import math

import numpy as np
from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "art" / "source"
OUTPUT = ROOT / "assets" / "animals"
FRAME_COUNT = 12
FRAME_MS = 80
CANVAS_SIZE = 240

# Paw centers and hip heights are measured on the cropped 202 px thumbnails.
# The order is back to front so alternate paws receive opposite gait phases.
LEGS = {
    "cachorro": ((31, 125), (91, 129), (139, 128), (177, 128)),
    "capivara": ((21, 139), (74, 144), (114, 140), (159, 142)),
    "coelho": ((43, 133), (83, 136), (120, 122), (148, 121)),
    "esquilo": ((64, 137), (112, 139), (154, 135)),
    "gato": ((35, 132), (91, 133), (127, 130), (165, 130)),
    "ourico": ((39, 155), (84, 157), (106, 157), (157, 151)),
    "porco": ((28, 149), (68, 151), (108, 150), (147, 149)),
    "raposa": ((63, 132), (112, 131), (138, 130), (172, 127)),
    "tartaruga": ((30, 139), (77, 141), (127, 138), (175, 136)),
    "urso": ((33, 139), (85, 139), (126, 138), (168, 135)),
}


def walking_frame(image: Image.Image, legs: tuple[tuple[int, int], ...], phase: float) -> Image.Image:
    """Bend each lower limb independently, lifting its paw on the forward swing."""
    pixels = np.asarray(image, dtype=np.float32)
    height, width = pixels.shape[:2]
    yy, xx = np.mgrid[:height, :width].astype(np.float32)
    offset_x = np.zeros((height, width), dtype=np.float32)
    offset_y = np.zeros((height, width), dtype=np.float32)
    total_weight = np.zeros((height, width), dtype=np.float32)

    for index, (paw_x, hip_y) in enumerate(legs):
        # The motion starts at the hip and reaches its full extent at the paw.
        reach = np.clip((yy - hip_y) / max(height - hip_y - 8, 1), 0, 1)
        reach = reach * reach * (3 - 2 * reach)
        width_at_y = 19 + 5 * (1 - reach)
        proximity = np.exp(-0.5 * ((xx - paw_x) / width_at_y) ** 2)
        weight = proximity * reach
        limb_phase = phase + (math.pi if index % 2 else 0)
        offset_x += weight * (16 * math.sin(limb_phase))
        offset_y += weight * (-9 * max(0, math.cos(limb_phase)))
        total_weight += weight

    # Keep neighboring limbs separate where their influence regions overlap.
    divisor = np.maximum(total_weight, 1)
    sample_x = xx - offset_x / divisor
    sample_y = yy - offset_y / divisor
    x0 = np.floor(sample_x).astype(np.int32)
    y0 = np.floor(sample_y).astype(np.int32)
    x1, y1 = x0 + 1, y0 + 1
    fx = (sample_x - x0)[..., None]
    fy = (sample_y - y0)[..., None]

    # Interpolate premultiplied RGBA to avoid dark edges on transparent paws.
    source = pixels.copy()
    source[..., :3] *= source[..., 3:4] / 255

    def sample(x: np.ndarray, y: np.ndarray) -> np.ndarray:
        valid = (x >= 0) & (x < width) & (y >= 0) & (y < height)
        sampled = source[np.clip(y, 0, height - 1), np.clip(x, 0, width - 1)]
        return sampled * valid[..., None]

    result = (
        sample(x0, y0) * (1 - fx) * (1 - fy)
        + sample(x1, y0) * fx * (1 - fy)
        + sample(x0, y1) * (1 - fx) * fy
        + sample(x1, y1) * fx * fy
    )
    alpha = result[..., 3:4]
    result[..., :3] = np.divide(
        result[..., :3] * 255, alpha, out=np.zeros_like(result[..., :3]), where=alpha > 0
    )
    return Image.fromarray(np.clip(result, 0, 255).astype(np.uint8), "RGBA")


def make_gif(name: str) -> None:
    image = Image.open(SOURCE / f"{name}.png").convert("RGBA")
    box = image.getchannel("A").getbbox()
    if box is None:
        raise ValueError(f"{name} is empty")
    image = image.crop(box)
    image.thumbnail((202, 202), Image.Resampling.LANCZOS)

    OUTPUT.mkdir(parents=True, exist_ok=True)
    image.save(OUTPUT / f"{name}.png", optimize=True)
    palette = image.convert("RGB").quantize(colors=255, method=Image.Quantize.MEDIANCUT)

    frames = []
    for step in range(FRAME_COUNT):
        sprite = walking_frame(image, LEGS[name], step * math.tau / FRAME_COUNT)
        frame = Image.new("RGBA", (CANVAS_SIZE, CANVAS_SIZE), (0, 0, 0, 0))
        frame.alpha_composite(sprite, ((CANVAS_SIZE - image.width) // 2, 229 - image.height))
        paletted = frame.convert("RGB").quantize(palette=palette, dither=Image.Dither.NONE)
        transparent = frame.getchannel("A").point(lambda value: 255 if value < 100 else 0)
        paletted.paste(255, mask=transparent)
        paletted.putpalette(palette.getpalette()[:765] + [0, 0, 0])
        frames.append(paletted)

    frames[0].save(
        OUTPUT / f"{name}.gif", save_all=True, append_images=frames[1:],
        duration=FRAME_MS, loop=0, disposal=2, transparency=255, optimize=False,
    )


if __name__ == "__main__":
    for animal in LEGS:
        make_gif(animal)
        print(f"Created {animal}.gif")
