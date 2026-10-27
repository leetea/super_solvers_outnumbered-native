# Room camera and recharge motion — 0.20

This corrects the earlier work notes' "energy-machine eye actor" label.
Actor2 is the purple ceiling security camera in each room. Its sprites are
ROOMS3..7, position19*8=152,y24, not the energy machine's FASTLOAD196..201.
The source uses a panning sequence, not a randomly timed blink.

Read-only unpacked analysis EXE SHA256:
ff2e0d28e0a6aa8bcf86db1ea8a2980d2ccb1e10dd793bc15ab1bb929697b464.
Raw1b03:00f6/0119/0132 and135d:0cf5 instruction evidence is retained locally
in verification/room-camera-instructions-0.20.json. Existing fountain-use
assembly and source135d:072b/0a1c,11b0:1559 establish lifecycle/call ordering.
No original input, executable, asset, ZIP or MKV was modified.

1b03:00f6 activates actor2 and draws ROOM3 without advancing the animation.
0119 updates it through resource5000 row14:3,4,5,6,7,6,5,4, each held for four
simulation updates.11b0:1559 calls it after LiveWire;1431 draws it between
LiveWire1 and player3. A full pan is32 updates, each normally24IRQ. It has no
random draws, motion displacement, collision, or sound request.

Room entry starts it before the nine small-front/front pose updates. Room exit
continues it through alignment, five back poses and four small-rear poses,
then0132 clears active and frame index. Raw0132 leaves the partial four-update
hold counter unchanged. Reentry draws3 but consumes that retained hold. Direct
flag clears during game/ending setup do not reset either animation counter.
The native next-game path carries those counters for the same player while
disabling the actor. Native per-profile persistence remains a platform
adaptation; it does not claim a shared DOS process phase across different users.

The optional native roomCamera field persists active, displayed sprite, next
frame and remaining hold. Older saves initialize a fresh phase if already in
a room; historical missing animation updates are not invented. Decoder/help,
questions, practice and synchronous zap/wait phases do not run1559 and therefore
retain the current phase. Ending-specific camera composition remains separate
from normal exploration; midnight retains the current frozen room view.

Local MKV verification extracted nominal174.0–177.9seconds at10fps, inspecting
the same152,24,32,26 region. Original Equipment-room/background composites
identify the visible6->5->4->3 portion before the activity transition. Samples
after about175.5seconds are occluded by the activity screen and excluded. The
RGB-error<60 visibility heuristic, lossy video and10fps sample do not prove
pixel/color calibration or exact IRQ timing. Full per-pose errors and limits
are in verification/room-camera-local-video-0.20.json. No YouTube browsing.

Recharge now uses the same recovered scrolling/alignment rule as doors and
elevators. Original1b03:013f alignment invokes148a(0) plus an unpaced viewport
copy per unit. New native actions use the existing documented4IRQ display
adaptation for those copies, retaining starting facing until the force-right
rear pose. Animation15 is9,10,11,12,203 at y78,75,72,69,66,24IRQ each. The
player remains203/y66 during dispensing. Animation29 is14..18 at y69..81,
24IRQ each, then restores initial facing. The aligned scrolled camera remains.

Absent-enemy random draws and active Telly/projectile movement now continue
once per alignment and pose frame: distance+10 updates, spawning disabled.
The nine earned or four empty dispenser frames still hold30IRQ each and do
not update auxiliary actors. Credits and sound35/36 occur once at dispensing
start, in source order even under a coarse timer advance. Dispense sound is
stopped before the first front-return pose, preserving following actor sounds
when the action finishes. Silent sound-index markers verify this ordering,
not perceptual audio parity. Per-frame cursor
persistence prevents replaying updates on resume. Credits, original top-strip
sprites and lower machine body behavior are retained from the earlier port.

Older active fountains with nil origin retain their prior pacing, positions
and y81 approximation until finished; they do not acquire invented historical
RNG draws. New actions persist origin and derive exact pose/scroll frames.
This is an explicit compatibility path, not full historical-state recovery.

713 checks cover original row/actor identity, full pan cadence, retained hold,
all five room entry/exit update totals, pause/resume, no extra random draws,
camera-only pixel changes, recharge pose heights/scroll, distance+10 draws,
frozen dispenser waits, timer-batch equivalence, credit idempotence and legacy
actions. Native-window ordinary Sound entry showed changing camera poses;
ordinary use of the naturally placed empty machine showed raised poses,
scroll alignment, continuing Telly/projectile motion and unchanged energy9.
Earned-credit and all counter/restore combinations are headless evidence.

Full-game completion remains unproven: remaining encounter/capture presentation,
timed activity effects and RNG, opening/File/sign-in, queued input, ending
refinements, complete palette/mask/audio parity and a fresh full playthrough
are still required. The unpaced display adaptation is not DOS driver timing.
