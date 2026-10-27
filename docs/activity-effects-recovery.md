# Original activity effects — native milestone 0.23

This implements four further original timed drawings in native Swift. It does not execute compiled TEMPLATE code. The original ZIP and local gameplay MKV remain read-only. See remaining-activity-effects-instructions-0.23.json for successful raw REA/assembly evidence, source hashes and transcribed tables. Analysis-only MZ entry-point wrappers are excluded from runtime and publication.

## Prize: TEMPLATE 8504 / 0x2138

The entry at module offset0065 loads at10065 in its analysis wrapper. Draw command10 calls1d62:017e: low + rand() % (high-low+1), using the recovered Turbo C stream. The flash count is an inclusive5..8 draw. Each flash selects0..3 excluding the previous prize, retries text colors14/15, and retries outline colors0,1,4,8,9,10,14,15. It draws, requests sound31, waits20IRQ, and restores white price/yellow outline. Four final black-price reveals each request31 and wait20IRQ. The first excludes the last flash; every reveal excludes already used prizes. Rejected values consume random draws. There is no explicit final sound stop.

Original outline tables follow B/C/A/D while price text follows A/B/C/D; this pairing is preserved. Bounds are inclusive. Only pixels matching color14 are replaced. No generic rectangle is substituted. The local video qualitatively corroborates different-price/different-ellipse flashes.

Fixture9100/seed1/variant0 starts from post-generation state2613937339. Eight flashes plus four reveals take240IRQ. At elapsed0/20/40/60/80/100/120/140 the cumulative draw counts are4/9/17/21/26/31/34/37. At160/180/200/220 they are38/40/41/54; final state600944149 and next rand5589. The native plan precomputes immutable frame descriptions, but the live session advances only to checkpoints reached by elapsed time. Saved initial state and applied cursor prevent early/repeated consumption. Drawing is pure. Cached plans avoid repeated schedule construction during repaint.

## Spinner: TEMPLATE8510 / 0x213e

The selected position is original field2. Sound30 begins; red highlight cycles0..9 with20IRQ holds. After the hold, stop only when step>13 and position equals the selected field. Selected0..9 durations are420,440,460,480,300,320,340,360,380,400IRQ. The selected highlight remains red and sound stops. No additional random draws occur. Original color14↔12 replacement is bounded by the two recovered rectangle tables.

## Great Eight: TEMPLATE8506 / 0x213a

Original auxiliary chart rows are generated first. Sound33 begins. Eight red/yellow pairs use waits60,20,20,20,60,60,60,60 per half, totaling720IRQ, then sound stops. Only color14 pixels inside(12,36)..(98,54) turn12; text and other colors retain their indices. Repainting does not regenerate rows.

## Equipment: TEMPLATE8516 / 0x2144

Sound34 is requested before auxiliary row RNG, matching the original entry003e. Eight header phases each hold50IRQ, totaling400. The four colors13,11,14,10 rotate one position per phase, returning to their original order at phases4/8. Headers are redrawn black over each fill. There is no explicit stop at completion. No extra random draws occur in the header loop. Question opening first stops prior sound as in1d06:00a2.

## Integration and verification

The existing persisted activity presentation now supports eight families. All use the real-time native IRQ pulse while actors/game minutes remain frozen. Input/calculator/menu guards keep questions unavailable until the final hold. Old ready saves do not replay introductions; prior0.22 presentation saves without new optional RNG fields remain readable. Sound34 is marked applied when requested before row generation, preventing duplicate start on the first tick.

800 native integration checks pass, including1280 final-image comparisons across these four320-case families, source-derived fixture schedules/colors, rejection-draw checkpoints, current-stream timing, save/resume/repaint equivalence, and all prior checks. These are native/headless observations, not original DOS runtime parity. Native-window observations are recorded separately in gui-observations-0.23.json; tested code/assets match the candidate through32 compiled sections and484 assets.

## Explicit remaining gaps

TV8512 remains static. Its raw loop has60 iterations with paired XOR, sound23, wait3, stop, wait3 (360IRQ). Point count starts51 and decreases every fourth iteration, requiring2580 coordinate calls. Command23 aliases the SAME bounded-range helper as command10 in the27-entry dispatch table; TV calls it without explicit parameters. The host caller/stack arguments remain unresolved. Replacing it with plain rand would invent the stream, so that change is not made. The graphics backend XOR selects EGA planes1..3 (mask14), but detailed driver parity remains unproven.

Prize background palette/driver differences from the video remain visible; these flashes do not resolve them. Source wait schedules do not establish analog/perceptual sound fidelity or original CPU-speed parity. Full menu/opening, queued BIOS input, mask/occlusion/palette, remaining ending details and fresh complete ordinary-playthrough validation remain required.
