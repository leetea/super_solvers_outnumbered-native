# Ending presentation and replay — local0.34

The original archive/video remain read-only. The runtime uses native Swift and
decoded data, with no x86 execution, DOS emulator or original drawing driver.
Static instruction evidence and original tables are retained in verification/
ending-presentation-instructions-0.34.json, ending-replay-instructions-0.34.json,
ending-tables-0.34.json and ending-copy-ABI-0.34.json.

Original147d:01cf draws the trophy, original font1393 headings/points/ranks,
two red footer rows175/176 and the yellow heading separator. Its six-command
DS0ef3 introduction lasts150IRQ.147d:0000 adds60 central red pixels between
the tier triangles,10IRQ each.147d:00b5 fills each earned triangle red/cyan/red,
40IRQ per color, requesting sound26 and stopping it after each120IRQ tier.
The post-award rank is used;64275 reachesPro (index3), so its animation lasts
150+600+4*120=1230IRQ. Champion adds the original16-command DS0f29 script.
export_endings.py now retains16scripts/425commands. No new animation is invented.

Original14df2/14d28 reveal/close the bonus by copying a cropped offscreen
rectangle into fixed64,16, in59steps of5IRQ. The source top is90-SI; the close
restores the exposed bottom row. It does not move the panel below the room.
Native composition retains those slices, repeated sound46/47 requests, original
blue9 inset and Winning Game red/black/yellow colors. Departure flags96 include
horizontal mirror32 as well as transparency64; the native renderer now honors
both. The earlier renderer omitted the mirror flag.

Original11b0:100c alternates FASTLOAD75/74 at252,163 for five100+100IRQ cycles,
requesting49 at each half. The native renderer applies this to wrong-hideout and
midnight paths. Midnight opens replay immediately after the1000IRQ warning;
other endings retain the original Enter/Escape wait. Enter/keypadEnter opens
untitled defaultYes replay. DS19b8 is the win text, DS1a09 the loss text. No
offers ordinary Exit/defaultNo; declining Exit returns Sign-In. Yes or Escape
from replay returns Sign-In too. A new adventure is chosen there rather than
automatically reusing the same player. Native result persistence remains atomic
and idempotent; replay itself does not duplicate the score award.

## Correction to0.29 confirmation layout

The earlier arithmetic offsets were right, but the two array entries were named
backwards:7312 is selection0/No at right-55,7314 is selection1/Yes at right-115.
This corrects every common confirmation to Yes-left/No-right. The supplied MKV
386.5s and441–444s corroborates that ordering. Historical0.29 screenshots/reports
are retained and do not prove the corrected presentation.

## Verification and limits

Candidate and extracted temporary ZIP pass1103 checks and strict signatures,
including source table counts, bonus crop endpoints/5IRQ changes/repeated cues,
rank separator rows/fourPro flashes, visible cyan/red bands, frozen input during
the tower, post-award display without premature commit, immediate midnight replay,
both replay routes and native Exit request. The native window separately completed
the isolated Equipment win to11680/64275 and the replayNo→ExitEscape→Sign-In path.
All copied player files remained byte-identical. This is reference-session GUI
evidence, not a fresh ordinary full-game playthrough. Audio was not evaluated by
listening, and analog speaker/CPU-speed equivalence is not claimed.

The workspace File Provider reattaches FinderInfo to app folders, causing strict
verification of the loose workspace copy to fail. The ZIP is packaged from a
clean temporary app, then extracted independently and strictly verified. Prefer
outputs/local-checkpoints/Outnumbered-0.34.zip for this checkpoint. This metadata
issue does not relax the extracted distribution gate.

Graphics masks/occlusion verification, broader audio comparison, a fresh complete
ordinary native campaign, final source/repository/distribution rebuilds and final
GitHub publication remain. The complete-game goal stays active.
