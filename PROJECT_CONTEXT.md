# Project context and decisions

The project began with an assessment of whether the supplied DOS game could be
recompiled into a genuine native Apple Silicon macOS app without a DOS emulator.
The shipped game contains16-bit x86 DOS executables and compiled resource drawing
modules. Direct source recompilation is unavailable without original source;
binary reverse engineering and native reimplementation are distinct approaches.

The user chose a native prototype, then authorized an end-to-end reimplementation
toward the complete game. The first prototype demonstrated native rendering and
controls but used invented rules. It is preserved separately and is not evidence
that the original game is complete.

The development app now translates recovered original resource data and rules
into Swift/Cocoa. Original files remain unchanged; decoded data, analysis copies,
native saves and generated app artifacts are separate. The app never executes
the DOS EXE, graphics drivers or compiled TEMPLATE drawing modules.

The user replaced the YouTube link with `OutNumbered Gameplay.mkv` as the gameplay
and sound reference. The reference ZIP SHA256 is
`6766fbaa4152436ec1096bf1a06c5889a7b82f25b5ee33bb7583629b8252dd14`;
the local video SHA256 is
`6960fb011e044a141e75e734e35140ff5c6c62e8e3440bf78f96d27baf957205`.
Neither input is included in this repository.

Question generation is compiled ahead of time for the recovered finite domain:
80 records ×10 stored seeds ×4 variations. This is data translation, not x86 or
DOS emulation. The30 unusual9056 references were resolved against original
cleared-buffer semantics and retain empty second paragraphs; no replacement
questions or answers were invented.

All reported evidence is scoped: source recovery, headless checks, native-window
observations, audio measurements and package rebuilding are distinct. No partial
milestone establishes pixel/audio parity or a finished faithful game. The complete
goal remains active until all required behavior and a complete playthrough are
verified.

On October24,2026, the user additionally requested a GitHub repository containing
the project, plan and chat-derived context, with updates after every completed
milestone. This private repository implements that request. This document is a
project-focused summary, not a verbatim chat transcript or a record of internal
agent/tool instructions.

Milestone 0.8 connects the original scripted ending and native session lifecycle.
A correct hideout runs the reveal/escape presentation and energy/time/victory
bonus tally; a wrong choice ends the game. The recorded checkpoint reaches
11,680 game points and 64,275 lifetime points. Native run IDs make result commits
idempotent after interruption, and replay retains earned lifetime/rank. These
checks do not establish a complete natural playthrough or exact presentation
parity. Original menus and the remaining fidelity work are still required.

Milestone 0.9 adds functional player/game/custom/practice menus and the recovered13-byte settings record. Game and practice settings are stored separately per native player; old profiles/sessions remain readable. Practice retains running counters across sets and cannot award adventure points or modify an unfinished adventure. Native macOS dialogs expose original values/validation rather than claiming DOS dialog pixel parity. Replay keeps mutated decoder pools while reseeding from the previous stream. Timed effects and practice/menu RNG still prevent a full campaign identity claim; score history/music and fidelity work remain.


Milestone 0.10 restores the original eight-topic help book:22 pages, four
illustrations, original font/keycaps, topic menu, frame and Back/Next/Done
navigation. F1 works from title, menus, activities and practice. Practice exposes
only About Drill for Skill. Help preserves unfinished question input and pauses
active adventure time. All332 headless checks pass; native-window observations
and independent package/source rebuilds are separate gates. See help-recovery.md.

The former notes_clipboard/paper catalog labels were corrected: original code
uses those assets for player sign-in. No source evidence establishes a notes
editor, so no invented editor is required. High-game history/music, original
practice/menu presentation, transitions, collisions, timed effects, ending
refinements and complete natural-playthrough validation remain required. The
complete-game goal stays active.


Milestone0.11 adds original lifetime/high-game score screens and the source
top-ten insertion rules. Individual winning games retain their pre-award rank;
ties stay behind existing equals, and ties with tenth do not qualify. History
and lifetime commit atomically with result recovery. Existing files without
history remain readable; historical games are not invented from lifetime totals.
353 native checks pass. Command7/8 open the score screens; Enter/Esc returns.
Arrow keys page lifetime rows when native profiles exceed the DOS ten slots.
Music/new-user options, original practice animations, full File/sign-in UI,
transitions/collision, timed effects and complete playthrough remain unfinished.
See score-history-recovery.md for original evidence and native adaptations.


Milestone0.12 connects independent Music and master Sound controls, opening
theme requests and all18 original new-user message texts. Native session flags
preserve original unseen/queued/acknowledged states; Yes resets them, No preserves
them. Source-derived room, challenge, collision, decoder, energy, clock and idle
input hooks display guidance through accessible macOS dialogs with readable key
names. Practice message state remains separate from the suspended adventure.
382 native checks pass. Native dialog pixels, exact settled-actor timing and
opening credits remain presentation gaps; see music-messages-recovery.md.
The complete-game goal remains active, with original practice animations,
transitions/collisions, timed effects, palette/sound calibration, ending refinements
and full natural-playthrough verification still required.
