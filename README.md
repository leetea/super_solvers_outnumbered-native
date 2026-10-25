# Outnumbered Native for macOS

A native Apple Silicon reimplementation of **Super Solvers Outnumbered**, written
in Swift with Cocoa. This is an active reconstruction project, not the finished
game. It uses translated original data and native game logic; no DOS emulator,
original DOS executable, or compiled DOS drawing routine runs inside the app.

## Current verified milestone: 0.7

All ten activity families and3,200 finite-domain question cases render natively.
Recovered new-game question choices, decoder generation, movement, Telly drills,
LiveWire, recharge, calculator, clues, scoring and separate native saves are
implemented.245 integration checks passed. The distributed source was rebuilt
with Apple tools and the extracted app was independently checked.

The final encounter, complete endings/progression, original menus/options,
timed effects, palette and full-playthrough fidelity remain unfinished. See
[the full plan](docs/PLAN.md), [project context](PROJECT_CONTEXT.md), and
[milestone history](MILESTONES.md). Headless checks are separate from native-window
observations and do not establish a complete game.

## Build on an Apple Silicon Mac

Requires macOS12 or later and Apple's command-line developer tools. Run:

```sh
zsh build.sh
```

The verified app is packaged in `build/Outnumbered-Native-Development.zip`.
Extract it in a local folder and open `Outnumbered Native Development.app`.
The wrapper extracts the checked-in derived runtime data, then invokes the Swift
build script. Python, a DOS emulator and a downloaded runtime are not required
to build or play this version. The app has an ad-hoc development signature;
it is not Apple-notarized.

In the app, Command-R opens the recorded rainfall question (answer644).
Command-D opens the recorded drill, and Command-4 opens a Junior question
selected by the recovered startup rules (answer165). Reference checkpoints
are isolated from player saves.

## Inputs and preservation

The original DOS ZIP and downloaded gameplay MKV are read-only local inputs
and are not committed. `source/runtime-data.zip` contains derived native runtime
images, fonts, PCM and generated question data. Their provenance and limitations
are documented in the recovery notes. This private repository does not grant
rights to original game artwork, sounds, names or other third-party content.

The local MKV supersedes the original YouTube reference. Screenshots at
https://www.myabandonware.com/game/super-solvers-outnumbered-115 remain a visual
reference. No video download or original executable is required at runtime.

## Milestone updates

The user authorized pushing an update after every verified milestone. Each
milestone commit records the resulting behavior, checks and remaining gaps.
Unverified work is not presented as a completed milestone. See
[the update workflow](docs/MILESTONE-WORKFLOW.md).
