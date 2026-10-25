# Original LiveWire behavior and native helper

`LiveWire.swift` is a pure native state helper recovered from the original module, retained Ghidra output and MOCKET.DAT:5000. It does not run DOS/x86, edit original assets, call the shared REA session or change the app/session/package files. `recover_livewire_tables.py` reproduces `livewire-recovery.json`, including original raw routine bytes, table offsets and evidence IDs.

## Recovered behavior

LiveWire is actor1, initially described by original words `(20,118,11,32,11,55,0,1,9)`. Its sprite origin is `(xUnits*8,118)` in original320×200 coordinates. Restoration bounds are88×32pixels. The collision interval is `[xUnits+1,xUnits+10]`, nine logical units wide, and the original positive state flag enables collision. The original collision helper has no vertical overlap check; player animation8 bypasses all collision checks.

### Spawn tests, guards and RNG

`FUN_135d_06ee` always consumes one `randRange(1,100)` when called, and spawns only when that draw is **strictly less** than `[40,50,70,80][difficultyTier]`, read from DS:11cf+26×tier. These are original rank-pair tuning thresholds, not invented frame/second probabilities. The supplied original RNG draw must be0..32767; the native helper computes `draw%100+1` exactly.

The original calls this test:

- On entering an active room in `FUN_135d_072b`.
- After an actual eligible room challenge returns in `FUN_11b0_0d3a`, independent of correct/exhausted/escaped outcome. It does not require a newly earned clue or reward.

A completed/ineligible hotspot that does not call the challenge controller does not trigger another spawn test. There is no recovered per-frame LiveWire spawn roll, separate cooldown, energy guard or additional level-specific spawn timer. The helper therefore exposes an explicit attempt method instead of inventing a background spawner.

Before entering an actual room challenge, the original hides any existing LiveWire and calls `FUN_1b03_0054(0)`; leaving the room also clears it. `FUN_1b03_000e` sets state1 and chooses the side:

| Player screen unit | Initial LiveWire X | Facing |
|---|---:|---:|
|≤20|30 /240pixels|−1, left|
|>20|3 /24pixels|+1, right|

The first image is always selector10000 / ROOMS.GRA ordinal0, drawn with original flag0x40, unmirrored. The spawn draw does not advance the walking animation record or play a sound directly. Normal callers clear/reset walking phase before fresh room/challenge attempts; the low-level routine itself does not forcibly reset it when replacing a currently active object.

### Walking and mirroring

State1 calls animation13: ROOMS.GRA ordinals0,1,2, one simulation tick per frame, and moves exactly one logical unit /8pixels in its current direction on every update. It then reverses:

- At **newX<3**, set facing+1. Thus X2 is a real boundary position.
- At **newX>25**, set facing−1. Thus X26 is also real.

Sound18 is requested after every walking update. There are no RNG draws during walking or dispersal.

Original `FUN_1b03_0065` sets the render flag **before** moving or checking those boundaries: facing−1 selects0x40 (unmirrored), +1 selects0x60 (mirrored). Therefore the outward-facing sprite at X2 or X26 remains for that frame, while the logical direction has already reversed. `renderMirrored` is stored independently from `facing` to preserve this one-frame distinction. Drawing from `facing` alone would mirror prematurely. Spawn similarly begins unmirrored regardless of its logical direction.

### Zap, dissipation, collision and removal

The high-level zap caller permits a LiveWire effect only for an energized endpoint hit while LiveWire state==1. `FUN_1afb_0082` then sets state3 and its signed-byte counter DS:7346 to5. The common zap schedule and endpoint predicate are already supplied by `OriginalZapSchedule` and `originalZapHitEffect` in Telly.swift; no separate weapon physics are added.

State3 is stationary and silent. It draws animation31, ROOMS.GRA ordinals10,11,12,13,14, once per simulation tick while decrementing5→0. On the **following sixth update**, the original decrements0→−1 and sets the actor flag to−1. The next erase/cleanup phase changes that flag to0 and the object is absent.

Two details are preserved:

- State3 remains a **positive collision flag**, so the original horizontal player/LiveWire collision test can still fire during these five dispersal frames. A second zap does not restart dispersal because the high-level zap effect requires state1.
- `FUN_1b03_0054` resets only the **walking** animation phase DS:687e. It does not reset the dispersal animation's phase or counter. If a room/challenge transition interrupts a dissolve, the next dissolve can begin at its retained phase. The native helper stores the two indices separately rather than resetting every animation on every spawn.

Collision actor1 takes the clean `FUN_11b0_160c(param_1=1)` branch: sound19, player animation30 with horizontal step−2 relative to the player's facing, remove LiveWire, queue warning6, then consume one energy. It adds no game-time penalty. `OriginalCollisionEffect.forActor(1,sameFacing:)` already returns exactly those common effect fields and can be reused unchanged; the same-facing argument does not affect actor1's branch. `LiveWire.collideWithPlayer()` supplies its deferred-removal/reset side effect.

## Integration API

Create and persist `OriginalLiveWire(tier:session.decoder.difficulty)`. Validate decoded data with `hasValidPersistenceState`. Important methods:

```text
attemptSpawn(playerScreenUnit:nextRandom:) -> OriginalLiveWireStep
beginFrame()
step() -> OriginalLiveWireStep
clear(deferErase: false)
disperseFromZap() -> Bool
collideWithPlayer()
```

`attemptSpawn` consumes exactly one original RNG value and returns `spawned`; draw its first sprite immediately if true. It does not itself inject a spawn sound. `beginFrame` clears pending−1 removal, matching original11b0:14b7. `step` belongs after enemy, player and projectile updates in11b0:1559. Draw `sprite` at `(xUnits*8,OriginalLiveWire.yPixels)` with `renderMirrored`. Use `collisionEnabled`, `collisionLeftUnit` and `collisionWidthUnits` for the original horizontal test, including state3. Call `disperseFromZap` after the normal90IRQ zap animation and delayed energy charge, when the energized hit effect is `.disperseLiveWire`.

Native `clear()` covers immediate scene/challenge transitions; `clear(deferErase:true)` and `collideWithPlayer()` mark−1 for the following erase. Either resets the walking phase only. A decoded state3 with a negative counter is rejected by `hasValidPersistenceState`, since it is unreachable and would otherwise never complete a native dissolve.

### Scripted caller timing still needed

Room entry creates LiveWire before the player's front-facing animation sequences6 and4. Those sequences repeatedly call the normal11b0:1559 update, moving LiveWire before the player regains control; the room-entry routine also explicitly requests sound18 at its end if LiveWire exists. Returning from a challenge similarly runs player-front sequence4 after the spawn test. The helper exposes the original initial spawn position, rather than inventing a fixed offset to compensate for omitted native transition animations. Parent integration must later advance these scripted ticks to match the supplied local recording.

## Verification and limits

Standalone native ARM64 compilation passed31 focused checks in `verification/livewire-checks.json`. Tests cover strict spawn thresholds for all four tiers, exactly one RNG draw per attempt, both spawn sides, first-frame rendering, three-frame walk phase, one-unit motion, both boundary overshoots/mirror delays, hitbox width, state3 collision positivity, five dispersal frames and sixth-step removal, interruption phase retention, deferred collision removal, invalid tiers and partial Codable save round trip.

This is static-rule/helper validation. No original DOS trace, new native GUI run, auditory comparison or full playthrough was performed by this subtask. Remaining gaps are app lifecycle/RNG integration, scripted entry/exit timing, full original masking/occlusion and camera transitions. The original DS:5b52 direction and DS:5b16 render flag are shared by Telly and LiveWire; their normal hallway/room lifecycles separate them, but transient multi-actor transitions still require comparison. The helper does not invent new enemies, rooms, spawn rates or energy-based loss behavior.

## Evidence index

- `FUN_11b0_0bbd` at `0x126bd`: `ev_371c2c192b0032a8514f64b1598796486641ed96f0531b0497633a53c0963ac5`
- `FUN_11b0_0c4c` at `0x1274c`: `ev_5429fa7cd2ff7aa81e651ecd79e1a534f3354dbac62b3e93bd60e53698dda858`
- `FUN_11b0_0d3a` at `0x1283a`: `ev_f4f32e305e06f6cb6533bc1e7ea03000cfed4001477d26eead5bf80939996659`
- `FUN_11b0_14b7` at `0x12fb7`: `ev_4738a53c0bb2aa0b234c7ae61dea14a86309eac3ceb2e445eefce36d49454393`
- `FUN_11b0_1559` at `0x13059`: `ev_926d9292e2da2beeb354bc237ac5d763b72a5d36d77613236a97a57f9872fc4f`
- `FUN_11b0_160c` at `0x1310c`: `ev_a34377dc3a3061a6d448e105cbb91ae07c760e3e057e972f41929171dac02e71`
- `FUN_135d_0035` at `0x13605`: `ev_1517ed96cb1c7e7c7e9c46877888619101d6d825c1faf454da05735a40059709`
- `FUN_135d_0667` at `0x13c37`: `ev_5707fe85e85cb1033e0e80a74f237388bc6c453651ff44e88fef4f230f88a13a`
- `FUN_135d_06ee` at `0x13cbe`: `ev_d2b4fff9b0955743d2d541977619bb11f152670a629fad0daa3ec45b16304891`
- `FUN_135d_072b` at `0x13cfb`: `ev_bf65c65be167732f92d09ed018134676e5084dfafcbb5c096c66f76f398acb10`
- `FUN_135d_0a1c` at `0x13fec`: `ev_6450c33a9e145ccb26e4b8a412930b515b36037900ffed15cbb8960a0b3ee221`
- `FUN_1afb_0082` at `0x1b032`: `ev_b0b3bbe5efb245e2ea8db442ae7fe155bd083493b03f0731c0b0c349e3424423`
- `FUN_1b03_000e` at `0x1b03e`: `ev_ffaf64ad2950040fa83e7065c767334c1643b795bcd2a175ad3eafddd9df0545`
- `FUN_1b03_0054` at `0x1b084`: `ev_fbca85236bebac94fd896e8f3368ab312ff9cbb3e402b61bf19d054b8485517b`
- `FUN_1b03_0065` at `0x1b095`: `ev_596061df3046a82633a96dcfb9a97a616c592a84a703aa4410741b492c10c6a1`
