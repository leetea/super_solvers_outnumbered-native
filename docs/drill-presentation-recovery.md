# Adventure Telly presentation recovery — milestone 0.21

The native adventure now uses original DRILL graphics for the introduction,
question television, spinning code card and captured-symbol burst. The original
executable remains read-only and is not present or executed in the app.

## Original procedures and call order

The caller is1fc6:09c3 (loaded0x20623). Its near calls cross a16-bit IP boundary.
Ghidra prints misleading segment-normalized destinations0x2fcc1/0x2fd2f;
raw E8 displacements with the caller's original CS1fc6 resolve to1fc6:0061
(0x1fcc1) and1fc6:00cf (0x1fd2f). The local analysis-only derivative changes
only the MZ initial CS/IP header to admit the latter procedure. Code, data and
relocations are unchanged; neither executable is distributed.

-1fc6:0061 alternates DRILL10/11 at76,28 for eight20IRQ frames. Each frame
requests sound23; completion draws DRILL12 and stops the sound. Adventure
starts its first240IRQ question wait after this introduction.
- Questions use the static DRILL12 overlay. Existing question generation,
feedback waits, acknowledgement RNG and50-point award rules are retained.
- On success,1fc6:00cf displays DRILL3..9 at152,55 for50IRQ each, requesting
sound48 after each exchange. The original clear uses byte-column coordinates
19..23, y53..89; native full redraw clears the equivalent black rectangle.
After350IRQ it draws DRILL2 at76,28. Only then does the caller collect the
next secret, draw FASTLOAD78+symbol at156,65, add100 and wait720IRQ.
- On insufficient correct answers or Escape while answering, the caller runs
another eight-frame introduction, then sound9, the No Code message at102,70
and a480IRQ wait. Enter cannot skip these synchronous waits.
-135d:0035 requests player state1 with zero horizontal/vertical motion after
its90IRQ zap. Native completion now resets the requested motion before the
next world update, retaining the already displayed pose until that update.

`verification/drill-presentation-instructions-0.21.json` retains the caller and
raw capture instructions. Introduction evidence remains the earlier
menu-analysis/practiceinitasm.json, evidence
`ev_73a1b43ad506d5edd65d00908b379150bd21d8b22c163b8da2e4e5231bc6dd2d`.
The sound-stop helper is also retained in menu-analysis/next-17d1a.json.

## Native timing and saves

`NativeDrill.presentation` is optional. New adventure drills have persisted
introduction/questions/capture/rejection/result stages, elapsed IRQ count and
an already-started sound flag. Older in-progress drills without this field
continue from their existing phase without retroactive animation. Practice
keeps its separately recovered introduction and result scripts.

Coarse pulses preserve unused time across presentation/question/result
boundaries. First-frame sound starts even when a phase boundary has no unused
time; restore does not reissue a sound for a frame already started. The code
reward is guarded until capture completion and remains idempotent after save
and restore. World actors and gameplay RNG freeze during presentation. The
adventure clock continues through ordinary drill polling, as before; this is
not a new proof of BIOS input-buffer or interrupt-level global-clock parity.

## Local recording comparison and limits

Only the supplied local OutNumbered Gameplay.mkv was used. Samples at30fps
show isolated original white-card masks3,4,5,6,7,8,9 in order around163.07–164.53s,
followed by the burst/secret and the900→1000 score change. The best white-mask
differences range12–24 pixels within the40×34 region, affected by recording
scaling/compression. Detailed samples and the explicit heuristic are retained
in `verification/drill-card-local-video-0.21.json`. This corroborates artwork,
order and approximate cadence; it is not bit-exact palette, IRQ, audio or
whole-screen validation. No new listening-parity claim is made.

Source-derived timing/save checks and native-window observations are reported
separately. The complete-game goal remains active: timed activity effects/RNG,
opening/File/sign-in presentation, queued input, ending refinements, detailed
masks/panel occlusion, palette/audio calibration and a fresh full adventure
playthrough remain before completion.
