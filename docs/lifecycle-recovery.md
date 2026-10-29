# Original File actions and menu returns — local0.32

Original x86 is used only as static evidence. The app implements these transitions in Swift; DOS/BIOS code is never executed. The archive and local gameplay recording remain unchanged. GitHub publication remains held until the complete app is ready.

## Corrected outer menu contract

This milestone corrects a previous interpretation instead of preserving tests for it. Source17570 starts a menu and loops while DS72aa is NONZERO (1759e/175a3). Enter17618 first blinks the selected row, then17620 calls176a9, restoring the parent, drawing neutral FASTLOAD57 and clearing72aa. It then calls the action and stores its result in72aa. Result0 ends the loop. A nonzero result calls174fc(F1), rebuilding Help topics at selection0.

Consequently music/sound/message/calculator choices return to their parent after dismissal. Canceled File actions also return to the parent. A Help page returns0 for Escape, closing Help; it returns1 for Done/F1, rebuilding topics. Local0.10 and0.31 had interpreted that last call as closing Help and had reversed those actions. Local0.31 also incorrectly kept Options open beneath its child. Historical checks and GUI observations describe those historical implementations, not proof of the corrected behavior. Current recovery documentation and checks now follow the full caller/callee sequence. Help page F2/F3 are ignored; only its source button navigation and F1/Escape apply. Score windows likewise wait for Enter/Escape and ignore function-menu keys.

`verification/lifecycle-instructions-0.32.json` retains the menu loop, clear/restore helper, Enter dispatcher, Help return logic, ordinary/practice File handlers and profile-file writer. `lifecycle-tables-0.32.json` retains exact DS352e/353c/354a/3558 descriptors and text. Ghidra's CS-relative switch coverage was incomplete; header-only seed derivatives under lifecycle-analysis expose the actual branch bodies. Only MZ initial IP/CS bytes20..23 differ, and payload equality is asserted. All analysis sessions are closed.

## Original File confirmations

All four descriptors use style3, centered coordinates and defaultNo. The existing native original dialog helper renders their source titles, CR line breaks, No/Yes buttons, navigation and Escape cancellation.

- Ordinary Play Another Game170d:0b60 draws DS352e, warning that the current game will not be saved. Only Yes saves the profile table through1a01:0188(3), then jumps to game choices through2370:003e with DS5b2e. It does not award a win/lifetime/high score or save the unfinished adventure as continuable.
- Practice Play Another Game170d:0b8c draws DS353c, asks to stop Drill for Skill, clears practice context and jumps to choices. The separate suspended native adventure remains available.
- Ordinary Start New Player170d:0bb4 draws DS354a, promising that game/score/rank are saved. Yes calls1a01:0070 to save the unfinished adventure, then jumps to Sign-In through DS5b1a.
- Practice Start New Player170d:0bdb draws DS3558, referring to retained practice settings. Yes clears practice context and selected-player state before Sign-In. It does not save an adventure from practice memory.

Native autosave is a platform addition. To represent the original explicit abandonment across a native quit/relaunch, Yes to ordinary Play Another Game marks the native session outcome `abandoned`. The native record can retain its old fields until replacement, but it is no longer offered by the Continue prompt. A subsequent ordinary/custom game starts fresh using the established generator lifecycle. Existing active/won/lost saves still load; original DOS files are never changed. This marker is native persistence infrastructure, not a claimed DOS file value. No score-history or lifetime award is issued for abandonment.

Practice menu/guide/quit save paths now refuse to write a suspended adventure. Leaving practice for game choices or player selection clears its transient in-memory adventure reference; the original native save remains available to Continue. The same guard covers native player/menu shortcuts, not only the source File flow. DefaultNo/Escape preserve partial question input, clock pause depth, generator, score and current player. Accepted Start New Player saves that same unfinished question for later continuation.

## Verification limits

Native model/state checks, actual window observations, extracted runtime packaging and independent source/repository rebuilds are separate gates. A fresh full ordinary campaign, remaining calculator/decoder/ending dialogs, graphics/masking and sound calibration remain required before complete-game status. Source/repository distribution rebuilds are deferred to the final app gate. No completion claim follows from this milestone's check count alone.

Final candidate/extracted runtime passed1,046 checks and strict signatures. Native GUI used a copied player directory and identical32 compiled sections/484 assets. It displayed allfour original File confirmations, observed Music return directly to the world, Help Done→first topic and Escape→world, ordinary New Player Yes→Sign-In, practice No→same drill and practice New Player Yes→Sign-In. Both adventure files were byte-identical across the practice phase. Ordinary Play Another Game Yes returned choices and persisted `abandoned`; copied score600/lifetime6350 and high-score table were unchanged. Normal quit verified. Cold abandoned-run restart and partial-question persistence are headless-verified in this version, not live-window claims. No fresh complete campaign was performed.
