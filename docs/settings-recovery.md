# Original settings editor — local 0.30

The original custom-game and Drill for Skill settings screens replace the macOS settings alert. The decoded table, drawing and input evidence are in verification/settings-tables-0.30.json and verification/settings-instructions-0.30.json. Original input files and resource bytes remain unchanged. Further GitHub updates remain on hold until the final app is ready.

## Source layout and controls

1f13:0000 draws a style1 frame at(47,4)..(275,174), clears its interior, adds rules at y16/y152 and, for a custom game, y40. The generic engine1f5e:0005 uses origin(50,5), bounds(270,169), foreground11h, backgroundffh, a font1393 title and font1396 row labels. Its footer uses the original four arrow glyphs, Escape to Go Back and Enter to Select.

DS4ecc and DS50ca contain30 records of17 bytes for practice and game. Each includes a kind, relative position, label pointer, six neighbor indices and state flags. The engine's last index29 is inclusive. Static headings are not focus targets. Types1/5 are checkbox/radio;2 is OK and3 is Undo. Byte16 bit0 is checked and bit1 focused. Font1396 supplies original checkbox glyphs127–130 and radio glyphs131–134, including the source one-pixel shift of focused checkboxes. No replacement icon assets or original CPU routines run in the app.

Initial focus is OK. Tab follows six groups: OK → Undo → first level/count → Addition → number0 → first blank format → OK. Shift-Tab and arrow keys follow the separate recovered neighbor columns, rather than a generic linear focus list. Space and Enter activate the focused control; Escape backs out. Keypad Enter is a native mapping to Return, and native mouse hit areas are an adaptation. F1 and ordinary letters are not settings actions in the source key table.

The idle input routine drains BIOS input to its latest key. It then holds focus23 IRQ ticks, draws it without focus for40 ticks and polls again. Native blink and settings polling retain that63-tick schedule. The source's idle new-user message15/16 remains scheduled after1200 ticks and is checked at input-poll boundaries; any input acknowledges/cancels it. Its message presentation is still a native alert pending the remaining message-screen work.

## Settings behavior

The13-byte settings bit rules and validation remain the existing recovered rules. OK reconstructs the record from visible operation/number/blank checkboxes and the radio selection, as1f13:02bf does; unused legacy bits are cleared only on acceptance. Invalid OK opens the original type2 Enter-to-Continue notice and then focuses Addition, number0 or the first blank format as appropriate. Its two source messages and line breaks are retained. That notice reads keys FIFO until Enter/Escape and flushes leftovers, distinct from the parent editor's latest-key polling.

A custom-game level selection reloads all standard settings for that level and returns focus to OK. Selecting the same level again also reloads its defaults. In practice, selecting5/10/15/20 only changes the number of problems and retains the other checkboxes and radio focus. The action descriptor's type5 value is2 for game and0 for practice; the caller's return2 branch reloads DS1277's standard record.

Undo restores the13-byte entry snapshot and returns focus to OK. There is no separate Standard Settings button in the original30-row table; choosing a game level provides that behavior.

The source has a subtle cancellation rule. Checkbox edits stay in widget flags until OK, but choosing a custom-game level changes the shared settings record immediately. The lifecycle2144:0009 writes that record back to the profile even when settings returns Cancel: instructions215fd..21638 mark the launch cancelled, then unconditionally copy DS5b6b to profile+0d and save the profile. Consequently backing out discards checkbox drafts but retains the last selected level's standard defaults for future games. Undo can restore the entry record before backing out. The native editor preserves this behavior while leaving any unfinished adventure and its own fixed settings unchanged. Practice cancellation does not persist checkbox/count drafts.

## Native integration and limits

The editor captures its parent image, suspends world/practice/opening updates and completes asynchronously. Valid custom settings are saved before new-game creation; practice has a separate profile settings record and independent question stream. Keyboard/mouse input is isolated from the parent, native Game menu actions are disabled while editing and stale input is cleared on exit. A validation notice cannot allow a queued Space to toggle a checkbox after Enter dismisses it.

The former Cocoa settings view and modal-panel event monitor are removed. Original labels, bit rules, saved-game continuation and previous random-stream behavior remain connected. Analysis derivatives only change initial IP/CS in an existing unpacked MZ analysis copy; their provenance is in settings-analysis/derivation.json. Code/data/relocations remain unchanged and none of these derivatives enter the runtime.

Verification includes source table links/positions, group/arrow navigation, exact level-versus-count behavior, Undo, canonical13-byte commits, validation/focus, cursor timing, latest-key versus FIFO notice input, state freezing, asynchronous launch, separate saved settings, practice continuity, idle guidance and the source cancellation rule. Headless renders, native-window observations and extracted-app gates are recorded separately. Final verification is recorded in verification/local-verification-0.30.json when that checkpoint is finished.

This is not the complete game. Original Options/new-user and remaining dialog presentation, full menu-tab/alternate input behavior, ending/rank/midnight refinement, complete graphic masking/occlusion/display and sound calibration, a fresh complete ordinary playthrough and the final independent source/repository/distribution gates remain required.

Final local checkpoint:988 checks pass in the candidate and extracted local ZIP, with strict signature verification. Native-window observations verified level reset, checkbox draft cancellation, practice count changes, Undo and drill start. Both copied session files remained byte-identical. See verification/gui-observations-0.30.json and local-verification-0.30.json.
