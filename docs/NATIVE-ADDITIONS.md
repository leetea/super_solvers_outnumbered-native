# Native additions and original behavior

This note records the original-versus-native comparison clarified during the
October 28, 2026 play test. It supersedes the earlier description of the music
restart as an original-game fidelity bug.

| Behavior | Original DOS game | Native macOS app |
|---|---|---|
| Music after an interrupting action sound | The tune restarts, as confirmed by the user's original-game reference and play test. | The locally delivered **1.0.2** resumes the tune from its interrupted position. This is an **added native enhancement**, not recovered original behavior. |
| Jumping in place | The original on-screen guidance lists **Up alone**, and the captured original-code analysis contains a vertical jump with zero horizontal movement. | **Up alone**, when an interaction does not take precedence, performs a stationary jump. The capability is present in the original evidence, so it is not classified as a new native feature. |

## Music resume enhancement

The native change preserves the music cursor while an accepted action sound
plays, then resumes that tune on its next normal request. The original sound
priorities and separate Music/Sound controls remain in force. A different tune,
an explicit scene stop, or disabling audio clears the saved cursor.

The user confirmed that 1.0.2 sounds correct, then supplied an original-game
reference showing that restarting the music was itself original behavior.
Accordingly, retaining the cursor is a deliberate native convenience. Earlier
release notes that call it a fix should be read with that qualification.

## Stationary jump clarification

The user observed that jumping worked only while moving left or right in their
original-game test and asked to identify the native stationary jump as added.
That observation is retained here, but the supplied reference contains contrary
evidence: its opening New User Message lists Up alone as a jump control.

The previously captured original-code analysis also supports a stationary jump:
the Up dispatch can reach `FUN_135d_0001`, which calls
`FUN_11b0_13b9(0xfff4, 0, 0xffff, 8)`. This requests jump animation 8 with
vertical step -12 and horizontal step 0. The original interaction dispatch
`FUN_11b0_0d3a` determines whether Up uses an object or takes that jump path.
See [player motion recovery](player-impact-recovery.md) and
[keyboard recovery](keyboard-recovery.md).

Thus, the reference test's inability to jump in place remains an observed
difference to investigate; it does not establish that the original lacked the
capability. Directional jumps/flips use Up with Left or Right. Space is the zap
control.

## Version and evidence scope

The music enhancement described here is in the locally delivered macOS 1.0.2
app. This documentation commit does not replace the repository's 1.0 source
snapshot or rebuild/publish the Windows executable.

The supplied reference recording was inspected locally. The recording and
original game assets are not uploaded with this note.
