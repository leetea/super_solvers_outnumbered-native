# Outnumbered Native Development Build 0.22

Open `Outnumbered Native Development.app` on an Apple Silicon Mac with macOS12 or later. This is a playable development milestone toward the complete game, not the finished game.

Choose **Game → Reference Rainfall Question** (Command-R) to try the question from your local gameplay recording. The answer is **644**. A first-try answer earns300; each wrong attempt reduces the available award by100. After two wrong answers, press Enter to reveal the original generated hint. This reference checkpoint does not affect saved player progress.

From the title screen, Return opens the player menu. Create or select a player, then choose Play Game, Customized Game or Customized Drill for Skill. Play Game offers Continue/New for an unfinished adventure. F2 opens the player menu; F3 opens sound/calculator options. Left/Right walks, Up enters a nearby door/elevator or jumps, Up with Left/Right flips, Space zaps, Tab opens/closes the decoder, and F1 opens original help. Use the decoder buttons or M to read the Match Rule. Numeric input, Backspace and Enter work in the rainfall activity.

Choose **Game → Reference Telly Drill** (Command-D) to play the recording's six questions. Answers are **19,12,22,7,22,3**. Correct answers earn50 each; at least five correct answers earn a code piece and100 more. Feedback pauses are automatic, and the game clock keeps running. This checkpoint uses an isolated native session.

The app includes Telly encounters, zaps, thrown tricks, generated math drills, code capture, room traversal, all ten activity families, decoder logic, recharge, LiveWire, the calculator and native saves. It now includes the original scripted hideout reveal, progressive bonuses, win/loss outcomes, lifetime points and replay. Separate custom game/practice settings, player switching, practice counters and unfinished-game continuation are now connected. Original opening/menu animations, detailed ending/transition effects, collision presentation, palette and complete fidelity validation remain incomplete. This is not a complete or pixel-exact game.

Native player files are separate from DOS assets:

`~/Library/Application Support/OutnumberedNativeReimplementation/`

The supplied DOS archive and local video are read only and unchanged. The app is ARM64 native and requires no DOS emulator, Python installation or downloaded runtime. It has an ad-hoc development signature, not Apple notarization.

The source archive contains Swift source, the build script and derived runtime assets. With Apple command-line developer tools available, open its source folder in Terminal and run `zsh build.sh`; the app is built next to that source folder. No dependency installation is performed.

The full roadmap and fidelity gaps remain in the project's `GOAL.md` and `work/reimplementation/DEVELOPMENT-STATUS.md`.

New checkpoints: Command-E opens a machine with four earned recharge units; press Up to use it. Command-L opens LiveWire; press Space promptly to disperse it. Command-G opens the recorded Cartoon Songs graph question; its answer is0. These checkpoints do not change player saves.

Calculator: type numbers and +, -, * or /. Press = (or E) to calculate, then Enter to submit. Operations chain left to right. Backspace/Del edits; C clears. Results must be whole numbers and at most9999. Mouse buttons work too. Game → Use Calculator turns it on/off. For rainfall, try832-123= followed by-65=, then Enter. Command-B opens a generated-original-data interview bar-chart checkpoint; its answer is25.

Command-1 opens Spinner (answer100); Command-2 opens Great Eight (answer106); Command-3 opens Equipment List (answer29). Each is an isolated original-data checkpoint. Extra chart numbers follow the recovered question seed and drawing rules, and repainting does not change them.

Command-4 opens a Junior question selected by the recovered original new-game rules (answer165). New games now store original seeds, variants and operations, enable one question per room at lower rank pairs and both at higher pairs, and generate decoder clues and machine placement afterward. All3,200 compiled question cases are available;30 retain unusual original references which produce an empty second paragraph. Existing saves preserve their progress through a marked migration. Original menu/practice presentation, timed activity effects and full campaign fidelity remain pending.

Command-5 opens the ending checkpoint from the local video: 2,650 points, 17 energy, 9:52 PM and 52,595 lifetime points. It runs the scripted reveal and awards 2,550 for energy, 4,480 for time and 2,000 for winning. The result is Game 11,680 / Total 64,275, crossing the Pro threshold. Enter then Yes starts a fresh isolated game. This checkpoint does not affect saved player progress.

In normal play, confirming a correct decoder choice runs the ending and saves lifetime points once; a wrong hideout choice or midnight loses without adding lifetime points. Partial ending progress is saved, and replay retains earned rank while resetting game progress. Bonus sliding, rank animation and midnight meter flashing still need refinement. The private GitHub repository is https://github.com/leetea/outnumbered-native-macos ; each verified milestone is pushed there.

Milestone 0.9 adds the original13-byte settings rules. Custom games can change operations, drill numbers/formats and room math level independently of earned rank. Practice sets have5,10,15 or20 questions, retain running attempts/correct counters between sets, and award no adventure points, energy or code pieces. Enter starts another set; Esc/F2 returns to the player menu. The suspended adventure is preserved. Settings use native macOS controls with Undo and Standard Settings. Replay now preserves mutated decoder pools while reseeding from the previous random stream; complete campaign stream identity remains unverified.


Milestone 0.10 restores the original eight-topic help book:22 pages, four
illustrations, original font/keycaps, topic menu, frame and Back/Next/Done
navigation. F1 works from title, menus, activities and practice. Practice exposes
only About Drill for Skill. Help preserves unfinished question input and pauses
active adventure time. All332 headless checks pass; native-window observations
and independent package/source rebuilds are separate gates. See help-recovery.md.

The former notes_clipboard/paper catalog labels were corrected: original code
uses those assets for player sign-in. No source evidence establishes a notes
editor, so no invented editor is required. Music, original
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


Milestone0.16 adds the original staged elevators: approach/shrunken/front poses, four mirrored-panel frames with source23IRQ waits, eight vertical bands with source23IRQ waits and correct direction, one-time travel sound/destination changes, final side-specific facing, input lockout and persistent travel progress. All563 native checks pass. Final native-window trips verified both left-side directions and corrected the viewport padding seam; right-side origins and save/resume have headless coverage. Existing resources remain unchanged. Camera/boundary edge cases, auxiliary actor stepping during synchronous transitions, collision/knockback/occlusion, timed activities, opening/File/sign-in, queued inputs and remaining ending/palette/audio fidelity still prevent complete-game status. See elevator-transition-recovery.md and gui-observations-0.16.json.


Milestone0.17 restores Telly, projectile and LiveWire updates during room/elevator pose and panel loops. Spawning stays disabled as in1559(0), but absent-enemy RNG draws and active motion continue. The elevator cleanup update is included; vertical scroll bands do not step actors. Saved per-frame cursors prevent repeated updates after restore, and older cursorless saves skip completed frames without replaying past RNG. Alignment preserves the initial facing until the original force-right pose. All582 native checks pass, including exact absent-enemy draw totals, active Telly motion, projectile/LiveWire updates, timer batching equivalence and legacy resume. A naturally spawned Telly/projectile advanced during a normal native-window News entrance; room exit and elevator travel also completed. Detailed camera/bounds, collision/knockback/occlusion, machine eye animation, timed activities, opening/File/sign-in, queued input and remaining ending/palette/audio fidelity keep the complete-game goal active.


Milestone0.18 restores original camera-before-actor ordering and signed movement for walking, horizontal jumps and door/elevator alignment. The recovered asymmetric floor-edge predicates preserve a two-unit jump camera overshoot; original screen bounds replace the former global clamp. New transition saves retain the recovered scrolled return viewport; older in-progress transitions retain their previous frame positions. All610 native checks pass, including floor traversals, edge arithmetic, transition alignment and enemy context ordering. Native-window walking and a Cartoon Room approach/entry/return verify the scrolled aligned viewport. Blocked-walk impact/recovery, collision/knockback/occlusion, machine eye animation, timed activities, opening/File/sign-in, queued input and remaining ending/palette/audio fidelity keep the complete-game goal active.


Milestone0.19 replaces the coarse player pose counter with persisted original walk/flip/impact/knockback/recovery states. Blocked walks play nine impact and nine recovery frames; collisions use the recovered word,200IRQ wait, reaction and one-time penalty. LiveWire uses its original ROOM reaction sprites. Telly and projectiles now draw after the player, matching actor slots. All675 native checks pass, including every reaction row, exact completion sounds, all projectile/facing combinations, partial-flash/reaction resume, frozen actors/RNG and opaque foreground pixels. Ordinary native-window play showed a boundary impact, a natural type25 projectile hit followed by recovery, and a vertical jump/landing. Impact-word timing and diagonal flips remain headless observations. Broader mask/encounter presentation, machine eye actor, timed activity effects/RNG, opening/File/sign-in, queued input, ending/palette/audio refinements and a fresh full playthrough keep the complete-game goal active.


Milestone0.20 restores the room ceiling security camera (correcting the earlier energy-machine-eye label): original panning row14, four-update holds, actor order, entry/exit lifecycle and retained timing state. Recharge now uses recovered scrolling alignment, raised player poses, continued enemy/projectile updates and exact per-frame RNG bookkeeping; the unpaced-copy display interval remains a documented native adaptation. Older in-progress actions retain their prior schedule. All713 checks pass. Local video shows the corresponding pan poses; ordinary native play separately showed a panning Cartoon camera and empty-machine interaction with scroll, moving Telly/projectile and unchanged energy9. Remaining encounter/capture presentation, timed activity effects/RNG, opening/File/sign-in, queued input, ending/palette/mask/audio refinements and a fresh full playthrough keep the complete-game goal active.


Milestone0.21 restores the original adventure Telly introduction, static question television, seven spinning code-card frames, capture burst and delayed reward, and rejection introduction/message wait. Presentation state and sound-start cursors survive saves without repeated rewards or frame sounds. Older in-progress drills retain their saved timing; practice remains separate. The player requests idle motion at zap completion. The local recording corroborates all seven card sprites and their order before the900→1000 award. Detailed driver masks, input buffering, palette/audio and complete-game fidelity remain open. See drill-presentation-recovery.md.

All740 native checks pass. Final native-window reference drill confirmed the introduction, spinning card at900, automatic return at1000 and lightning piece in the decoder; the rejection introduction and No Code message were separately observed. This fixture verification is not a fresh ordinary full adventure win.


Milestone0.22 restores timed bar growth, measurement needles, line-series plotting and cassette arrivals with their original waits and sound requests/stops. The question panel and input appear after the sequence. Partial native saves preserve animation/sound progress; older ready-to-answer saves retain their state.771 checks pass, including1280 endpoint comparisons and frozen actor/RNG validation. The local video corroborates plotting and needle order. Native windows separately verified plot/bar animations and answers, plus an ordinary Cartoon cassette activity159→300points and room clues. Remaining prize/TV/spinner/music/equipment effects, input buffering, opening and other documented fidelity gaps keep the complete-game goal active. See activity-timing-recovery.md.
