# Camera and signed movement recovery — 0.18

Read-only input: unpacked analysis EXE SHA256
ff2e0d28e0a6aa8bcf86db1ea8a2980d2ccb1e10dd793bc15ab1bb929697b464.
Focused Ghidra instruction evidence is retained locally in
verification/movement-instructions-0.18.json. No original assets were edited.

11b0:148a calls14b7 (erase/begin frame),0b1b (scroll),1559
(enemy/player/projectile/room actors),1431 (draw). 0b1b derives signed
world direction from horizontal animation argument times facing and passes
its absolute magnitude to0c96. 0b6b shifts camera and the screen coordinates
of player, active Telly and projectile before their updates. Native ordinary
movement now prepares that viewport before updateTelly, then commits the
player movement before projectile/collision processing.

Raw0c96 instructions confirm left scroll requires screenX>=6 and
screenX-magnitude<6. In scenes0/5, camera-magnitude must remain at or above
the first segment. Right scroll uses screenX+magnitude>=26; amount is that
sum minus26. In scenes4/9 it requires camera<scene*38. This tests the old
camera, allowing151->153 on a two-unit frame. It does not clamp the new
camera to152. Native persistence therefore admits the resulting extra unit
(camera153, player up to186 on the lower floor; upper floor offset190).
New movement frames bound screen X to1..33. Persistence retains its prior
independent player/camera validation to avoid rejecting older saved viewports.

1732 predicts screenX+horizontal*facing after scrolling. Prediction<=1
sets the horizontal argument to screenX-1; prediction>=33 sets it to
33-screenX, then multiplies by facing. This preserves the original signed
argument arithmetic instead of replacing it with a global-world clamp.
Walking requests one unit; horizontal jumps request two. Full original
blocked-walk impact9/recovery28 and collision presentation are still pending.

Room and elevator alignment use the same one-unit movement rule, retaining
the starting facing (including backwards walking) until the force-right rear
pose. A News approach from player56/camera50 aligns to53/camera47, preserving
screen6 while the hall scrolls. The aligned camera is retained for room return.
The left elevator approach17/camera11 aligns to11/camera5. Each transition
camera delta shifts enemy/projectile screen coordinates exactly once before
that frame's actor update. Existing per-frame RNG cursors remain in force.

Optional usesOriginalMovement is true on new transitions and absent/nil in
pre0.18 decoded saves. Nil retains the previous transition's camera/positions
and schedule to avoid changing a transition already in progress. This does
not retroactively correct earlier saves' past camera or RNG history.

Headless verification includes source thresholds, signed alignment, room
bounds, one-unit overshoot, repeated floor traversal with one/two-unit
frames, door/elevator aligned return, legacy scheduling and enemy update
ordering. Native-window observations and package verification are separate
evidence, recorded in the milestone verification report.

This milestone covers position/camera arithmetic and frame ordering. It does
not claim hardware pixel-strip parity, complete collision/knockback/occlusion,
machine eye animation, timed activities, opening/File/sign-in, queued input,
or remaining ending/palette/audio fidelity. The complete-game goal is active.
