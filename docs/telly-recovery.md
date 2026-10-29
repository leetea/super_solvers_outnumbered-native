# Original Telly, zap, projectile and warning recovery

This subtask adds pure native helpers in `Telly.swift`. It does not edit `NativeApp.swift`, `Session.swift`, packaging, or the original DOS files. It does not call the shared REA session. Evidence is retained pseudocode, the supplied instruction dossier, unchanged module bytes, original HELP and the user's local video.

`recover_telly_tables.py` writes `original-telly-tables.json` directly from `work/SSO-unpacked-analysis.EXE`. Analysis linear address A maps to file byte8064+A−0x10000. DS-relative address D maps to analysis0x23f30+D. Original animation lists come from MOCKET.DAT indexed record5000, already decoded by `World.swift`.

## Helper API and integration order

`OriginalTelly(tier:0...3)` stores enemy and projectile states, exact animation phase/hold counters, position, facing and belly flags. It is Codable. A decoded instance must pass `hasValidPersistenceState` before use.

One normal frame follows the original order:

1. `beginFrame()` completes pending erasures/removals, corresponding to11b0:14b7.
2. Apply any camera shift with `shiftForCamera(by:)`, using logical units, not pixels.
3. `step(context:nextRandom:)` updates/spawns Telly. Supply the campaign's original `rand()` outputs in0...32767. The helper performs the original modulo/range operations and preserves the call order in the recovered routines.
4. Update the player, as the original11b0:1559 does after Telly.
5. `stepProjectile()` moves and animates any thrown object.
6. Original collision testing occurs after those updates. The helpers expose `OriginalCollisionEffect` and the original horizontal gap calculation; the caller still owns full world/player integration and masking.

`OriginalTellyStep` returns original sound-slot IDs and spawn/projectile/removal events. Current body sprite, belly-overlay sprite/offset, facing and projectile sprite are readable from the state. A sound event is the original request, not proof that restarting a PCM file on every request reproduces the original sound scheduler. The native audio layer must preserve its own supported request semantics.

`OriginalZapSchedule` supplies exact firing/beam positions, frame ordinals, timing and endpoint-hit predicate. `originalZapHitEffect` decides empty/miss/unlit Telly/lit Telly/room LiveWire behavior. It does not fabricate a math drill or award a code by itself; parent-owned encounter code must run the original drill and call the existing decoder capture method at its recovered success point.

## Spawn rules and RNG calls

`FUN_11b0_1559` draws `randRange(1,1000)` whenever Telly's state is0, **even if subsequent guards prohibit spawning**. Creation requires all of:

- draw strictly below the tier's spawn threshold;
- nonzero caller parameter (normally3 in active main play,0 during several scripted animations);
- hallway mode DS:11a6 nonzero;
- first-action/moved flag DS:0096 nonzero;
- no active enemy projectile DS:6b1e ==0.

The helper's explicit context carries these guards. It does not invent a timer-based spawn interval. A displayed percentage would additionally depend on modulo bias and campaign RNG consumption, so the raw comparisons are the authoritative rules.

The four tuning records serve lifetime rank pairs, not four unrelated games:

| Tier / rank pair | Spawn comparison, draw1..1000 | Stop comparison, draw1..100 | Resume comparison, draw0..100 | Throw comparison, draw1..100 | Lit flag, draw1..100 | Walk step units | Near-spawn field |
|---|---|---|---|---|---|---:|---:|
|0 Trainee/Junior|<10|<60|<15|<20|>0|1|8|
|1 Senior/Pro|<15|<50|<12|<25|>30|2|6|
|2 Expert/Master|<30|<40|<11|<35|>40|2|4|
|3 All-Star/Champion|<40|<30|<9|<45|>50|2|2|

The spawn, throw, lit, walk and near-spawn values are fields at DS:11c1+26×tier. Stop/resume byte pairs are DS:1229+2×tier.

`FUN_1592_0091` begins in state3, clears visible/stored light flags, and resets the phase indices for disappearance animation32 and appearance animation33. If fewer than four secret symbols are captured, it makes the lit-flag random draw; at four captures it does **not** consume that draw.

Spawn direction is chosen from screen X:

- Player unit+3 >20: enemy begins at−3, facing+1 (from left).
- Otherwise: enemy begins at35, facing−1 (from right).

It then always draws0..100. If the result is<50, or the side is forced by a hallway end, it uses appearance state8 at `playerUnit−(nearSpawnField+8)×enemyFacing`. Hallway indexmod5 ==0 forces near appearance when facing+1; indexmod5 ==4 forces it when facing−1. Otherwise it begins the ordinary walking animation at the edge and exposes its stored eligible belly flag.

Player/object coordinates use8pixels per logical X unit. Telly's original Y is77; its collision interval is X+1 through X+7, six units wide. Original actor restoration bounds are8units×64pixels.

## State machine and original animation schedules

| State | Meaning recovered from control flow | Animation / motion |
|---:|---|---|
|0|Absent|Eligible for the guarded spawn draw.|
|3|Walking|Animation10:100,101,102,103, held2ticks each; ±tier walk step per simulation tick.|
|4|Stopped / ready to throw|Animation11:104,105,106,107, held2ticks; no X movement.|
|5|Throwing|One of animations17..20, selected by thrown-object kind22..25; no X movement.|
|7|Zapped/blinking|Animation34:100,112 repeated4times; nine state updates before state9.|
|8|Appearing|Animation33:111,110,110,109,108. Creation draws its first frame; four more updates return to walking.|
|9|Disappearing|Animation32:108,109,110,110,111 for five updates; the following update marks removal.|
|−1|Pending erase|The next original erase phase changes this to0.|

The stun duration DS:5b84 and appearance/disappearance counter DS:6d52 are **different variables**. They must not be merged, or a nine-tick stun leaves disappearance stuck above its five-frame terminal count. The helper preserves separate counters.

Animation phases are retained separately for each original animation record. Switching walking/stopped/throw animation does not automatically reset all phase indices. The original explicitly resets only appearance/disappearance phase indices during spawn. The helper retains those semantics.

Every active enemy update first requests sound17. In hallway mode, a Telly that has moved more than8logical units past the player reverses its facing/render flip flag. While its state is below5 it restores the eligible belly flag. A stopped enemy first draws for resume; if that comparison succeeds, the stop draw is skipped. Otherwise it draws for stopping, which only applies when5<X<19. A separate throw draw is consumed on **all active states**, including stun and appearance. A successful throw comparison requires stopped state and no current projectile, then consumes the random object-kind draw22..25.

The body's visible light is an original overlay, not a newly painted glow: walking selects FASTLOAD204+the current walk phase at Y+22; stopped selects208 at Y+24. During a throw the previous lit flag is saved, hidden, and restored when its attack-animation phase wraps.

Appearance/disappearance request sound50. Ordinary removal clears the visible lit flag. The zapped path `stun()` requests sound16 if the belly was lit, otherwise42, then clears both visible and stored eligible flags. In the normal player zap dispatcher, an actually lit Telly instead starts a drill; the separate stun method preserves the original lower-level function's branch behavior for supported callers.

## Thrown objects: recovered missing switch cases

`assembly-0x13448.json` has complete pre-switch setup but omits the four real case blocks. Its indirect jump was interpreted under an incorrect CS alias and wandered into unrelated code. The actual code segment base is0x11b00; the word table at analysis0x134c8 contains relative offsets19d0,19d8,19e0,19e8, giving targets0x134d0,0x134d8,0x134e0,0x134e8. Raw instructions there are short MOV pairs:

```text
134d0: BF 05 00  BE 51 00  EB 16   DI=5, SI=81
134d8: BF 02 00  BE 5B 00  EB 0E   DI=2, SI=91
134e0: BF 04 00  BE 73 00  EB 06   DI=4, SI=115
134e8: BF 03 00  BE 76 00         DI=3, SI=118
```

The common tail stores SI in projectile Y DS:6b14 and DI in collision width DS:6b22.

| Object kind | Attack animation | Release phase index after advancing | Projectile frames | Y | Collision width units | Impact word sprite |
|---:|---:|---:|---|---:|---:|---:|
|22|17|2|115,116|81|5|210|
|23|18|0|183,184,185|91|2|212|
|24|19|3|189,190|115|4|209|
|25|20|3|193,194|118|3|211|

Release indices are original DS:11ab words `[2,0,3,3]`; impact sprites are DS:11b3 words `[210,212,209,211]`. Object23's release index0 means it is created when the attack cycle wraps, on the same update that changes Telly back to stopped.

The instruction dossier proves speed is drawn inclusively from `[walkStep,walkStep+1]`, then multiplied by facing. A right-facing throw starts at TellyX+4. A left-facing kind22 or24 starts at TellyX−4; kinds23/25 start at TellyX. Lifetime starts at0x7ffd simulation ticks.

`FUN_11b0_18c2` moves and animates the projectile, requests sound`kind−12` every third lifetime tick, decrements lifetime, and marks removal when lifetime expires or X<2 / X>32. Its final near-edge branch assigns **positive2**, including for a left-facing case; the helper preserves this asymmetric original statement rather than replacing it with a guessed sign correction. Camera shifts move both enemy and projectile coordinates.

## Zap sequence and hit test

Original HELP is explicit: Space zaps. The action is permitted only while player animation/state<3. `FUN_135d_0035` then runs synchronously:

1. Player FASTLOAD47,48,49, each10IRQ ticks. Right-facing draws at current X; left-facing temporarily shifts player draw X−4units.
2. Sound14 with energy,15 when empty. This begins after the first30IRQ ticks.
3. Six beam iterations, each10IRQ ticks, FASTLOAD50..55 if energy is nonzero. Beam Y=playerY+12.
4. Right beam X=playerX+8units. Left beam firstX=playerX−7, then subtracts original DS:00c0 bytes `[5,3,0,0,0,0]` after each iteration, producing X offsets `−7,−12,−15,−15,−15,−15`.
5. Restore the player rectangle and idle animation; stop the sound stream. The high-level caller deducts one energy after the90IRQ-tick animation if energy was nonzero.

Empty zaps still run all nine timed iterations but draw no beam and cost no energy. Ninety IRQ ticks are about0.380seconds under the conventional PIT frequency; this is an inferred native conversion, not a recorded duration measurement.

Target selection uses Telly when its state is1..6; otherwise it considers nonzero LiveWire state. Target endpoints are X+collisionLeft and that value+collisionWidth. Each beam iteration tests whether **either target endpoint** lies inclusively inside `[beamX,beamX+12]`. This is not a general rectangle-overlap test: a target that completely spans the beam without either endpoint inside would not hit. The native schedule preserves this original predicate.

After an energized hit, hallway play calls the unlit Telly stun path or requests the drill when the belly is lit. In a room it disperses LiveWire only if LiveWire state==1. An empty hit cannot award a code or start a drill. Telly, player and enemy projectiles do not receive their usual simulation updates inside this synchronous zap loop; hardware IRQ time continues, and the game clock is polled again afterward.

## Collision and energy effects

The horizontal gap function in11b0:0bbd treats touching endpoints as gap0; a collision occurs when gap<1. Player animation8 (normal jump/flip) skips collision checks. Priority is projectile actor5, then active Telly actor4 (state<7), then LiveWire actor1. This helper does not replace the complete actor/state selection in the caller.

| Collision | Energy | Game-time penalty | Player response | Warning | Sounds |
|---|---:|---:|---|---:|---|
|LiveWire actor1|−1|0|animation30, horizontal step−2|6|19|
|Telly actor4|−1|0|animation26 with same facing,27 otherwise; step+2 relative to player facing|2|51 then20|
|Thrown object22/23|0|+15minutes|animation26/step+2 if same facing,27/step−2 otherwise|1|20|
|Thrown object24/25|0|+15minutes|animation9/step−1|1|20|

The impact-word helper11b0:14fe waits200IRQ ticks and clears ordinary Telly before the body-collision code chooses its disappearance state. This clears its visible light. Telly already in state7 or9 is preserved by that impact helper. Projectile impacts remove the projectile and clear ordinary Telly; the parent must apply these side effects alongside the returned `OriginalCollisionEffect`. The pure effect object itself does not animate a player or modify a session clock.

Energy reaches zero without an independent energy-based game-over branch: zero prevents an effective zap; the midnight deadline is the explicit loss trigger recovered elsewhere. Low energy (<6) queues warning11. Refill mechanics remain in the separate world/session implementation.

## Warnings

`OriginalEncounterWarnings` reproduces queued unseen/pending/shown flags:0,1,255. The original new-game menu clears18bytes at DS:5bd7. Its automatic safe-state pass scans only IDs0..12; it shows the first pending message when Telly==0, projectile==0 and player state<3, then marks it255. Immediate messages can address higher valid IDs, independently of that automatic scan. Messages do not repeat after being shown.

The enclosing original New User Messages flag DS:5bef is initially true only for Trainee rank, and can be passed explicitly to the native helper. The helper does not silently force all warnings on for higher ranks. Showing a queued original dialog pauses/restores the clock through11b0:1245/1291; the parent UI still owns that modal action.

## Validation and limits

The standalone ARM64 helper test built and passed31checks in `verification/telly-checks.json`, including spawn guards/RNG consumption, near/edge spawning, walking, separate stun/disappearance counters, projectile release/cleanup, exact left/right zap geometry, empty timing, lit/empty/jumping zap effects, collision costs, safe-state warning order, immediate higher-ID messages, and Codable round trip validation. The test source is `verification/telly-test-main.swift`; the temporary executable is `verification/telly-compile/telly-checks`.

This is **static-rule helper validation**, not a DOS trace or native playthrough. Remaining integration requirements include full campaign RNG-call equivalence, actor clipping/occlusion, all scripted modal timing, player reaction frames, world/camera interaction, save validation and the original sound-request scheduler. LiveWire AI and Master of Mischief behavior are not invented here. The local recording corroborates visible Telly encounters, lit-belly drill transitions and continuing game time; its five-second review frames do not prove per-frame enemy timing.

## Retained evidence index

- `FUN_11b0_1559` at `0x13059`: `ev_926d9292e2da2beeb354bc237ac5d763b72a5d36d77613236a97a57f9872fc4f`
- `FUN_11b0_15e3` at `0x130e3`: `ev_ec966d2b07140f1eeb2d7cfb2c1eb6c6b1f0a0d58f887b8e76af3b6d310fdf65`
- `FUN_11b0_160c` at `0x1310c`: `ev_a34377dc3a3061a6d448e105cbb91ae07c760e3e057e972f41929171dac02e71`
- `FUN_11b0_18c2` at `0x133c2`: `ev_300ace7a02b79a9e74e6378bca1b9840a4529538599ec85a3508e735d9b58a7b`
- `FUN_11b0_1948` at `0x13448`: `ev_b28ef4d5b01c25d7a9cac2ceb02be22c999bb3008fe45c9090b32fdbef15b548`
- `FUN_135d_0035` at `0x13605`: `ev_1517ed96cb1c7e7c7e9c46877888619101d6d825c1faf454da05735a40059709`
- `FUN_135d_0667` at `0x13c37`: `ev_5707fe85e85cb1033e0e80a74f237388bc6c453651ff44e88fef4f230f88a13a`
- `FUN_1592_000e` at `0x1592e`: `ev_4918638841a3cc0dcb19b709acaaf83ee71e64c2d833200efbf714d6949c0afa`
- `FUN_1592_0038` at `0x15958`: `ev_32b819e83f9d148d003359e2ae6caa50a57409106f0eba93f7e3ea52d01f0a75`
- `FUN_1592_0050` at `0x15970`: `ev_fd22b823ac0bbe376e1adcd14f0d12b38c70fe1aabbd53aa2c82887150421b5f`
- `FUN_1592_0091` at `0x159b1`: `ev_fac5b66ac40079ee6134dacf8f11db04da9825ff2fcd3d252d26ed6d56e89890`
- `FUN_1592_01ed` at `0x15b0d`: `ev_8d464682257382398c64eed0ba1733992773d3ffabf4f419e6ecc67f815af6d0`
- `FUN_1592_0212` at `0x15b32`: `ev_d983c3a3c95236b55f02bdd4004747af422163cc5d21142d0253f372cd402579`
- `FUN_1592_0505` at `0x15e25`: `ev_a235a2dbd25311be491f826353484527c22c30047d3c5508e7b92c5da05d8be0`
- `FUN_170d_022a` at `0x172fa`: `ev_64343a8f06f3ba7afe96ce6b24effbfa4af524ea04b872a65e82354eb4e83769`
- `FUN_170d_029a` at `0x1736a`: `ev_ded611e552a774ac605a3f11bb92e1492efc7db0bea13c34aa6526d7ccc3db4e`
- `FUN_170d_02f6` at `0x173c6`: `ev_353eee4e66ded755e5f88c77d12138b73dd08f04b580acf5c2b67fc9bc2f4fcd`
- `assembly-0x13448.json`: `ev_9dbfa813e6bbc4e1ef8dd8100405d3d9c194d012a0f214af5ec68c0bfef1d725`; its documented missing case blocks were independently decoded from raw bytes above.
