# Reference gameplay observations

Observed 2026-10-24 UTC through the actual in-app browser. These are sampled visual observations, not an exhaustive input recording or an audio analysis. The game archive was not modified. No remote video/audio was downloaded.

## Sources and edition

- [User-specified YouTube playthrough](https://www.youtube.com/watch?v=lhjQlyE-uws): **OutNumbered Gameplay**, Shortmandesigner, duration **7:28**. The title card visibly identifies **1990, V1.02**. Playback and seeking worked in the in-app browser. The browser screenshots do not expose audible audio, so no claim of hearing, measuring, or matching the soundtrack is justified from this inspection.
- [User-specified MyAbandonware gallery](https://www.myabandonware.com/game/super-solvers-outnumbered-115): 19 linked screenshots. Gallery title card also identifies V1.02. The gallery mixes a full-color presentation and a cyan/magenta/white/black presentation. Do not treat all captures as one palette target. Full image URLs are in `references.json`.
- Original asset `HELP.DAT` rules extracted by the main task are a stronger source for controls and general rules than inference from the playthrough. See `help_rules.json` / `original_help.md`.

## Observed sequence and mechanics

| Video time | Actual observation | Implementation implication / limit |
|---|---|---|
| 0:00 | Title card, native pixel artwork, V1.02, Enter prompt. | Matches the supplied DOS edition's title identity. |
| 0:08 | Introduction explains a TV-station hideout, room math challenges, clues, and a midnight deadline. | The station investigation is a full-game loop rather than isolated math questions. |
| 0:13–0:18 | Introduction depicts Telly and explains zapping it in halls, completing drills, collecting secret code, then using the decoder to choose a hideout. | Room-clue and hallway-code acquisition are separate paths. |
| 0:28 | Exterior station shot, opening door. | Entry animation / transition reference. |
| 0:38 | Lobby desk with SGTV; top menu Help F1, File F2, Options F3. HUD shows Time 9:00 P.M., Energy bar, Score; bottom prompt Tab to decoder. | Preserve the HUD layout and keyboard access. Exact energy values cannot be inferred from pixel bar width alone. |
| 0:48–1:15 | Weather challenge: left information graphic, right word problem, calculator below the question, Esc back to station. | Stable challenge-screen layout. Challenge input is calculator-style rather than a plain one-field answer. |
| 1:08 | Dialog requires `=` before another calculator operation. | Calculator operation state matters. |
| 1:15 | Weather answer display 644. | The observed question is (832 − 123 − 65) = 644. |
| 1:20 | Back in weather/news room; Time 9:03 P.M., Score 000300. | Reliable completed-question score checkpoint. Do not assume every question always awards 300; original help says attempt/rank affect rules. |
| 1:40 | Hallway Cartoon doorway, player entering; Telly and a tall camera-like robot are both visible. | Multiple hallway hazards/characters; do not merge every robot into Telly. Exact collision behavior not observed. |
| 1:50 | Cartoon challenge graphic is a two-series line chart, initially shown without question; HUD time reads Pause. | Information graphic can animate/build before the question. |
| 2:00 | Cartoon question and calculator visible. | Graph-reading question family. |
| 2:14 | Full-screen Telly close-up, `? − 10 = 9`; Score 000600, Time 9:12 P.M. | Drill UI is distinct from room word problems; time runs during drills. |
| 2:19 | `19 − 10 = 9`, positive feedback, Score 000650, Time 9:13 P.M. | One observed correct drill adds 50 in this run. |
| 2:29 | `15 − ? = 8`, Score 000750, Time 9:16 P.M. | Missing operand can be in a different position. This is not necessarily the second question; frames were sampled. |
| 2:39 | Blank Telly screen between items/reward, Score 000850, Time 9:18 P.M. | Transition checkpoint. |
| 2:44 | Lightning symbol appears in starburst on Telly screen, Score 001000, Time 9:19 P.M. | First secret-code symbol. Exact sequence length and reward formula require executable/help evidence. |
| 2:49 | Hallway Equipment door; microphone prop between doors. | Hallway decoration and doorway reference; score was obscured in this sample. |
| 2:59 | Old-time costume item table and word problem. | Equipment-room challenge family. |
| 3:44–3:54 | Harpsichord graphic with hundreds/tens/ones controls; word problem asks new ones digit after adding 123. | Place-value question family. |
| 4:29 | Prize is Right graphic with four priced gifts and a subtraction problem. | Game-show question family. |
| 5:19 | Headphones symbol reward, Time 9:43 P.M., Score 002300. | Further code capture; energy bar visibly higher than initial half bar, but this does not establish how recharge happened. |
| 5:30 | Hallway News door and energy supply machine; player zaps Telly with a visible pulse/ring effect. | Zapper visual reference. Exact fire cadence / collision is unmeasured. |
| 5:59 | Telly close-up in another drill sequence, Time 9:50 P.M. | Repeated encounters. |
| 6:14 | Decoder shows five rooms, four clue slots per room, four secret-code slots. Three secret symbols acquired, fourth blank. Buttons TV Station, Match Rule, Decide. | Decoder can be opened before the secret is complete; do not force all four symbols to inspect it. |
| 6:19 | Match Rule explanation says hideout has same pictures in same pattern as secret code. A fully illustrated rule display is visible. | This is one observed match rule. Do not generalize to all ranks without archive evidence. |
| 6:24 | Equipment row selected; Yes/No confirmation of hideout decision. | Two-step selection and confirmation. |
| 6:34 | Solver calls Master out inside equipment room. | Successful decision changes to an in-room ending scene. |
| 6:44 | Master appears and acknowledges being found. Time remains 9:52 P.M. | Win-scene character/animation reference. |
| 6:54 | Bonus overlay shows Time Left 4,480 while clock is counting toward midnight. | Remaining time is converted through an animated tally. Exact formula not derived from one intermediate frame. |
| 7:04 | Tally has reached midnight; player exits. | Ending transitions to results. |
| 7:19 | Results show player Jeremy, Game 11,680, Total 64,275; rank ladder. | Separate per-game and lifetime scores. |

## Question samples, paraphrased

These are observed numeric fixtures for reproduction/comparison, not a complete question corpus.

- Weather / rainfall: map labels Fremont **832 mm**, New York **915 mm**, Dallas **655 mm**. Fremont receives **123 mm** from one cause and **65 mm** from another; remaining rainfall is **644 mm**.
- Cartoon songs: line chart with weekdays Mon–Fri and seconds axis; legend distinguishes silly songs and nursery rhymes. The question asks the difference on Monday. Both series appear overlapped at 180 in that frame; answer **0** is a visual inference, not a sampled successful-answer frame.
- Costume items: lace **115 yards**, silk **174 yards**, high-top boots **190 pairs**, velvet **127 yards**, riding boots **171 pairs**, high-heeled boots **102 pairs**. Question totals the three boot kinds: **463 pairs** (arithmetic derived from the displayed numbers; successful-answer frame not inspected).
- Harpsichord: controls show **873**; question adds **123** and asks the new ones digit: **6** (arithmetic derived).
- Prize is Right: A **$90**, B **$52**, C **$46**, D **$33**. Hidden prize value is **$908** decreased by A: **$818** (arithmetic derived).
- Gallery image 12: video-cassette durations A **58**, B **77**, C **26**, D **45** minutes. Question totals A and D: **103** (arithmetic derived).
- Gallery image 17: four gift prices A **$37**, B **$30**, C **$80**, D **$40**; question C reduced by B: **$50** (arithmetic derived).

## Decoder data actually observed

Five room labels: **News Room, Game Show Room, Cartoon Room, Equipment Room, Sound Room**.

At 6:14 the captured secret prefix is **lightning, headphones, telephone, blank**. Local-video inspection later corrected the earlier small browser-image interpretation: **the fourth code slot is still blank at the successful decision**; the Equipment Room's full clue row supplies lightning, headphones, telephone, transmitter/tower. Other row sequences in the rule/decision frame:

- News: lightning, headphones, tower, telephone.
- Game Show: lightning, telephone, headphones, tower.
- Cartoon: telephone, tower, lightning, headphones.
- Sound: telephone, tower, headphones, lightning.

The 6:14 rule preview's Equipment/Sound clues are not identical to the later Match Rule panel. Treat the Match Rule screen as a rule demonstration/state transition, not proof of every randomization rule. The exact time at which each row is revealed was not sampled.

## Rank thresholds independently visible at 7:19

| Rank | Lifetime points |
|---|---:|
| Trainee | 0 |
| Junior | 5,000 |
| Senior | 30,000 |
| Pro | 60,000 |
| Expert | 120,000 |
| Master | 200,000 |
| All-Star | 300,000 |
| Champion | 500,000 |

## Gallery-specific observations

- Image 1: V1.02 full-color title.
- Image 2: full-color introductory objective.
- Image 4: Club Member Sign-In, name/rank/score rows, New Member entry, Up/Down cycling, Enter selection.
- Image 12: video-cassette table challenge.
- Image 13: hallway energy supply device by Equipment doorway, low energy, score 000300.
- Image 14: cyan/magenta/white/black title presentation.
- Image 15: alternate-palette exterior.
- Image 16: alternate-palette game-show room.
- Image 17: alternate-palette Prize is Right challenge.
- Image 18: alternate-palette hallway and Telly with Game doorway.

Other gallery URLs were inventoried but not individually inspected at full resolution. No claim is made about those images' precise contents.

## Still unverified / avoid fabricating

- **Audio:** video playback exists but no supported audio-listening/capture capability was available in the browser tools. Music notes, timbres, durations, voice, effect waveforms, and audio device configuration were not assessed. Use recovered sound commands/data for a native implementation and retain a separate listening/comparison task.
- Exact movement speed, jump/flip arc, animation cadence, firing cadence, camera/hazard collision rules and invulnerability timing.
- Full hallway topology/length and all encounter spawn rules; sampled views establish named doors and props, not the complete spatial map.
- Wrong-answer dialogs, hint timing and reduced awards; original HELP.DAT is available for general attempt rules.
- Exact clock tick rate, energy quantities/costs, recharge amount, bonuses, and every score increment.
- Every rank/difficulty's question counts, arithmetic operators, generated question parameters and match-rule variants.
- Timeout, exhausted-energy and wrong-hideout loss screens; no such branch was inspected in this winning playthrough.
- Save-file compatibility. The gallery establishes profile selection and lifetime ranking, not binary save semantics.

The practical verification standard is to label replacement timing/rules as provisional until the original executable or further reference behavior substantiates them.
