# Milestones and completion plan

1. Inspect the supplied DOS archive and executable formats; preserve original hashes.
2. Prove native Apple Silicon rendering, input and packaging with a prototype.
3. Recover original resources, question generation, answers, scoring and sound streams.
4. Implement rooms, traversal, doors/elevators, enemies, collisions and recharge.
5. Implement ten activities, drill, calculator, clues, decoder and eligibility rules.
6. Implement progression, endings, menus, Help, settings, practice and isolated saves.
7. Recover presentation details, input buffering, palette/masks, audio and ending timing.
8. Verify a normal campaign, quit/resume/replay and independent app/source/repository builds.
9. Package 1.0 and publish the final verified repository snapshot.

Milestones 1–8 are locally verified for the named EGA/PC-speaker native target.
The final publication records milestone 9. The earlier 0.28 snapshot was the last
remote checkpoint before the user's hold; versions 0.29–0.36 were local milestones.

The final presentation work recovered original confirmation/settings/options
panels, calculator advice/remainder behavior, decoder decision panels, rank/bonus
scripts and midnight meter flashes. Independent raster checks cover all 389
bitmaps across 2,334 compositing cases. All 52 PCM streams regenerate identically;
selected events correlate with the local MKV, without claiming every event was
individually audible or analog-identical. A 60 Hz presentation clock executes the
winning ending in 44.965 seconds versus the recovered 44.952-second sequence.

Final gates: extracted ARM64 release signature and 1,118 checks; independent source
archive rebuild and 1,118 checks; independent repository build/extract and 1,118
checks; assets preserved across rebuilds; original ZIP/MKV hashes unchanged;
ordinary five-room win, two earned code pieces, visible-clue deduction, saved-game
resume, 6,900-point Junior award and replay. See docs/FINAL-ACCEPTANCE.md.

Future changes should preserve these gates and the native target boundaries.
No unresolved required gameplay feature is being deferred into a future milestone.
