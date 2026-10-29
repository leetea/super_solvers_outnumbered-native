# Continue after verified/published0.12

The full-game goal remains ACTIVE. This turn made concrete recovery,
implementation, window QA, package/source rebuilding and GitHub publication
progress; it is not a blocked/no-progress turn. No live build/test handles or
REA session remain. This supersedes NEXT-AFTER-SCORES.md and older handoffs.

Private repo https://github.com/leetea/outnumbered-native-macos .
main dc54897587ac47f7b510a290b38b21f005826509,
tree7e142ed8f49f94725a6dabd73eb7ae57afe75218. All90 file blobs verified.
repository-sync.json current. No Git CLI checkout/new sign-in/automation needed.

0.12 native source: Tutorial.swift, TutorialText.swift, GameTutorial.swift,
TutorialChecks.swift; updates to Encounter sound policy, NativeApp, GameMenus,
Session, GameEncounters/GameEndings and explicit fixture construction flags.
382 checks pass in extracted runtime, independently rebuilt source ZIP and
extracted repository build. All32 compiled ARM64 sections and484 runtime assets
match final GUI/shipping; repository484 assets match final snapshot.

Shippingbinary9bc905c4f77033e8de5a1811f77497186bbeee6e41da855663c108148e941831.
RuntimeZIP6b4009c7c2869b0284007311f2836e6a0d59c41e43b40b279694e8fb806afc98.
SourceZIP27fbdd70932f97ca5eea1e78f028513b8c35d2cd331d8c4fa67c8bf0363e6cd3.
Original ZIP/MKV hashes rechecked unchanged. Local MKV supersedes YouTube.

## Music and messages

Source1bda:0580 requires434e nonzero for all sound and4348 zero for streams0..5.
Music Off stops any current stream, sets4348; On clears it without immediately
starting sound. Sound is master. Opening1a4e:00b4 repeatedly requests0, now used
in the native title tick.52 PCM resources unchanged; no perceptual audio claim.

18 source strings atDS136b are retained by TutorialText.swift/export_tutorials.py.
Native macOS alerts substitute readable bracketed keys. They are functional
accessible presentation, not DOS dialog pixels. Source5bd7..5be8 flags0/1/ff and
5bef enable flag are inside saved103-byte block5b8a..5bf0. Optional native session
state reads old saves; native pending deadlines are a native save extension.
Yes resets18 flags; No preserves them. Queued0..12 scan in order once actors
settle; direct messages check seen state. Idle timers cancel/mark seen on first
input. Practice has independent transient state, retained across sets/player
context. It inherits enabled choice without writing the suspended adventure.

Clock/energy guidance triggers only on corresponding updates. Resetting flags
at9:02 must not immediately replay notice0; tutorialLastMinute/Energy caches fix
this. Actor-settled timing remains approximate until knockback/transitions land.

Window QA caught an unnecessary save during practice guidance: values stayed
identical but unsorted JSON encoding rewrote file bytes. Final showNewUserMessage
SKIPS save for practice and tutorialPracticeContext. Do not fix by sorting JSON
or allowing writes. Both native tests and real GUI compare unchanged file bytes.
Nested practice setup also must not add/resume adventure clock pauses.

## Evidence and GUI state

Final app /private/tmp/Outnumbered-Messages-Final.app uses only temporary
/private/tmp/outnumbered-012-final-gui-players. CUA finalMessagesApp binding may
persist. It is on the native player menu for temporary Guidance Check, ordinary
new game at9:02,score0,energy12 after actual live-clock search guidance. Music Off,
Sound On. Other older verification apps may remain; do not close user apps.

GUI observed0/13/15/16/17, Music Off/Sound On, No preserving flags and Yes clearing
all18, legacy save missing newUserMessages field, and ordinary new-game9:00→9:02.
Practice setup guidance final file hash remained exactly
e7520e594540060f0aa38f95fc35487cf23c5792f21b56f8d9d442c0eadb16ac.
verification/gui-observations-0.12.json and gui-0.12-code-identity.json scope all
claims. Only fixed/final screenshots listed there establish the final build;
pre-fix candidate files are retained separately as diagnostic evidence.

Creating a new unique app via cua.getApp took up to899seconds. Reusing the same
bundle path/ID after a verified quit and replacing its derived contents took
under1second. Before replacing, dismiss modal dialogs, CmdQ and inspect
cua.listApps until that exact verification app is absent; it can exit
asynchronously. There is no cua.computer.launch_app on this mac backend.

## Packaging

Synced Documents immediately restores FinderInfo. package_verify.py now creates
metadata-free runtime ZIP, extracts it under/private/tmp, strictly verifies that
EXACT distribution and uses its verified resources for source packaging. It
compares shipped/raw executable hash, then independently extracts/rebuilds/checks
source. Strict signatures are not weakened. Final ZIP is the portable artifact;
raw synced .app metadata can still fluctuate. Source/repo wrapper builds use
private temporary app staging. No compiled DOS drawing modules/executable shipped.

## Next meaningful full-game work

Prioritize original practice animations and an ordinary complete gameplay-loop
validation, while recovering remaining transition/collision presentation. Avoid
endlessly adding menu widgets while leaving the natural playthrough unverified.
Original practice1fc6:0061 alternates DRILL10/11 then12/sound23. Perfect helper
1fc6:0007 uses DS5516 script. Imperfect selects DS5771 pointers to5378/5435,
sounds28/34; practice consumes two result RNG draws. Retained menu-analysis/
practiceinit*, practicecelebrate*, menuraw2 and menu-practice-recovery.md locate
all prior evidence. Existing EndingTimeline/script export may offer reusable
render primitives; inspect before introducing a generic engine or dependencies.

Native applicationWillTerminate already calls game.save(); this was verified in
NativeApp.swift at the end of0.12. Original File/exit confirmations and sign-in
presentation still differ. Also required: original File/exit/sign-in flow,
opening credits/presentation, detailed room/door/elevator transitions, knockback,
queued input/feedback, timed activity effects, palette/masks/occlusion, bonus/rank/
midnight effects, calibrated audio and complete natural playthrough/all-rank edge
cases. Native new-user/options/settings dialogs remain presentation adaptations.
Former notes assets are confirmed sign-in art; do not invent a notes editor.
Publish every VERIFIED milestone using source ZIP ->manifest ->GitHub lease.
