# Original question setup — native milestone 0.7

Original files remain read only. Evidence comes from the unpacked analysis copy
of SSO.EXE, original decoded TEMPLATE question records, and retained REA results.
This is static recovery, not a DOS runtime replay. The downloaded gameplay MKV
remains the video reference; YouTube was not used.

## Startup choices and order

`question-generation-analysis/generation-0.json` preserves raw instructions for
original 1d06:0207. It draws all ten question seeds first (rand()%10+1), then, for
each slot, one variant (0..3) and rejection-sampled enabled operation row (0..3).
The operation row is enabled by bit16 in the first four configuration bytes and
mapped through DS:4c6a, whose original bytes are 0,2,3,1. The default four settings
records are retained, with original offsets and source hash, in
`question-generation-analysis/original-tables.json`.

For rank tiers0/1, one slot per adjacent pair is enabled using the low bit of a
random1..100 draw. Tiers2/3 enable all ten slots. Choices for inactive slots still
consume randomness. The native app stores every choice at game start and uses
the exact record/seed/variant identity on interaction; it no longer picks a
random bank entry at the door.

Original 16c0:00d7 invokes question setup, decoder generation, then energy-machine
placement, in that order. NativeSession now follows this order. The initial
seed is truncated to16bits, matching original srand's argument.

`generation-2.json` preserves the template selection instructions. The family
bases at DS:4c72 are9070,9010,9100,9120,9050,9140,9020,9040,9060,9130.
Each adds its operation index and a band offset. Math level0 uses band0;
levels1/2 use band5 only for operation indices0/3; level3 uses band5 for all.
Original 2144:0009 initializes math level from rank tier and replaces it with
configuration byte0&3 when custom room settings are chosen. The native model
supports every nonempty operation mask and each math level; original custom
settings menus are still pending.

## Question entry and auxiliary chart numbers

`entry-0.json` preserves 1d06:00a2. Entry calls srand with the stored question seed,
generates its data, binds pointers, then invokes the drawing module. The data
compiler now retains the full32-bit random state after generation. Native entry
restores that state before building music/equipment auxiliary columns. Reopening
regenerates the same chart and leaves the same random state; repainting and
resuming an already prepared active chart consume no random numbers.

This fixes the recovered generation boundary. It does not establish complete
campaign stream identity: original timed activity effects and any random draws
inside those effects remain under investigation.

## Thirty cross-group references

The previous strict group bounds rejected record9056 variants1/2/3 for every
seed1..10. `generation-1.json` shows original 1d62:0077 computes
group.offset+index*group.itemSize without comparing the index with group.count.
Original 1d36:000f clears the entire sum(count*itemSize) field allocation before
generation.

In9056, group5 has four182-byte fields starting at188. The three references5.4,
5.5 and5.6 therefore resolve to916,1098 and1280 inside the1538-byte allocation.
At the time each string is copied, its first byte is zero for all ten seeds.
They produce an empty second question paragraph. The native data interpreter
now follows this shared-buffer addressing while retaining allocation bounds;
it does not permit reads outside the allocation or change original records.
Every alias is recorded in `verification/challenge_reference_aliases.json`.

All80 records ×10seeds ×4variants now compile:3,200 successes, zero unsupported
cases. The original answer and first paragraph are preserved even where source
data is unusual. No substitute question or corrected answer is fabricated.
This covers the stored parameter space of the recovered new-game question
path; full custom/practice lifecycle and runtime fidelity still need validation.

## Saves and verification

New sessions persist original startup choices. Pre-0.7 saves lack the historical
startup seed/choices, so migration preserves their decoder, assigned questions
and progress, generates missing choices once from their saved stream, and marks
`migratedQuestionSetup`. They are not presented as historical original campaigns.
The isolated drill checkpoint explicitly preserves its old decoder fixture;
seed6908 is a selected reference fixture, not an inferred original DOS seed.

Native0.7 passes245 integration checks, including all3,200 cases rendered through
the real NativeGameView code, exact seed-one startup fixtures,240 combinations
of rank tier/math level/operation mask, decoder/fountain ordering, migration,
and repeatable chart generation/resume. Native-window verification separately
shows the original-selected Junior bar question accepting165 for300points.
The complete game remains unfinished: ending encounter, session progression,
menus/options, transitions, timed effects, palette and full-playthrough validation
remain required.
