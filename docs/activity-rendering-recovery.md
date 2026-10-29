# Native activity rendering recovery

## Implemented static activity context

`ActivityTemplates.swift` owns native overlays for two additional activities. It draws the original bitmap and generated original field values; it does not execute compiled x86 drawing routines or emulate DOS hardware.

API:

```swift
let renderer = ActivityTemplates(content: originalContent)
let support = try renderer.draw(challenge, on: canvas)
```

`ActivityTemplates.supportedHotspots` is `[2, 6]`. `ActivityRenderSupport.providesActivityContext` reports whether the data required for the activity is rendered. `limitations` preserves animation and palette gaps. An unsupported template returns `.unsupported` and leaves the canvas unchanged. Root code continues owning map rendering, question text, calculator, input, native window and navigation.

`OriginalChallenge.originalWord(at:)` and `originalString(at:)` flatten group items in stored order. This reproduces the original compiled drawing modules' far-pointer array layout. Access bounds, field extents and NUL termination are checked.

### Prize board — hotspot 2

- Original compiled module: TEMPLATE.GRA ID8504 (`0x2138`).
- Original bitmap: ID8505 (`0x2139`), displayed at `(8,19)`.
- Generated prices: flattened items1,2,3,4; string is `$` followed by the original generated integer.
- Font: MOCKET.DAT ID5014 (`0x1396`, original font4).
- Price center X coordinates: `[54,83,155,157]` for A,B,C,D.
- Price Y coordinates: `[85,43,50,98]`.
- Text X coordinate: center minus integer half of original measured string width.
- Text ink: opaque black, corroborated by the recording.

Compiled module evidence: loop at local0x0087 reads flattened fields1 through4 and formats `$amount`; width measurement follows. Static placement tables are at local0x0414 and0x041c. The final drawing pass at local0x037f repeats the same placement after random flashes. The original INT60 dispatcher table independently maps command9 to font selection `1c45:016a`; command9(4) therefore selects original font4. This is no longer inferred from an unrelated hotspot jump table.

The original random price flashes, timer waits and prize-outline effects are omitted. The native bitmap background currently differs from the local recording in some red/purple/blue pattern pixels. Global bitmap index1-to-black behavior loses a blue gift-wrapper pixel at `(105,110)` that remains blue in the recording. This may require per-draw driver/mask semantics. No palette replacement has been invented to conceal the discrepancy. The activity's original amounts, font, price placement and readable context are recovered; complete image equivalence is not claimed.

### Television table — hotspot 6

- Original compiled module: TEMPLATE.GRA ID8512 (`0x2140`).
- Original bitmap: ID8513 (`0x2141`), displayed at `(8,19)`.
- Title: flattened item24, font1 (`MOCKET.DAT.1393`), Y29; X is `10 + (174 - measuredWidth)/2`.
- Six row labels: flattened items5 through10, original font4, X30.
- Six numbers: flattened items11 through16, original font4, right aligned to X133.
- Six units: flattened items17 through22, original font4, X139.
- Rows: Y45,58,71,84,97,110.
- Ink: black.

Compiled module evidence: title load and centering at local0x0063 through0x00a5; command9(4) at0x00a6; row loop at0x00bd through0x0164. The subsequent60-step random television-static introduction is not implemented. Static original table content is retained.

## Independent local reference fixtures

Only the user-supplied local file is used. Reference SHA256:

`6960fb011e044a141e75e734e35140ff5c6c62e8e3440bf78f96d27baf957205`

- `reference-media/frame-054.png`, about265seconds: original record9108, seed1, variant0. A$90, B$52, C$46, D$33. The generated question asks for$908 decreased by Prize A; answer818. Native graphic: `verification/prize-template-native.png`.
- `reference-media/frame-036.png`, about175seconds: original record9025, seed8, variant0. Title `Old-Time Costume Items`; rows Lace115yards, Silk174yards, Hi-top boots190pairs, Velvet127yards, Riding boots171pairs, Hi-heeled boots102pairs. The question asks for the sum of the three boot counts; answer463. Native graphic: `verification/television-template-native.png`.

The four original price labels at the recovered coordinates give black-ink overlap0.825 against binarized H.264 reference pixels with font1396, versus0.313 with font1393. This is diagnostic font corroboration, not an exact-frame claim.

Viewport RGB mean absolute differences against the compressed local reference:

- Prize board: `[28.67,9.42,34.25]`, including the explicit palette discrepancy.
- Television table: `[9.74,8.66,9.30]`.

Hashes and exact metric scope are recorded in `verification/activity-reference-comparison.json`.

## Native verification

Built the renderer with the shared native canvas and challenge model using Apple's Swift compiler. The standalone native check rendered every supported bounded-bank case:

- 320 prize-board cases.
- 320 television-table cases.
- 640 total with validated generated field extents and fonts.

An unsupported lined-chart case returned unsupported and left the canvas unchanged. The two native fixture PNGs were opened and visually compared with the local reference frames. `verification/activity-rendering-checks.json` records these checks. This remains static data/native rendering verification, not execution of the original DOS game or full playthrough fidelity.

## Remaining activity gaps

The existing map renderer remains owned by root. Seven additional dynamic graphic types are not implemented here:

| Hotspot | Compiled/bitmap IDs | Missing recovered drawing behavior |
|---|---|---|
|1|8502/8503|Chart layout, tick labels, scales, bars/lines and generated legends.|
|3|8510/8511|Spinner sectors, numeric labels and animated/color state.|
|4|8506/8507|Music/activity chart geometry and generated labels.|
|5|8508/8509|Measurement-column slider/copy behavior and generated readings.|
|7|8516/8517|Colored-rectangle geometry and generated dimension labels.|
|8|8514/8515 or8520/8521|Grid rendering, axes, line series, labels and scale semantics.|
|9|8518/8519|Original cassette resource10015, stacked cassette drawing and generated labels.|

Additional recovered but unimplemented clues:

- 8508 has original column X table `[24,80,136]` at local0x0280 and strings `100s`, `10s`, `1s`. Flattened fields24 through26 feed column readings. It copies regions between original backing surfaces while moving the slider; drawing command26 needs exact semantics before native translation.
- 8518 draws cached bitmap10015 before cassette labels. Four rows start from local106 and descend by20, using dynamic image writes; cassette resource creation needs recovery. API2 is the original cached-bitmap draw function, not evidence that bitmap10015 exists as a directly indexed GRA record.
- The INT60 table maps command13 to driver/backend target11041, command16 to10b48 and command17 to10c38. Their meanings remain unproven until the backend instructions are analyzed. They must not be assumed to be generic rectangles or lines solely from their call shapes.

No unsupported graphic is synthesized or labeled faithful.
