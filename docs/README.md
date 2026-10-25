# Outnumbered Native Development Build 0.7

Open `Outnumbered Native Development.app` on an Apple Silicon Mac with macOS12 or later. This is a playable development milestone toward the complete game, not the finished game.

Choose **Game → Reference Rainfall Question** (Command-R) to try the question from your local gameplay recording. The answer is **644**. A first-try answer earns300; each wrong attempt reduces the available award by100. After two wrong answers, press Enter to reveal the original generated hint. This reference checkpoint does not affect saved player progress.

From the title screen, Return opens/resumes a native Player session. Left/Right walks, Up enters a nearby door/elevator or jumps, Up with Left/Right flips, Space zaps, Tab opens/closes the decoder, and F1 opens controls. Use the decoder buttons or M to read the Match Rule. Numeric input, Backspace and Enter work in the rainfall activity.

Choose **Game → Reference Telly Drill** (Command-D) to play the recording's six questions. Answers are **19,12,22,7,22,3**. Correct answers earn50 each; at least five correct answers earn a code piece and100 more. Feedback pauses are automatic, and the game clock keeps running. This checkpoint uses an isolated native session.

The app now includes Telly encounters, zaps, thrown tricks, generated math drills, code capture, room traversal, map/prize-board/television-table activities, decoder logic and partial-game saves. It also includes energy recharge, LiveWire, measurement controls, video cassettes and Cartoon line charts. It now includes bar charts and the original calculator arithmetic/editing rules. All ten activity families now have native visual context for the recovered question bank. Complete custom/practice settings, final sequence, progression and fidelity refinements remain incomplete. Some palette, collision and transition details also remain incomplete. This is not a complete or pixel-exact game.

Native player files are separate from DOS assets:

`~/Library/Application Support/OutnumberedNativeReimplementation/`

The supplied DOS archive and local video are read only and unchanged. The app is ARM64 native and requires no DOS emulator, Python installation or downloaded runtime. It has an ad-hoc development signature, not Apple notarization.

The source archive contains Swift source, the build script and derived runtime assets. With Apple command-line developer tools available, open its source folder in Terminal and run `zsh build.sh`; the app is built next to that source folder. No dependency installation is performed.

The full roadmap and fidelity gaps remain in the project's `GOAL.md` and `work/reimplementation/DEVELOPMENT-STATUS.md`.

New checkpoints: Command-E opens a machine with four earned recharge units; press Up to use it. Command-L opens LiveWire; press Space promptly to disperse it. Command-G opens the recorded Cartoon Songs graph question; its answer is0. These checkpoints do not change player saves.

Calculator: type numbers and +, -, * or /. Press = (or E) to calculate, then Enter to submit. Operations chain left to right. Backspace/Del edits; C clears. Results must be whole numbers and at most9999. Mouse buttons work too. Game → Use Calculator turns it on/off. For rainfall, try832-123= followed by-65=, then Enter. Command-B opens a generated-original-data interview bar-chart checkpoint; its answer is25.

Command-1 opens Spinner (answer100); Command-2 opens Great Eight (answer106); Command-3 opens Equipment List (answer29). Each is an isolated original-data checkpoint. Extra chart numbers follow the recovered question seed and drawing rules, and repainting does not change them.

Command-4 opens a Junior question selected by the recovered original new-game rules (answer165). New games now store original seeds, variants and operations, enable one question per room at lower rank pairs and both at higher pairs, and generate decoder clues and machine placement afterward. All3,200 compiled question cases are available;30 retain unusual original references which produce an empty second paragraph. Existing saves preserve their progress through a marked migration. Complete custom/practice menus, timed activity effects and full campaign fidelity remain pending.
