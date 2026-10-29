# Encounter/drill recovery handoff

**Historical partial handoff, superseded by `DRILL-RECOVERY.md` and the 0.3 implementation.** The statements below about missing native encounters and unresolved operand transforms describe an earlier state. The ambiguity is zero-factor multiplication, not subtraction. Preserve this file as history; use the new ledger for continuing work.

This is partial static evidence, not implemented native encounter behavior. The previous parallel worker stopped before writing its planned Encounter.swift. Do not assume that file or helper exists.

Recovered cleanly from existing pseudocode and source byte tables:

- Regular Telly drills use question count`2*difficultyTier+4`:4,6,8,10. A code piece requires at leastN−1 correct answers, allowing one error. Correct answers award50; successful code capture adds100.
- Practice/custom drill length is`((configByte0&3)*5)+5`:5,10,15,20. Practice elapsed counter is updated every240IRQ ticks. The regular drill uses the continuing game clock; tuning DS11d7 is not established as an independent question deadline.
- Default13-byte configuration rows at DS1277 are preserved in`encounters-tables.json`. Bit0x10 in entries0..3 selects operators; bit0x04 in entries0..12 selects numbers; bit0x08 in entries0..2 selects the missing expression position. DS5754 operator characters are`+`, `*`, `-`, `\`(division).
- Pool enumeration includes ordered pairs when at least one operand is selected; the other ranges0..12. Division excludes the zero low-nibble factor. Pools shuffle without replacement and refill when exhausted. Operand/result transformations and alternate zero-subtraction acceptance require focused assembly review before porting.
- Code capture clears the first still-hidden decoder secret flag and increments capture count. Decoder.swift already exposes this as collectSecret(). The actual encounter lifecycle still must invoke it at the recovered success point.

Focused instruction dossiers already supplied:

- `assembly-0x20ad3.json`: drill question construction,112 analyzed instructions; Ghidra jump-table body coverage is incomplete. Review exact native targets in raw original bytes rather than following corrupt startup pseudocode.
- `assembly-0x13448.json`: enemy projectile initialization,53 analyzed instructions. Rank-table field at+0x0a chooses a speed in[field,field+1], multiplied by facing; later switch cases are not covered.
- `assembly-0x1ba90.json`: keyboard ISR. Original HELP independently establishes the relevant controls.
- Source original routines in `game-pseudocode.c`:20c7:0005 for drill loop,209f:00e3 for question generator,135d:0035/0667 for zap animation/energy,18e7:02ed for secret capture. Some16-bit switches are contaminated and need raw-byte/assembly confirmation.

The regular zap uses sound14 with energy and15 when empty, and deducts energy after its animation. Jump helper135d:0001 has no direct sound call. Native development app uses these supported sound slots and does not substitute speculative door/jump sounds. Its coarse pose animation is not the complete original zap sequence or a collision implementation.

Next: recover missing switch targets for original drill operand construction and projectile cases, then implement pure helpers plus a real Telly encounter. Native app currently does not spawn Telly, run drills, capture code pieces or recharge energy.
