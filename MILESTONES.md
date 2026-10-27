# Milestones

The repository starts with the verified0.7 snapshot. Earlier milestones are
documented history, not backdated Git commits.

| Milestone | Result | Verification and limits |
|---|---|---|
| Prototype | Native rendering and controls proved practical | New prototype rules; separate from original-game recovery |
| 0.3 | Telly/zap/drill/code capture and original rainfall interaction | Native-window reference fixtures; full ending still absent |
| 0.4 | Energy machine, LiveWire and additional activity contexts |139 integration checks; recharge and LiveWire window observations |
| 0.5 | Original calculator arithmetic and bar charts |189 integration checks; native input and300-point results |
| 0.6 | Native contexts for all ten activity families |213 checks;3,170 cases rendered;30 generation cases then unresolved |
| 0.7 | Original startup selection, eligibility, bands and RNG boundary; all3,200 cases recovered |245 checks; extracted app verified and packaged source rebuilt; Junior165 and music106 accepted in native windows |
| 0.8 | Scripted hideout reveal, progressive bonuses, win/loss results, persistent lifetime/rank updates and replay; corrected room backgrounds |269 checks; native window reached Game 11,680 / Total 64,275 and replay; normal save/restart/result-commit recovery checked in temporary player directories; extracted app and source rebuild verified |
| 0.9 | Player menus, custom settings, independent Drill for Skill and unfinished-game continuation; replay preserves decoder pools |309 checks; native-window settings/practice flow; extracted app and source rebuild verified; original UI/practice animations remain pending |
| 0.10 | Original eight-topic help,22 pages and four illustrations, source navigation and practice-only help |332 checks; native window navigation and state preservation; extracted app/source rebuild verified |
| 0.11 | Original lifetime and high-game score tables, persistent top ten and pre-win ranks |353 checks; native score display/return-to-input; extracted app and source rebuild verified |
| 0.12 | Independent music/sound controls and original new-user guidance/state |382 checks; native window message/options flow; extracted app and source rebuild verified |
| 0.13 | Original practice introduction/result scripts, sound wait, counters and timer |469 checks; native practice window flow; portable app/source and repository rebuild checks |
| 0.14 | Ordinary adventure win, persisted score/rank and fresh replay verified | Unchanged 0.13 app; all five rooms, four natural Telly captures, News Room decision, 6,350 total; normal quit/relaunch and score tables verified |
| 0.15 | Staged room-door entrances/exits, persistent transition progress and aligned returns; elevator final facing | 504 native checks; ordinary News doorway window captures; unpaced-frame timing uses documented native adaptation; elevator animation remains pending |
| 0.16 | Staged elevator panels, vertical travel, persistent progress and input lockout | 563 checks; both left-side directions in final native window; all four origins and save/resume headless; detailed camera/actor fidelity still pending |
| 0.17 | Telly/projectile/LiveWire updates and RNG during transitions; persisted frame cursors | 582 checks; natural Telly/projectile motion during native-window News entry; legacy migration and timer-batch equivalence checked headlessly |
| 0.18 | Camera-before-actor ordering, signed movement and scrolling doorway/elevator alignment | 610 checks; original edge overshoot and legacy transition compatibility; native Cartoon Room scrolled approach/entry/return |

The full-game goal is **not complete**. The ordinary winning loop is now verified. Next are
opening/File presentation and transitions,
collision presentation, effects, palette and complete-playthrough validation. Exact bonus sliding,
rank-tower animation and midnight meter flashing remain presentation gaps.


Milestone0.11 adds original lifetime/high-game score screens and the source
top-ten insertion rules. Individual winning games retain their pre-award rank;
ties stay behind existing equals, and ties with tenth do not qualify. History
and lifetime commit atomically with result recovery. Existing files without
history remain readable; historical games are not invented from lifetime totals.
353 native checks pass. Command7/8 open the score screens; Enter/Esc returns.
Arrow keys page lifetime rows when native profiles exceed the DOS ten slots.
Music/new-user options, original practice animations, full File/sign-in UI,
transitions/collision, timed effects and complete playthrough remain unfinished.
See score-history-recovery.md for original evidence and native adaptations.


Milestone0.12 connects independent Music and master Sound controls, opening
theme requests and all18 original new-user message texts. Native session flags
preserve original unseen/queued/acknowledged states; Yes resets them, No preserves
them. Source-derived room, challenge, collision, decoder, energy, clock and idle
input hooks display guidance through accessible macOS dialogs with readable key
names. Practice message state remains separate from the suspended adventure.
382 native checks pass. Native dialog pixels, exact settled-actor timing and
opening credits remain presentation gaps; see music-messages-recovery.md.
The complete-game goal remains active, with original practice animations,
transitions/collisions, timed effects, palette/sound calibration, ending refinements
and full natural-playthrough verification still required.


Milestone0.13 restores the original Drill for Skill introduction and all three
result animations (108 recovered sprite commands), their sounds and the
sound-completion wait before the original Enter-to-continue prompt. The source
counter panel/digits,120-tick problem-count boundary and independent practice
timer replace the previous native footer. Running counters survive another set;
practice still awards no adventure rewards and never writes its suspended save.
469 native checks pass, including both imperfect animation/sound selections,
exact two-draw result RNG consumption, timer/counter boundaries, sound waiting,
repeated sets, visible questions and deterministic animation repainting.
Keyboard-buffer/driver parity, opening/File presentation, transitions/collisions,
timed activities, palette/audio calibration, ending refinements and a full
natural adventure playthrough remain. See practice-presentation-recovery.md.
