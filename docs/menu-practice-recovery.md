# Native menus, settings and practice: milestone0.9

The native app now exposes player selection/creation, ordinary/custom games,
unfinished-game continuation, custom Drill for Skill, lifetime scores and sound/
calculator controls. Title Return opens the player menu. F2 opens Play Another
Game; F3 opens native options. Settings use accessible macOS controls with the
original labels, values, Undo, Standard Settings and validation rules. These
are native equivalents, not recovered DOS dialog pixels.

## Original evidence and data

Read-only input is the unpacked analysis derivative
`work/SSO-unpacked-analysis.EXE`, SHA256
`ff2e0d28e0a6aa8bcf86db1ea8a2980d2ccb1e10dd793bc15ab1bb929697b464`.
REA/Ghidra evidence is retained in `menu-analysis/`: menuraw0 is1f13:03a2
(validator), menuraw1 is2144:0009 (start/custom/practice lifecycle), menuraw2
is1fc6:0cd9 (practice entry). practiceasm0/1 cover1fc6:09c3 and1fc6:04d8;
practice-count recovers20c7:0005. Raw bytes resolve wrapped near-call targets
which Ghidra displays under a normalized segment. At206cb, E8 F3 F5 targets
1fcc1, not2fcc1. Its original CS:IP is1fc6:0061. The entry-context derivatives
change only initial IP/CS header bytes; no original code/relocation bytes change.
practiceinitasm and practicecelebrate retain those helper instructions.

DS5b6b is a13-byte shared configuration; DS1277 contains four standard records:

```
28, 4,20, 4,4,4,0,0,0,0,0,0,0
29,12,28, 4,4,4,4,0,4,0,4,0,0
30,20,20,20,4,4,4,4,4,4,4,0,0
31,28,28,20,4,4,4,4,4,4,4,4,4
```

- Bit16 in bytes0..3 enables Addition, Multiplication, Subtraction, Division.
- Bit4 in bytes0..12 selects numbers0..12 for the drill pool.
- Bit8 in bytes0..2 enables result, left-operand and right-operand blanks.
- Byte0 low two bits select math level0..3 for a custom game; the native labels
  are1,2,3,4(selects all). In practice they select5,10,15,20 questions per set.
- The validator requires at least one operation, number and blank format. It
  separately rejects division alone with only zero selected. The raw pool can
  contain entries in that case; the original UI validation is the reason it is
  rejected. No claim that the pool is empty is made.

2144:0009 starts from rank defaults and retains separate13-byte custom game and
practice records (profile offsets0d and1a). Custom room settings use only the
operation flags and math level; Telly problems also use number/blank selections,
while their set size remains4/6/8/10 according to rank pair.

Practice has DS790e set, counts attempts at problem entry (DS534c) and correct
answers after the first240-tick feedback wait (DS7912). Both counters wrap after
9999. Correct answers play sound37 and never award adventure points; practice
never awards a secret code or the100-point capture bonus. Its per-set question
count is5*(lowBits+1). Enter starts another set with running counters; Esc/F2
returns to the menu. The source rebuilds its problem pool per set. Existing
arithmetic, unique pool enumeration, random blank rejection and feedback waits
are shared with the recovered Telly drill implementation.

## Native save and lifecycle behavior

Custom settings are optional fields on each native profile. Session settings
are optional for backward compatibility and are fixed for that game; changing
future custom settings cannot replace its room questions or drill configuration.
Practice is transient and has a separate native RNG stream. It does not mutate
the suspended adventure or its file, including its clock, score, energy, decoder,
question and partial activity. Profiles retain independent adventures.

New adventure creation can now reseed from the previous generator while keeping
its mutated decoder symbol/pattern pools. Both ordinary replay and a new-game
menu choice use this continuity path. The first game still obtains an initial
native seed. This fixes the previous unconditional pool reset; it does not
establish complete DOS campaign stream identity, because timed drawing/menu/
practice consumption still differs or is not fully recovered.

## Verification and remaining limits

Rule/save/render checks cover all four settings records and set sizes, original
validation errors, custom operation/math-level room generation, rank-sized
custom Telly drills, feedback-delayed practice counters and no rewards, repeated
sets, independent profiles, unchanged suspended adventure bytes, old profile/
session compatibility, menu/modal clock suspension and decoder-pool continuity.
The accessible macOS settings controls are tested in a native window, separately
from the headless checks. See `verification/gui-observations-0.9.json` for build
identities and exact observations; packaging must verify extracted runtime and
an independent rebuild of the source ZIP before publication.

Still required: original notes and full help, high-game score history, new-user
messages, original music option, exact original menu art/pagination and practice
intro/result animation scripts. The practice result uses native text; its two
imperfect-result random draws and original sound indices28/34 are retained, but
the associated original animation is not yet translated. Perfect sets use40.
Original1fc6:0061 alternates DRILL sprites10/11, then12, with sound23; that
interstitial is retained as evidence and remains pending. Remaining encounter,
transition, ending, palette and complete-playthrough fidelity work still prevents
claiming a complete game. The original ZIP and local MKV are never modified.

A display/capture discrepancy remains explicitly unresolved: some computer-use window captures omit fixed text or labels on repeated frames, while a temporary diagnostic build writes identical correct native canvas PNGs before drawing. A direct CoreGraphics drawing trial did not resolve the captures and was reverted; diagnostic frame writing is removed from shipping source. verification/diagnostic-practice-canvas.png and diagnostic-missing-text-capture.png retain the distinction. This does not establish whether the discrepancy is in capture, background-window presentation or another display stage. No pixel-parity or fully resolved GUI claim is made.


## Superseding0.13 presentation recovery

The earlier pending-practice-animation statements above are historical.
practice-presentation-recovery.md records the implemented original introduction,
three result scripts, sound wait, counter panel and timer. Help, score history,
new-user guidance and music have also landed in0.10..0.12; File/sign-in,
transitions and full-game verification remain incomplete.
