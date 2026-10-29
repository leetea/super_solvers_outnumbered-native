# Original decoder recovery

This is static recovery from the supplied executable, cross-checked with the local recording. It is not original source and not a DOS runtime trace. `Decoder.swift` is a pure Swift translation of the recovered puzzle generator, flags, clue collection and decision eligibility. It has no UI or application entry point. `DecoderTests.swift` is a separate executable check.

## Source identity and address convention

- Analysis executable: `work/SSO-unpacked-analysis.EXE`, SHA-256 `ff2e0d28e0a6aa8bcf86db1ea8a2980d2ccb1e10dd793bc15ab1bb929697b464`.
- Unpacked 105,040-byte load module: SHA-256 `2921914264db12e80f4e18133840b5c0a064c209aa286fb7ca7e062043e19ef8`.
- Module begins at file offset8,064. For original segment:offset addresses, subtract load paragraph0x1000 before mapping into the module. Thus DS23f3 maps to module0x13f30; function199f:0138 maps to module0x9b28 / Ghidra address0x19b28.
- Parent-provided REA assembly evidence: `decoder-rank0-assembly.json` (`ev_aff6e32ae78fa820d7f818f4624e83e4adecaa66409fffb456d4957d1ab64862`), `decoder-rank2-assembly.json` (`ev_c48f97328334785ed29aa31aff8635dda484d5d6e20d5a6fd5aa06162d75a39a`), `decoder-19726-assembly.json` (`ev_9f3d71bf62cfa3655bf5791a3d494d8ebb662e797adc1d194c896f0e6ee5d12a`). These derive from copies with entry-point metadata changed for analysis; module bytes/relocations are retained.
- Existing `game-pseudocode.c` covers other supporting routines. Its199f:05f4 switch is contaminated by a misresolved 16-bit jump table that jumps into unrelated Turbo C startup pseudocode. The raw bytes / focused assembly take precedence.
- `decoder-recovered-tables.json` preserves the raw table values and four independently transcribed seed1 fixtures.

## State layout

| DS offset | Meaning / evidence |
|---|---|
| 3806 | Five u16 room IDs:10,12,13,14,15 (News, Game Show, Cartoon, Equipment, Sound). Used by18e7:0267 to map current room. |
| 3810 | Four u16 clue-reveal counts:4,4,2,2. Indexed by5b86. |
| 39d8 | Mutable20-symbol pool, initially0..19. |
| 39ec | Nine four-byte repetition patterns:0011,0012,0101,0102,0110,0112,0120,0121,0122. |
| 3a10 | All24 permutations of0123 in lexicographic order. |
| 3a70 | Mutable position pool0123, reset after each replacement call. |
| 3a74 | Room-order source01234 followed byNUL. |
| 5b86 | Four-tier difficulty index; original rank selection computes rankIndex>>1. |
| 5bbb | Final five room-clue rows, four bytes each. |
| 5bcf | Four secret-code bytes. |
| 5bd3 | Number of captured code pieces; initialized0 and incremented by18e7:02ed. |
| 5bd5 | Match Rule:0 same pictures/same order;1 same pictures/different order;2 different pictures/same repetition pattern. |
| 5beb | Stored hideout room-row index, selected during final row shuffle. |
| 5b91 | Current zapper energy, not a decoder-mode flag. Used throughout11b0:0ee0 and ending bonus code. |
| 5b92 | Pending recharge earned by challenges; consumed by energy-supply machine1b03:013f. |
| 7328 | Temporary generated room rows before shuffle into5bbb. |
| 7322 | Highlighted room-row selection. |
| 7324 | Highlighted bottom button0..2. |
| 7326 | Count of fully revealed room rows, cached by eligibility routine. |

Every symbol byte retains **bit0x80 for hidden**. Rendering masks symbol with0x3f and adds sprite index0x4e. Clearing visibility uses`&0x7f`, preserving other bits. The Swift component deliberately retains raw flagged bytes rather than replacing them with nil values.

## Generator and randomness

Original236a:0013 reads32-bit seed atDS5abe/5ac0, multiplies by`0x015a4e35`, adds1 with wrapping32-bit arithmetic, stores the result and returns`(seed>>16)&0x7fff`. Seed1 first returns346. Swift uses the same arithmetic.

199f:0584 shuffles all20 symbols by choosing`rand()%remaining`, swapping that entry with the last remaining entry, then reducing remaining. The pool remains mutated across games. 199f:0029 applies the same shuffle to selected smaller arrays. 199f:0071 draws distinct symbols while mutating the shared symbol pool. `DecoderGenerator` preserves its symbol/pattern pools and RNG state between generated puzzles; creating a new generator resets the original initial tables.

The seed means **the RNG state immediately before decoder generation**. Other original game functions consume the same RNG, so a video timestamp or a new-game wall clock does not establish that state.

The199f:05f4 raw switch at0608 contains near targets0610,0615,061a,061f, which call0138,01cd,02fa,039e respectively. Afterwards05bc hides every code/clue byte,0522 shuffles rows and records the winning row, then5bd3 is reset0.

| Tier / rank pair | Generator | Recovered construction |
|---|---|---|
| 0 Trainee/Junior | 199f:0138 | Secret is shuffled pool slots16..19. Row0 copies it. Rows1..4 replace1,2,2,3 distinct positions respectively with values chosen from pool0..15; those replacement pictures cannot be secret pictures. Match Rule0. |
| 1 Senior/Pro | 199f:01cd | Choose permutation-table index2..21 by rejection. Use its ordered symbols for secret and row0; distractors use indicesk−2,k−1,k+1,k+2. Match Rule0. |
| 2 Expert/Master | 199f:02fa | Secret uses pool10..13. Row0 contains those pictures. Distractors derive overlapping windows9..12,11..14,12..15 plus a modified secret with positions1/2 replaced by pool9/14. All five rows are individually shuffled. Match Rule1. |
| 3 All-Star/Champion | 199f:039e | Choose one of nine repeated-position patterns; swap selected pattern with last table entry. Build secret with three randomly drawn distinct pictures. Build row0 with the same repeated-position pattern and a newly drawn three-picture alphabet. Build four distractors from the first eight pattern entries, excluding selected pattern, with new alphabets. Match Rule2. |

Finally, row order01234 is shuffled, rows are copied to5bbb, and the index containing generated row0 becomes5beb. Both symbol pool and tier3 pattern-table swap persist into subsequent games.

### Preserve the distinction between semantic Match Rule and winning authority

The original tier2 generator **does not reject an identity shuffle** of row0; tier3 **does not reject a newly drawn alphabet whose picture set equals the secret's**. Thus rare generated rows can fail a literal semantic rule comparison while still being the stored winning row. In4,000 first-game puzzles over seeds0..999, the independent Swift check found43 tier2 identity-order cases and3 tier3 same-picture-set cases. This matches the lack of rejection code and is retained, not silently corrected.

`DecoderMatchRule.matches` is a semantic comparison helper. `DecoderPuzzle.isWinningChoice(room:)` follows the original authority: selected row equals stored5beb. Do not use the semantic helper to replace that comparison or expose hidden values to players.

## Clue collection and reveal

- 18e7:027e scans a room's four clue bytes and clears the first hidden flag. If all are visible, it changes nothing.
- 18e7:02b5 calls that operation4,4,2,2 times according to difficulty. Thus lower tiers reveal a complete room row per successful challenge; higher tiers need two successful room challenges for a full row.
- 18e7:02ed clears the next hidden secret byte and increments captured count. The safe Swift helper returns nil once all four are revealed; it does not reproduce the original out-of-range read after exhaustion.
- 18e7:04df counts rows whose four clue flags are all clear.
- 18e7:000a and0131 animate only visible symbols. Hidden symbols are not a different picture; their high bit suppresses the reveal animation.

## Decide eligibility and win/loss condition

The raw18e7:0537 helper is:

```
fullyRevealedRooms = countCompleteRows()
eligible = (capturedPieces == 4 && fullyRevealedRooms > 0)
        || (capturedPieces > 0 && fullyRevealedRooms == 5)
```

18e7:0563 additionally allows a decision when all five room rows are complete and both current energy5b91 and pending recharge5b92 are zero. This is consistent with permitting a final guess after all clues are obtained but no code can be captured. The corresponding Swift method accepts current energy and pending recharge explicitly.

If ineligible,0563 opens an explanatory dialog and returns. Otherwise it computes`selectedRoom==hideoutRoom`, opens Yes/No confirmation, then calls147d:0d8d with the computed success flag and selected room. It does not compare revealed prefixes or require all four code pieces at confirmation.

Local recording frame077 at6:20 has three acquired code pieces plus one blank, and all room rows displayed; the Equipment choice succeeds. This directly supports the second eligibility branch and corrects the earlier low-resolution browser interpretation of a fourth acquired piece.

## Validation and limits

Built with:

```
swiftc -module-cache-path work/reimplementation/verification/decoder-module-cache -target arm64-apple-macos13.0 work/reimplementation/Decoder.swift work/reimplementation/DecoderTests.swift -o work/reimplementation/verification/decoder-tests
work/reimplementation/verification/decoder-tests
```

Result: four seed1 fixtures generated by an independent Python transcription of the raw tables/control flow matched secret, all room rows, hideout and final RNG state.4,000 seeded puzzles passed deterministic replay, symbol bounds, reveal lifecycle, eligibility, Codable round trip and semantic-rule helper checks. The check also preserves the rare semantic coincidences above. These are native code/static-translation checks, **not an original DOS execution comparison**.

Original assets/executable were read only. Swift does not depend on REA, DOS, an emulator, Python or downloaded media at runtime. Remaining integration work belongs to the native app: rendering original symbol frames, input/highlight/confirmation, game difficulty selection, shared RNG integration if historical stream identity is required, save-profile boundaries, and ending transitions.
