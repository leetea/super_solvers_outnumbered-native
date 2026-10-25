# Remaining activity displays, native0.6

All ten activity families now have native visual context. This establishes the available recovered question bank's playability; it does not establish a complete game, exact campaign RNG identity, or pixel/audio parity.

## Source and method

Original compiled drawing modules8506/8510/8516 are retained unchanged in the decoded catalog. Analysis wrappers in `template-code-analysis/derivatives.json` prepend a32-byte MZ header only; their payload hashes match the original decoded modules. Static Ghidra16-bit exports are `template-213a-functions.json/.c/.asm`, `template-213e-*` and `template-2144-*`. No original x86 code is interpreted or executed by the app. All REA targets are closed.

`ActivityFinal.swift` translates those drawing routines to Swift. `OriginalActivityState` reconstructs auxiliary drawing-time random values once and persists them with their challenge identity. `GameActivityState.swift` prepares/reuses this state on opening or restoring an activity. Rendering never consumes RNG. The source-derived ranges and uniqueness rules are preserved; full original campaign RNG ordering is still unfinished, so auxiliary values are not claimed to be those from a historical recording.

## Spinner, hotspot3

Original8510:00e9 draws generated wheel values from flattened fields5..14 at embedded X/Y tables03b6/03ca. Fields17/18 control center text and font; LAST adds SPIN. It spins through sectors before leaving the selected field2 highlighted. Native drawing omits the timed spin and retains the final static result. Both highlight rectangles use original tables03de..046a, offset by bitmap origin8/19.

The original command13 target was independently recovered from the full unpacked executable: thunk104ea→11041. `palette-driver-assembly.json` shows the graphics color-compare read mask and replacement writes. This supports replacing logical color14 with12 within the two selected rectangles, rather than repainting the sector or guessing an arrow. A fixture check verifies the source yellow pixels become red within those exact bounds. The palette analysis derivative changes only MZ initial IP/CS; its module code remains unchanged.

## Great Eight music chart, hotspot4

Original8506 draws title, rank numbers/song names and two selected header types from fields0/1. Fields2/3 select rows; fields4/5 and6/7 contain their values; fields12/13 their names; fields14..19 fill the remaining names. Headers come from the embedded Last Wk's Pos./Weeks on Chart/Calls This Week/Calls Last Month strings and anchors103/143.

The first numeric column draws auxiliary values from fields8/9 and rejects duplicates against both selected values and previous auxiliary values. For field20>7 it also reserves field22 and displays it in row2 unless a selected row takes precedence. The second column uses fields10/11 without uniqueness and optional field23 in row2. Calls occur column-by-column, not row-by-row. This is original random drawing behavior, not fabricated filler. The native state retains every drawn value and survives save/reopen.

## Equipment List, hotspot7

Original8516 uses selected row0, quantity1, days2, cost3, selected name10 and unit18. Filler names11..17 and units19..25 accompany source random ranges4/5,6/7,8/9. It draws all quantities, then all days, then all costs. A selected name containing a space occupies multiple label rows and shifts numeric baselines; filler names are not split. Single-space units are displayed as empty, as in the original mutation.

Original header color animation ends with logical colors13/11/14/10 in the four source column strips. Native drawing preserves that final state and labels while omitting timed cycling. Quantity centering, day/currency alignment, dollar signs and selected multi-line baselines follow the recovered routines.

## Verification and explicit limits

- All930 available cases for these three families render:320 spinner,290 music,320 Equipment List. Selected names/values are checked against original generated fields; auxiliary data is stable across repaint and save/reopen.
- All3,170 recovered cases across ALL ten families render through the actual native game view. Thirty9056 cases remain unresolved at original cross-group reference indices5.4/5.5/5.6, not silently replaced.
- The213 integration checks include these cases, native correct-answer rewards/clues, partial drawing saves and the spinner color-compare operation.
- Actual native-window checkpoints accepted100,106 and29 respectively, each for300 points. Equipment List completion visibly revealed its four room clues in the decoder. These are generated-original-data mechanics checkpoints, not claimed as independently matched local-video seeds.
- Checkpoints use Command-1/2/3 and do not modify player saves. Original archive and local MKV remain unchanged.

Remaining work includes native/exhaustive question generation, exact new-game eligibility/selection and shared RNG lifecycle; timed intro effects, full palette/driver fidelity, menus/settings/notes; detailed collisions/transitions; final encounter/endings/progression and full playthrough validation.
