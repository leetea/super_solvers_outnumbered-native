# Native elevator transition recovery (0.16 candidate)

Original sources: unchanged analysis executable and game-pseudocode.c135d:039b,0243,09af,0bda. Active visual reference: supplied local OutNumbered Gameplay.mkv. No DOS code or graphics-driver code is executed by the native app.

## Schedule

Align to elevator.startUnit+5 using animation2. The unpaced viewport-copy alignment loop uses the same documented4IRQ native presentation interval as room doors. All following timed loops preserve explicit source waits:

- Rear approach9..13 at Y78,75,72,69,66:24IRQ each.
- Open177,176,175,none:23IRQ each; player13 atY66 drawn in front.
- Small rear19..22 atY62,58,54,50:24IRQ each.
- Close175,176,177,178:23IRQ each; small player22 atY50 behind panels.
- Travel in8bands, cumulative18,36,54,72,90,108,126,146pixels:23IRQ each; no player. Sound22 for origin0/4 and21 for5/9, requested once at travel start.
- Destination opening177,176,175,none:23IRQ each; small front23 atY50 behind panels.
- Small front23..26 atY54,58,62,66 and front14..18 atY69,72,75,78,81:24IRQ each.
- Final closing175,176,177,178:23IRQ each; large front18 atY81 in front. Idle faces right for origins0/5, left for4/9.

Destination left screen X12, right24; destination camera starts at scene*38. The candidate retains the current camera model during the approach. Detailed world-scroller/boundary behavior remains separately unverified, including unusual off-centre edge approaches.

## Graphics and scroll

Base179 is96x62 at y53. Left opening begins at (elevator.screenStart+2)*8. A panel's right mirrored partner begins leftX+96-bitmapWidth. SourceDS:5b69 stores bitmap width in4pixel groups; using the decoded pixel width is equivalent. Panels175..178 are16/24/32/48pixels wide; closed178 covers both halves. Base is drawn before the player, then panels before/after the player according to0243's foreground flag. Repainting opaque base after the player would incorrectly erase it even with fully open panels.

135d:039b shifts viewport y14..159 and x0..311. For origins0/4, old image moves down and target image enters at the top, starting with its bottom18rows142..159. Reverse travel moves old image up and target top18rows14..31 enter at the bottom. Final band20 completes146rows. Menu/HUD and the right margin are untouched. NativeCanvas composites each cumulative state from both original backdrops, so restored saves reproduce the same band without storing screenshots.

verification/local-elevator-motion-contact-0.16.png samples local video89..93.833s at6fps,6columns x5rows. It independently shows close/shrink, downward old-room scrolling, cactus destination entering above, front emergence and final close. It confirms stage order/direction, not exact per-frame timing or audio perception.

## Native state

Optional NativeSession.activeElevator stores origin/startUnit/elapsedIRQ and one-time travel-sound/destination flags. Main world stepping, keyboard, mouse and game menus are locked during the source-synchronous sequence. IRQ ticks accumulate without processing displayed minutes until the sequence ends. Destination and final facing apply at the original stage boundaries. Legacy saves omit the new field. Mid-travel restoration is checked for both directions; save files contain state, never original executable code.

## Limits

563 checks pass, and final native-window trips verified both left-side travel directions. Right-side origins and save/resume are headless evidence. Both backplates now include the viewport border and black padding row158 before compositing, preventing a blue seam at the join; render checks cover all three adjoining border rows in both directions. The local frame019 center pixel is near-black at158/159, while160 is blue; compression prevents a bit-exact palette inference. Elevator implementation alone does not finish the full-game goal. Remaining detailed camera/bounds, collision/knockback/occlusion, timed activity effects, opening/File/sign-in, queued inputs, ending refinements, masks/palette and calibrated audio remain explicit work. Actors currently use the native transition freeze policy; original auxiliary actor stepping during synchronous pose loops is not fully matched.
