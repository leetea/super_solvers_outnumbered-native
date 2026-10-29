#!/bin/zsh
set -euo pipefail
source_dir="${0:A:h}"
destination="${1:-${source_dir:h}/Outnumbered.app}"
build_mode="${2:-release}"
if [[ "$destination" != *.app || -e "$destination" || -L "$destination" ]]; then
  print -u2 "Choose a new .app destination; existing files and bundles are preserved."
  exit 2
fi
swift_flags=()
case "$build_mode" in
  release) ;;
  distribution) ;;
  development) swift_flags=(-D OUTNUMBERED_DEVELOPMENT) ;;
  *) print -u2 "Use release, development or distribution as the second argument."; exit 2 ;;
esac
if [[ "$build_mode" == distribution ]]; then
  if [[ "${OUTNUMBERED_SIGNING_IDENTITY:-}" != "Developer ID Application: "* || -z "${OUTNUMBERED_NOTARY_PROFILE:-}" ]]; then
    print -u2 "Distribution requires OUTNUMBERED_SIGNING_IDENTITY and OUTNUMBERED_NOTARY_PROFILE in your keychain."
    exit 2
  fi
fi
build_dir="$(mktemp -d /private/tmp/outnumbered-native.XXXXXX)"
trap 'rm -rf "$build_dir"' EXIT
app="$build_dir/Outnumbered Native Development.app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources/assets"
xcrun swiftc "${swift_flags[@]}" -O -file-prefix-map "$source_dir=source" -target arm64-apple-macosx12.0 -module-cache-path "$source_dir/port-module-cache" -framework Cocoa \
  "$source_dir/Application.swift" "$source_dir/Platform.swift" "$source_dir/PlatformMac.swift" "$source_dir/EndingPulseChecks.swift" "$source_dir/RasterChecks.swift" "$source_dir/RasterFixtures.swift" "$source_dir/RankPresentation.swift" "$source_dir/EndingPresentationChecks.swift" "$source_dir/AdviceText.swift" "$source_dir/AdviceChecks.swift" "$source_dir/DecoderPanel.swift" "$source_dir/LifecycleChecks.swift" "$source_dir/Options.swift" "$source_dir/Notices.swift" "$source_dir/OptionsChecks.swift" "$source_dir/SettingsEditor.swift" "$source_dir/SettingsEditorChecks.swift" "$source_dir/Dialogs.swift" "$source_dir/DialogChecks.swift" "$source_dir/PaletteChecks.swift" "$source_dir/Keyboard.swift" "$source_dir/KeyboardChecks.swift" "$source_dir/SignIn.swift" "$source_dir/SignInChecks.swift" "$source_dir/Opening.swift" "$source_dir/OpeningChecks.swift" "$source_dir/TutorialChecks.swift" "$source_dir/GameTutorial.swift" "$source_dir/Tutorial.swift" "$source_dir/TutorialText.swift" "$source_dir/Scores.swift" "$source_dir/GameScores.swift" "$source_dir/ScoreChecks.swift" "$source_dir/Game.swift" "$source_dir/GameSettings.swift" "$source_dir/PracticePresentation.swift" "$source_dir/GameMenus.swift" "$source_dir/MenuChecks.swift" "$source_dir/Help.swift" "$source_dir/GameHelp.swift" "$source_dir/HelpChecks.swift" "$source_dir/RoomCamera.swift" "$source_dir/GameRoomCamera.swift" "$source_dir/RoomCameraChecks.swift" "$source_dir/FountainMotionChecks.swift" "$source_dir/PlayerMotion.swift" "$source_dir/GamePlayerMotion.swift" "$source_dir/PlayerMotionChecks.swift" "$source_dir/Movement.swift" "$source_dir/MovementChecks.swift" "$source_dir/TransitionActors.swift" "$source_dir/TransitionActorChecks.swift" "$source_dir/ElevatorTransition.swift" "$source_dir/GameElevatorTransition.swift" "$source_dir/ElevatorTransitionChecks.swift" "$source_dir/DoorTransition.swift" "$source_dir/GameDoorTransition.swift" "$source_dir/DoorTransitionChecks.swift" "$source_dir/World.swift" "$source_dir/Decoder.swift" "$source_dir/QuestionSetup.swift" "$source_dir/QuestionSetupChecks.swift" "$source_dir/Endings.swift" "$source_dir/GameEndings.swift" "$source_dir/EndingRenderer.swift" "$source_dir/EndingChecks.swift" "$source_dir/NativeCanvas.swift" \
  "$source_dir/ChallengeRenderer.swift" "$source_dir/ActivityTemplates.swift" "$source_dir/ActivityMore.swift" "$source_dir/ActivityFinal.swift" "$source_dir/ActivityFinalChecks.swift" "$source_dir/GameActivityState.swift" "$source_dir/ActivityPresentation.swift" "$source_dir/ActivityEffects.swift" "$source_dir/ActivityEffectsChecks.swift" "$source_dir/GameActivityPresentation.swift" "$source_dir/ActivityPresentationChecks.swift" "$source_dir/Encounter.swift" "$source_dir/DrillPresentation.swift" "$source_dir/DrillPresentationChecks.swift" "$source_dir/Telly.swift" \
  "$source_dir/LiveWire.swift" "$source_dir/Fountain.swift" "$source_dir/Calculator.swift" "$source_dir/GameCalculator.swift" "$source_dir/CalculatorChecks.swift" "$source_dir/Session.swift" "$source_dir/IntegrationChecks.swift" "$source_dir/EncounterChecks.swift" "$source_dir/EnergyLiveWireChecks.swift" "$source_dir/NativeApp.swift" "$source_dir/GameEncounters.swift" \
  -o "$app/Contents/MacOS/OutnumberedNative"
# Only decoded data resources and offline-rendered PCM are included. Original
# EXE, graphics driver machine code, and compiled TEMPLATE drawing code are not.
rsync -a --include='*/' --include='*.bin' --exclude='*' "$source_dir/resources/assets/catalog/decoded/" "$app/Contents/Resources/assets/catalog/decoded/"
find "$app/Contents/Resources/assets/catalog/decoded" -name 'TEMPLATE.GRA.*.bin' ! -name '*.2135.bin' ! -name '*.2137.bin' ! -name '*.2139.bin' ! -name '*.213b.bin' ! -name '*.213d.bin' ! -name '*.213f.bin' ! -name '*.2141.bin' ! -name '*.2143.bin' ! -name '*.2145.bin' ! -name '*.2147.bin' ! -name '*.2149.bin' ! -name '*.214b.bin' -delete
rsync -a "$source_dir/resources/assets/audio/" "$app/Contents/Resources/assets/audio/"
cp "$source_dir/map_coordinates.json" "$app/Contents/Resources/assets/map_coordinates.json"
cp "$source_dir/challenges.json" "$app/Contents/Resources/assets/challenges.json"
cp "$source_dir/ending-sequences.json" "$app/Contents/Resources/assets/ending-sequences.json"
cp "$source_dir/help-pages.json" "$app/Contents/Resources/assets/help-pages.json"
cat > "$app/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleExecutable</key><string>OutnumberedNative</string>
<key>CFBundleIdentifier</key><string>local.outnumbered.native.development</string>
<key>CFBundleName</key><string>Outnumbered Native Development</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleShortVersionString</key><string>0.36.0</string>
<key>CFBundleVersion</key><string>36</string>
<key>LSMinimumSystemVersion</key><string>12.0</string>
<key>NSHighResolutionCapable</key><true/>
</dict></plist>
PLIST
if [[ "$build_mode" != development ]]; then
  /usr/libexec/PlistBuddy -c 'Set :CFBundleIdentifier local.outnumbered.native' "$app/Contents/Info.plist"
  /usr/libexec/PlistBuddy -c 'Set :CFBundleName Outnumbered' "$app/Contents/Info.plist"
  /usr/libexec/PlistBuddy -c 'Set :CFBundleShortVersionString 1.0.0' "$app/Contents/Info.plist"
  /usr/libexec/PlistBuddy -c 'Set :CFBundleVersion 100' "$app/Contents/Info.plist"
fi
python3 "$source_dir/../tools/check_privacy.py" "$app"
xattr -cr "$app"
xattr -d com.apple.FinderInfo "$app" 2>/dev/null || true
if [[ "$build_mode" == distribution ]]; then
  codesign --force --options runtime --timestamp --sign "$OUTNUMBERED_SIGNING_IDENTITY" "$app"
  ditto -c -k --norsrc --noextattr --keepParent "$app" "$build_dir/notarization.zip"
  xcrun notarytool submit "$build_dir/notarization.zip" --keychain-profile "$OUTNUMBERED_NOTARY_PROFILE" --wait
  xcrun stapler staple "$app"
  xcrun stapler validate "$app"
  spctl --assess --type execute "$app"
else
  codesign --force --sign - "$app"
fi
xattr -d com.apple.FinderInfo "$app" 2>/dev/null || true
codesign --verify --deep --strict "$app"
mkdir -p "$destination"
rsync -a "$app/" "$destination/"
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
