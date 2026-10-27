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


Milestone0.13 restores the original Drill for Skill introduction and all three
result animations (108 recovered sprite commands), their sounds and the
sound-completion wait before the original Enter-to-continue prompt. The source
counter panel/digits,120-tick problem-count boundary and independent practice
timer replace the previous native footer. Running counters survive another set;
practice still awards no adventure rewards and never writes its suspended save.
469 native checks pass, including both imperfect animation/sound selections,
exact two-draw result RNG consumption, timer/counter boundaries, sound waiting,
repeated sets, visible questions and deterministic animation repainting.
Keyboard-buffer/driver parity, opening/File presentation, transitions/collisions,
timed activities, palette/audio calibration, ending refinements and a full
natural adventure playthrough remain. See practice-presentation-recovery.md.


Milestone0.15 adds staged room-door entrances and exits using the recovered walking/rear/front/shrunken poses, panel order, aligned hallway return and source24IRQ pose waits. Native input is locked during the synchronous sequence. Transition state persists across native saves and destination initialization runs once after restoration. Legacy saves remain readable. All504 checks pass locally and ordinary News entrance/exit poses were captured in the native window. Elevator final facing is corrected, but its animation/vertical scroll remain unfinished. Unpaced original viewport copies are presented for4IRQ ticks natively; this is an explicit timing adaptation, not original-CPU-speed parity. See door-elevator-transition-recovery.md.


Current verification status0.15: ordinary native win/restart/replay was established at0.14; staged room-door transitions, aligned returns and elevator final facing are now implemented with504 checks. Older milestone paragraphs above retain their historical verification limits. Full elevator animation/scroll, collision/timed effects, opening/File/sign-in and remaining presentation/audio fidelity are still required.


Milestone0.16 adds the original staged elevators: approach/shrunken/front poses, four mirrored-panel frames with source23IRQ waits, eight vertical bands with source23IRQ waits and correct direction, one-time travel sound/destination changes, final side-specific facing, input lockout and persistent travel progress. All563 native checks pass. Final native-window trips verified both left-side directions and corrected the viewport padding seam; right-side origins and save/resume have headless coverage. Existing resources remain unchanged. Camera/boundary edge cases, auxiliary actor stepping during synchronous transitions, collision/knockback/occlusion, timed activities, opening/File/sign-in, queued inputs and remaining ending/palette/audio fidelity still prevent complete-game status. See elevator-transition-recovery.md and gui-observations-0.16.json.


Milestone0.17 restores Telly, projectile and LiveWire updates during room/elevator pose and panel loops. Spawning stays disabled as in1559(0), but absent-enemy RNG draws and active motion continue. The elevator cleanup update is included; vertical scroll bands do not step actors. Saved per-frame cursors prevent repeated updates after restore, and older cursorless saves skip completed frames without replaying past RNG. Alignment preserves the initial facing until the original force-right pose. All582 native checks pass, including exact absent-enemy draw totals, active Telly motion, projectile/LiveWire updates, timer batching equivalence and legacy resume. A naturally spawned Telly/projectile advanced during a normal native-window News entrance; room exit and elevator travel also completed. Detailed camera/bounds, collision/knockback/occlusion, machine eye animation, timed activities, opening/File/sign-in, queued input and remaining ending/palette/audio fidelity keep the complete-game goal active.


Milestone0.18 restores original camera-before-actor ordering and signed movement for walking, horizontal jumps and door/elevator alignment. The recovered asymmetric floor-edge predicates preserve a two-unit jump camera overshoot; original screen bounds replace the former global clamp. New transition saves retain the recovered scrolled return viewport; older in-progress transitions retain their previous frame positions. All610 native checks pass, including floor traversals, edge arithmetic, transition alignment and enemy context ordering. Native-window walking and a Cartoon Room approach/entry/return verify the scrolled aligned viewport. Blocked-walk impact/recovery, collision/knockback/occlusion, machine eye animation, timed activities, opening/File/sign-in, queued input and remaining ending/palette/audio fidelity keep the complete-game goal active.


Milestone0.19 replaces the coarse player pose counter with persisted original walk/flip/impact/knockback/recovery states. Blocked walks play nine impact and nine recovery frames; collisions use the recovered word,200IRQ wait, reaction and one-time penalty. LiveWire uses its original ROOM reaction sprites. Telly and projectiles now draw after the player, matching actor slots. All675 native checks pass, including every reaction row, exact completion sounds, all projectile/facing combinations, partial-flash/reaction resume, frozen actors/RNG and opaque foreground pixels. Ordinary native-window play showed a boundary impact, a natural type25 projectile hit followed by recovery, and a vertical jump/landing. Impact-word timing and diagonal flips remain headless observations. Broader mask/encounter presentation, machine eye actor, timed activity effects/RNG, opening/File/sign-in, queued input, ending/palette/audio refinements and a fresh full playthrough keep the complete-game goal active.
