# Native Telly/drill recovery, 0.3

This ledger supersedes `encounters-recovery-partial.md`. Source recovery is static evidence; native-window observations are listed separately. No DOS execution or full campaign RNG identity is claimed. The user's local MKV replaces the historical YouTube reference.

## Implemented semantics

`Telly.swift`, `Encounter.swift` and `GameEncounters.swift` implement the original hallway Telly, projectiles, zap, math drill and code reward. `telly-recovery.md` retains the enemy tables and detailed helper evidence.

- Rank tiers use4/6/8/10 questions and default13-byte configuration rows from DS1277. Operator selection uses bit16, number selection bit4, and blank selection bit8. Default pool sizes are240/306/647/663.
- Pool enumeration visits operation, selected number, other number, then the swapped pair if unseen. At least one operand must be selected. Division excludes a zero low factor. Selection swaps a random remaining entry with the last remaining entry, then decrements the remaining count; refilling preserves the shuffled array. Blank selection repeats random modulo3 until enabled.
- Packed pair bits are operation:high:low. Addition/multiplication use high and low directly. Subtraction becomes `(high+low)-low=high`; division becomes `(high*low)/low=high`. Missing-divisor zero cases use a nonzero identity. Source1fc6:04d8 accepts any three-digit operand for `?*0=0` or `0*?=0`; this is multiplication ambiguity, not subtraction.
- Correct feedback waits240IRQ ticks, then awards50, then waits240 more. Wrong feedback waits480 ticks, shows the correct value in red for720, then continues. Between-question wait is120; initial wait240. Input is accepted only while asking. The game clock continues during regular drills.
- At leastN−1 correct answers grants100 and the next decoder secret exactly once. Aborting while asking retains the original threshold behavior. Successful result hold is720 ticks; unsuccessful hold480. The reference checkpoint's seed6908 was chosen to match visible symbols; it is not an inferred DOS recording seed.
- Zap is90IRQ ticks with frames47/48/49 and beam50..55; energy is charged at completion. Lit energized hits open a drill; unlit hits stun. Telly facing+1 mirrors its art (opposite the player artwork convention). Belly overlay shares body x and uses y+22 walking/y+24 standing.
- Original horizontal overlap, jump exclusion and collision priority are retained. Body contact costs1 energy; projectile contact adds15 game minutes. Knockback/impact animation is still incomplete. LiveWire and fountain behavior remain absent.

## Static evidence to reuse

- `drill-case-0-assembly.json`, `drill-case-2-assembly.json`, `drill-case-3-assembly.json`, `drill-math-0-assembly.json`, `drill-math-1-assembly.json`: recovered switch targets. The old direct20bbc/20bef error files are not authoritative.
- `drill-0x209f9-assembly.json`, `drill-0x20a4e-assembly.json`, `drill-0x20c37-assembly.json` and `rea-drill-*-evidence.json`: supporting routines and closed-session exports.
- `drill-analysis-derivatives.json`: derived MZs alter only initial IP/CS header bytes20..23. Code and relocation data are unchanged. Originals remain read only.
- Main question switch at20b81 targets20b89 for addition/multiplication,20bbc for subtraction,20bef for division. Math helper switch20a6d targets20a75 for addition/subtraction and20aa5 for multiplication/division.
- `drawing-api-handler-assembly.json` and `drawing-api-table.json`: true INT60 handler1c9a:0002 indexes DS4bf0 and far-calls drawing services. Do not confuse it with the activity dispatcher. Ghidra sometimes reverses segment-register MOV text; raw bytes8c c8 and8e d8 mean AX←CS then DS←AX.

## Audio

All52 speaker streams are rendered offline. Effect51 is an impact stream at11678..12016,338bytes,167IRQ ticks (about0.706s), not a stop command. Its stream SHA256 is `4c9eb36f24f15b15c81adcd045bb6fead91414eae45e3096e3557a4bc22c3e96`.

`OriginalSoundPolicy` preserves DS4506 priorities: an incoming effect interrupts only if strictly higher priority. Equal priority does not restart. Slot51's priority reads the next original word0x460c; the bounded native table retains17932. No perceptual, analog or bit-exact sound claim is made.

## Independent reference and verification

`drill-video-fixtures.json` records the six manually read questions and exact local-video frame timings. Answers19,12,22,7,22,3 take score600 to900, then1,000 with the lightning secret. Feedback-to-award spans approximately1.0–1.033s in the30fps source, consistent with240IRQ ticks. Later video shows a wrong answer9 for `?+6=17`, then red11 without a score award.

The102 integration checks include5,568 pair/blank mathematical identities, pool exhaustion/refill, fixture questions, delayed awards, one-time capture, continuing clock, partial saves and0.2 compatibility. Pure Telly helpers have31 checks; activity renderers have640 bank-case checks. Headless checks do not establish interactive success.

Native-window evidence in `verification/gui-observations-0.3.json` separately records the six-answer checkpoint and a live Telly→zap→generated drill→second secret path. The live run reached1,350 and then midnight; both secrets remained visible. This does not establish the original ending sequence or a finished game.

Remaining fidelity gaps include full campaign RNG consumption, queued input, portrait/capture transitions, collision animations, palette/mask behavior, broader ranks/settings and sound calibration. Continue from these sources instead of repeating completed recovery.
