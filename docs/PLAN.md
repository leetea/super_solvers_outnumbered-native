# Active goal: complete native Outnumbered reimplementation

Build a complete, self-contained ARM64 macOS reimplementation of Super Solvers Outnumbered. The original DOS executable, graphics drivers and DOS/PC CPU environment are not part of the finished app. Keep original assets and the supplied reference video unchanged.

## Current verified state — 0.28, October27,2026

924 native checks pass. The ordinary full adventure win and normal
quit/relaunch/replay were established at0.14; later fidelity milestones still
require a fresh complete playthrough before final completion.0.15–0.18 add
original staged doors/elevators, transition actor/RNG updates and camera rules.
0.19 adds persisted player motion, boundary/reaction sequences, collision-word
waits and original actor foreground order. Ordinary native play observed a
boundary impact, natural type25 projectile hit/recovery and vertical jump.
Independent runtime/source/repository rebuild verification accompanies each
published milestone. This is a development build, not the completed game.

The0.20 camera/recharge milestone implements the room ceiling camera
(the earlier energy-machine-eye label was incorrect) and recharge pose,
scroll and auxiliary-actor lifecycle. The0.21 milestone restores adventure Telly introduction, code-card capture,
rejection and persisted result waits. The0.22 milestone restores timed bars, needles, line plots and cassettes.
The0.23 milestone restores prize RNG/price/outline effects, spinner highlights, music flashes and equipment headers.
The0.24 milestone resolves TV caller-stack range arguments and restores its static effect.
The0.26 milestone restores original opening, member sign-in and File/play menus.
General world/practice queue behaviour is restored at0.27. Next recover remaining alternate/modifier input and original dialog presentation,
ending refinements and palette/audio calibration. Keep the
original completion criteria below; cosmetic fidelity and complete-loop
validation remain part of the requested end state. Detailed source-mask and
panel-occlusion parity need broader evidence than the current opaque overlap
check. See player-impact-recovery.md and DEVELOPMENT-STATUS.md.

## Current authoritative references

- Original ZIP: `Super-Solvers-Outnumbered_DOS_EN.zip`, SHA-256 `6766fbaa4152436ec1096bf1a06c5889a7b82f25b5ee33bb7583629b8252dd14`. Member hashes are in `outputs/archive-inventory.json`.
- Local gameplay/sound video: `local-inputs/OutNumbered Gameplay.mkv`, SHA-256 `6960fb011e044a141e75e734e35140ff5c6c62e8e3440bf78f96d27baf957205`. The user explicitly replaced browsing the YouTube link with this local file. The goal tool's original objective still contains the historical link; this newer user instruction supersedes it.
- Screenshot reference: https://www.myabandonware.com/game/super-solvers-outnumbered-115 . Gallery contains mixed palette modes, so determine palette from the matching edition/reference rather than blindly copying every capture.
- Original code/data, HELP.DAT, retained REA/Ghidra evidence, and timestamped local-video observations take precedence over invented prototype behavior.

## Milestones and acceptance criteria

1. Reference and preservation baseline: established source hashes, edition, local frames/audio, observed mechanics and unresolved gaps. Local-video replacement is authoritative; no further YouTube browsing. Original ZIP is also available unchanged at `local-inputs/Super-Solvers-Outnumbered_DOS_EN.zip`; ZIP and MKV hashes were rechecked October 24.
2. Complete asset recovery and native rendering: room backgrounds, sprites, fonts, HUD, teaching templates and sound. 389 bitmap records and 430 font glyphs recovered; all52 PC-speaker data sequences rendered to PCM. Trailer semantics, exact palette/transparency and audio parity still require validation.
3. One authentic original interaction: the recovered rainfall question now runs in the native development app. Original question text/numbers/answer644, three-attempt flow, Enter-before-hint acknowledgement, 300/200/100 score, room clues, pending recharge, paused clock and original-data correct/wrong PCM are integrated. Verified in an actual native window and with independent fixture checks. All3,200 recovered finite-domain question cases are compiled into native data. Original new-game choices, eligibility, template bands and setup order are implemented in0.7; complete custom/practice lifecycle and timed activity random consumption remain pending.
4. Traversal and encounters: hallway/room/elevator traversal plus Telly spawn/movement/throw/stun, projectiles,90IRQ zaps, delayed energy cost, drills and code-piece capture are integrated. Native drill pools reproduce original arithmetic and rank counts; the local six-question fixture reaches600→900→1,000. Body/projectile penalties are implemented; LiveWire room encounters and energy-machine recharge are integrated. Staged room/elevator transitions, camera ordering, persisted boundary/knockback/recovery and collision-word waits are implemented through0.19. Full masking/encounter and transition fidelity still require validation.
5. Complete game logic: all challenge types and ranks, drill/custom settings, four secret-code pieces, room clues, decoder/match rules, calculator, help, win/loss states, awards and progression. Native0.8 now includes the original scripted hideout reveal, energy/time/victory tally, wrong-choice/midnight losses, persistent lifetime/rank updates and replay, with269 passing checks and an observed ending checkpoint. Native0.9 adds player/game/custom/practice menus, separate13-byte settings, practice counters/no rewards and unfinished-game continuation, with309 checks. Music, exact menu/practice presentation, detailed effects/transitions and complete-playthrough verification remain required. Not complete.
6. Native persistence and packaging: profile foundation plus versioned atomic native session saves now preserve location, question/input/attempt state, clock, clues and score. Corrupt/future saves are preserved; transient menu pauses are normalized for resume. A self-contained ARM64 development bundle is available in outputs; final complete-game packaging remains.
7. Fidelity validation: compare full playable loops and representative edge cases against the original code and local recording; visually inspect the native window, check audio measurements, package/extract/launch independently, and retain clear limits. Not complete.

## Current working material

- `work/prototype/` and `outputs/Outnumbered Native Prototype.app`: preserved first playable prototype, with deliberately new gameplay. Do not mistake this for the complete game.
- `work/reimplementation/`: expanded native source, original resource catalog, decoded images/fonts/audio, question VM recovery, references and static evidence.
- `work/reimplementation/reference-media/source.json`: local video identity and measured tracks. Derived PNG frames and mono PCM are analysis copies only.
- `work/reimplementation/REFERENCE-OVERRIDE.md`: local-video replacement instruction and workspace migration.
- `outputs/Outnumbered Native Development.app`: current0.27 ARM64 development app with911 checks. All ten activity families, source-derived question setup, ordinary winning loop, core menus/custom/practice/help/scores, music/message options, staged traversal, camera rules, enemies, drills, zaps, recharge and player reactions are integrated. Checkpoint commands are isolated reference sessions, not ordinary-play evidence. Read the current status and milestone verification for remaining gaps; this is separate from the preserved first prototype.
- `work/reimplementation/DEVELOPMENT-STATUS.md`: implemented behavior, verification, known approximations and next work. Treat this alongside this checklist when continuing.

Current workspace is `.`. Earlier work was copied from the previous Codex directory without modifying that directory; compiler caches were omitted.

## GitHub milestone updates — authorized October24,2026

The user requested a GitHub repository containing the project, plan and relevant
chat context, with a push after every verified milestone. The private repository
is https://github.com/leetea/outnumbered-native-macos . The initial milestone0.7 was published
at commit `eaaeb33eb1f2daeb026ae8a79be1ee1eb8afb362`; all46 published file blobs
were checked against the local publication snapshot. The repository build ZIP
was extracted, strictly signature-verified and passed245 checks.

`repository/` is the local publication snapshot, with source in `repository/source`
and derived data in its runtime-data.zip. It is not a Git CLI checkout. Active
work stays in `work/reimplementation/`. Publish each next milestone only after
native checks, relevant window observations and source/package verification pass.
Update its README, plan, project context and milestone ledger; preserve unrelated
remote work using the current head/lease. The GitHub connector can upload blobs,
trees and commits and update main. Repository creation through the signed-in
website is complete; no CLI/token installation or recurring automation is needed.
Original ZIP/video and DOS executable/compiled drawing modules stay out of Git.
`repository/docs/MILESTONE-WORKFLOW.md` gives the continuing publication steps.

## Completion rule (unchanged)

The goal stays active until the complete gameplay loop and required game features are implemented and verified. Static analysis, recovered assets, a partial prototype, headless tests, or disabled unresolved mechanics do not establish a finished faithful game. Distinguish observed reference behavior, recovered code semantics, new native infrastructure and remaining assumptions. Do not silently invent a missing mechanic or mark a partial implementation complete.

Milestone0.9 extends source-derived settings into the app and preserves decoder pools between games. Settings use native macOS controls, and practice deliberately suspends the native adventure with its own RNG. Complete original menu/practice random consumption and interstitial presentation remain fidelity tasks; no campaign bit-identity or full-game completion is asserted.


Milestone 0.10 restores the original eight-topic help book:22 pages, four
illustrations, original font/keycaps, topic menu, frame and Back/Next/Done
navigation. F1 works from title, menus, activities and practice. Practice exposes
only About Drill for Skill. Help preserves unfinished question input and pauses
active adventure time. All332 headless checks pass; native-window observations
and independent package/source rebuilds are separate gates. See help-recovery.md.

The former notes_clipboard/paper catalog labels were corrected: original code
uses those assets for player sign-in. No source evidence establishes a notes
editor, so no invented editor is required. Music, original
practice/menu presentation, transitions, collisions, timed effects, ending
refinements and complete natural-playthrough validation remain required. The
complete-game goal stays active.


Milestone0.11 adds original lifetime/high-game score screens and the source
top-ten insertion rules. Individual winning games retain their pre-award rank;
ties stay behind existing equals, and ties with tenth do not qualify. History
and lifetime commit atomically with result recovery. Existing files without
history remain readable; historical games are not invented from lifetime totals.
353 native checks pass. Command7/8 open the score screens; Enter/Esc returns.
Arrow keys page lifetime rows when native profiles exceed the DOS ten slots.
Music/new-user options, original practice animations, full File/sign-in UI,
transitions/collision, timed effects and complete playthrough remain unfinished.
See score-history-recovery.md for original evidence and native adaptations.


Milestone0.12 connects independent Music and master Sound controls, opening
theme requests and all18 original new-user message texts. Native session flags
preserve original unseen/queued/acknowledged states; Yes resets them, No preserves
them. Source-derived room, challenge, collision, decoder, energy, clock and idle
input hooks display guidance through accessible macOS dialogs with readable key
names. Practice message state remains separate from the suspended adventure.
382 native checks pass. Native dialog pixels, exact settled-actor timing and
opening credits remain presentation gaps; see music-messages-recovery.md.
The complete-game goal remains active, with original practice animations,
transitions/collisions, timed effects, palette/sound calibration, ending refinements
and full natural-playthrough verification still required.


Milestone0.13 restores the original Drill for Skill introduction and all three
result animations (108 recovered sprite commands), their sounds and the
sound-completion wait before the original Enter-to-continue prompt. The source
counter panel/digits,120-tick problem-count boundary and independent practice
timer replace the previous native footer. Running counters survive another set;
practice still awards no adventure rewards and never writes its suspended save.
469 native checks pass, including both imperfect animation/sound selections,
exact two-draw result RNG consumption, timer/counter boundaries, sound waiting,
repeated sets, visible questions and deterministic animation repainting.
Keyboard-buffer/driver parity, opening/File presentation, transitions/collisions,
timed activities, palette/audio calibration, ending refinements and a full
natural adventure playthrough remain. See practice-presentation-recovery.md.


Milestone0.15 adds staged room-door entrances and exits using the recovered walking/rear/front/shrunken poses, panel order, aligned hallway return and source24IRQ pose waits. Native input is locked during the synchronous sequence. Transition state persists across native saves and destination initialization runs once after restoration. Legacy saves remain readable. All504 checks pass locally and ordinary News entrance/exit poses were captured in the native window. Elevator final facing is corrected, but its animation/vertical scroll remain unfinished. Unpaced original viewport copies are presented for4IRQ ticks natively; this is an explicit timing adaptation, not original-CPU-speed parity. See door-elevator-transition-recovery.md.


Milestone0.16 adds the original staged elevators: approach/shrunken/front poses, four mirrored-panel frames with source23IRQ waits, eight vertical bands with source23IRQ waits and correct direction, one-time travel sound/destination changes, final side-specific facing, input lockout and persistent travel progress. All563 native checks pass. Final native-window trips verified both left-side directions and corrected the viewport padding seam; right-side origins and save/resume have headless coverage. Existing resources remain unchanged. Camera/boundary edge cases, auxiliary actor stepping during synchronous transitions, collision/knockback/occlusion, timed activities, opening/File/sign-in, queued inputs and remaining ending/palette/audio fidelity still prevent complete-game status. See elevator-transition-recovery.md and gui-observations-0.16.json.


Milestone0.17 restores Telly, projectile and LiveWire updates during room/elevator pose and panel loops. Spawning stays disabled as in1559(0), but absent-enemy RNG draws and active motion continue. The elevator cleanup update is included; vertical scroll bands do not step actors. Saved per-frame cursors prevent repeated updates after restore, and older cursorless saves skip completed frames without replaying past RNG. Alignment preserves the initial facing until the original force-right pose. All582 native checks pass, including exact absent-enemy draw totals, active Telly motion, projectile/LiveWire updates, timer batching equivalence and legacy resume. A naturally spawned Telly/projectile advanced during a normal native-window News entrance; room exit and elevator travel also completed. Detailed camera/bounds, collision/knockback/occlusion, machine eye animation, timed activities, opening/File/sign-in, queued input and remaining ending/palette/audio fidelity keep the complete-game goal active.


Milestone0.20 restores the room ceiling security camera (correcting the earlier energy-machine-eye label): original panning row14, four-update holds, actor order, entry/exit lifecycle and retained timing state. Recharge now uses recovered scrolling alignment, raised player poses, continued enemy/projectile updates and exact per-frame RNG bookkeeping; the unpaced-copy display interval remains a documented native adaptation. Older in-progress actions retain their prior schedule. All713 checks pass. Local video shows the corresponding pan poses; ordinary native play separately showed a panning Cartoon camera and empty-machine interaction with scroll, moving Telly/projectile and unchanged energy9. Remaining encounter/capture presentation, timed activity effects/RNG, opening/File/sign-in, queued input, ending/palette/mask/audio refinements and a fresh full playthrough keep the complete-game goal active.


Milestone0.23 restores prize price/outline flashes and their original retry-based random consumption, spinner highlights, Great Eight music-header flashes and Equipment List header cycles. Native saves retain the initial random stream and applied checkpoint cursor; repainting cannot advance it, and future phases do not consume it early. Question/input appear only after the recovered waits.800 native checks pass, including1280 endpoint comparisons, exact54-draw prize fixture/next-draw validation, partial restore and prior0.22 compatibility. Native windows separately verify spinner/music/equipment answers and a normal new-game prize activity17→300points with Game Show clues. The TV static effect remains pending because its command23 aliases a bounded-range helper with unresolved caller arguments. Opening/File/sign-in, queued input, driver masks/palette/audio, ending refinements and a fresh complete playthrough still prevent complete-game status. See activity-effects-recovery.md.


Milestone0.24 restores the television-table noise introduction:60 paired XOR phases with original sound/waits and2580 random draws. Focused caller-stack recovery establishes the no-argument range bounds0..8512; the native effect preserves the EGA byte masks, including its same-byte crossing quirk.818 checks pass, covering320 static endpoints, independent coordinates/stream states, save/resume, input lockout and every byte alignment. Native windows verified the isolated168→300 checkpoint and a normal Equipment TV activity222→600 total/room clues. All nine activity families with timed drawing now have native schedules; the map needs no such intro. This does not establish complete campaign/pixel/audio identity. Opening/File/sign-in, queued input, remaining mask/palette/ending/audio refinements and a fresh full ordinary win remain required. See television-effect-recovery.md.


Milestone0.25 restores the three-page opening with24 original instruction lines, Enter-keycap prompts,12000IRQ page deadlines and24IRQ grey wipes, followed by40 original sprite/sound commands in three scripts (320/160/1080IRQ). The native compositor retains source restore references and callback copy bounds, locks input during the entrance and hands off to the existing player menu.848 checks pass, including timeout cycling, sound boundaries, ignored-key clock stability, pure repainting and suspended-game preservation. Native windows show title/objective/Telly pages, Escape/No, flight and station frames, completion and replay. Copied profile/session files remain byte-for-byte unchanged. Native F1/click/exit-dialog adaptations and broader palette/mask/audio limits are explicit. Original File/sign-in, general input buffering, remaining ending refinements and a fresh complete ordinary win remain required. See opening-presentation-recovery.md.


Milestone0.26 restores the original member clipboard and eight-slot name editor, the three-choice play panel and separate adventure/practice File menus. The source-derived rows, rank/lifetime columns, wrap navigation, XOR selection and caret timing replace the earlier eight-item native menu. Existing native player names/saves remain compatible. Removal is a named native adaptation: profiles move into a recoverable archive, and their unfinished sessions and high-game history remain intact. 877 native checks pass, including independent file preservation, archive/reload/restore, duplicate rejection, menu/pause navigation and pure rendering. Native confirmations/settings/restore controls, general BIOS buffering, remaining ending/rank/midnight/palette/mask/audio refinements and a fresh full ordinary playthrough still prevent complete-game status. See signin-file-recovery.md.

Next: original general BIOS input queue/repeat semantics, remaining confirmation/settings and ending/rank/midnight behavior, full driver palette/masks/occlusion and audio calibration, then a fresh full natural adventure and final packaging review.


Milestone0.27 adds recovered last-key world polling, deferred ordinary keys through synchronous gameplay actions, separately tracked held controls and original right-walking priority. Held Up/diagonal requests repeat after landing; Space follows first-make/repeat/release flags at game frames. Practice keeps early Enter through its result animation/sound wait, while new answer fields discard keys from preceding drawing/feedback. 911 checks pass, including input queue ordering/flush, deferred door delivery, physical movement across menus, release/priority/landing, editor lockout and queued practice continuation. Native focus loss clears input as a platform adaptation. BIOS buffer capacity/overflow, alternate modifier/keyboard-type handling, remaining dialog/ending input, palette/mask/audio refinements and a fresh complete ordinary adventure remain unverified; this is not the complete game. See keyboard-recovery.md.


Milestone0.28 restores the original EGA palette swap (index0 blue, index1 black), retains all original bitmap indices through drawing, and applies the same palette to text and primitives. Source pen11h remains black for final prize prices; random pen0 remains blue. Black/white selection and TV XOR now preserve the low plane. Local MKV31/33/110s corroborates black member text, selected rows, menu footers and plot/background colors. 924 checks pass, including thirteen palette/index/RGBA/compositing checks. Full masks/occlusion, display/audio calibration, original dialogs/alternate input/endings and a fresh complete ordinary playthrough remain open. See palette-recovery.md.
