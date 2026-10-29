# Graphics and audio verification — local0.35

Original ZIP/MKV are read-only; their hashes are unchanged. The native target
is the original16-color EGA presentation with PC-speaker musical data, composed
through Cocoa/Swift. No DOS runtime or original machine code executes.

## Raster boundary

Cached resource loader1647b decompresses twice and calls04b4→10684. The converter
skips the16-byte CGA translation table, copies declared width/height, and converts
packed nibbles into four EGA bitplanes.11168 clips the declared image, ORs all
four planes to obtain the transparent write mask (only logical color0 skips),
and reverses bit order for mirror20h. Black1 remains opaque. Evidence is retained
in bitmap-conversion-instructions-0.35.json and graphics-driver-instructions-0.35.json.

An independent plane-based oracle compares all389 original catalog bitmaps
against the native canvas in six cases: opaque, transparent, mirrored, partial
left/top/right/bottom clipping, and a four-pixel destination alignment. Each
case begins over all16 background colors. All2,334 full-canvas comparisons pass.
All original bitmap widths are multiples of8; all26 extra decoded extents remain
retained outside the declared height. The source converter and painter use the
declared extent, so extra rows are not evidence of additional normal painted rows.
This verifies the target raster algebra, not an original DOS whole-frame trace.
Existing source-derived world/door/elevator foreground ordering remains in place.
CGA/monochrome output, alternate hardware and CPU-speed display-copy durations
are not represented as identical by this native port.

## Sound boundary

All52 PCM files regenerate byte-identically from the recovered stream commands,
pitch table, PIT1193182Hz/IRQdivisor5041 and articulation rules. No sound asset
was retuned or replaced. audio-comparison-0.35.json retains all per-effect hashes
and broader spectral searches at the unchanged source pitch and tempo.

The supplied recording shows EnergyLeft2550 at407.272s, the WinningGame2000
panel at418.416s, and trophy introduction at434.048s. Native sounds46/47/16 have
corresponding spectral candidates with similarities0.94302/0.94908/0.91801.
The correct-answer7 candidate at76.808s has0.9748 similarity, corroborating the
earlier long-note pitch/timing measurement. These scores are diagnostic cosine
similarities, not probabilities, perceptual judgments or analog/phase identity.
Short/shared sounds have false candidates; the recording does not exercise all52.
Tandy multi-channel synthesis is outside the PC-speaker target. Original priority
arbitration and per-call music/master-sound gating remain native implementations.

## Native startup and gates

An opt-in local first-draw report measures0.255995s from native main to drawing
the first window frame. CUA took34.39s to return from getApp, while its earlier
ending-app call took463.3s and most delay preceded process launch. The measured
native startup does not reproduce that service delay. The report writes only
when OUTNUMBERED_NATIVE_STARTUP_REPORT is explicitly set for verification.

Candidate and extracted local runtime pass1111 checks/strict signatures; both
are ARM64. All32 compiled sections/484 assets match the isolated GUI copy.
The native window rendered title/rainfall, quit normally, and left copied player
files byte-identical. Latest checkpoint is outputs/local-checkpoints/
Outnumbered-0.35.zip. Final ordinary campaign and independent final source,
repository and distribution gates remain. GitHub is held until final app ready.
