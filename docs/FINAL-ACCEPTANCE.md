# Final app acceptance — 1.0

The native EGA/PC-speaker reimplementation has passed its required local release
gates. It is a native reimplementation informed by original code and data, not
direct recompilation of the DOS executable. Original ZIP/video inputs were preserved.

| Requirement | Final evidence | Status |
| --- | --- | --- |
| ARM64 macOS executable without DOS runtime or compiled DOS drawing modules | Extracted release and repository rebuild: arm64, strict signature, system libraries only, forbidden executable/module scan | Passed |
| Original input preservation | ZIP and local MKV SHA256 equal original recorded hashes | Passed |
| Station, five rooms, traversal, doors/elevators, enemies, zaps, collision and recharge | Recovered code and native checks; ordinary final campaigns traversed both floors, used rooms, captured Telly, took collision damage and recharged | Passed |
| Ten challenge families, selection/answer rules, four arithmetic operations and calculator | 3,200 recovered question cases; renderer/calculator/advice checks; final ordinary room observations | Passed within recovered finite domain |
| Code pieces, room clues, three decoder rules and decision eligibility | Focused checks plus final run: two earned pieces, all five rooms, same-picture/same-pattern rule; visible ON AIR + camera uniquely identified Game Show | Passed |
| Eight ranks, game/lifetime/high-game scoring | Rank/award/history checks; final ordinary win 2,100 + 700 energy + 3,100 time + 1,000 victory = 6,900; Junior shown in results and replay member list | Passed |
| Graphics | All 389 bitmaps, 2,334 independent plane-based full-canvas comparisons; palette, masks, mirror, clipping, all backgrounds | Passed raster boundary; live campaign composition also observed |
| Sound and music | All 52 recovered PCM streams regenerate byte-identically; selected spectral matches against supplied local MKV; independent sound/music settings | Passed recovered stream boundary |
| Opening, Sign-In, File/Options/Help/settings/practice | Recovered presentation and focused native checks; prior native-window ledgers; final ordinary opening, sign-in, options and Help usage | Passed |
| Win/wrong-hideout/midnight, bonuses, rank tower/Champion and replay | Focused source/script checks; final ordinary midnight and win; fresh win 44.9654s versus recovered 44.9523s; replay returns to Sign-In | Passed |
| Separate native saves and result recovery | Preservation/corruption/future-version/idempotence checks; final normal quit/reopen/continue restored 1,800 score, code and all clues; final history and 6,900 lifetime persisted | Passed |
| Self-contained runtime ZIP | Clean extract, strict signature, 1,118 native checks; no developer tools needed to play | Passed |
| Independent source and repository builds | Source archive rebuild: 1,118 checks; repository wrapper build, extraction, strict signature, 1,118 checks and identical bundled assets | Passed |
| Final repository publication | Prepared after app readiness; see the private repository and separate delivery publication receipt | Separate publication receipt |

The ordinary winning run ID is 98406997-C2AD-4188-9487-5699611C7555. It used ordinary
controls, unmodified saves and no development checkpoints. Failed earlier final
campaigns are retained as loss/coverage evidence, not relabeled as wins.
Detailed local records are in work/reimplementation/verification/final-campaign-1.0.

Named adaptations: native window/input/focus and mouse selection, recoverable
member removal, separate native persistence and 60 Hz presentation. The target
is EGA 16-color and recovered PC-speaker streams. CGA/monochrome/Tandy variants,
analog speaker identity and CPU-speed-identical timing are outside this target.
Not every sound has an individually observed local-video match. The signature is
ad-hoc, not Apple notarization. These boundaries are not unfinished gameplay features.
