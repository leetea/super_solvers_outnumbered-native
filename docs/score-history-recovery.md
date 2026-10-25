# Original score tables — milestone0.11 work

This recovers separate lifetime totals and individual high games. Original code
is inspected through entry-context derivatives of the read-only unpacked DOS
analysis executable. score-analysis/derivatives.json proves only MZ initial
IP/CS header bytes20..23 change; code and relocations are unmodified.

## Original rules

Original170d:0668 dispatches File/Lifetime Scores and High Game Scores to
170d:091a (linear179ea) and170d:0a1f (17aef). Both use panel style7 at
(16,26)..(300,179), font1393, source headings Name/Rank/Lifetime or High Score,
ten rows and an Esc-to-Go-Back footer. Row output21b1:0073 prints name atx30,
rank atx140 and comma-formatted numeric score right-aligned at272. Lifetime
rows starty53; high-game rowsy55; both advance10pixels. Original menu accepts
Esc or Enter to dismiss.

Lifetime sorting1a01:03cc initializes ten member-slot indices and swaps a later
entry ahead only when its unsigned32-bit total is larger. This pairwise swap
ordering is not a stable sort for equal totals. Empty member slots are skipped.

High-game data atDS6cba comprises ten15-byte records: nine name bytes,
unsigned32-bit score at+9 and rank index at+13. Game score itself is a16-bit
unsigned word. Original1a01:026a captures rank before adding the win to lifetime,
caps lifetime at9,999,999, and replaces slot9 only if the game score is strictly
greater than the current last score. It bubbles upward only past smaller values.
Equal scores keep existing order; a tie with tenth is excluded. Zero cannot enter
an empty table. Multiple games by the same player can appear.

Original147d:0c55 (15425) calls the update after the winning reveal/bonus routine;
wrong-hideout and midnight losses do not use this award path. The retained caller
and raw insertion assembly establish the scope. Source21b1:0039 obtains rank from
the selected member's current lifetime total; rank thresholds remain the already
recovered eight values. Source170d:0c9b formats commas; the native formatter does
not depend on machine locale.

## Native integration

Optional highGameScores is added to the existing atomic native profile document.
It is separate from lifetimePoints, preserves the original top-ten/rank/tie rules,
and commits together with lifetime and lastResultRunID. Old files without history
remain readable. No historical individual games are invented from old lifetime
totals. Reference checkpoints do not write either score table. Invalid history
(over ten, unordered, duplicate run IDs or invalid names/zero scores) is rejected
without changing its file.

The original display geometry/text is drawn on the native indexed canvas.
Native names can be longer than the DOS eight characters, so display clips only
the name column while retaining full saved names. Native profiles can exceed the
DOS ten slots: lifetime pages use ten rows, with arrow-key paging. This is native
infrastructure, not a claim that DOS supported more members. High games remain
limited to ten. New native menu entries/Command7/8 expose both tables; original
full File-menu presentation remains a fidelity task.

Opening scores suspends active adventure time and practice advancement; nested
help/score/menu exits release only their own transient pause. Rendering does not
sort or mutate saved state. Tests/window/package evidence are recorded separately.
The full game remains unfinished: music/new-user options, original practice
animations, transitions, collision response, timed activities, ending refinements,
palette/sound comparisons and complete natural-playthrough validation remain.
