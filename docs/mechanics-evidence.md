# Clock, energy, score and lifetime ranks recovered from the DOS executable

Scope: offline original executable bytes and existing Ghidra output only. No REA session, DOS execution, original-asset mutation or shared browser access was used for this recovery. Ghidra pseudocode is a reverse-engineering aid, not the original source; some unrelated routines contain overlapping-instruction and bad-jump-table errors.

Analysis artifact: `work/SSO-unpacked-analysis.EXE`, SHA-256 `ff2e0d28e0a6aa8bcf86db1ea8a2980d2ccb1e10dd793bc15ab1bb929697b464`. The DOS module begins at file offset 8064. A reported analysis linear address `A` maps to file offset `8064 + A - 0x10000`. DS is analysis segment `0x23f3`, so DS-relative data offset `D` maps through `A=0x23f30+D`. The unrelocated segment immediate in file bytes is `0x13f3`; Ghidra adds its load segment `0x1000`.

## Clock

The timer setup at analysis `0x1ca1b` (`FUN_1ca1_000b`, evidence `ev_6de81d026c543454605e13b96f3a2ca1672906d8bcfaab82c7aa370941197e3a`) saves vector 8, installs its own handler at segment `1ca1:0060` (linear `0x1ca70`), and writes PIT channel 0 divisor `0x13b1=5041` using bytes `B1 13`.

The ISR is not adequately represented by the exported decompiler functions. Direct bytes establish:

| Analysis address | Original instruction bytes | Meaning |
|---|---|---|
| `0x1ca80` | `ff 06 78 73` | Increment word DS:7378. |
| `0x1ca84` | `83 3e 78 73 0d` | Compare the BIOS-chain divider with 13. |
| `0x1ca89` | `7c 0b` | Skip the chain if the divider is below 13. |
| `0x1ca8b` | `c7 06 78 73 00 00` | Reset the divider. |
| `0x1ca91` | `9c ff 1e 5c 4c` | Push flags and far-call the saved vector 8. |
| `0x1ca96` | `83 06 7e 5b 01` | Add one to low word of the game IRQ counter. |
| `0x1ca9b` | `83 16 80 5b 00` | Add carry to the high word. |

**The 32-bit DS:5b7e/5b80 counter increments on every new PIT interrupt, not once per original BIOS tick.** The divide-by-13 operation only controls chaining of the original BIOS handler.

`FUN_170d_0007` (`0x170d7`, evidence `ev_6bacd4e991b5b164fc5e2f50f2a23c9562b6bc9ba62fccba8514d047c1491ce8`) polls the deadline at DS:6d5a/6d5c. When the counter is **strictly greater** than the deadline, it calls `FUN_11b0_109e(1)` to add one displayed game minute, then sets the next deadline to the **current counter + 780 (`0x30c`)**. It does not add multiple elapsed minutes to catch up in one poll. The main loop then schedules its nominal next frame for current counter +24.

Using the conventional rounded PC PIT input frequency of 1,193,182 Hz:

- IRQ frequency = `1193182 / 5041 = 236.695... Hz`.
- Nominal deadline interval = `780 * 5041 / 1193182 = 3.295373... seconds per game minute`.
- 180 such intervals = `593.167178... seconds` (about 9 minutes 53 seconds) of clock-active time, before polling and other scheduling effects.
- With an exactly regular 24-IRQ polling cadence, the strict comparison makes each interval 792 IRQ ticks, or `3.346071... seconds`. Actual DOS loop processing, pauses and modal activity can add variation. Neither nominal interval is a recorded end-to-end runtime measurement.

The input frequency is a hardware convention used for native conversion, not an oscillator measurement from this artifact. `VerifiedClock.nominalSecondsPerGameMinute` documents that assumption. Its `pollAfterIRQTicks` performs precisely one deadline poll, allowing the caller to reproduce the original frame cadence. `advance(realSeconds:)` converts real time into IRQ ticks and performs one poll; it deliberately does not silently catch up multiple minutes.

`FUN_11b0_1245` (`0x12d45`, evidence `ev_779fb9251c3a46219143811665d5706fb01b464ae88c321243ea230537ece8a3`) increments a nested pause counter at DS:00a6. At the outermost pause it stores the remaining deadline offset. `FUN_11b0_1291` (`0x12d91`, evidence `ev_e044a0406d10a399fda27c4e1cf2be11659cccc664f3ad6571f539a4443f8f9b`) decrements it and restores current counter + saved remaining offset on the final resume. Room challenge entry surrounds its UI with these pause/resume calls. The ISR counter continues while the displayed game clock is paused.

`FUN_16c0_00d7` (`0x16cd7`, evidence `ev_57dbfa344203aac866c19d093ae491a57c95118422cd2688c6d8aa10b985e923`) initializes the displayed HHMM value to **900**, session score to zero, energy to **12**, pending refill credits to zero, and a fresh clock deadline. Top-level startup sets the deadline to current counter +780.

`FUN_11b0_109e` (`0x12b9e`, evidence `ev_ec9fdd2b7000618f94f77bced397eff81480d7e103a0ccc9d34b06cd4c2321db`) stores HHMM numerically, rolls minute values above 59 into hours, and clamps values above 1159 to 1200. At midnight during normal active play it clears session score and energy and enters the loss path. A collision branch in `FUN_11b0_160c` adds 15 displayed game minutes directly. Clock advancement must therefore support verified event penalties as well as regular timer ticks; the current pure helper only covers regular ticks/pause/end.

## Eight lifetime ranks and four tuning records

**There are eight lifetime-rank thresholds but only four 26-byte tuning records at DS:11c1.** Interpreting eight successive records here would read unrelated bytes as game rules.

The eight little-endian 32-bit values at DS:5852 are exactly:

| Rank index | Rank | Lifetime points |
|---|---|---:|
| 0 | Trainee | 0 |
| 1 | Junior | 5,000 |
| 2 | Senior | 30,000 |
| 3 | Pro | 60,000 |
| 4 | Expert | 120,000 |
| 5 | Master | 200,000 |
| 6 | All-Star | 300,000 |
| 7 | Champion | 500,000 |

`FUN_21b1_0008` (`0x21b18`, evidence `ev_8b05041f7dbd3a458b8cf7f55f066158582cc075e55e6952f280cb6f7a3be6c4`) scans those eight thresholds. `FUN_21b1_0039` (`0x21b49`, evidence `ev_42130366e544e7c182ebe97d677d860272d0e82a6b4b89ee21779d16a1c32574`) supplies a selected player's 32-bit lifetime total. `FUN_21b1_02e6` (`0x21df6`, evidence `ev_ebc8b60c850f950255f9d2a37e39049ea64576e8bc16831ea0b3c8490e4d37f0`) sets DS:5b86 to the returned rank index shifted right by one. Thus tuning rows serve the pairs Trainee/Junior, Senior/Pro, Expert/Master, All-Star/Champion.

Raw tuning rows, 13 little-endian 16-bit words each:

```text
0: 300, 100, 10, 20,  0, 1, 8, 40, 1000, 100, 25, 20, 2
1: 300, 100, 15, 25, 30, 2, 6, 50, 2000, 150, 35, 40, 2
2: 600, 200, 30, 35, 40, 2, 4, 70, 3000, 300, 50, 40, 2
3: 600, 200, 40, 45, 50, 2, 2, 80, 5000, 400, 60, 80, 2
```

| DS field in row 0 | Values across rows 0–3 | Interpretation supported by the call sites |
|---|---|---|
| 11c1 | 300, 300, 600, 600 | Room challenge reward before wrong-answer deductions. |
| 11c3 | 100, 100, 200, 200 | Deduction for each prior wrong answer. |
| 11c5 | 10, 15, 30, 40 | Threshold against random 1..1000 for enemy creation, with further state guards in `FUN_11b0_1559`. |
| 11c7 | 20, 25, 35, 45 | Threshold against random 1..100 for enemy state 4 transition to `FUN_1592_01ed`; precise visible behavior remains to be matched. |
| 11c9 | 0, 30, 40, 50 | Threshold for enemy flag DS:5b4c while fewer than four code pieces are held; link to lit-belly availability is an interpretation pending trace confirmation. |
| 11cb | 1, 2, 2, 2 | Enemy movement step in `FUN_1592_0212`; also read elsewhere. |
| 11cd | 8, 6, 4, 2 | Offset used for a near-player enemy spawn path: `(field+8)*facing`. |
| 11cf | 40, 50, 70, 80 | Threshold against random 1..100 to call `FUN_1b03_000e` after a room interaction. Visible hazard identity remains to be matched. |
| 11d1 | 1000, 2000, 3000, 5000 | Fixed victory bonus. |
| 11d3 | 100, 150, 300, 400 | Victory bonus per remaining energy unit. |
| 11d5 | 25, 35, 50, 60 | Victory bonus per remaining displayed game minute. |
| 11d7 | 20, 40, 40, 80 | **Unidentified. Not implemented as a guessed mechanic.** |
| 11d9 | 2, 2, 2, 2 | Pending refill-credit increment on a successful room challenge; code reads its low byte. |

## Score

`FUN_1d06_00a2` (`0x1d102`, evidence `ev_15bc3e38c3447015e48caf8bf26a44e30c9fd2666d47acb660993d7941f9a79c`) awards:

```text
roomAward = tuning.roomBase - tuning.wrongAnswerDeduction * previousWrongAnswers
```

The wrong-answer count lives at DS:`5bb1 + roomChallengeIndex`. It begins at zero and increments on incorrect answers. The normal answer paths use values 0, 1 and 2. Awards are therefore **300/200/100** at Trainee through Pro, or **600/400/200** at Expert through Champion. The referenced original-play video corroborates 300 for a first-try Trainee weather answer; the formula and higher-rank values come from executable evidence.

The clean timed-drill routine `FUN_1fc6_04d8` awards **50 per correct answer** when DS:790e == 0 (gameplay rather than standalone practice), and `FUN_1fc6_09c3` (`0x20623`, evidence `ev_dea5ac3caf3d7318fb07176f75054ccde5b503e8112daefcda381f840794d77c`) awards **100** when the drill success path reveals a code piece. Exact question counts and correctness thresholds are outside this recovery task and must be supplied before the drill is implemented.

`FUN_147d_0882` (`0x15052`, evidence `ev_c586efd4bdfb71e8b29d41b3abc482dcb9975339482fe08904621bfdbff6a27f`) drains remaining energy and time through their animated meters while awarding:

```text
victoryExtra = fixedVictoryBonus
             + remainingEnergy * pointsPerEnergy
             + remainingDisplayedMinutes * pointsPerMinute
```

At displayed HHMM, remaining minutes are `(12 - hour)*60 - minute` (180 at 9:00, zero at 12:00). The fixed bonus and multipliers depend on the four tuning rows, not on eight separate records.

`FUN_11b0_1327` is a **16-bit word addition** to DS:5b8c. The raw bytes beginning at `0x12e30` include the word ADD to DS:5b8c. The six-digit HUD rendering does not make the stored score six decimal digits wide. The pure score helper preserves unsigned 16-bit wrapping, rather than silently changing original overflow behavior.

`FUN_1a01_026a` (`0x1a27a`, evidence `ev_86335b04316a2ac49eccc85a6bbec7d180e7fad4a2c85bac7e061416762d6337`) adds the session score to the player's 32-bit lifetime total, saturating at **9,999,999 (`0x0098967f`)**. Its clean caller is the victory sequence `FUN_147d_0c55`, after bonus conversion. Original HELP explicitly says lifetime points are retained on a win. The native helper accordingly adds lifetime points only when `won == true`.

## Energy

- Fresh game energy = **12**, pending refill credits = **0** (`FUN_16c0_00d7`).
- `FUN_11b0_0ee0` (`0x129e0`, evidence `ev_64c3525c7241fc6045f1ed828ec35a7c9aeb222210b1a0e1778797d724106d88`) tests whether the signed current energy plus the requested delta is nonnegative. If so it stores the low byte of the result. Negative results are rejected. Below six energy units it calls the low-energy warning helper.
- The energy bar draws `min(energy,24)`. **24 is a drawing limit, not an internal capacity clamp.** Energy is a signed byte internally; pathological overflow is possible in the original arithmetic. The pure helper reflects the byte semantics, while normal game paths use small positive/refill and -1 deltas.
- A zap consumes **one** energy after its animation if energy was nonzero, including a miss (`FUN_135d_0667`, evidence `ev_5707fe85e85cb1033e0e80a74f237388bc6c453651ff44e88fef4f230f88a13a`). A hit is not a prerequisite for the cost.
- Enemy collision logic in `FUN_11b0_160c` (`0x1310c`, evidence `ev_a34377dc3a3061a6d448e105cbb91ae07c760e3e057e972f41929171dac02e71`) also consumes one energy on its ordinary branch. One distinct branch adds a 15-minute time penalty and returns before the energy deduction; mapping every visible enemy subtype still needs tracing.
- Successful room math challenges add **two pending refill credits** to DS:5b92. `FUN_1b03_013f` (`0x1b16f`, evidence `ev_e7f340e1aad1b59d1d395a0397fdbe5c75eb5e490d7f76fe588e5efb9ec765cb`) adds all pending credits to energy at the fountain, then clears the pending count. With no credits, a separate warning/animation path occurs.
- Two additional refill-credit additions appear inside severely corrupted overlapping pseudocode. They are **not sufficient evidence to claim that timed-drill success awards refill credits**. The clean drill success path currently proves points and code-piece behavior only.

## Native implementation and validation status

`Game.swift` now contains pure `VerifiedClock`, `VerifiedScore`, `VerifiedEnergy` helpers and the previously prepared native profile infrastructure. Its `--self-test` covers strict timer boundaries, nested pause/resume, midnight, rank thresholds, all four score rows/eight rank mappings, first/second/third attempt scoring, victory bonus arithmetic, 16-bit score wrapping, win-only lifetime addition/cap, initial energy/cost/empty-meter behavior, and energy above the visible meter maximum.

No build, original DOS runtime comparison, live native window, manual input test or audible-output validation was performed by this subtask. Parent controls compilation and launch. The helpers establish recovered components; they do **not** constitute a complete game, verified room graph, complete challenge bank, complete enemy AI or a matched audiovisual recreation.
