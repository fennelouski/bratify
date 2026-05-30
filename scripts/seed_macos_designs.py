#!/usr/bin/env python3
"""
seed_macos_designs.py — pre-populate the brat app with diverse showcase designs
before taking App Store screenshots on macOS.

Usage:
    python3 scripts/seed_macos_designs.py            # seed + backup existing
    python3 scripts/seed_macos_designs.py --restore  # restore original data
"""
import argparse, json, os, shutil, subprocess, sys, uuid
from datetime import datetime, timezone

HOME = os.path.expanduser("~")
CONTAINER = f"{HOME}/Library/Containers/com.nathanfennel.brat/Data"
DOCS_DIR   = f"{CONTAINER}/Documents"
# Sandboxed app uses container Application Support; unsigned build uses system-wide path.
IMG_CACHE_CONTAINER = f"{CONTAINER}/Library/Application Support/ImageCache"
IMG_CACHE_SYSTEM    = f"{HOME}/Library/Application Support/ImageCache"
IMG_CACHE           = IMG_CACHE_CONTAINER   # primary write target; also write to system path
# Primary path (sandboxed) and fallback path (unsandboxed/system-level)
DESIGNS_FILE         = f"{DOCS_DIR}/designs.json"
DESIGNS_FILE_SYSTEM  = f"{HOME}/Documents/designs.json"
BACKUP_FILE          = f"{DOCS_DIR}/designs.json.bak"
BACKUP_FILE_SYSTEM   = f"{HOME}/Documents/designs.json.bak"

os.makedirs(IMG_CACHE_CONTAINER, exist_ok=True)
os.makedirs(IMG_CACHE_SYSTEM, exist_ok=True)

def ts():
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

def default_design():
    return {
        "brightness": 0, "contrast": 1, "saturation": 1, "exposure": 0,
        "gamma": 1, "sepia": 0, "invert": False, "pixelate": 0,
        "sharpen": 0, "monochrome": 0, "vignette": 0, "hue": 0,
        "highlightAmount": 1, "shadowAmount": 0, "grain": 0, "bloom": 0,
        "duotoneIntensity": 0, "duotoneColorHex": "8ACE00", "vibrance": 0,
        "posterizeLevels": 0, "colorTemperature": 6500, "colorTint": 0,
        "photoEffect": None, "halftone": 0, "unsharpMask": 0,
        "backgroundImageKey": None,
        "backgroundScale": 1, "backgroundFlipHorizontal": False,
        "backgroundFlipVertical": False, "backgroundBlur": 0,
        "backgroundAlpha": 1, "backgroundBrightness": 0,
        "backgroundContrast": 1, "backgroundSaturation": 1,
        "backgroundExposure": 0, "backgroundGamma": 1, "backgroundSepia": 0,
        "backgroundInvert": False, "backgroundPixelate": 0,
        "backgroundSharpen": 0, "backgroundMonochrome": 0,
        "backgroundVignette": 0, "backgroundHue": 0,
        "backgroundHighlightAmount": 1, "backgroundShadowAmount": 0,
        "backgroundGrain": 0, "backgroundBloom": 0,
        "backgroundDuotoneIntensity": 0, "backgroundDuotoneColorHex": "8ACE00",
        "backgroundVibrance": 0, "backgroundPosterizeLevels": 0,
        "backgroundColorTemperature": 6500, "backgroundColorTint": 0,
        "backgroundPhotoEffect": None, "backgroundHalftone": 0,
        "backgroundUnsharpMask": 0,
        "blur": 0, "height": 512, "width": 512,
        "pixelationScale": 1, "stretch": 0.3,
    }

def make(text, bg="#8ACE00", text_color="#FFFFFF", auto_color=False,
         image_key=None, font="Arial", font_size=96,
         pixelate=0, blur=0.0, stretch=0.3):
    d = default_design()
    d.update({
        "text": text,
        "backgroundColor": bg,
        "textColor": text_color,
        "usesAutomaticTextColor": auto_color,
        "fontName": font,
        "fontSize": float(font_size),
        "pixelate": pixelate,
        "blur": blur,
        "stretch": stretch,
        "id": str(uuid.uuid4()).upper(),
        "creationDate": ts(),
        "modifiedDate": ts(),
    })
    if image_key:
        d["backgroundImageKey"] = image_key
    return d

# ---------------------------------------------------------------------------
# Background image prep
# ---------------------------------------------------------------------------

def convert_heic_to_cache(heic_path):
    tmp = f"/tmp/bratify_bg_{uuid.uuid4().hex[:8]}.jpg"
    try:
        result = subprocess.run(
            ["sips", "-s", "format", "jpeg", "-s", "formatOptions", "80",
             "--resampleWidth", "1200", heic_path, "--out", tmp],
            capture_output=True, timeout=30
        )
        if result.returncode != 0:
            print(f"  sips failed for {os.path.basename(heic_path)}: {result.stderr.decode()[:80]}")
            return None
        img_key = str(uuid.uuid4()).upper()
        shutil.copy2(tmp, os.path.join(IMG_CACHE_CONTAINER, img_key))
        shutil.copy2(tmp, os.path.join(IMG_CACHE_SYSTEM, img_key))
        print(f"  Converted {os.path.basename(heic_path)} -> {img_key}")
        return img_key
    except Exception as e:
        print(f"  Could not convert {os.path.basename(heic_path)}: {e}")
        return None
    finally:
        if os.path.exists(tmp):
            os.remove(tmp)

def prepare_backgrounds():
    wallpapers = [
        "/System/Library/Desktop Pictures/iMac Green.heic",
        "/System/Library/Desktop Pictures/Mac Pink.heic",
        "/System/Library/Desktop Pictures/Mac Purple.heic",
    ]
    keys = []
    for wp in wallpapers:
        if os.path.exists(wp):
            key = convert_heic_to_cache(wp)
            if key:
                keys.append(key)
    return keys

# ---------------------------------------------------------------------------
# Restore
# ---------------------------------------------------------------------------

def restore():
    restored = False
    if os.path.exists(BACKUP_FILE):
        shutil.copy2(BACKUP_FILE, DESIGNS_FILE)
        os.remove(BACKUP_FILE)
        print(f"Restored {DESIGNS_FILE} from backup.")
        restored = True
    if os.path.exists(BACKUP_FILE_SYSTEM):
        shutil.copy2(BACKUP_FILE_SYSTEM, DESIGNS_FILE_SYSTEM)
        os.remove(BACKUP_FILE_SYSTEM)
        print(f"Restored {DESIGNS_FILE_SYSTEM} from backup.")
        restored = True
    if not restored:
        print("No backup found — nothing to restore.")
        sys.exit(0)

# ---------------------------------------------------------------------------
# Seed
# ---------------------------------------------------------------------------

def seed():
    if os.path.exists(DESIGNS_FILE):
        shutil.copy2(DESIGNS_FILE, BACKUP_FILE)
        print(f"Backed up existing designs -> {BACKUP_FILE}")
    if os.path.exists(DESIGNS_FILE_SYSTEM):
        shutil.copy2(DESIGNS_FILE_SYSTEM, BACKUP_FILE_SYSTEM)
        print(f"Backed up existing designs -> {BACKUP_FILE_SYSTEM}")

    print("Preparing background images...")
    bg_keys = prepare_backgrounds()
    g = bg_keys[0] if len(bg_keys) > 0 else None   # green wallpaper
    p = bg_keys[1] if len(bg_keys) > 1 else None   # pink wallpaper
    u = bg_keys[2] if len(bg_keys) > 2 else None   # purple wallpaper

    # Each design: different color, font, text, pixelate/blur combo, and stretch
    # (stretch varies text appearance, serving as kerning variation).
    # Fonts used: serif, handwriting/script, geometric, typewriter, display, cursive.
    designs = [
        # 1. Pastel blue · Georgia (serif) · image bg · tight stretch
        make("hello summer",
             bg="#A8D8EA", text_color="#1A1A2E",
             font="Georgia", font_size=100,
             image_key=g,
             pixelate=3, blur=1.0, stretch=0.1),

        # 2. Neon pink · Bradley Hand (handwriting) · loose stretch
        make("creative mode",
             bg="#FF6EC7", text_color="#FFFFFF",
             font="BradleyHandITCTT-Bold", font_size=90,
             pixelate=5, blur=0.0, stretch=0.7),

        # 3. Orange · Futura (geometric/retro) · image bg · tight stretch
        make("design life",
             bg="#FF8C42", text_color="#FFFFFF",
             font="Futura-Medium", font_size=104,
             image_key=p,
             pixelate=2, blur=2.0, stretch=0.15),

        # 4. Lime green · Baskerville (classic serif) · medium stretch
        make("indie dev",
             bg="#8ACE00", text_color="#1A1A1A",
             font="Baskerville", font_size=112,
             pixelate=4, blur=0.0, stretch=0.35),

        # 5. Lavender · American Typewriter · wide stretch
        make("good vibes",
             bg="#C5B4E3", text_color="#2D1B69",
             font="AmericanTypewriter", font_size=95,
             pixelate=0, blur=3.0, stretch=0.65),

        # 6. Dark · Zapfino (calligraphy script) · image bg · medium stretch
        make("just imagine",
             bg="#1A1A2E", text_color="#E8D5B7",
             font="Zapfino", font_size=68,
             image_key=u,
             pixelate=6, blur=1.5, stretch=0.4),

        # 7. Coral · Gill Sans (clean sans) · very tight stretch
        make("love this app",
             bg="#FF6B6B", text_color="#FFFFFF",
             font="GillSans", font_size=98,
             pixelate=3, blur=0.0, stretch=0.05),

        # 8. Golden yellow · Copperplate (display) · loose stretch
        make("make it pop",
             bg="#FFD166", text_color="#1A1A1A",
             font="Copperplate", font_size=96,
             pixelate=0, blur=2.5, stretch=0.8),

        # 9. Teal · Snell Roundhand (cursive) · normal stretch
        make("dream big",
             bg="#06D6A0", text_color="#FFFFFF",
             font="SnellRoundhand", font_size=110,
             pixelate=7, blur=0.0, stretch=0.3),

        # 10. Warm cream · Brush Script (handwritten) · medium-wide stretch
        make("stay curious",
             bg="#FFF0DC", text_color="#5C3317",
             font="BrushScriptMT", font_size=100,
             pixelate=2, blur=1.0, stretch=0.55),
    ]

    data = json.dumps(designs, indent=2)
    os.makedirs(DOCS_DIR, exist_ok=True)
    with open(DESIGNS_FILE, "w") as f:
        f.write(data)
    # Also write to the unsandboxed fallback path so an unsigned Xcode build can read it.
    os.makedirs(os.path.dirname(DESIGNS_FILE_SYSTEM), exist_ok=True)
    with open(DESIGNS_FILE_SYSTEM, "w") as f:
        f.write(data)

    print(f"\nWrote {len(designs)} designs to {DESIGNS_FILE}")
    print(f"Wrote {len(designs)} designs to {DESIGNS_FILE_SYSTEM}")
    if bg_keys:
        print(f"Background images cached: {len(bg_keys)} wallpapers")
    else:
        print("No background images — all designs use solid colours.")

# ---------------------------------------------------------------------------

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--restore", action="store_true", help="Restore backed-up designs")
    args = parser.parse_args()
    if args.restore:
        restore()
    else:
        seed()
