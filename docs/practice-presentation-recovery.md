# Practice presentation, milestone 0.13

This translates recovered data and control flow into native Swift. No DOS code,
processor or graphics driver executes. The archive and local MKV remain read-only.

## Evidence

The unpacked analysis derivative SHA256 is
ff2e0d28e0a6aa8bcf86db1ea8a2980d2ccb1e10dd793bc15ab1bb929697b464.
menu-analysis/practiceinitasm.json and practicecelebrate.json retain the opening
and perfect-set helpers. practice-analysis/derivatives.json proves that additional
entry seeds change only MZ IP/CS header bytes20..23, preserving all code, data
and relocations. practice-analysis/recovery.json and timer.json retain REA/Ghidra
results. Exact raw bytes resolve wrapped near calls where Ghidra normalizes CS.

1fc6:0061 draws DRILL10/11 at76,28, alternating eight20-IRQ-tick frames, requests
sound23 for each frame, then draws DRILL12 and stops sound. This runs before the
first problem and again after Enter between sets.

The common nine-byte sprite-script engine135d:0fc9 runs with30 IRQ ticks/frame:
DS5378 has21 commands/900 ticks; DS5435 has25/1020; DS5516 has62/2130. These are
FASTLOAD player poses, including transparent/mirrored flags and one-based prior
command rectangle restoration. PracticePresentation.swift preserves all108
commands directly from the original byte records. It reuses the existing data
format rather than executing or interpreting DOS instructions.

At the end of a set, perfect results play40 and use5516. Imperfect results make
two independent random draws: sound28/34, then animation5378/5435. The response
waits until both animation and actual native sound playback finish before showing
the original Enter glyph at105,105 and `to Continue` at164,105. Sound Off removes
the sound wait. Enter during the response cannot immediately restart a set.

The original counter panelDRILL13 is at208,162. Problems/correct digits use
FASTLOAD64..73, right-aligned to x300, with eight-pixel digit spacing at177/188.
Problem count increments after the first120 ticks of a240-tick preparation wait,
including subsequent practice problems. Correct count increments after the
first240-tick correct-feedback wait; both counters wrap at10000. Attempts and
correct totals survive another set, independently of adventure score and saves.

Timer1fc6:01ac increments seconds, carries after59, wraps after999 minutes and
uses source digit/colon positions. Input poll20e2:0146 checks a240-tick deadline;
it updates once when an expired deadline is polled rather than catching up every
missed second after feedback. Native practice uses the existing24-IRQ-tick
window update cadence. Practice time is independent of adventure time.

## Scope and limits

The native renderer reconstructs frames from an immutable background on each
repaint, replaying elapsed sprite commands. This avoids persistent trails and
makes repeated draws deterministic. Native checks cover original command counts,
durations, mirror/restoration relationships, timer/counter boundaries, both
imperfect animations/sounds, two-draw RNG consumption, sound wait and repeated
sets. Headless checks are distinct from real native-window observations.

This milestone does not establish complete DOS keyboard-buffer parity. App menu
shortcuts remain native controls; input received during presentation is not a
BIOS keyboard queue. Full driver masking, palette and audio calibration remain
open, as does the previously recorded occasional missing-static-text window
capture discrepancy. Full natural adventure playthrough and remaining movement,
encounter, opening and ending refinements are still required for completion.
