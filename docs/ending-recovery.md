# Original ending and native session lifecycle — milestone0.8

Original ZIP/video/assets remain unchanged. This recovery translates original
presentation data and game rules into Swift/Cocoa. The native app executes no
DOS program, x86 instruction interpreter, graphics driver or compiled TEMPLATE
drawing code. The local `OutNumbered Gameplay.mkv` is the video reference.

## Decision, reveal and loss rules

Original18e7:0563 tests decision eligibility, asks for confirmation, and compares
the selected room with stored hideout DS:5beb. A wrong choice ends the game;
it is not an opportunity to try every room without consequence. A correct
choice runs a scripted reveal/escape followed by bonuses and rank presentation.
The original does not introduce a new player-controlled chase at this point.

The retained Evidence is in `ending-analysis/decision.json`, `rule-0.json`,
`rule-1.json`, `original-1.json` and `entry-tail.json`. `derivatives.json` proves
that analysis derivatives changed only initial MZ IP/CS bytes20..23. Code, data,
relocations and the original archive were not changed.

The midnight path is separate. Original11b0:109e clears game score/energy,
flashes the empty meter for1000IRQ ticks, then opens the replay flow. It does
not invent a last-minute search of the hideout. The native path preserves the
loss, score reset and warning duration; the exact meter-flash pixels remain
pending. Expiry is handled before another Telly random draw.

Wrong-choice clock advancement retains original `(11-hour)*60+minute` and
the original displayed-clock cap. It is not replaced with an invented fixed
penalty or unconditional midnight time. A loss adds no lifetime points and
does not display the victory trophy screen.

## Translated presentation data

Original135d:0fc9 reads nine-byte commands: signed resource ID; byte x/y,
right/bottom, restore reference, flags and wait-frame count. Coordinates x/right
are in four-pixel units. Resource−1 restores a rectangle from a backing canvas;
resource−2 stops the current sound and starts the sound identified by x. A
positive resource draws a sprite, optionally restoring the rectangle from the
one-based referenced command, then waits frameCount*frameTicks.

`export_endings.py` compiles14 original scripts/403 commands into
`ending-sequences.json`. The native renderer composes them from decoded data.
FASTLOAD IDs are direct;10000+ refer to CLOSE1 during a win or CLOSE2 during a
wrong decision. Original file-table indices10/11/12 select CLOSE1/CLOSE2/TROPHY.
Source fragments, sound cues and restore coordinates remain independently
inspectable. No executable or driver is needed in the runtime.

The source ending's selected-room hallway table is1,3,6,7,8. Adding190 produces
background records191,193,196,197,198. This corrected the native Cartoon,
Equipment and Sound background mapping. Decoded bitmap bytes are unchanged;
the old descriptive catalog labels were corrected as derived metadata. The
Equipment background also matches local gameplay frame-081.png.

## Bonuses, ranks and persistence

Original147d:0882 awards remaining energy, remaining time and the victory bonus
in that order, using the rank-pair tuning table. The native tally retains UInt16
game-score arithmetic. Original11b0:0f87 includes a final zero-remainder
iteration, which matters for timing: a change equal to its step waits twice.
Each energy decrement and score change therefore takes20IRQ ticks, or40ticks
per energy unit across both operations. Source sound cues retain priority;
explicit script sound commands interrupt as the original does.

The recorded checkpoint starts at2650points,17energy and9:52PM. At Senior tier,
the source bonuses are2550 for energy,4480 for time and2000 for winning:
2650→5200→9680→11680. Original1a01:026a adds only a winning game's final score
to lifetime points and caps the total at9,999,999. The reference lifetime52595
therefore becomes64275, passing the60000 Pro threshold.

Native session saves preserve the frozen ending inputs and elapsed timeline.
Repainting and resuming reconstruct the tally without repeating awards. Native
profile fields `lifetimePoints` and `lastResultRunID` are new infrastructure,
not a claim that the DOS save format used UUIDs. They make the profile/session
commit boundary idempotent: a restart after the profile update recognizes the
same run and does not add the result twice. Replay starts a fresh run with
earned lifetime/rank and reset clock, score, energy, questions and clues.

Reference checkpoints remain isolated from player files. Their replay prompt
explicitly describes an isolated game rather than claiming that a player score
was saved. Normal player sessions use the saved-score/replay wording.

## Verification and remaining limits

Native-window playback showed entry, the original BONUS artwork and2550energy
label, then Game11680/Total64275 and a working replay into a fresh9:00PM game.
The exact capture/build meanings are retained in the GUI observation ledger.
The normal profile flow is checked in temporary player directories, including
mid-tally restart, completed-profile commit, simulated interruption between the
profile and session writes, and a new game reopened from disk.

The ending is a concrete gameplay milestone, not a finished faithful game.
Original door/scroll transitions, bonus sliding, rank-tower animation, meter
flashing, complete clipping/palette/driver behavior and calibrated ending audio
still require refinement. Native timers advance in24IRQ-tick frame increments.
Original menus/options/help/notes/practice, collision/queued-input details and
full-playthrough validation also remain required. Do not mark the goal complete
from a reference checkpoint or headless checks.
