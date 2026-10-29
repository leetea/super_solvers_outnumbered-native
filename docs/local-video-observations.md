# Local reference-video observations

This is the active visual reference. It supersedes further YouTube inspection on the user's instruction. Earlier `reference-observations.md` remains historical browser research; the observations below were independently checked against the supplied **local** frames. No internet or remote media was used for this pass.

## Identity and extraction convention

- Original, read-only: `local-inputs/OutNumbered Gameplay.mkv`.
- SHA-256 (from `reference-media/source.json`): `6960fb011e044a141e75e734e35140ff5c6c62e8e3440bf78f96d27baf957205`.
- 11,265,052 bytes; Matroska container; 320×200 H.264, 30 frames/second; 48,000 Hz stereo Opus; duration 448.961 seconds.
- Parent task extracted `reference-media/frame-001.png` at approximately 0 seconds, then one frame every 5 seconds. Frame N corresponds to `(N−1)×5` seconds. These are nominal extraction times; the original stream's time base is milliseconds and compressed decoding can differ by one frame.
- Frame names below are relative to `work/reimplementation/reference-media/`.
- `local-inspection/contact-01.png` through `contact-03.png` combine 30 consecutive frames each, row-major, five columns and six rows. These are derived analysis copies; originals remain unchanged.
- `local-inspection/lobby-grid.png`, `challenge-grid.png`, and `decoder-grid.png` are nearest-neighbor 4× analysis copies with a 10-source-pixel grid.

## Local verification checkpoints

| Local time | Frame | Verified visual evidence |
|---|---|---|
| 0:00 | 001 | Title identifies 1990 V1.02. |
| 0:05 | 002 | Objective: room clues and midnight deadline. |
| 0:10–0:15 | 003–004 | Telly drill / secret-code / decoder introduction. |
| 0:30 | 007 | Three start modes: Regular Game, Customized Game, Customized Drill for Skill. Up/Down cycle, Enter selects, Esc returns. |
| 0:35 | 008 | Lobby HUD: 9:00 P.M., score 000000, energy approximately half the meter. |
| 0:40 | 009 | News hallway door, energy-supply machine to its right. |
| 0:45 | 010 | Rainfall challenge information graphic, word problem, calculator. |
| 1:05 | 014 | Calculator state dialog requiring equals before the next operation. |
| 1:15 | 016 | Successful rainfall answer **644**, score **000300**; time field reads Pause. |
| 1:20 | 017 | News/weather room again, score 300, clock 9:03 P.M. |
| 1:25 | 018 | Hallway elevator, purple couch, framed pictures, potted tree. |
| 1:30 | 019 | Elevator and cactus. |
| 1:35 | 020 | Cartoon door; Telly and tall camera-shaped robot. |
| 1:40 | 021 | Cartoon room, television/film props. |
| 1:45 | 022 | Cartoon chart is drawn before question; time Pause. |
| 1:50–2:00 | 023–025 | Cartoon graph-reading question. |
| 2:05 | 026 | Exiting Cartoon room, score **000600**. |
| 2:10 | 027 | Telly close-up and colored-screen transition; score 600, clock 9:11 P.M. |
| 2:15 | 028 | Missing-value drill `?−10=9`; score 600, 9:12 P.M. |
| 2:20 | 029 | Correct `3+12=15`, positive feedback, score650. |
| 2:25 | 030 | Correct `10+12=22`, positive feedback, score700. |
| 2:30 | 031 | Correct `15−7=8`, positive feedback, score750. |
| 2:35 | 032 | Correct `22−10=12`, positive feedback, score800. |
| 2:40 | 033 | Correct `12−3=9`, positive feedback, score850. |
| 2:45 | 034 | Lightning code symbol, score **001000**, clock9:19 P.M. |
| 2:50 | 035 | Equipment room entered from left doorway. |
| 2:55–3:15 | 036–040 | Costume-item table question. |
| 3:20 | 041 | Successful costume answer **463**, score **001300**. |
| 3:25 | 042 | Equipment room exit, 9:23 P.M. |
| 3:30–3:35 | 043–044 | Sound hallway doorway and another Telly encounter/approach. |
| 3:40 | 045 | Harpsichord place-value graphic, time Pause. |
| 3:45–3:55 | 046–048 | Harpsichord question, controls show873 and question adds123, asks resulting ones digit. |
| 4:00 | 049 | Sound room, score **001600**. |
| 4:05 | 050 | Sound hallway exit. |
| 4:10–4:15 | 051–052 | Elevator/cactus/couch hallway sequence. |
| 4:20 | 053 | Game Show room entered. |
| 4:25–4:30 | 054–055 | Prize is Right subtraction challenge. |
| 4:35 | 056 | Game hallway exit, score **001900**. |
| 4:40 | 057 | Lobby passed again; score1900. |
| 4:45 | 058 | News doorway/energy-supply hallway; visibly higher energy. Exact recharge input/frame was not isolated. |
| 4:50–4:55 | 059–060 | Telly drills, clock continues. |
| 5:00–5:10 | 061–063 | Further missing-value drills and feedback. |
| 5:15 | 064 | Code-award transition, score **002300**. |
| 5:20 | 065 | News hallway, 9:44 P.M. |
| 5:25 | 066 | Decoder with first two secret symbols and partly populated room rows. |
| 5:30–6:00 | 067–073 | Further Telly drills. At5:55, a wrong answer is red and score remains2500; at6:00 a later correct answer raises score2550. |
| 6:05 | 074 | Telephone code symbol, score **002650**, 9:51 P.M. |
| 6:10 | 075 | Decoder with three captured secret symbols and only some room rows filled. |
| 6:15–6:20 | 076–077 | Decoder populated/presented for Match Rule and Equipment selection; secret still shows three symbols plus blank. |
| 6:25 | 078 | Equipment hallway, 9:52 P.M., score2650. |
| 6:30–6:40 | 079–081 | Equipment room win scene begins. |
| 6:45 | 082 | Master visible; pre-bonus score2650. |
| 6:50 | 083 | Bonus overlay: **Energy Left2,550**. |
| 6:55 | 084 | Bonus overlay: **Time Left4,480**. |
| 7:00 | 085 | Bonus overlay: **Winning Game2,000**. |
| 7:05 | 086 | Score **011680**, clock midnight. |
| 7:10–7:15 | 087–088 | Player exits, then results: Game11,680 / Total64,275; rank ladder. |
| 7:20 | 089 | Saved-score/rank dialog and invitation to play again. |
| 7:25 | 090 | Exit Program confirmation. |

The supplied local recording therefore **does not require four code symbols to make a successful decision**: its third-symbol secret prefix is enough to distinguish the selected room. Do not force four captured pieces merely because the lock has four slots.

### Exact ending arithmetic / inference boundary

The locally visible final tally is consistent exactly with `2,650 + 2,550 + 4,480 + 2,000 = 11,680`. At9:52 P.M. there are128 game minutes until midnight; `4,480 ÷128 =35` points per minute for this run. This ratio is an inference from one recording, not yet proof of all rank-dependent bonus formulas.

The first Telly sequence shows six correct equations across the sampled frames (the historical browser frame at2:19 additionally captured19−10=9). Score advances from600 to1000 by the code reward. Its exact award scheduling should come from executable recovery rather than assuming each positive-feedback screenshot has already applied its score update.

## Layout in original 320×200 coordinates

Origin is top-left. These are visual measurements to approximately ±1–2 source pixels, not addresses recovered from the executable. H.264/YUV color bleeding makes exact border-pixel classification unreliable. Use decoded original graphics to resolve the last pixel.

| Element | Bounds / position |
|---|---|
| Menu strip | y0–10, full width; Help x0–52, File x53–103, Options x104–167 approximately. |
| Exploration viewport | Outer x4,y14,width312,height146; rounded black inner edge. |
| HUD lower panel | x4,y162,width312,height36. |
| Main exploration prompt | x8,y176 approximately. |
| Stats labels | Left edge x216–218; Time y165, Energy y176, Score y188 approximately. |
| Values enclosure | x254,y162,width60,height36. |
| Time value | x256–312,y164–173. |
| Energy meter | x256,y175 through approximatelyx305,y185. |
| Score digits | x258–310,y188–197. |
| Challenge left graphic | x8,y20,width174,height136 approximately. |
| Challenge question frame | x192,y18,width120,height120 approximately; text beginsx198,y32. |
| Calculator | x192,y140,width120,height58 approximately. |
| Calculator display | x198,y144,width52,height16 approximately. |
| Challenge Esc prompt | x8,y186 approximately. |
| Decoder left title/lock region | x8–168,y18–158 approximately. |
| Decoder room rows | x176–304,y18–159 approximately, five rows of roughly28pixels. |
| Decoder buttons | y168–196; TV Station x8–52, Match Rule x64–104, Decide x116–156 approximately. |

The viewport holds a horizontally scrolling hallway; room interiors are fixed screens. The visible walk cycle's foot position varies by scene and jump/flip state; a single global y=151 floor would not reproduce every source frame. News-room standing feet are aroundy136; hallway player feet are aroundy130–143 depending on transition/animation frame. Treat these as rendering observations, not final collision coordinates.

## Topology and rooms

Confirmed visited rooms: News/weather, Cartoon, Equipment, Sound, Game Show. Interior reference sequence is frames017,021,035/042,049,053, then the winning Equipment room079–087. Both side doors are drawn in each interior; this recording enters/exits through the left-facing opening in several cases.

Hallway props include the lobby desk, potted tree, purple couch, framed artwork, elevator, cactus, microphone stand, energy-supply machine and wall color-bar monitors. Consecutive screenshots establish the observed progression **lobby → News → elevator vicinity → Cartoon → Equipment → Sound → elevator vicinity → Game → lobby**, but this sampling alone does not establish whether the elevator is one shared shaft, multiple floor endpoints, or a complete collision/world-coordinate map. Preserve this ambiguity until raw executable/world data resolves it.

## Fixtures and remaining limits

- Weather fixture:832−123−65=644, first visible successful room award300.
- Costume fixture:190+171+102=463, completed room score1300.
- Harpsichord fixture:873+123=996, requested ones digit6; completed room score1600.
- Prize fixture:908−90=818; completed room score1900.
- Rank thresholds and game/lifetime separation match the earlier browser observations, now locally visible at7:15.
- Local wrong drill at5:55 proves red answer feedback and no immediate score award. The sequence later recovers and wins; it is not a game-over branch.
- Timeout, empty energy, wrong hideout, every rank's question counts, and all match-rule variants remain unverified by this recording.
- **Sound:** the parent task extracted `gameplay-audio.wav` for quantitative comparison. This visual-analysis subtask did not listen to the soundtrack and makes no listening-based claim. Audio fidelity conclusions belong to the parent's independent sound analysis.
