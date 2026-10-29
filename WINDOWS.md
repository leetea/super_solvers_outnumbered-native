# Windows native port — 1.0.2 candidate

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
Calculator accepts digits and arithmetic keys. Ctrl-R at Sign-In removes a member recoverably; Ctrl-Shift-R restores a
removed member.

Saves are under %LOCALAPPDATA%/OutnumberedNativeReimplementation, separately from
read-only assets. Do not replace original saves to test. Use the existing
OUTNUMBERED_NATIVE_DATA_DIR override for isolated verification. Copy macOS save
files into a separate test directory before compatibility checks.

No final Windows release or interactive success is claimed until recorded gates
pass. Original DOS ZIP, gameplay MKV, compiler caches and player saves are excluded.

## Windows 10 desktop acceptance

The user has a Windows 10 test machine. Once a candidate ZIP is available:

1. Extract the full folder and open Outnumbered.exe. No developer tools or extra
   runtimes should be installed. Record the candidate's build/commit identity.
2. Run Run-Windows-Checks.cmd; retain its checks.json and errors.txt. Verification
   uses a separate directory, leaving regular player profiles untouched.
3. Check the opening, keyboard and mouse controls, resizing, display scaling,
   sound/music toggles, switching away and back, and Help/File/Options screens.
4. Complete an ordinary adventure: capture code, answer room questions, recharge,
   use the calculator and decoder, quit/resume mid-game, win and replay. Confirm
   rank and high-game history. Also check a loss and a separate practice set.
5. Move the extracted folder to a path with spaces/non-ASCII characters and
   launch again. Saves should remain available under LOCALAPPDATA.

A Windows 11 desktop run is still required separately before claiming tested
Windows 10/11 compatibility. Hosted Windows Server CI does not replace that run.

## Updates synchronized with macOS 1.0.2

This candidate includes corrected hallway end walls, Energy colors, centered
Time/Score values, the master speech bubble and the single-player ending fix.
Music resumes from its interrupted position after action sounds. This is an
added native enhancement: the original DOS game restarted the tune. See
[the behavior comparison](docs/NATIVE-ADDITIONS.md).

The package includes build-info.json with its source commit. Automated checks
cover 1,160 cases, clean-PATH startup, SDL display/audio setup and nonzero-position
music playback setup. Dummy-device checks do not establish audible output or
interactive Windows 10/11 compatibility. Keep all bundled DLLs and assets beside
Outnumbered.exe; extracting only the executable is insufficient.
