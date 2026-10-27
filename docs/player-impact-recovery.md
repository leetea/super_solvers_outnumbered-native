# Player impacts, reactions and actor order — 0.19

Read-only unpacked EXE SHA256:
ff2e0d28e0a6aa8bcf86db1ea8a2980d2ccb1e10dd793bc15ab1bb929697b464.
Focused Ghidra instruction dossiers for11b0:13b9/14fe/160c/1732 and
135d:0cf5 are retained locally in verification/player-impact-instructions-0.19.json.
Animation rows come from unchanged MOCKET.DAT resource5000. This is native
state translation; no original CPU instructions or graphics drivers execute.

NativePlayerMotion replaces render-time tick%8 and the transient jump counter.
Its persisted fields distinguish animation selected for the next update from
the sprite drawn by the current one, preserving source completion frames.
Original actor requests reset the frame index, admit ordinary states only
when settled/finished, and allow reaction states>8 to interrupt another state.
Held horizontal input changes facing even when its walk request is rejected.
The existing native Up+Left/Right mapping implements the documented flip.
Reproduction of BIOS keyboard buffering/repeat timing remains separate work.

All these source rows hold each sprite for one24IRQ simulation frame:

| State | Sprites | Motion and completion |
|---|---|---|
|1 idle|0|No displacement; background/step sound1/2 in hall,4/5 in room|
|2 walk|1..8|One unit along facing; frame phase advances independently of render calls|
|8 flip|34,35,36,37,38,39,35,34|Vertical−12 for four frames, then+12 for four; horizontal0 or2; sound38 then idle|
|9 impact|27,28,29,28,27,30,31,32,33|Stored collision horizontal argument; sound20 when remaining count reaches3; then28|
|26 knockback|40,41,42,43,43,43,43|Seven frames; sound38 then idle|
|27 knockback|99,99,99,99,30,31,32,33|Eight frames; then28|
|28 recover|44,45,46,44,45,46,44,35,35|Nine frames; sound38 then idle|
|30 LiveWire|ROOMS8,9,8,9|Four frames, horizontal−2; then idle|

1732 first evaluates the post-camera movement bound. A blocked walk requests
state9 with horizontal/vertical0 and decrements its count once immediately.
It draws the first impact sprite in that same update, using restore width8;
later reaction updates use width10 (ordinary/flip width6). The old state2
branch requests the ordinary sound and avoids a second decrement. The exact
boundary sequence is therefore nine impact plus nine recovery frames. Width
values are retained as evidence/state; full original restore-mask artifacts
are not claimed by the native redraw renderer.

11b0:0c4c exempts only state8 from collisions. Its priority is projectile5,
then Telly4, then LiveWire1. Native body/projectile encounters show the original
word before applying the reaction and costs.14fe draws at y52 and waits200IRQ;
raw instructions show body-word X=min(player,Telly)+1, projectile-word X=player
(the projectile branch skips INC SI). Actor simulation and input are suspended
during this synchronous wait; IRQ time accumulates and displayed minutes are
processed when it finishes. Saved partial flashes resume the remainder without
duplicating the penalty. Word sprites are210/212/209/211 for tricks22..25 and211
for body hits. Body sound51 precedes the wait; sound20 follows it. Original
strict sound priority remains in force, so these are requests, not a guarantee
that every request interrupts currently playing PCM.

At completion14fe removes an ordinary Telly, retaining stunned/disappearing
states.160c selects the existing recovered effects: Telly costs one energy and
state26/27 with horizontal2 according to equal/opposite facing; projectile22/23
uses26/+2 or27/−2 and adds15 displayed minutes;24/25 uses9/−1 and15minutes.
LiveWire has no word wait; it requests sound19 and state30/−2, removes the wire
and costs one energy. State30 draws ROOM sprites, not FASTLOAD ordinals.

1431 draws actors in slot order: LiveWire1, player3, Telly4, projectile5.
The native redraw order now respects those foreground relationships. An opaque
overlap check uses the original Telly/player bitmap pixels to verify that Telly
survives at overlapping pixels. This does not establish every planar-driver
restore/mask quirk, belly backup artifact, or transition-panel overlap case.

Headless checks cover original row identity, exact boundary/flip/reaction
sequences and sound frames, reaction admission, all four projectile types and
both relative facings, word-before-cost ordering,200IRQ save/resume, one-time
penalties, actor/RNG freeze, recovery resume, LiveWire sprite rendering, opaque
foreground pixels and legacy sessions without the optional fields. Actual
native-window observations are recorded separately; fixtures are not described
as ordinary play. The local MKV remains the active video reference; no YouTube
browsing was used. A95-second local frame was inspected for original asset
scale/context; it does not independently prove impact timing or audio parity.

The complete-game goal remains active. Remaining work includes broader
collision/occlusion validation, full encounter/capture presentation, machine
eye actor, timed activity effects and RNG, opening/File/sign-in, queued input,
ending refinements, palette/audio calibration and a fresh full playthrough.
