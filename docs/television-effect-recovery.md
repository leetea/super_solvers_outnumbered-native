# Television static effect — native0.24

The original television-table activity now has its introductory noise sequence, translated into Swift. No DOS instructions, interrupt handler, CPU or EGA device is executed in the app. Original inputs remain read-only. The prior0.23 unresolved-call note is superseded by this caller/stack analysis.

## Evidence and stack argument recovery

`verification/television-effect-instructions-0.24.json` retains successful original-binary raw assembly/bytes and evidence identities. The module entry/wrapper/body and range helper are also retained in `remaining-activity-effects-instructions-0.23.json`. Subject identities remain explicit: unpacked analysis EXE SHA256ff2e0d28e0a6aa8bcf86db1ea8a2980d2ccb1e10dd793bc15ab1bb929697b464 and unmodified8512 module inside its analysis-only wrapper. The wrappers are excluded from runtime/repository.

Command23 and command10 both dispatch to1d62:017e, a two-argument inclusive-range helper. The TV module calls23 without explicit arguments; substituting plain rand would change coordinates. Focused raw caller recovery resolves the stack:

- World interaction11b0:0d3a (loaded1283a) saves SI/DI, sets DI=0, and calls1d06:00a2. The intervening ordinary C calls preserve DI.
- The question dispatcher1d06:000a saves SI, selects module0x2140 for hotspot6 (raw switch bytes at1d087), loads the module and calls its far entry. SI remains0x2140; DI remains0.
- The module far entry saves BP/DS, changes DS to CS, sets its pointer arguments and calls local003e without changing SI/DI.
- Local003e allocates0xd2 bytes, then PUSH SI / PUSH DI. The no-argument random call pushes only command23. Wrapper002c pops its near return and command. INT60 removes the interrupt frame and CALLFs the selected helper.
- The helper PUSH BP / MOV BP,SP therefore sees saved DI=0 at BP+6 and saved SI=0x2140 at BP+8. Its result is `rand() % 8513`. Subsequent signed remainder operations use136/95, then add29. All values are nonnegative.

This is a static ABI/control-flow derivation from the supplied artifact, not a live DOS register trace. Ghidra Listing reversed a few segment-register MOV operands in its text; the retained raw bytes establish actual MOV DS,BP / MOV DS,AX directions. We do not use the earlier overlapping switch decompilation as proof of branch bodies. Original inputs were not patched or run.

## Timeline and random stream

The table/title/labels/numbers/units draw first. A counter starts51 and decrements at iteration multiples of4. There are60 iterations, each consisting of XOR draw, request sound23, wait3IRQ, stop sound, wait3IRQ. Total360IRQ. Even iterations generate new point pairs; odd iterations XOR the same spans again and restore the original table. Counts are50,50,49,49,...36,36 across the30 generated sets, consuming2580 range-helper calls.

The plan uses immutable point sets. Only a reached even-phase checkpoint updates the live session random state. Odd clears, repaints and restored waits do not consume random values. The existing saved initial stream, elapsed time and applied-random/sound cursors preserve partial sessions; older ready questions retain their ready state.

Independent fixture9020/seed1/variant0 starts from1153135800. At0IRQ,100 draws leave2654337172 and the first five pairs are(52,61),(40,45),(90,85),(34,70),(29,121). At12IRQ,200 draws leave1340861360. At24IRQ,298 draws leave3535864326. The final generated set at348IRQ has2580 draws/state2042767204; the next random value after completion is6746. Final clear starts354IRQ, sound stops357IRQ, and input unlocks360IRQ.

## Narrow translation of the original EGA noise operation

The selected graphics backend104b:0964 sets map-mask0x0e and logical-XOR0x18, preserving color bit0. For the TV call x2=x1+1 and y2=y1, its actual first-byte/last-byte mask arithmetic is unusual. At x modulo8=0..7 the net masks arefc,fe,ff,ff,ff,ff,fc,7e. The crossing-byte case writes both masks to the same byte. Native code retains these masks rather than replacing the call with a clean two-pixel line. Each selected pixel XORs palette index14. Duplicate spans cancel in their original order; paired iterations restore every index.

Only this fixed TV operation is translated; this is not an EGA interpreter. Current native bitmap index1 remapping, palette, broader driver transparency and occlusion remain documented fidelity gaps. Consequently these tests do not establish pixel parity with the original display. The supplied local playthrough visits the other Equipment activity and does not establish an exact-frame TV noise fixture. No auditory/perceptual sound claim is made.

## Validation

Automated checks cover the independent coordinates and exact stream states,60×6IRQ schedule, sound/stop boundaries, all eight byte alignments, duplicate cancellation, double-XOR restoration, all320 finite television cases at the static endpoint, coordinate extents, early input lockout, partial save/restore at6/11/12IRQ, final stream and answer168→300/room clues. Native-window observations and package/source/repository rebuild verification are separate evidence. Command-T opens an isolated original-data television checkpoint without modifying player progress.

The complete-game goal remains active. Opening/File/sign-in presentation, original input buffering, remaining ending/rank/midnight details, mask/palette/audio calibration and a fresh full ordinary adventure still need completion and validation.
