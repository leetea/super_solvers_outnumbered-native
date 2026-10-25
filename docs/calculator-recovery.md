# Original calculator and native0.5 integration

The calculator is a direct Swift state-machine reconstruction, not a general expression evaluator. Source evidence is unpacked MZ SHA256`ff2e0d28e0a6aa8bcf86db1ea8a2980d2ccb1e10dd793bc15ab1bb929697b464`, original HELP.DAT and retained instruction Evidence. No DOS code was executed.

## Source semantics

- DS7309 states0..4 are empty, first operand, operator selected, second operand, result. Key IDs0..9 are digits,10Enter,11+,12−,13*,14/,15equals,16clear,17delete. DS72ac/72ae retain operands, DS72b0 the current number string, DS72c3 its length, DS72c0 the operator.
-17e4:03dd allows four digits; further digits request sound26. A numeric zero buffer is replaced by the next digit, preventing leading zero accumulation.
- A selected operator clears the input buffer but displays the first operand. Deleting the last digit of the second operand restores this state. Deleting again removes the operator and restores the first number for editing.
- The high-level1e98:02b2 wrapper is essential: before non-digit input it normalizes result state4 to first-operand state1. This permits chaining and editing the result. A digit after a result starts a new number. Looking only at the lower-level key4 branch would incorrectly forbid chaining and clear results on Delete.
-17e4:022c implements addition, nonnegative subtraction, multiplication and integer division. Results above9999 return−4; subtraction below zero returns−3; zero divisor returns−6. Division with remainder displays quotient/r and original whole-number advice, then returns−2. The caller clears arithmetic-error/remainder state. Native alerts retain the original warning text; their Cocoa presentation is new infrastructure.
- Equals works only after a second operand. The original also accepts E/e. Enter submits a plain number or result; it shows original guidance for blank input, missing second operand, or an unevaluated expression. Operators after a second operand require equals first. The calculator uses left-to-right chained operations rather than precedence.
- Original warning strings were extracted from the far-pointer table DS16a5; Enter/equal keycap controls become plain text in native alerts. The original on/off option is exposed as a native Game menu checkbox. Original F3 menu presentation remains incomplete.

## Files and evidence boundary

`Calculator.swift` holds arithmetic, input state, notices and original button glyph bounds. `GameCalculator.swift` integrates keyboard/mouse entry, submission, wrong-answer reset, on/off state and migration of pre0.5 partial numbers. `Session.swift` persists partial expressions separately from DOS assets. The original glyph bounds from DS3714/3738/375c/3780 are expanded by three pixels for native button-face clicks; exact pressed-button animation and digit bitmap rendering remain fidelity gaps.

`calculator-analysis/derivatives.json` identifies all seeded MZ analysis derivatives. Only initial IP/CS bytes20..23 change; code and relocations remain identical. Per-case `math-*-assembly.json`, `key-*-assembly.json`, `delete-*-assembly.json` and `digit-seeded-assembly.json` contain full instruction Evidence. The unseeded `digit-assembly.json` is a not-found error and is not authoritative. Initial broad procedures include contaminated cross-function bodies; the seeded case exports are authoritative. Optional original-session bundle export timed out during automatic permission review; the individual instruction Evidence was retained and work continued. All analysis targets were subsequently closed.

`CalculatorChecks.swift` checks arithmetic/errors, four-digit/zero behavior, operand/result editing, high-level chaining, all17 visible button mappings,3,844 small arithmetic/error combinations, partial-expression saves and old native-number migration. The actual NSView key route is checked with an equals event. Headless checks remain separate from GUI proof.

## Native-window observations

The recorded rainfall fixture was calculated in the live app:832−123 gave709 using the original E shortcut; then on-screen minus, keyboard65 and on-screen equals gave644. Clicking on-screen Enter produced correct feedback and300 points. PNGs `gui-calculator-mouse-644.png` and `gui-calculator-correct-300.png` retain the result.

The computer-use tool's `equal` key token did not evaluate the first expression; its literal`=` token was unsupported. The original missing-equals warning appeared on the subsequent operator. This is recorded as an automation-input limitation, not evidence that physical keyboard equals fails: native equals-event routing passed, and E plus the mouse equals button were observed working. The warning capture is named `gui-calculator-operator-order-warning.png`.

Remaining fidelity work includes original menu/dialog/pressed-button animation, glyph-level comparison and full playthrough/rank validation. Arithmetic and persisted editing are implemented; this does not complete the entire game.
