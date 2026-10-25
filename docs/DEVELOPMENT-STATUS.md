# Native reimplementation 0.11 — October 25, 2026

The complete-game goal remains active. This turn made concrete implementation progress; it was not a wait or a blocked turn.

## Current playable milestone

`outputs/Outnumbered Native Development.app` is a self-contained ARM64 Cocoa/Swift app. It loads decoded original image/font data and offline reconstructed PCM. It does not execute the DOS EXE, graphics drivers, compiled TEMPLATE drawing code, or a DOS/PC CPU emulator. The previous, invented-rules prototype remains separate and unchanged.

Use **Game → Reference Rainfall Question** (Command-R) for answer644, or **Reference Telly Drill** (Command-D) for the six recorded answers19,12,22,7,22,3. These isolated Senior-rank checkpoints do not overwrite player saves. The drill starts at600 and reaches1,000 after six correct answers plus a lightning code piece. Its native decoder seed6908 is selected to match the three observed code symbols and Equipment hideout; it is not a recovered historical DOS seed. Return from the title now opens a player menu with separate native profiles, game/custom/practice choices and unfinished-game continuation.

Implemented in the development app:

- Native320×200 indexed canvas; original bitmap/font loading, original font measurement/wrapping and Enter/Esc/Tab keycap glyphs. Bitmap index1 is rendered as opaque black based on matching local-video wall/menu/player pixels; full driver mask behavior remains under analysis.
- Native exploration of the original two-floor hallway graph, five room interiors and paired elevators. Original object coordinates and player-width overlap select doors and activities. Original8-frame walking and fixed jump/flip schedules replace prototype physics.
- Original map, prize-board and television-table activity data now render natively. Prize/TV rendering passed640 recovered bank cases and two local-video fixtures. Measurement controls, video cassettes and one/two-series Cartoon line charts also render natively, covering960 additional bank cases. Bar charts also render natively across320 cases. Spinner, Great Eight music chart and Equipment List now render natively too; all ten activity families have source-derived visual context for the recovered bank. Prize palette/driver masking and both decorative intro animations remain incomplete; do not mistake static readable activity content for pixel-exact parity.
- Four-digit numeric answer entry, correct/wrong PCM, reading advice after one wrong answer, explicit Enter acknowledgement after the second, generated hint, and resolution after the third. Correct answers award300/200/100 at lower rank pairs,600/400/200 at higher pairs. A resolved question cannot award twice. Source1d06:00a2 gives clues on either correct or exhausted completion; only correct completion adds pending recharge.
- Recovered decoder puzzle generation, raw hidden-symbol flags, clue reveal and decision eligibility, original symbol/board/button artwork and Match Rule text. A confirmed choice now enters the original scripted ending: a wrong hideout loses; a correct hideout runs the reveal, progressive energy/time/victory tally and result screen.
- Separate versioned atomic session saves preserving room/return position, clock state, assigned question, partial input/attempt state, score, energy, pending recharge and decoder state. Existing corrupt/future saves are rejected and retained. Decoder/help pauses are normalized when restoring exploration.
- Original Telly spawn/movement/throw/stun phases, projectiles, lit belly overlays, endpoint-based zaps,90IRQ zap timing, delayed energy charge and real drill entry are integrated. Body collisions cost1 energy; thrown tricks cost15 game minutes. Collision knockback/impact animations remain incomplete.
- Native drill pools retain original enumeration and shuffle-without-replacement order, default rank settings,4/6/8/10 question counts, operand/result blanks, inverse subtraction/division construction and zero-factor ambiguity behavior. Feedback waits and delayed50-point awards are recovered from source and corroborated by local30fps frames. At leastN−1 correct answers grants the next code piece and100 points. The clock continues during drills. Partial Telly, zap and drill states are saved;0.2 sessions remain readable.
- Original LiveWire room-entry/post-activity spawn tests, movement, mirrored sprites, walking sound, energized zap dispersal and horizontal collision cost now run natively. Empty zaps cannot disperse it; jump excludes collision. The five dissipation frames remain collidable, as in the source. Exact room-entry scripted transitions, knockback and automatic warnings remain incomplete.
- The energy machine now replaces one of the original nine hallway furnishings. Up runs the recovered player/dispensing frames, adds all earned recharge credits once, clears them, and runs an empty response on reuse. Mid-recharge saves retain the one-time award. The original two-pixel-per-unit HUD meter is restored.
- All52 PC-speaker streams are available, including newly recovered impact51. Original strict sound-priority arbitration is implemented; slot51 preserves its original priority-word overread value as a bounded native table entry. This is not an analog or perceptual audio-parity claim.

## Evidence and verification

- Local video is `local-inputs/OutNumbered Gameplay.mkv`, SHA256`6960fb011e044a141e75e734e35140ff5c6c62e8e3440bf78f96d27baf957205`; verified unchanged this turn. YouTube is no longer used.
- Original ZIP found at `local-inputs/Super-Solvers-Outnumbered_DOS_EN.zip`, SHA256`6766fbaa4152436ec1096bf1a06c5889a7b82f25b5ee33bb7583629b8252dd14`; verified unchanged this turn. Earlier temporary attachment path is gone; extracted read-only evidence and the Downloads copy remain.
- `verification/native-integration-checks.json` additionally covers5,568 original pair/blank combinations, recorded six-question sequence, score600→900→1,000, code reward once, continuing drill clock, partial drill/zap persistence and old-session compatibility. Headless rendering remains separate from GUI verification. `telly-checks.json` records31 focused helper checks; activity rendering has640-case evidence.
- Decoder check rebuilt and ran: four independently transcribed raw-table fixtures plus4,000 seeded puzzles, deterministic replay, reveal/eligibility/save behavior. Original generator semantic coincidences remain preserved.
- Native window actually launched through computer use. Checked wrong-answer advice, second-wrong Enter acknowledgement, readable hint,644 accepted for100 after two errors and300 on the first try, News Room door return, movement, and visible News clues in the decoder. PNG evidence is in `verification/gui-*.png`. No claim that sound was perceptually heard or matched exactly.
- The 0.3 native-window check also completed all six local-video drill questions, reached1,000 and displayed the lightning secret. Then a live hallway Telly spawned; a real zap consumed one energy and opened a newly generated drill. Five correct answers and one deliberate error earned250 plus the100-point headphones secret, reaching1,350. The following capture shows the development midnight loss screen; the decoder retains both secrets. This verifies the encounter/reward path, not a complete ending or full playthrough. `verification/gui-observations-0.3.json` records exact screenshot meanings.
- Original correct-answer PC-speaker sequence7 has a strong measured pitch/tempo correspondence to the local recording around76.76s; see `reference-media/correct-answer-comparison.json`. PCM is an approximation of digital speaker output, not an analog/audio-bit-exact reconstruction.
- ARM64 Mach-O and system-library linkage checked. Packaging verification records app/ZIP hashes, signature and relocated headless execution. No installer or third-party runtime is required to play this milestone. Source rebuilding uses Apple command-line developer tools.

## Gaps that still prevent completion

1. Complete original menu/practice presentation and campaign RNG consumption. New-game question selection, eligibility, template bands and seed/variant choices now follow recovered source rules; all3,200 question cases compile and render. Data generation is compiled ahead of time for the recovered finite seed/variant domain. Original timed drawing effects and their random draws still prevent a complete campaign stream identity claim. Pre-0.7 saves use a marked migration because they lack historical startup choices.
2. Original timed activity effects and music/menu presentation. Calculator arithmetic is implemented; exact original dialog/pressed-button/digit rendering and F3 option presentation remain incomplete.
3. Detailed collision knockback/impact animations, portrait/code-capture transitions, queued input during feedback and full encounter sound/animation comparison. Telly/drill/zap/capture now run, but their native integration still needs broader runtime validation. No speculative door/jump sounds are substituted.
4. Detailed scrolling/door/elevator animations, exact HUD digits/meters, transparent/mirrored driver semantics, sprite occlusion and full-frame video comparison. Current room entry/exit/elevator changes are immediate native transitions.
5. Complete original ending presentation and remaining session/menu lifecycle. Native reveal, wrong-choice/midnight losses, bonus arithmetic, persistent lifetime/rank updates and replay now work. Original door/scroll transitions, bonus sliding, rank-tower animation and midnight meter-flash pixels remain incomplete; core profile/game/custom/practice choices now work; remaining original menu features/presentation are documented below.
6. Full playthrough validation, representative all-rank/activity edge cases, calibrated sound comparison, and final distribution packaging/signing. The ad-hoc development signature is not Apple notarization.

Next work should complete original question eligibility/selection and generation, then the original final encounter, while refining scripted transitions and collision response. Reuse retained assembly, raw byte tables and the local drill fixtures; do not restart completed recovery or reference browsing. `drill-analysis-derivatives.json` proves that analysis seeds changed only MZ initial IP/CS, never code or relocation bytes.

The next-work sentence above is historical through0.6. Question setup and ending recovery below supersede it. Continue with original menus/options/practice and the remaining transitions, collision and fidelity work.

`DRILL-RECOVERY.md` supersedes the historical `encounters-recovery-partial.md` handoff.

The0.4 verification adds native recharge/session/LiveWire integration checks and960 additional activity cases. Native-window observations verified a recharge meter increase and an energized LiveWire zap/removal. The isolated Command-E and Command-L checkpoints are mechanics fixtures, not recovered historical campaign seeds. `fountain-recovery.md`, `livewire-recovery.md` and `activity-more-recovery.md` retain sources and limits. Local source-video bar measurements show18→38 red columns at285.3s, consistent with9→19 energy; the transient three-column reading in another sample is not an integer-energy measurement.

Final0.4 app checks:139 passed, including all960 additional generated activity cases and the independently transcribed Cartoon Songs values/plot positions. In the final native window, the recorded graph rendered correctly and answer0 produced correct feedback and300 points. The recharge lower-body and exact meter corrections are covered by native render checks; earlier recharge/LiveWire window captures are retained with their build limitation.

Native0.5 adds the original four-digit calculator state machine, integer arithmetic/errors, equals/E, left-to-right chaining, operand/result deletion, original warning text, keyboard/mouse submission, native on/off checkbox and partial-expression saves with0.4 number migration. Live-window input calculated644 and submitted it for300 points. Bar charts add320 native contexts; seven of ten activity families now render. `calculator-recovery.md` records exact source, native UI differences and computer-use equal-token limits.

Final0.5 verification:189 integration checks passed, including3,844 arithmetic/error combinations, all1,280 additional static activity-bank cases, native equals-event routing and0.4 partial-number migration. The native window verified calculated644→300points, interview25→300points and calculator-off644→300points. Physical equals input was not established through the computer-use key token; E and mouse equals worked and the exact limitation is retained in the GUI ledger.

Native0.6 completes visual-context translation for all ten activity families. All3,170 recovered bank cases render through NativeGameView; the30 unresolved9056 cases remain explicit. Music/equipment auxiliary drawing values follow recovered original ranges/uniqueness and column-order rules, are generated once outside rendering, and are persisted. Spinner color14→12 replacement is backed by the original11041 driver routine.

Final0.6 verification:213 integration checks passed. Native-window checkpoints accepted spinner100, music106 and Equipment List29 for300points each; decoder Equipment clues were visibly revealed. Strict bundle verification still runs after bounded FinderInfo cleanup retries, and relocated/source ZIP checks remain required. `final-activities-recovery.md` records sources and limits. `GENERATION-NEXT.md` locates the newly recovered original setup order, lower-rank question eligibility and remaining math-level/selection uncertainties; current native new-game filtering/RNG ordering remain approximate.

Native0.7 replaces approximate new-game selection with original stored seeds, variants, enabled operations, per-rank eligibility and math-level template bands. Question choices precede decoder/fountain generation. Entry restores the recovered32-bit post-generation RNG state before music/equipment auxiliary columns. All3,200 cases now compile and render;30 original cross-group references yield empty second paragraphs inside the original zeroed allocation. They are retained with diagnostics rather than rewritten. Legacy saves preserve existing progress through a marked, once-only question-setup migration.

Final0.7 native checks:245 passed, including exact seed-one setup fixtures at all four tiers,240 rank/custom-setting combinations, all3,200 full-view renders, original generation boundaries, chart regeneration/resume, and legacy saves. The live native window separately accepted the original-selected Junior bar answer165 for300points and regenerated music answer106 for300points. `question-generation-recovery.md` and `verification/gui-observations-0.7.json` record the evidence and limits. The complete game is still unfinished.

Native 0.8 translates 14 original ending scripts containing 403 commands, with source-derived sprite/restore coordinates, frame waits and sound cues. The correct hideout now leads through a native reveal and progressive bonus tally; a wrong choice ends the game. Midnight follows its separate score/energy-clear path. Cartoon, Equipment and Sound backgrounds are corrected to original records 196/197/198. Native profile/run IDs preserve lifetime points and prevent a repeated result award after interrupted saves.

Final 0.8 checks: **269 passed**. These include mid-tally autosave/resume through the normal profile path, a simulated restart between profile and session commits, and replay reopened from disk with earned rank. The final native window showed Energy Left 2,550, the progressing score, Game 11,680 / Total 64,275, and a working replay into a reset 9:00 PM game. `ending-recovery.md` and `verification/gui-observations-0.8.json` retain exact evidence and limits. Command-5 opens this isolated reference checkpoint; it never writes player progress. The complete-game goal remains active.

Native 0.9 connects player creation/selection, separate custom game/practice settings, original configuration validation, unfinished-game continuation and Drill for Skill sets. Practice tracks attempts/correct answers across sets, applies no adventure rewards, and leaves the suspended game unchanged. Custom settings feed both room setup and Telly pools; rank still controls Telly count. Replay/new-game creation now retains mutated decoder pools and derives its next seed from the prior stream. Separate practice RNG and remaining timed/menu effects prevent claiming complete campaign identity. Native macOS dialogs replace original setting-dialog pixels. High-game history, music and original practice interstitial scripts remain pending. See menu-practice-recovery.md.

Final 0.9 candidate:309 headless checks passed, including an unchanged suspended adventure/file during practice, profile separation, legacy saves, all four practice sizes, custom room/drill settings, original validation and replay pool continuity. Native-window observations and package/source-rebuild verification are recorded separately. The complete-game goal remains active.


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
