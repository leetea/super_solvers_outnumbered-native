# Windows native port — implementation in progress

Target: Windows 10 22H2 / Windows 11, Intel/AMD x64. Portable ZIP, native Swift
and SDL3. No DOS emulator, Apple runtime or CPU emulation is part of the app.
The macOS 1.0 release remains preserved separately.

Shared controller, logical keyboard events and raw framebuffer use Foundation.
PlatformMac.swift owns AppKit presentation. PlatformWindows.swift and the small
SDL C bridge own Windows input, window, scaling and audio. Existing logical key
identifiers are internal game-control IDs, not OS keyboard codes.

Windows build: Swift 6.4.1, Visual Studio x64 C++ tools, Windows SDK and official
SDL 3.4.18 development package. From a developer PowerShell, run:

    ./windows/build.ps1 -SDLRoot C:/path/to/SDL3-3.4.18

The workflow runs on Windows x64. A passing hosted-server build is not proof of
interactive Windows 10/11 compatibility. Final release still requires clean-PC
startup, sound, scaling, focus, ordinary win/loss and save/replay acceptance.

Controls: arrows, Up to interact/jump, Space to zap, Tab to open decoder, Enter,
Escape, F1 Help, F2 File, F3 Options, Home/F12 left flip, Page Up right flip.
Calculator accepts digits and arithmetic keys. Ctrl-R at Sign-In opens restore
removed member; Ctrl-R is reserved for restoration on Windows.

Saves are under %LOCALAPPDATA%/OutnumberedNativeReimplementation, separately from
read-only assets. Do not replace original saves to test. Use the existing
OUTNUMBERED_NATIVE_DATA_DIR override for isolated verification. Copy macOS save
files into a separate test directory before compatibility checks.

No final Windows release or interactive success is claimed until recorded gates
pass. Original DOS ZIP, gameplay MKV, compiler caches and player saves are excluded.
