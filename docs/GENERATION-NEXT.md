# Continue from0.7: final encounter and complete session lifecycle

Question setup recovery is implemented and verified. Do not redo it. See
`question-generation-recovery.md`, QuestionSetup.swift and245-check report.
All3,200 question cases compile/render, including the30 original in-buffer
references which produce empty second paragraphs. New-game choices/order and
question-entry RNG reset are source-derived. Custom/practice menus and timed
effects still need integration; complete campaign RNG identity is not claimed.

The next major gameplay gap is the original Master of Mischief encounter:
NativeApp.confirmDecision currently explains that it remains unavailable. Do
not turn a correct decoder guess directly into victory. Recover original
decision penalties, discovery/chase/escape/capture conditions, animation/sound,
win/loss bonuses, lifetime point/rank updates and next-session flow, using
retained game-pseudocode.c and original bytes through REA as needed. Use the
local MKV ending frames/audio for comparison, never the superseded YouTube link.

Other open gaps: original menus/options/help/notes and practice, collision
knockback/impact sequences, queued input, timed activity effects, transitions,
palette/driver fidelity, full playthrough verification and final distribution.
Check any clue-reveal assumptions against original1d06:00a2 and18e7:02b5 while
integrating the ending; current room completion is native infrastructure.

Existing drill checkpoint uses an explicitly preserved decoder fixture seed6908
to retain observed symbols. It is not a recovered historical campaign seed.
Pre-0.7 saves lack original startup choices; marked migration preserves their
decoder, existing questions and progress rather than pretending to reconstruct
the missing original seed. Native0.7 source/runtime packages still require
relocated strict-signature and Apple-tools source-rebuild verification.

The complete-game goal stays ACTIVE. This turn made concrete implementation
progress; it was not a waiting or no-progress turn. No agents/processes are
needed for already completed0.7 work. REA original analysis session was closed.
