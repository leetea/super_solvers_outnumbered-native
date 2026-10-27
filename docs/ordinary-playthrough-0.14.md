# Milestone 0.14: ordinary adventure win and restart verification

This is a verification milestone for the unchanged 0.13 ARM64 app, not a new binary release. The complete-game goal remains active.

A temporary native profile, Full Game Check, first completed all five room activities but lost at midnight. Its ordinary replay completed all five activities again, naturally zapped four Telly encounters, answered their arithmetic questions, collected all four secret pieces, and selected News Room from the visible decoder evidence. No reference fixture, save edit, forced spawn, chosen seed or hidden hideout lookup was used to reach the win. Decoder and Options pauses were used between observations.

The room answers were News 3, Spinner 5, Sound 1, Equipment 98 and Cartoon 56. The second Telly set contained one actual reading mistake: 11 minus 9 received 3, displayed the correction 2, and still qualified with three correct answers. Other sets were perfect. The resulting ordinary score before the ending was 2,650; energy was 8 and time was 10:44 PM.

The four secret pictures (On Air, book, gramophone and microphone) matched News Room in order under the displayed Match Rule. Confirming News Room triggered the native winning animation and bonuses: 2,650 + 800 energy + 1,900 time + 1,000 victory = 6,350. The results window showed Game 6,350 / Total 6,350. The lifetime crossed the 5,000 Junior threshold.

Normal application-menu Quit and a fresh launch preserved 6,350 lifetime points, Junior rank, and exactly one high-game entry of 6,350 at the original pre-win Trainee rank. Selecting Play Game after the completed win started a new run with a different run ID, score 0, no completed rooms and an empty decoder, while retaining lifetime 6,350. Relaunch starts at the title/player menu; the finished results screen was not restored. One screenshot named win-restored records this fresh replay world; its filename is not a claim of results restoration.

Structured observations and screenshot hashes are in gui-observations-0.14.json. Original input archives/video and temporary player/session snapshots remain outside the repository. This establishes an ordinary winning loop, persistence and fresh replay. It does not establish every random/rank branch, every animation frame, perceptual audio parity or complete fidelity.

Remaining work includes original opening/File/sign-in presentation; door/elevator/scroll/knockback/occlusion details; timed activity effects; masks/palette/audio calibration; queued input behavior; bonus sliding, rank-tower animation and midnight flashing. Existing 469 checks and packaged artifacts remain the verified 0.13 results, not newly rerun 0.14 checks.
