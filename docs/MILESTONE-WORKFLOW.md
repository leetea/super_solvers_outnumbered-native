# Authorized milestone update workflow

Destination: `leetea/outnumbered-native-macos`, private, default branch `main`.
The user authorized source/plan/context updates after each verified milestone.

1. Complete the actual milestone and retain its limitations. Do not label
   unimplemented behavior, a fixture or headless check as a complete game.
2. Run relevant native checks, inspect meaningful native-window behavior, build
   the app, verify the extracted package, and rebuild the packaged source.
3. Refresh the repository source snapshot and derived runtime-data ZIP from
   that verified source package. Keep original ZIP/video, DOS executables,
   compiled DOS modules, player saves, compiler caches and credentials out.
4. Update README, the full plan, project context, milestone history and a
   compact verification record. Preserve the local-video override.
5. Inspect the changed file manifest, publish one descriptive milestone commit,
   then verify the remote branch and changed files. Use a normal fast-forward;
   do not overwrite unrelated remote work.

The GitHub connector can create blobs/trees/commits and update the branch.
Repository creation required the signed-in GitHub website; it is already done.
No GitHub CLI installation, saved access token or recurring automation is needed.

The local `repository/` folder is a publication snapshot. Active development
continues in `work/reimplementation/`; preserve unverified work there until its
milestone passes. The initial snapshot was 0.7; later verified milestones update
the source, derived runtime data, plan, evidence summary and milestone ledger.
