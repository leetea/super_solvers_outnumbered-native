# Timed charts, measurement controls and cassettes —0.22

The native app now animates four recovered activity families before enabling
answer entry: bars, measurement sliders, one/two-series line charts and video
cassettes. Original code and resources remain read-only. These are Swift data
schedules and native drawing operations, not interpretation of compiled DOS
TEMPLATE code.

## Source evidence and exact wait order

The existing TEMPLATE8502/8514/8520 raw instruction exports are retained in
`template-code-analysis/`. New analysis-only MZ wrappers for8508 and8518 prepend
32bytes without changing their module payload. The focused Ghidra instructions,
pseudocode, input hashes and derivation metadata are retained in
`verification/activity-timing-instructions-0.22.json`. All analysis sessions were
closed. The original INT60 table maps6 to sound request,7 to1ca1:00ab delay,
8 to stop,12 to deadline start and14 to deadline wait. Raw1ca1:00ab instructions
confirm unsigned32-bit elapsed comparison; its earlier decompiler output hid
the changing interrupt counter and must not be read as an infinite loop.

- **Bars8502:**00bf requests sound27 for each bar.0582 grows filled scanlines
  from124 down through the computed top, starting each deadline before drawing
  and waiting `5 + floor(10 / rowOrdinal)` IRQ ticks. Only after the last wait
  does00bf outline the complete bar and stop sound. Zero-height bars still
  execute their outline/request/stop without a growth wait. The recorded
  generated interview fixture has heights32,16,48,16 and waits187,107,267,107,
  totaling668IRQ. Partial bars have no premature black outline.
- **Measurement8508:**00bd requests27 only for a nonzero reading. For each
  column, it loops step0 through `9*reading` inclusive. Each iteration waits
  `floor(90 / (step+1))` IRQ BEFORE restoring the backing strip and drawing
  the original ROOMS18 needle at `136-step`. Thus no first needle appears
  until90IRQ. Columns run left to right and each stops sound afterward,
  including a zero reading. The local Harpsichord8/7/3 fixture uses408,399,344
  IRQ, totaling1151. Native full redraw restores the immutable background
  rather than emulating the original two backing buffers.
- **Line charts8514/8520:**0271/0311 draw the first point immediately, then
  the next line and point before requesting29, waiting150IRQ and stopping.
  The first held image already has two points. Series1 completes before
  series2 begins. A five-point/two-series chart has eight150IRQ waits,
  totaling1200. Original span rasterization and endpoint rounding are retained.
- **Cassettes8518:**003e draws D,C,B,A at106,86,66,46, including each label,
  value and unit. Each row requests32, waits60,50,40,30IRQ respectively and
  stops, totaling180. The question panel follows the final wait.

These four compiled drawing paths contain no drawing-time random requests.
Native opening still restores the recovered post-question-generation stream;
the animation advances neither that stream nor world actors. This does not
claim complete campaign RNG identity: prize flashes and other unresolved
activity/menu paths still need recovery.

## Integration, input and save behavior

`NativeActivityPlan` derives ordered visual and sound events from the original
question fields. `NativeActivityPresentation` stores question identity, elapsed
IRQ count and an applied-sound cursor in the native session. A partial restore
continues from that cursor; repainting has no effects or random draws.

The existing60Hz presentation pulse uses real elapsed time. Normal world-frame
polling is suspended during the presentation, avoiding double counting. IRQ
time continues while displayed game minutes stay paused. Actors freeze, the
question side stays black, and the question panel/calculator/instructions and
new-user question prompt appear after the last wait. Key/mouse answers and
menus are locked during the synchronous sequence. Original BIOS input buffering
is still a separate fidelity task; this milestone ignores early answers rather
than claiming a recovered input queue. Older active-question saves without the
optional presentation retain their existing ready-to-answer state. Re-entering
an unfinished activity runs its original introduction anew.

## Verification and remaining work

31 additional checks bring the total to771. They compare all320 cases for each
of these four families at the timeline endpoint with their previously verified
static rendering (1280 cases), check explicit fixture deadlines and sound order,
coarse/fine pulses, partial save/restore, invalid sound cursors, frozen actors/RNG,
black question area, blocked early input and the ordinary post-animation award.

The local video around107–112seconds shows the two line series drawing in order,
a paused clock and a black question side until completion. Around221–226seconds
it shows the three Harpsichord needles arriving and accelerating left to right
before the question appears. The retained sampling record distinguishes
nominal video times and compressed colors from original IRQ timing.
Native-window observations and headless checks are separate evidence.

This milestone does not finish the game. Prize-price flashes/outlines, television
static, spinner and music/equipment effects, opening/File/sign-in presentation,
queued input, ending/rank/midnight refinements, detailed masks/panel occlusion,
palette/audio calibration and a fresh complete ordinary adventure remain.
Display refresh can coalesce very short original scanline waits; no bit-exact
PC display, driver-memory or perceptual audio claim is made.
