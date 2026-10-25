#!/bin/zsh
set -euo pipefail
source_dir="${0:A:h}"
destination="${1:-${source_dir:h}/Outnumbered Native Development.app}"
build_dir="$(mktemp -d /private/tmp/outnumbered-native.XXXXXX)"
trap 'rm -rf "$build_dir"' EXIT
app="$build_dir/Outnumbered Native Development.app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources/assets"
xcrun swiftc -O -target arm64-apple-macosx12.0 -module-cache-path "$source_dir/module-cache" -framework Cocoa \
  "$source_dir/Game.swift" "$source_dir/World.swift" "$source_dir/Decoder.swift" "$source_dir/QuestionSetup.swift" "$source_dir/QuestionSetupChecks.swift" "$source_dir/NativeCanvas.swift" \
  "$source_dir/ChallengeRenderer.swift" "$source_dir/ActivityTemplates.swift" "$source_dir/ActivityMore.swift" "$source_dir/ActivityFinal.swift" "$source_dir/ActivityFinalChecks.swift" "$source_dir/GameActivityState.swift" "$source_dir/Encounter.swift" "$source_dir/Telly.swift" \
  "$source_dir/LiveWire.swift" "$source_dir/Fountain.swift" "$source_dir/Calculator.swift" "$source_dir/GameCalculator.swift" "$source_dir/CalculatorChecks.swift" "$source_dir/Session.swift" "$source_dir/IntegrationChecks.swift" "$source_dir/EncounterChecks.swift" "$source_dir/EnergyLiveWireChecks.swift" "$source_dir/NativeApp.swift" "$source_dir/GameEncounters.swift" \
  -o "$app/Contents/MacOS/OutnumberedNative"
# Only decoded data resources and offline-rendered PCM are included. Original
# EXE, graphics driver machine code, and compiled TEMPLATE drawing code are not.
rsync -a --include='*/' --include='*.bin' --exclude='*' "$source_dir/resources/assets/catalog/decoded/" "$app/Contents/Resources/assets/catalog/decoded/"
find "$app/Contents/Resources/assets/catalog/decoded" -name 'TEMPLATE.GRA.*.bin' ! -name '*.2135.bin' ! -name '*.2137.bin' ! -name '*.2139.bin' ! -name '*.213b.bin' ! -name '*.213d.bin' ! -name '*.213f.bin' ! -name '*.2141.bin' ! -name '*.2143.bin' ! -name '*.2145.bin' ! -name '*.2147.bin' ! -name '*.2149.bin' ! -name '*.214b.bin' -delete
rsync -a "$source_dir/resources/assets/audio/" "$app/Contents/Resources/assets/audio/"
cp "$source_dir/map_coordinates.json" "$app/Contents/Resources/assets/map_coordinates.json"
cp "$source_dir/challenges.json" "$app/Contents/Resources/assets/challenges.json"
cat > "$app/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleExecutable</key><string>OutnumberedNative</string>
<key>CFBundleIdentifier</key><string>local.outnumbered.native.development</string>
<key>CFBundleName</key><string>Outnumbered Native Development</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleShortVersionString</key><string>0.7.0</string>
<key>CFBundleVersion</key><string>7</string>
<key>LSMinimumSystemVersion</key><string>12.0</string>
<key>NSHighResolutionCapable</key><true/>
</dict></plist>
PLIST
xattr -cr "$app"
xattr -d com.apple.FinderInfo "$app" 2>/dev/null || true
codesign --force --sign - "$app"
xattr -d com.apple.FinderInfo "$app" 2>/dev/null || true
codesign --verify --deep --strict "$app"
mkdir -p "$destination"
rsync -a --delete "$app/" "$destination/"
xattr -cr "$destination"
# File Provider can immediately re-add FinderInfo to the derived bundle root.
# Retry metadata cleanup, while still requiring strict signature verification.
verified=0
for attempt in 1 2 3; do
  xattr -d com.apple.FinderInfo "$destination" 2>/dev/null || true
  if codesign --verify --deep --strict "$destination"; then verified=1; break; fi
done
if (( verified == 0 )); then exit 1; fi
echo "$destination"
