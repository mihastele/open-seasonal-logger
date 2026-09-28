#!/bin/sh
# Renders every Seasonal icon from the SVG masters in brand/icons/:
#   icon.svg       full-bleed app icon (Paper->Linen gradient + brush mark)
#   foreground.svg brush mark at 50% on transparency (masked-icon artwork)
# Requires rsvg-convert (Fedora: sudo dnf install librsvg2-tools).
# The .ico and maskable composites additionally need python3 + Pillow;
# they are skipped with a warning when Pillow is missing.
# Re-run after editing either master.
set -eu

ROOT="$(cd "$(dirname "$0")" && pwd)"
SRC="$ROOT/icons/icon.svg"
FG="$ROOT/icons/foreground.svg"

ANDROID="$ROOT/../android/app/src/main/res"
IOS="$ROOT/../ios/Runner/Assets.xcassets/AppIcon.appiconset"
LINUX="$ROOT/../linux"
SITE="$ROOT/../site"
WEB="$ROOT/../web"

render() {
  rsvg-convert -w "$1" -h "$1" "$2" -o "$3"
}

# Android legacy launcher icons
render 48  "$SRC" "$ANDROID/mipmap-mdpi/ic_launcher.png"
render 72  "$SRC" "$ANDROID/mipmap-hdpi/ic_launcher.png"
render 96  "$SRC" "$ANDROID/mipmap-xhdpi/ic_launcher.png"
render 144 "$SRC" "$ANDROID/mipmap-xxhdpi/ic_launcher.png"
render 192 "$SRC" "$ANDROID/mipmap-xxxhdpi/ic_launcher.png"

# Android adaptive-icon foregrounds (108dp @ mdpi..xxxhdpi).
# Background is @color/ic_launcher_background (values/colors.xml).
render 108 "$FG" "$ANDROID/mipmap-mdpi/ic_launcher_foreground.png"
render 162 "$FG" "$ANDROID/mipmap-hdpi/ic_launcher_foreground.png"
render 216 "$FG" "$ANDROID/mipmap-xhdpi/ic_launcher_foreground.png"
render 324 "$FG" "$ANDROID/mipmap-xxhdpi/ic_launcher_foreground.png"
render 432 "$FG" "$ANDROID/mipmap-xxxhdpi/ic_launcher_foreground.png"

# iOS app icons (names match Contents.json)
render 20   "$SRC" "$IOS/Icon-App-20x20@1x.png"
render 40   "$SRC" "$IOS/Icon-App-20x20@2x.png"
render 60   "$SRC" "$IOS/Icon-App-20x20@3x.png"
render 29   "$SRC" "$IOS/Icon-App-29x29@1x.png"
render 58   "$SRC" "$IOS/Icon-App-29x29@2x.png"
render 87   "$SRC" "$IOS/Icon-App-29x29@3x.png"
render 40   "$SRC" "$IOS/Icon-App-40x40@1x.png"
render 80   "$SRC" "$IOS/Icon-App-40x40@2x.png"
render 120  "$SRC" "$IOS/Icon-App-40x40@3x.png"
render 120  "$SRC" "$IOS/Icon-App-60x60@2x.png"
render 180  "$SRC" "$IOS/Icon-App-60x60@3x.png"
render 76   "$SRC" "$IOS/Icon-App-76x76@1x.png"
render 152  "$SRC" "$IOS/Icon-App-76x76@2x.png"
render 167  "$SRC" "$IOS/Icon-App-83.5x83.5@2x.png"
render 1024 "$SRC" "$IOS/Icon-App-1024x1024@1x.png"

# Linux: bundled window icon + installable hicolor theme set
render 512 "$SRC" "$LINUX/runner/assets/app_icon.png"
for s in 16 22 24 32 36 48 64 72 96 128 192 256 512; do
  mkdir -p "$LINUX/icons/hicolor/${s}x${s}/apps"
  render "$s" "$SRC" \
    "$LINUX/icons/hicolor/${s}x${s}/apps/com.seasonal.seasonal.png"
done

# Static site favicons
cp "$SRC" "$SITE/favicon.svg"
render 16  "$SRC" "$SITE/assets/icon-16.png"
render 32  "$SRC" "$SITE/assets/icon-32.png"
render 180 "$SRC" "$SITE/assets/apple-touch-icon.png"
render 192 "$SRC" "$SITE/assets/icon-192.png"
render 512 "$SRC" "$SITE/assets/icon-512.png"

# Flutter web shell
render 32  "$SRC" "$WEB/favicon.png"
render 192 "$SRC" "$WEB/icons/Icon-192.png"
render 512 "$SRC" "$WEB/icons/Icon-512.png"

# Standalone brand renders
render 512  "$SRC" "$ROOT/icons/icon-512.png"
render 1024 "$SRC" "$ROOT/icons/icon-1024.png"

# Composites needing Pillow: maskable web icons (foreground over Linen)
# and the multi-size site .ico. Skipped gracefully when Pillow is missing.
if python3 -c "import PIL" 2>/dev/null; then
  render 192 "$FG" /tmp/seasonal-fg-192.png
  render 512 "$FG" /tmp/seasonal-fg-512.png
  render 256 "$SRC" /tmp/seasonal-ico-256.png
  python3 - "$WEB" "$SITE" <<'EOF'
import sys
from PIL import Image
web, site = sys.argv[1], sys.argv[2]
for size in (192, 512):
    bg = Image.new('RGBA', (size, size), (0xF3, 0xE9, 0xDE, 255))
    bg.alpha_composite(
        Image.open(f'/tmp/seasonal-fg-{size}.png').convert('RGBA'))
    bg.convert('RGB').save(f'{web}/icons/Icon-maskable-{size}.png')
Image.open('/tmp/seasonal-ico-256.png').save(
    f'{site}/favicon.ico', sizes=[(16, 16), (32, 32), (48, 48)])
EOF
  rm -f /tmp/seasonal-fg-192.png /tmp/seasonal-fg-512.png \
    /tmp/seasonal-ico-256.png
else
  echo "warning: Pillow not found, skipped Icon-maskable-*.png + favicon.ico" >&2
fi

echo "Rendered Seasonal icons."
