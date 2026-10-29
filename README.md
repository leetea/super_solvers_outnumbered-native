# Outnumbered! for Apple Silicon — 1.0

A native Swift/Cocoa macOS reimplementation of Super Solvers Outnumbered.
The game runs directly on Apple Silicon with recovered artwork, fonts, question
data and PC-speaker sound streams. No DOS emulator, DOS executable or compiled
DOS drawing module runs inside the app.

## Play and build

The final app ZIP is supplied with the project delivery. Extract it and open
Outnumbered.app on an Apple Silicon Mac running macOS 12 or newer. Playing needs
no developer tools or extra packages. The app is ad-hoc signed, not notarized.
See [the player guide](docs/PLAYER-GUIDE.md) for controls and native save locations.

To build from this repository with Apple's Command Line Tools:

```sh
zsh build.sh
```

This unpacks the included translated runtime data, builds a release app locally,
and writes `build/Outnumbered-1.0.zip`. No network or original DOS executable is
needed. Source is in `source/`; recovery evidence is in `docs/`.

## Verified scope

The station, five rooms, ten activity families, arithmetic drill, encounters,
recharge, calculator, clues, decoder, eight ranks, endings, score history, menus,
Help, practice and separate native saves are implemented. Release builds hide
development checkpoints.

The final candidate passed 1,118 native checks in the extracted app, an independent
source archive rebuild and an independent repository rebuild. An ordinary UI-only
campaign captured two code pieces, solved all five rooms, resumed after quitting,
identified the Game Show Room from visible clues, won 6,900 points, reached Junior
and replayed to the member list. This is distinct from the automated checks.
See [final acceptance](docs/FINAL-ACCEPTANCE.md) and [verification](docs/final-verification.json).

The presentation target is EGA 16-color graphics and recovered PC-speaker streams.
Native windows, focus, mouse controls, separate saves and recoverable member
removal are documented adaptations. Alternate DOS display/audio hardware,
identical analog speaker output and CPU-speed-identical presentation are outside
this target. Original content retains its ownership; no ownership or redistribution
rights are conferred by this private reconstruction repository.
