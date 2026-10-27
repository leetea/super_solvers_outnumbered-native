# Additional original activity renderers

`ActivityMore.swift` translates static drawing endpoints directly to Swift. It reads original bitmap/font resources and the generated original field array. It does not execute or interpret original x86 code.

Current API:

```swift
ActivityMore(content: content).draw(challenge, on: canvas)
```

The result is the existing `ActivityRenderSupport` type. Current `supportedHotspots` are `[1,5,8,9]`; other types return unsupported without fabricating graphics.

## Measurement controls: hotspot5, drawing8508, bitmap8509

Original compiled TEMPLATE local offsets:

- 0x0280: column-X table24,80,136.
- 0x028c: original strings `100s`, `10s`, `1s`.
- 0x003e through0x00bd: label positioning, centered at X34,90,146 and Y39.
- 0x00bd through0x01ed: original backing-surface column copy and needle animation.
- 0x01ee through0x027f: title from flattened field9, center X99/Y22; control values from fields24,25,26.

The original animation begins with the needle at Y136 and moves upward one pixel per loop, for nine increments per control unit. The static endpoint is `Y =136 -9*reading`, reading0 through9. The needle bitmap is the original ROOMS.GRA ordinal18, relative cached bitmap10018; it is not newly drawn artwork.

The controls' copied regions are24pixels wide. The original renderer copies each column to a backing surface and restores it while the needle moves. The Swift endpoint draws the final original needle with its zero-index mask, omitting the incremental movement and timer effects. Full original driver/mask behavior remains under analysis.

Local recording fixture: TEMPLATE9145, seed9, variant3 generates `Harpsichord`, readings8,7,3, and the question asking for the new ones-control value after adding123. Native needle positions are `(24,64)`, `(80,73)`, `(136,109)`; answer6. The original local reference `frame-046.png` shows the same title, controls and question. Native screenshot is `verification/measurement-template-native.png`; comparison metadata is `verification/measurement-template-comparison.json`.

## Video cassettes: hotspot9, drawing8518, bitmap8519

Original compiled TEMPLATE local offsets:

- 0x0047: first cassette row106, initial letter'D'.
- 0x0074 through0x0096: original cached bitmap10015 at byte-column14, equal to56pixels.
- 0x0096 through0x00ac: letter X83 and row+5.
- 0x00ad through0x00fc: number from flattened item3-i, right aligned to118 at row+4.
- 0x00fd through0x0119: unit from flattened item4 at X130, row+4.
- 0x013c through0x0157: decrement row by20 and letter by1, for four cassettes.

The static equivalent draws A/B/C/D at Y46,66,86,106. It uses the original ROOMS.GRA ordinal15 bitmap120x19 and original font4/MOCKET1396. No cassette artwork is synthesized.

Important ordinal correction: ROOMS15 is the cassette, ROOMS16 is the calculator, ROOMS17 is the question panel, ROOMS18 is the measurement needle. Earlier exploratory notes incorrectly called ROOMS15 the calculator. The manifest and decoded bitmaps establish these zero-based ordinals.

Relative cached bitmap IDs are not separate archive IDs. `FUN_160a_0a22` relocates10000+n to the current appended-resource base+n. These resources are therefore recoverable from the current ROOMS file. The source code starts at D and works upward; reversing traversal gives the same final static layout. Original timed arrival and per-row audio remain omitted.

Native fixture TEMPLATE9130/seed1/variant0 shows A86minutes, B50minutes, C12minutes, D20minutes. It is a generated-original-data fixture, not an independently observed cassette scene in the local recording. Native image: `verification/cassette-template-native.png`.

## Cartoon line charts: hotspot8, drawing8514/8520, bitmap8515/8521

The original module exports are retained in `template-code-analysis/`. Their MZ analysis wrappers prepend32 bytes without changing module payloads; `derivatives.json` records original hashes and address mapping. Every REA session is closed. The native translation preserves the count-dependent X tables, baseline/interval scaling, strict half-interval rounding, tick labels, vertical text, legend positions, red5×5/black3×3 points and original span-based line rasterizer. It supports one-series and compact one/two-series layouts. Original plotting delays and sounds remain omitted.

TEMPLATE9068/seed7/variant3 matches local `reference-media/frame-025.png`: title Cartoon Songs, both series180,180,210,180,270, weekdays Mon–Fri and answer0. The resulting native chart visually matches the recording's static content. Its original point centers are(64,97),(86,97),(108,80),(130,97),(152,46). `verification/cartoon-songs-native.png` retains the native endpoint. This is not a full-frame or pixel-exact palette/driver claim.

## Bar charts: hotspot1, drawing8502, bitmap8503

The complete compiled8502 module exports and alternate-entry helper are retained in `template-code-analysis/`. Native geometry uses original count field2, values3..7, baseline8, interval9, category labels10..14, axis labels15/16, title17 and palette theme18. Spacing is`(121-count*17)/(count+1)`. Inclusive bar bounds are X48+spacing+(17+spacing)*index throughX+17, Y125−16*(value−baseline)/interval through125. The source grows scanlines upward and then outlines the bounds. The native endpoint preserves these positions, tick/font placement and original theme colors while omitting growth delays/audio. The original unused022b axis helper is not substituted for the baked bitmap axes.

All320 recovered bar cases render. A generated9010/seed1/variant0 fixture has four interview bars6,3,9,3, baseline0 and interval3; the Tuesday question answer is25 after restoring22 cut minutes. This is a static-code/generated-data fixture, not independently claimed as a local-video scene. Native image:`verification/native-interviews-bar-chart.png`.

## Native verification and limits

The standalone native check originally rendered960 measurement/line-chart/cassette cases. The main app checks now render all320 available generated cases for each of bar charts, measurement, line charts and cassettes, totaling1,280. They also independently assert the recorded Cartoon chart's values/point locations and the generated interview-bar values. Resource/data bounds and control ranges are checked before rendering.

No full activity fidelity claim is made. Original intro timing/audio, driver masking and some palette behavior remain open. The remaining hotspots3,4,7 are now implemented in ActivityFinal.swift; see final-activities-recovery.md. Original timed effects and full campaign generation remain unfinished.


##0.22 superseding timing recovery

The bar-growth, needle movement, line-series waits and cassette arrival omissions above are historical. Native timelines now restore their recovered timing, sound requests/stops and deferred question-panel entry. Endpoint geometry and driver-mask limits remain as documented. See activity-timing-recovery.md.
