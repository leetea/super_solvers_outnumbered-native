# Historical milestone0.8 handoff

NEXT-HELP-NOTES.md supersedes this file after verified/published0.9.

The previous goal turn made concrete implementation and verification progress.
The ending/replay milestone is packaged and published. Do not redo its recovery
or treat it as waiting/no progress. The complete-game goal remains ACTIVE.

## Current evidence

- Native app0.8 and both output ZIPs are current.269 integration checks pass.
  Packaged app extraction, strict signatures and packaged-source rebuild passed.
  The repository wrapper also rebuilt0.8; its extracted ZIP passed269 checks and
  strict signature verification. No build, test or REA session remains active.
- Final binary SHA256:db5a9c33d60db72bfc111cc9a11326ec3acd885dc44f5960fde03dcdec7abd4d.
  Runtime ZIP:362f3ecaf30574147ca4d53457e578a1eb3ac388d137c48d94f13090e0147372.
  Source ZIP:d9013e07bc9a4f05a8a712a662f583d0b93cd6b39a236a068c6a720f5417c925.
- Actual final-candidate window showed Energy Left2550/score4600 during tally,
  Game11680/Total64275, the isolated replay prompt, then a fresh9:00PM game.
  `verification/gui-observations-0.8.json` distinguishes these from older captures.
  Normal-profile autosave/restart and interrupted result commits were verified
  in temporary directories, not by altering player progress.
- `ending-recovery.md` is the polished source/rule/limits report. ENDING-NEXT.md
  below its new heading retains historical pre-verification recovery notes.

## Next functional gaps

Original menus, profile selection, options, notes, help and practice flow remain
incomplete. Current NativeApp starts/resumes an automatic Player profile; the
separate ProfileController in Game.swift is not integrated. F1 shows native
control instructions, and the drawn File F2/Options F3 header is not a complete
original menu implementation. Preserve existing native save compatibility.

Useful original-code entry points in game-pseudocode.c:

-2144:0009 (linear21449): start/play/continue/custom/practice menu lifecycle.
-1f13:0000: original thirteen-byte settings UI;1f13:0380 copies rank defaults.
  QuestionSetup.swift already recovers room operator enable bit16, row mapping,
  math-level bands and per-rank eligibility. DRILL-RECOVERY.md/Encounter.swift
  retain drill configuration generation; integrate settings rather than invent
  another difficulty system. Original custom settings can differ from rank.
- Original HELP.DAT text/layout extraction is in original_help.json/.md and
  asset_catalog.py; retain original pagination/illustration limits until recovered.
  Original notes artwork is DMOCKET.GRA.1b62/.1b63. Find exact notes/help behavior
  in retained source and the local MKV before implementing persistence semantics.
-16c0:00d7 (16cd7) obtains a new seed from the shared rand stream, reseeds it,
  then creates questions, decoder and fountain. Decoder.swift explicitly retains
  mutated symbol/pattern pools between puzzles. Current beginNextGame still
  constructs a fresh generator with an OS-selected seed, so exact campaign replay
  RNG/pool continuity is a known gap. Address it alongside new-game/menu flow;
  do not claim complete campaign stream identity from current0.8 checks.

Further work still required: detailed collision/knockback, queued input, door/
scroll/elevator transitions, timed activity effects, bonus/rank animation,
midnight meter flashing, palette/driver fidelity, calibrated sound comparison,
all-rank/custom-setting integration and complete natural-playthrough validation.
Do not mark the complete goal achieved from the ending checkpoint.

## Publishing is authorized and must continue

Private repository:https://github.com/leetea/outnumbered-native-macos . Current
main commit02e0fff48b08faf9d8607431104e4c61eef42866, tree
e67e762164f534c79f1c9d5479073b99c960b460. All54 file blobs match the publication
manifest. repository-sync.json records current state. No gh CLI/token was installed;
the connected GitHub tools have push access. No confirmation is needed again.

After every verified milestone: package/check first; update repository README,
MILESTONES, PROJECT_CONTEXT and docs/PLAN, then run prepare_repository.py. It
reads the hash-verified source ZIP, copies its Swift/build/docs, creates the
derived runtime-data.zip and emits text batches and a manifest with Git blob
hashes. This avoids publishing unfinished active work. Preserve unrelated remote
changes by checking the current head and using an expected SHA on update_ref.

`repository/` is a publication snapshot, not a Git CLI checkout. The root wrapper
builds/signs in /private/tmp and outputs a metadata-free ZIP; copying raw.apps
into its synced Documents build folder repeatedly reacquired FinderInfo. Do not
repeat that failed approach or weaken strict signature verification.

The local gameplay MKV continues to supersede YouTube. Original ZIP/video remain
unchanged and outside Git. Runtime includes decoded data/PCM, never DOS EXE,
graphics drivers or compiled TEMPLATE drawing modules.
