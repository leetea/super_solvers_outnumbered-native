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
5. Complete game logic: all challenge types and ranks, drill/custom settings, four secret-code pieces, room clues, decoder/match rules, calculator, notes/help, win/loss states, awards and progression. Not complete.
6. Native persistence and packaging: profile foundation plus versioned atomic native session saves now preserve location, question/input/attempt state, clock, clues and score. Corrupt/future saves are preserved; transient menu pauses are normalized for resume. A self-contained ARM64 development bundle is available in outputs; final complete-game packaging remains.
7. Fidelity validation: compare full playable loops and representative edge cases against the original code and local recording; visually inspect the native window, check audio measurements, package/extract/launch independently, and retain clear limits. Not complete.

## Current working material

- `work/prototype/` and `outputs/Outnumbered Native Prototype.app`: preserved first playable prototype, with deliberately new gameplay. Do not mistake this for the complete game.
- `work/reimplementation/`: expanded native source, original resource catalog, decoded images/fonts/audio, question VM recovery, references and static evidence.
- `work/reimplementation/reference-media/source.json`: local video identity and measured tracks. Derived PNG frames and mono PCM are analysis copies only.
- `work/reimplementation/REFERENCE-OVERRIDE.md`: local-video replacement instruction and workspace migration.
- `outputs/Outnumbered Native Development.app`: current0.7 playable milestone. Command-R opens the local rainfall checkpoint; Command-D opens its six-question Telly drill. Command-4 opens an original-selected Junior question (answer165). These are isolated reference sessions. All ten activity families and3,200 recovered cases now have native visual context. Original timed effects, final encounter and session progression remain unresolved. This is separate from the preserved first prototype.
- `work/reimplementation/DEVELOPMENT-STATUS.md`: implemented behavior, verification, known approximations and next work. Treat this alongside this checklist when continuing.

Current workspace is `.`. Earlier work was copied from the previous Codex directory without modifying that directory; compiler caches were omitted.

## Completion rule

The goal stays active until the complete gameplay loop and required game features are implemented and verified. Static analysis, recovered assets, a partial prototype, headless tests, or disabled unresolved mechanics do not establish a finished faithful game. Distinguish observed reference behavior, recovered code semantics, new native infrastructure and remaining assumptions. Do not silently invent a missing mechanic or mark a partial implementation complete.
