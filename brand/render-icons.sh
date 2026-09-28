#!/bin/sh
# Renders the Seasonal app icons from brand/icons/icon.svg.
# Requires rsvg-convert. Re-run after editing the icon.
set -eu

ROOT="$(cd "$(dirname "$0")" && pwd)"
SRC="$ROOT/icons/icon.svg"

ANDROID="$ROOT/../android/app/src/main/res"
IOS="$ROOT/../ios/Runner/Assets.xcassets/AppIcon.appiconset"

render() {
  rsvg-convert -w "$1" -h "$1" "$SRC" -o "$2"
}

# Android launcher icons
render 48  "$ANDROID/mipmap-mdpi/ic_launcher.png"
render 72  "$ANDROID/mipmap-hdpi/ic_launcher.png"
render 96  "$ANDROID/mipmap-xhdpi/ic_launcher.png"
render 144 "$ANDROID/mipmap-xxhdpi/ic_launcher.png"
render 192 "$ANDROID/mipmap-xxxhdpi/ic_launcher.png"

# iOS app icons (names match Contents.json)
render 20   "$IOS/Icon-App-20x20@1x.png"
render 40   "$IOS/Icon-App-20x20@2x.png"
render 60   "$IOS/Icon-App-20x20@3x.png"
render 29   "$IOS/Icon-App-29x29@1x.png"
render 58   "$IOS/Icon-App-29x29@2x.png"
render 87   "$IOS/Icon-App-29x29@3x.png"
render 40   "$IOS/Icon-App-40x40@1x.png"
render 80   "$IOS/Icon-App-40x40@2x.png"
render 120  "$IOS/Icon-App-40x40@3x.png"
render 120  "$IOS/Icon-App-60x60@2x.png"
render 180  "$IOS/Icon-App-60x60@3x.png"
render 76   "$IOS/Icon-App-76x76@1x.png"
render 152  "$IOS/Icon-App-76x76@2x.png"
render 167  "$IOS/Icon-App-83.5x83.5@2x.png"
render 1024 "$IOS/Icon-App-1024x1024@1x.png"

# Standalone brand renders
render 512 "$ROOT/icons/icon-512.png"
render 1024 "$ROOT/icons/icon-1024.png"

echo "Rendered Seasonal icons."
