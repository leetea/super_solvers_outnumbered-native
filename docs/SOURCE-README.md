# Outnumbered! for Apple Silicon

A native macOS reimplementation of Super Solvers Outnumbered using recovered
original artwork, fonts, questions, game rules and PC-speaker sound data.
Version 1.0 has passed an ordinary winning campaign, quit/resume/replay, and
independent distribution, source-archive and repository rebuild checks.
It contains no DOS emulator or executable DOS/drawing-driver code.

## Play

Extract the ZIP and open Outnumbered.app on an Apple Silicon Mac with macOS12
or newer. The app includes its data and sounds; no Python, DOSBox or developer
tools are needed to play. It uses an ad-hoc local signature, not Apple notarization.

Use the arrow keys to walk, Up to enter a door/use an object or jump, Space to
zap, and Tab to see the decoder. Enter accepts answers/selections; Escape goes
back where the original game allows. F1 opens Help, F2 File and F3 Options.
Some Mac keyboards require holding Fn for those function keys. The calculator
accepts digits, +, -, *, /, = (or E), C and Delete. Mouse clicks on game buttons
are a native convenience. The Game menu also provides macOS shortcuts.

The original game loop includes the TV station and five rooms, all ten challenge
families, Telly/LiveWire encounters, Drill for Skill, energy recharge, secret code
and room clues, three decoder match rules, eight ranks, win/loss/replay, settings,
Help and score tables. Development reference checkpoints are hidden in release.

## Saves

Players and unfinished games use separate native JSON files under the app's
Application Support directory. The DOS archive and supplied video are never
modified or used as a writable save directory. Practice preserves the suspended
adventure. Removing a member archives it recoverably; use Game → Restore Removed
Member to recover it. Existing native-development players remain compatible.

## Build from source

With Apple's Command Line Tools installed on an Apple Silicon Mac:

```
zsh build.sh /private/tmp/Outnumbered.app release
```

No network, package manager or original DOS executable is needed. All Swift
sources and required decoded data accompany this archive. For the optional
developer menus, replace release with development. To run verification:

```
OUTNUMBERED_CHECK_OUTPUT=/private/tmp/outnumbered-checks /private/tmp/Outnumbered.app/Contents/MacOS/OutnumberedNative --self-test
```

Choose a fresh output directory for each run. Verification writes isolated test
players there, not your real profiles. Diagnostic startup/ending reports are
opt-in through OUTNUMBERED_NATIVE_STARTUP_REPORT/OUTNUMBERED_NATIVE_ENDING_REPORT.

## Scope

The target is the16-color EGA presentation and recovered PC-speaker sound stream.
Native windows, mouse input/focus, recoverable member removal, separate saves and
60Hz presentation are documented platform adaptations. CGA/monochrome/Tandy
hardware and identical analog speaker/CPU-speed behavior are not claimed.
This is a reimplementation informed by original code/data, not direct binary
recompilation. Original game artwork and other content retain their ownership.
See the included recovery documents and final verification report for evidence.
