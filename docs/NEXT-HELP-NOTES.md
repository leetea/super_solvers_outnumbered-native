# Continue after verified and published0.9

The previous goal turn made concrete recovery, implementation, GUI, package and
publication progress. It is not a blocked/no-progress turn. The complete-game
goal remains ACTIVE. Do not re-create the repository or ask for sign-in again.

## Authoritative current state

- Private repo: https://github.com/leetea/outnumbered-native-macos . main commit
  ab82925bf6937fdadd208407933064e7df057d34, tree
  b9e3430f31d587250f13e2225ce55987d83c1a2c. All63 blobs match the manifest.
  repository-sync.json is updated. The repository mirror has no Git CLI checkout.
- Native0.9 source: GameSettings.swift, GameMenus.swift, MenuChecks.swift and
  changes in NativeApp/Session/Game/Encounter/GameEncounters/GameEndings.
 309 checks pass in shipping app, extracted runtime ZIP, independently rebuilt
  source ZIP, and extracted repository wrapper build. All build/test handles
  completed; REA was closed. No pending agent work is required.
- Shipping binary SHA256 fa19bcb7a83b0cfadf402cb12e46739a1ec4882b53030aac6b27634d1a3fc7b8.
  Runtime ZIP cc41f316229e3c00a877ed1946d22947000c0e997b00aa1b65f765be658d2398.
  Source ZIP c881eb524cc64e769500bc6e590794ac30db3bff9d8a7dabfe757e3b69f97874.
- Source and original ZIP/MKV hashes remain unchanged. Local MKV supersedes
  YouTube; do not browse the superseded video link.

## New functionality and evidence

Title Return opens player menus. Core selection/creation, normal/custom games,
Continue/New prompt, separate custom/practice settings, lifetime display and
F2/F3 sound/calculator options work. Settings use native accessible controls;
these are not DOS dialog pixels. The shared13-byte record, original validation,
defaults and practice sizes5/10/15/20 are in menu-practice-recovery.md.

Practice uses its own native RNG/counters, never adventure rewards, and leaves
the suspended adventure unchanged. Native window reached5/5 correct, then
Problems6/Correct5 in another set, then resumed the prior custom adventure.
Its game file SHA stayed41b649531e4eadfd8cbcddd17d23ad83030be0a976812272833d74d0702b43f0
through practice; score0,energy12,9:03PM and prior settings resumed.
verification/gui-observations-0.9.json scopes each observation. A metadata-only
verification bundle uses temporary players; all32 compiled Mach-O sections match
shipping (gui-0.9-code-identity.json). Re-signing changes whole binary hashes.

Replay now retains mutated decoder pools and derives a seed from prior RNG.
Complete campaign stream identity is still unverified: timed drawing/menu and
practice consumption differ. Practice interstitials/result scripts are evidence,
not implemented animations. Do not treat the native result text as recovered art.

## Display/capture discrepancy

Repeated computer-use captures sometimes omit fixed text/operators/labels while
the app's temporary diagnostic PNG of the native frame stays identical/correct.
Diagnostic direct-CoreGraphics drawing did not resolve this and was reverted;
no diagnostic writer or drawing change remains in shipping source. Correct full
frames also appear in captures. Preserve the scope: this has not been proved a
game renderer bug, a capture bug, or a fully resolved display path. Continue its
validation with actual evidence. Do not blindly repeat drawing changes.

## Next recovery: full help and remaining original menu behavior

IMPORTANT correction discovered after the0.9 snapshot: asset_catalog.py/.json
descriptive labels notes_clipboard/notes_paper for DMOCKET1b62/1b63 were visual
guesses. Original21b1:02e6, linear21df6, draws them as the player-selection screen
at(0,0) and(0,94), while listing/deleting/creating/selecting up to10 DOS members.
Original HELP text does not mention a notes editor. Do not invent a persistent
notes feature from these labels. Correct catalog descriptions after checking
the original menu handlers; retain the actual full-game scope.

Useful files: original_help.json/.md (literal spans, raw hex and source offsets),
game-pseudocode.c (retained REA evidence IDs). HELP.DAT SHA256
e12419e3d15436f8370583ff459982fec236986791318bf7c9ca4555e90f22c1.
Recover original HELP record table, topics, pagination, illustrations and drawing
commands before implementing full source-faithful help. Existing F1 text is new
native control help only. Remaining menus include high-game history, new-user
messages, music, original file/exit behavior and exact sign-in presentation.

Source helper pointers:1fc6:0061 alternates DRILL10/11 then12 with sound23;
1fc6:0007 runs perfect-set script DS5516. Imperfect practice responses choose
independent sound28/34 and script pointers DS5771 (DS5378/5435). menu-analysis/
retains all raw instructions and entry-only derivative proof; no original code
bytes were changed. These scripts still need translation and reference checks.

Further full-game requirements remain: transitions, collision/knockback and input
queues, timed activities, rank/bonus animations, midnight meter flash, original
palette/masking, calibrated sounds and a complete natural playthrough. Publish
each verified next milestone using the existing source-ZIP/manifest/GitHub lease
workflow. No extra permission, CLI credentials or recurring automation is needed.
