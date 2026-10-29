# Historical ending recovery notes, superseded by verified0.8

**Current handoff:** Read NEXT-MENUS.md. Native0.8 now passes269 checks, final
window verification and all package/repository rebuild checks. It is published
at GitHub commit02e0fff48b08faf9d8607431104e4c61eef42866. No process is pending.
The original notes below describe the earlier work-in-progress state; do not
redo completed verification or treat its265-check count as current.

The preceding turn made concrete progress: original ending recovery, native
ending/tally/result/progression implementation and265 passing integration checks.
It also completed the user's new GitHub request by publishing verified0.7.
The complete-game goal remains ACTIVE.0.8 is not yet a published milestone.

## Current authoritative state

- Active Swift source is in this directory. New files: Endings.swift,
  GameEndings.swift, EndingRenderer.swift and EndingChecks.swift. Build.sh builds
  version0.8 and copies ending-sequences.json into resources.
- `outputs/Outnumbered Native Development.app` is now the0.8 candidate, compiled
  and265 checks pass. `/private/tmp/outnumbered-08-checks.json` and
  verification/native-integration-checks.json contain that report. No build or
  test process is pending. REA analysis sessions were closed.
- Download/source ZIPs and `outputs/NativeDevelopmentSource` are still verified
  0.7. Do not mistake them for0.8. `package_verify.py` must copy the new ending
  JSON/recovery notes and require265 checks before0.8 packaging.
- Native0.8 window testing is still required. The currently running app may be
  the older0.7 process; quit/relaunch through CUA before testing Command-5.
  The checkpoint begins at2650points,17energy,9:52PM and52595lifetime. Its
  Equipment hideout should reveal/animate, tally2550+4480+2000 to11680, then
  show64275lifetime and Pro. It does not touch player saves.

## Recovered rules and evidence

`ending-analysis/` retains full REA Evidence and two analysis derivatives whose
only changes are MZ initial IP/CS bytes20..23. derivatives.json checks code/data
and relocation identity. The first tail-seed probe was corrected to155ca before
retention; entry-tail.json is the corrected result.

-135d:0fc9 reads nine-byte DATA commands: signedresource,byte x/y/right/bottom,
  one-basedrestoreCommand,flags,waitFrames. x/right are four-pixel units.−1
  restores a rectangle from a backing canvas;−2 stops current sound and starts
  sound x. Positive resources draw, optionally restore a prior command rectangle,
  then wait waitFrames*frameTicks. Native code translates this data; no x86/DOS.
- `export_endings.py` compiles14scripts/403commands into ending-sequences.json.
  FASTLOAD ids are direct; ids10000+ use CLOSE1 for win and CLOSE2 for wrong
  hideout. Source file table begins DS3277: file10=CLOSE1,11=CLOSE2,12=TROPHY.
-18e7:0563 compares selected row with stored hideout; a wrong choice ends the
  game. A correct choice runs the scripted reveal/escape and tally. There is
  no new interactive chase mechanic to invent.
-147d:0882 awards energy*perEnergy, remainingMinutes*perMinute, then victory
  bonus.11b0:0f87 loops quotient+1 times, including a zero remainder wait. A
  delta equal to its step therefore waits twice; each energy decrement and
  matching score change uses20IRQticks, so a unit costs40IRQticks total. Source
  video shows2650→5200→9680→11680, matching2550/4480/2000 bonuses.
-1a01:026a adds the final UInt16 session score only on a win, caps lifetime at
  9,999,999 and retains ranks. New optional native profile fields persist lifetime
  and lastResultRunID to make result commit idempotent across save/restart.
-11b0:109e midnight path clears score/energy and runs a1000-tick warning before
  replay. It does not run a fictitious hideout search. Native meter flash pixels
  remain a presentation gap. Clock expiry is now handled before new Telly RNG.
- Wrong-choice time advancement uses original `(11-hour)*60+minute`, not a new
  always-midnight rule. Wrong results show room/taunt rather than win trophies.
- Native room backgrounds13/14/15 now map to196/197/198. Source selected row
  hallway table1,3,6,7,8 plus190 and local Equipment frame prove this correction.
  The old asset_catalog.py/JSON descriptive room labels for c4/c5/c6 are still
  wrong and should be corrected as derived metadata, without touching bitmaps.

## Work still needed for0.8

Inspect actual Command-5 window progression, correct UI/presentation errors,
test a real saved normal profile result/new game (isolated temp profile), ensure
crash-safe once-only commit, retain exact GUI observations. Rendering all403
commands has resource checks; live playback is not yet established. Native PNGs
for energy/time/win/results/wrong choice exist and were inspected; original
BONUS font and exact final numbers look correct. Current code has source-derived
timing but simplified bonus slide, rank transitions and some driver effects.

Package/extract/source-rebuild0.8 only once relevant fixes pass. Then update
status/README/GOAL/recovery notes and push its verified milestone to GitHub.
Do not mark the full game complete: menus/options/help/notes/practice, collision
knockback, queued input, detailed transitions/timed effects, palette/driver
fidelity and complete-playthrough validation remain pending.

## GitHub is already created and verified

Private https://github.com/leetea/outnumbered-native-macos ; main commit
eaaeb33eb1f2daeb026ae8a79be1ee1eb8afb362, tree
a235b7b0feca2801d7255395b03a1b9239acf47f. All46 blobs match the local
`repository/` publication snapshot. repository-sync.json records it. Source,
plan, chat-derived project context, milestone ledger and derived runtime-data
ZIP are included. Original ZIP, video, DOS EXE/compiled modules and saves are not.

The user explicitly authorized a push after EVERY verified milestone. Continue
that workflow without asking permission again. The connector has admin/push
access; use create_blob/tree/commit/update_ref with the current branch head and
expected SHA. No gh CLI, credentials or automation was installed. `repository/`
is a clean publication snapshot, not a Git CLI checkout. Update it from the
verified source package, not from unverified work.

The repository wrapper builds/signs in /private/tmp and packages a ZIP in build/.
Copying a raw.app into the synced Documents checkout repeatedly acquired
FinderInfo despite retries; ZIP output solves that. The final wrapper command
passed; its ZIP was extracted in a fresh temp folder, strict-signature verified
and ran all245 baseline checks. Do not repeat the unsuccessful raw.app copy
strategy or weaken signature verification.

GitHub UI tab2 is marked deliverable. Its screenshot is
outputs/github-milestone-0.7.png. Old tab1 disappeared after user login; a fresh
tab2 was created at the exact repo URL and visibly showed Private/eaaeb33.
If replying to the GitHub request, embed that proof screenshot in the final
response as required by browser instructions. API reads already verified head,
milestone text and every file blob; no need to repeat them.
