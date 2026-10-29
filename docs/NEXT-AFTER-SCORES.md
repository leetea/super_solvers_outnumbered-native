# Continue after verified/published0.11

Full-game goal remains ACTIVE. This turn made concrete source recovery, native
implementation, window verification, package/source rebuild and publication
progress. No blocker, live build/test handle or REA session remains. This file
supersedes NEXT-AFTER-HELP.md and the older handoffs.

Private repo https://github.com/leetea/outnumbered-native-macos .
main09689c8b1a4982c4c50c7feed85d76fae5dae155,
tree5b333f718c2b1c6e147ba616a54a78897fd46201. All80 file blobs verified;
repository-sync.json current. No Git CLI checkout, new sign-in or automation needed.

0.11 adds Scores.swift, GameScores.swift, ScoreChecks.swift and optional
NativeSaveFile.highGameScores. Original high-game update1a01:026a is called from
winning147d:0c55 only. It captures pre-award rank, adds capped lifetime, inserts
strictly above tenth and bubbles past strictly lower scores. Equal games retain
existing order; zero cannot enter an empty table. Multiple games/player allowed.
Native commit updates history/lifetime/runID atomically, reads legacy absent
history, rejects corrupt history without rewriting. Reference checkpoints excluded.

Original score panels170d:091a/0a1f, row21b1:0073, sorting1a01:03cc and formatter
170d:0c9b are retained in score-analysis/. MZ entry seeds change only header20..23.
Original names are8 chars/ten members; native longer names clip only at display,
extra native profiles page ten rows. Command7/8 and native menu expose tables;
original full File menu/sign-in presentation still pending. Style7 shares style0:
18-pixel bottom separator and Esc footer. Help.swift gained a default21 optional
separator argument, scores pass18. A first candidate's erase-line artifact was
fixed before final GUI/package; no hack remains.

353 checks pass in shipping, extracted app, independently rebuilt source ZIP
and extracted repository-wrapper build. Final32 compiled sections and484 runtime
assets match GUI verification; wrapper484 assets match final snapshot. Original
ZIP/MKV hashes unchanged; local MKV supersedes YouTube. Runtime stays ARM64 native,
no DOS executable/compiled drawing modules/emulator. Development ad-hoc signature.
Shippingbinary64573a011350629232671abdbb5e660f43f3ec4cb7fbb22a9322e9b6bcd0d10b.
RuntimeZIP9ea1c08e7340be3d0515f1b7390cce873f4f9efcd1b47973eef4401b21420064.
SourceZIPc6790de5ee978d1ba4d1ef0c7143ffad0acf45b82aa4ebb78b8cdfa877bb0ae1.

GUI final app /private/tmp/Outnumbered-Scores-Final.app uses only temporary
/private/tmp/outnumbered-011-gui-players. CUA finalScoresApp binding may persist.
Last screen rainfall input42 after high-game table ->F1help ->Esc ->Esc. Score
rows were display fixtures, not claims these wins were earned in a natural run.
Persistence is separate native-test evidence. GUI ledger/code identity in
verification/gui-observations-0.11.json and gui-0.11-code-identity.json.
Scores final getApp took6sec; first uniquely named app getApp took321sec. There
is no cua.computer.launch_app on this mac backend; do not retry that API.

Next useful work: original music/New User Messages controls and remaining
practice animations. Preliminary evidence in menu-analysis/next-*.json:
170d:0668 Options case0=177df New User Messages, case1=1797a music,
case2=179b7 sound, case3=17828 calculator. Practice callback17916 uses1797a/179b7.
Music accesses DS4348, sound DS434e. Helper170d:0c4a (17d1a) can set434e0,
sets43e4=52,43e2=0, calls1bda:05fc. Do not infer flag polarity/on-off semantics
solely from temporary pseudocode names: inspect source dialog records3512/3520
and labels/source sound policy before implementing. New User Messages sets
5bef from dialog34da and can clear18 bytes5bd7. Source rendering/trigger sites
still need recovery. Do not invent generic toast/messages without evidence.

Original practice interstitials:1fc6:0061 alternates DRILL10/11 then12/sound23;
1fc6:0007 perfect script DS5516, imperfect DS5771 ->5378/5435, sounds28/34.
Other full-game work: original file/exit/sign-in, transitions/knockback/inputqueues,
timed activities, palette/masking, calibrated sound, bonus/rank/midnight effects,
and a complete natural playthrough. Keep goal active and publish each verified
milestone. Former notes_clipboard/paper labels are corrected to sign-in assets;
no source evidence of notes editor. Do not invent one.
