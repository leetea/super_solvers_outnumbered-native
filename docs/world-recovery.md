# Original world, coordinates and player movement

Recovery uses offline `game-pseudocode.c`, the unchanged analysis executable, original HELP and catalogued original data. No DOS execution or shared REA session was used. `world-recovery.json` carries source offsets, original bytes, all object/animation/actor rows and relevant Ghidra evidence IDs. `recover_world.py` reproduces it from read-only inputs. `World.swift` exposes the recovered data and graph; it does not invent unobserved gameplay.

## Original world table

`FUN_11b0_0081` copies **MOCKET.DAT indexed resource 5000 (`0x1388`)** into three runtime tables. Catalogued decoded path: `resources/assets/catalog/decoded/MOCKET.DAT.1388.bin`, original-file offset62, length1402, SHA-256 `977269778d70cf0f7430faad53d9eef7299a300fa9ea31ef29dc28f77ffb327a`.

| Offset within resource | Length | Runtime target | Proven structure |
|---|---:|---|---|
| 0 | 384 | DS:6b2b | 16 scene records × 4 object slots × 6 bytes |
| 384 / 0x180 | 910 / 0x38e | DS:672a | 35 animation records × 26 bytes |
| 1294 / 0x50e | 108 / 0x6c | DS:6ab8 | 6 actor records × 18 bytes |

Object format: signed-byte kind, signed-byte startX logical unit, signed-byte drawY pixel, signed-byte exclusive endX logical unit, unsigned little-endian 16-bit sprite selector. The original player/object X logical unit is **8 pixels**. High-level image helpers pass twice that value to a blitter whose X argument denotes four-pixel groups. Conflating either with pixels produces a four/eightfold placement error.

`kind=0` is decoration, `1` a door, `2` elevator, `6` hallway endcap, `9` energy supply, `11..20` room math hotspots, and `-1` inactive. Original hit testing scans all four slots and uses the **last matching slot**, with overlap:

```text
start <= playerX < end OR playerX < start < playerX+6
```

It is not point-only testing: the player's six-unit/48-pixel width can overlap a hotspot before its left edge reaches it. The near-edge comparison is strict. Inactive and decorative rows still participate in the original scan; their resulting kind determines the fallback behavior.

## Topology

Two continuous hallway bands contain five 304-pixel segments each:

```text
0 — 1(News) — 2(Reception) — 3(Game Show) — 4
|                                             |
5 — 6(Cartoon) — 7(Equipment) — 8(Sound) — 9
```

The vertical links are elevators **0↔5** and **4↔9**. Walking does not wrap between4 and5, and it does not connect0 to9. Labels upper/lower are intentionally omitted here until their visual correspondence is matched; source indices establish the graph independently.

| Door hallway | Interior scene | Background selector, DMOCKET.GRA | Interior math hotspot kinds | Interior exit |
|---:|---:|---:|---|---|
| 1 | 10 | 191 / 0x00bf, News | 12, 11 | Return to saved hallway/camera/player location |
| 3 | 12 | 193 / 0x00c1, Game Show | 13, 14 | Same |
| 6 | 13 | 197 / 0x00c5, Cartoon | 19, 20 | Same |
| 7 | 14 | 198 / 0x00c6, Equipment | 18, 17 | Same |
| 8 | 15 | 196 / 0x00c4, Sound | 16, 15 | Same |

Scene11 exists as a table record but no active hallway door leads to it. Hallway2 is the reception scene with no room door. **There are ten room math hotspots, two per room, with challenge index `kind−11` from0 through9.** Do not add an invented sixth room or assume fifteen room math activities.

`FUN_135d_072b` records the current hallway, global player X and screen X, aligns the player with the door, animates the entrance and computes the interior index as hallway+9 for hallway<5, otherwise hallway+7. It sets the player's interior X to the first object's start position (unit5=40pixels). `FUN_135d_0a1c` restores saved hallway/world/screen coordinates. `FUN_135d_039b` maps elevator origins0/4 to+5 and5/9 to−5; exit screen X is unit12=96pixels for the left elevator and unit24=192pixels for the right.

## Placement and artwork

The complete320×200 game layout has:

| Element | Static code placement |
|---|---|
| Original top menus | FASTLOAD ordinal57, 320×12, drawn at(0,0) |
| Original right stats panel | FASTLOAD ordinal56, 104×36, drawn at(216,162) |
| Interior background |320×143, drawn at **(0,15)** |
| Hall wall strips | FASTLOAD ordinals137..174, 38×8×94, drawn at **x8+8×i, y31** |
| Original player start | Hallway2, camera world unit76, player world unit96, screen unit20→**x160,y81**, facing right |
| Player normal restoration rectangle |48×64; idle/walking artwork is48×62 |
| Hallway door frame | FASTLOAD124, x=object.start×8, **y48** |
| Door room labels | FASTLOAD117..121 at the object's own x/y |

The local video measures the exploration border at approximatelyx4,y14,w312,h146. That is consistent with the decoded background beginning at y15 **inside** its top edge; it is not a reason to shift the original image down to the prototype's earlier y24. Border side sprites58/59 are drawn at x0 and304, y15 and156; their transparent/mirror flags need to be retained. The full wall starts at x8 and ends at x311. Room background data can extend under the side-mask artwork, which the original then redraws.

Exact unscrolled hallway furnishing rows:

| Hall | Objects in draw order: kind / sprite / (x,y) pixels / exclusive endX pixels |
|---:|---|
|0|endcap6/123/(8,28)/32; elevator2/122/(48,31)/176; sofa0/129/(184,33)/280|
|1|plant0/131/(24,33)/80; News door1/117/(112,37)/184; boom0/132/(200,35)/264|
|2|plant0/131/(24,33)/80; reception0/133/(112,40)/240; plant0/131/(256,33)/312|
|3|TV0/130/(32,19)/72; Game door1/118/(120,37)/192; plant0/131/(200,33)/256|
|4|sofa0/129/(32,33)/128; elevator2/122/(144,31)/272; endcap6/123/(296,28)/312|
|5|endcap6/123/(8,28)/32; elevator2/122/(48,31)/176; cactus0/128/(192,35)/248|
|6|camera0/126/(32,37)/128; Cartoon door1/119/(160,37)/232; inactive slot spanning240..296|
|7|microphone0/125/(32,33)/88; Equipment door1/120/(136,37)/208; TV0/130/(240,19)/280|
|8|chair0/127/(40,33)/80; Sound door1/121/(88,37)/160; TV0/130/(192,19)/232|
|9|cactus0/128/(40,35)/96; elevator2/122/(144,31)/272; endcap6/123/(296,28)/312|

The energy machine is **not fixed in one scene**. `FUN_16c0_000b` chooses one of nine flattened scene×4+slot indices from executable DS:3382: `[2,6,14,16,22,24,28,34,36]`. They correspond to `(scene,slot)` `(0,2),(1,2),(3,2),(4,0),(5,2),(6,0),(7,0),(8,2),(9,0)`. It restores the prior selected furnishing, preserves the new furnishing's startX, changes kind to9, drawY to37, exclusive endX to startX+12, and sprite to195. The new machine image is88pixels wide, while its interaction interval is12units=96pixels.

Exact room hotspot intervals (player-width overlap rules apply):

| Room | Kind → challenge index | X interval pixels | Table Y |
|---|---|---|---:|
|News|12→1|120≤x<144|60|
|News|11→0|208≤x<224|60|
|Game Show|13→2|96≤x<128|60|
|Game Show|14→3|192≤x<200|60|
|Cartoon|19→8|112≤x<136|60|
|Cartoon|20→9|272≤x<296|60|
|Equipment|18→7|120≤x<128|60|
|Equipment|17→6|272≤x<280|60|
|Sound|16→5|112≤x<144|60|
|Sound|15→4|192≤x<200|60|

All interior exits use kind1 at X interval40..96pixels. Room hotspot sprite203 is the original back-facing player pose; it is an approach/interaction aid, not a replacement for the large object already painted in the room background.

## Movement, keys and animation

Original HELP offsets0x0060 and0x014f explicitly establish Left/Right movement, Up contextual interaction/jump, Up+Left/Right flip, Space zap, Tab decoder, and F1/F2/F3 menus. **Space is not jump.**

`FUN_170d_0007` checks diagonal flags, Up, Space and horizontal flags; `FUN_11b0_0d3a` tests nearby objects, dispatching door/elevator/fountain/room math interaction when state/collision conditions permit. With no applicable interaction, it calls `FUN_135d_0001`, which requests animation8 with vertical delta−12 and horizontal delta0. Diagonal input requests the same animation8 with horizontal delta2units per simulation tick and the selected facing.

Main-loop pacing is nominally24PIT IRQ ticks per simulation frame: `24×5041/1193182 = 0.101396...seconds`, about9.86simulation frames/second. Work performed before the wait can increase a frame's time; this is static recovery, not a live performance measurement.

| State/animation | Recovered frame ordinals | Hold per frame | Motion |
|---:|---|---:|---|
|1 idle|0|1 tick|stationary|
|2 walk|1,2,3,4,5,6,7,8|1 tick|1logical unit=8pixels each tick, signed by facing|
|3 walk toward background|9..13|1 tick|Used during doorway/elevator approach; motion arguments vary by caller|
|4 walk toward foreground|14..18|1 tick|Used during exit; motion arguments vary by caller|
|5 small rear poses|19..22|1 tick|Door/elevator sequence|
|6 small front poses|23..26|1 tick|Door/elevator sequence|
|7 fire|47,48,49|1 tick|The zap function draws these at10IRQ intervals rather than main-loop24IRQ cadence|
|8 jump/flip|34,35,36,37,38,39,35,34|1 tick|−12pixels vertical per tick for4ticks, then+12 for4ticks; horizontal0forUp or±16pixels fordiagonal|
|9 impact|27,28,29,28,27,30,31,32,33|1 tick|Used by collisions/boundary response; not the normal standing jump|

The normal jump's Y offsets relative to ground are `[-12,-24,-36,-48,-36,-24,-12,0]`. A diagonal flip's nominal X offsets are `[16,32,48,64,80,96,112,128]`, signed by facing; the original screen-edge and scroll logic can alter actual on-screen position. These are a fixed original animation schedule, not invented gravitational physics.

`FUN_11b0_1732` bounds player left X to units1..33 (8..264pixels), consistent with its48pixel width and the inner play area ending near312. Camera scrolling starts when movement would carry screen X past unit6 on the left or26 on the right, with special floor-edge conditions for scenes0/5 and4/9. It shifts the wall/furnishings and adjusts screen X while retaining the player's global X. `World.swift` currently exposes the graph and recovered schedules, not a guessed replacement for the detailed scroller.

Animation format, 13signed words: frameCount, currentFrameIndex, nine frame-selector slots, remainingTicksOnCurrentFrame, resetTicksPerFrame. `FUN_135d_0cf5` selects the current frame, decrements its counter, resets it to the final word and advances modulo frameCount when it reaches zero. Most animations hold one tick; robot walking states10/11 hold two, and state14 holds four. The full35original rows are in the JSON.

## Validation and unresolved details

`OriginalWorld.selfChecks(resource:)` verifies the original scene/animation/actor counts, ten unique challenge indices, every door/room/background relationship, disjoint floor edges and paired elevators, overlap boundary behavior, full walk/flip frame lists, original player rectangle and all nine fountain candidates. Parent controls compiling and integrating this file; no native GUI was launched by this subtask.

Remaining work includes original-driver transparency/mirroring and sprite masking, complete scroll edge transitions, all enemy/obstacle collision states, and a direct runtime trace for each door/elevator sequence. The keyboard ISR switch table is corrupted in existing pseudocode; a narrow instruction dossier was requested for scan-code mapping. Its visible controls are independently established by original HELP and the local recording.

## Evidence index

- `FUN_11b0_0081` at `0x11b81`: `ev_d3e7bad54a2fc0cc40a77ae63081b6d73d85e5f2334e7de2066268d0558214c2`
- `FUN_11b0_0946` at `0x12446`: `ev_feeee7f7ca91c4c96179904d119e5187fc5172cae579dc026a757315a6b59399`
- `FUN_11b0_0a5c` at `0x1255c`: `ev_5ead4a22b4c089b0177804f85c419a7908baf0ce4d92475245fbf012dc4ff5c1`
- `FUN_11b0_0c96` at `0x12796`: `ev_9e5f2e7e7dfbf4f32c942006181d44d1cd70f2af8c118d1d50a1dbcd522f96b0`
- `FUN_11b0_0d3a` at `0x1283a`: `ev_f4f32e305e06f6cb6533bc1e7ea03000cfed4001477d26eead5bf80939996659`
- `FUN_11b0_13b9` at `0x12eb9`: `ev_139f31a0b74dcac6df5d9067de6b5565d19cdaf31aaf23df50a1afffbad97911`
- `FUN_11b0_1732` at `0x13232`: `ev_ac4c6caaaa1b3af505d7ce4d77861c7eda9743c6b2406b253916d36237da572b`
- `FUN_135d_0001` at `0x135d1`: `ev_eb8208837f68546c9c87029b2688dbd0f5a1f6f652cfb0555bb1b6d859c3e6eb`
- `FUN_135d_039b` at `0x1396b`: `ev_7beabb8098b9decd7a649d13845897b0b9447c4dadcb86bed2f805781b6ce3f4`
- `FUN_135d_0667` at `0x13c37`: `ev_5707fe85e85cb1033e0e80a74f237388bc6c453651ff44e88fef4f230f88a13a`
- `FUN_135d_072b` at `0x13cfb`: `ev_bf65c65be167732f92d09ed018134676e5084dfafcbb5c096c66f76f398acb10`
- `FUN_135d_0a1c` at `0x13fec`: `ev_6450c33a9e145ccb26e4b8a412930b515b36037900ffed15cbb8960a0b3ee221`
- `FUN_135d_0cf5` at `0x142c5`: `ev_e3cf8691afe84c26b82e75ba3a3ed22a50f51ee9b2d08f398ede6b23296ebba2`
- `FUN_16c0_000b` at `0x16c0b`: `ev_1a4bd2b64bfe73376c7d4e6b53146d645705392817445e73a76cadd2b011fb42`
- `FUN_170d_0007` at `0x170d7`: `ev_6bacd4e991b5b164fc5e2f50f2a23c9562b6bc9ba62fccba8514d047c1491ce8`
