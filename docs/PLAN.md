# Active goal: complete native Outnumbered reimplementation

Build a complete, self-contained ARM64 macOS reimplementation of Super Solvers Outnumbered. The original DOS executable, graphics drivers and DOS/PC CPU environment are not part of the finished app. Keep original assets and the supplied reference video unchanged.

## Current authoritative references

- Original ZIP: `Super-Solvers-Outnumbered_DOS_EN.zip`, SHA-256 `6766fbaa4152436ec1096bf1a06c5889a7b82f25b5ee33bb7583629b8252dd14`. Member hashes are in `outputs/archive-inventory.json`.
- Local gameplay/sound video: `local-inputs/OutNumbered Gameplay.mkv`, SHA-256 `6960fb011e044a141e75e734e35140ff5c6c62e8e3440bf78f96d27baf957205`. The user explicitly replaced browsing the YouTube link with this local file. The goal tool's original objective still contains the historical link; this newer user instruction supersedes it.
- Screenshot reference: https://www.myabandonware.com/game/super-solvers-outnumbered-115 . Gallery contains mixed palette modes, so determine palette from the matching edition/reference rather than blindly copying every capture.
- Original code/data, HELP.DAT, retained REA/Ghidra evidence, and timestamped local-video observations take precedence over invented prototype behavior.

## Milestones and acceptance criteria

1. Reference and preservation baseline: established source hashes, edition, local frames/audio, observed mechanics and unresolved gaps. Local-video replacement is authoritative; no further YouTube browsing. Original ZIP is also available unchanged at `local-inputs/Super-Solvers-Outnumbered_DOS_EN.zip`; ZIP and MKV hashes were rechecked October 24.
2. Complete asset recovery and native rendering: room backgrounds, sprites, fonts, HUD, teaching templates and sound. 389 bitmap records and 430 font glyphs recovered; all52 PC-speaker data sequences rendered to PCM. Trailer semantics, exact palette/transparency and audio parity still require validation.
3. One authentic original interaction: the recovered rainfall question now runs in the native development app. Original question text/numbers/answer644, three-attempt flow, Enter-before-hint acknowledgement, 300/200/100 score, room clues, pending recharge, paused clock and original-data correct/wrong PCM are integrated. Verified in an actual native window and with independent fixture checks. All3,200 recovered finite-domain question cases are compiled into native data. Original new-game choices, eligibility, template bands and setup order are implemented in0.7; complete custom/practice lifecycle and timed activity random consumption remain pending.
4. Traversal and encounters: hallway/room/elevator traversal plus Telly spawn/movement/throw/stun, projectiles,90IRQ zaps, delayed energy cost, drills and code-piece capture are integrated. Native drill pools reproduce original arithmetic and rank counts; the local six-question fixture reaches600→900→1,000. Body/projectile penalties are implemented; LiveWire room encounters and energy-machine recharge are integrated. Knockback/impact animations and full transition fidelity remain incomplete.
5. Complete game logic: all challenge types and ranks, drill/custom settings, four secret-code pieces, room clues, decoder/match rules, calculator, help, win/loss states, awards and progression. Native0.8 now includes the original scripted hideout reveal, energy/time/victory tally, wrong-choice/midnight losses, persistent lifetime/rank updates and replay, with269 passing checks and an observed ending checkpoint. Native0.9 adds player/game/custom/practice menus, separate13-byte settings, practice counters/no rewards and unfinished-game continuation, with309 checks. Music, exact menu/practice presentation, detailed effects/transitions and complete-playthrough verification remain required. Not complete.
6. Native persistence and packaging: profile foundation plus versioned atomic native session saves now preserve location, question/input/attempt state, clock, clues and score. Corrupt/future saves are preserved; transient menu pauses are normalized for resume. A self-contained ARM64 development bundle is available in outputs; final complete-game packaging remains.
7. Fidelity validation: compare full playable loops and representative edge cases against the original code and local recording; visually inspect the native window, check audio measurements, package/extract/launch independently, and retain clear limits. Not complete.

## Current working material

- `work/prototype/` and `outputs/Outnumbered Native Prototype.app`: preserved first playable prototype, with deliberately new gameplay. Do not mistake this for the complete game.
- `work/reimplementation/`: expanded native source, original resource catalog, decoded images/fonts/audio, question VM recovery, references and static evidence.
- `work/reimplementation/reference-media/source.json`: local video identity and measured tracks. Derived PNG frames and mono PCM are analysis copies only.
- `work/reimplementation/REFERENCE-OVERRIDE.md`: local-video replacement instruction and workspace migration.
- `outputs/Outnumbered Native Development.app`: current0.12 playable milestone. Command-R opens the local rainfall checkpoint; Command-D opens its six-question Telly drill. Command-4 opens an original-selected Junior question (answer165); Command-5 runs the ending checkpoint to Game11680/Total64275 and replay. These are isolated reference sessions. All ten activity families and3,200 recovered cases have native visual context. Core player/custom/practice menus are integrated; music/history, exact presentation, timed effects, detailed transitions and complete-game fidelity remain unresolved. This is separate from the preserved first prototype.
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
