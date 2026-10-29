# Original help recovery — milestone 0.10

The native help book translates all22 pages, eight topics and four illustrations
from the original HELP.DAT. SHA256:
`e12419e3d15436f8370583ff459982fec236986791318bf7c9ca4555e90f22c1`.
No original input is modified. The runtime reads translated JSON and bitmap data;
it does not execute DOS code.

## File format and coverage

The first eight bytes are page counts3,5,3,3,2,2,3,1. The following22 four-byte
records contain little-endian text and illustration offsets. The96-byte header,
NUL-terminated Latin1 strings, and four image records account for all10,951 bytes
without gaps or overlaps. `export_help.py` asserts this coverage before emitting
help-pages.json. The retained help-analysis/data-coverage.json records each range.

Text includes the original keycap characters and ~XXXYYY absolute pixel-position
commands. The recovered text engine starts at(28,37), uses font1393 and10-pixel
line spacing. Image records have two placement bytes followed by the ordinary
18-byte bitmap header and packed4-bit pixels. Their positions are(36,37),
(36,37),(36,37),(96,67); sizes48×42,48×42,48×41,120×19.

## Source behavior

Original1c45:004d/016a/01ac/037c establish text drawing, fonts, page data and the
page loop. Original1862:000e/0174 establish button bounds/selection inversion.
Panel style4 at1862:05f9 uses bounds(16,19)..(300,189), a21-pixel bottom region,
and the source blue/white frame. FASTLOAD57/61 draw the toolbar and selected Help.
Topic/menu titles come from DS33b4 and the original menu records at DS3424.
Practice exposes only About Drill for Skill, routed to topic7.

The first page has Next only; later pages add Back, and the final page uses Done.
Local0.32 corrected an earlier interpretation of the outer menu-loop condition.
Esc returns0 from the page loop, ending the menu and restoring the parent. Done
and F1 return1; the Enter dispatcher then calls174fc(F1), rebuilding Help topics
with selection0. The loop17570 continues while DS72aa is NONZERO. Reading the
page result alone had reversed these actions in earlier native versions. Source
raw instructions retained in lifecycle-instructions-0.32.json prove both the
helper return and its caller's behavior. F2/F3 are ignored inside a Help page;
menu-tab navigation remains available on the topic list.

Help is transient native UI. It pauses an active adventure and restores its
previous screen/input; practice help leaves both its counters and suspended
adventure unchanged. Native checks exercise all22 pages, repeat rendering,
button navigation, active-question preservation and practice separation.

## Corrected catalog inference

The old descriptive labels notes_clipboard/notes_paper were visual guesses.
Original21b1:02e6 draws DMOCKET1b62/1b63 behind DOS member selection, creation
and deletion. They are now labeled player_sign_in_clipboard/paper. No recovered
HELP text or menu record establishes a notes editor; an invented editor is not
part of the reconstruction plan. Original sign-in presentation remains work.

## Verification limits

Headless checks establish native data/state/render behavior, separately from
window observations and source/package rebuilds. Static screens now request a
redraw when content changes, instead of on every timer tick. Repeated native
help captures are identical. This does not establish pixel parity for the whole
game, resolve every previous dynamic-screen capture discrepancy, or complete the
game. Original menu/music/history, practice interstitials, transitions, collision
presentation, timed activities, ending refinements and a natural playthrough
remain required.
