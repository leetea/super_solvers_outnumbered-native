# Music and new-user messages — milestone0.12

The original sound gate1bda:0580 (linear1c320) requires DS434e nonzero for every
stream. Streams0..5 additionally require DS4348 zero. Thus Sound is the master
switch; Music independently enables the first six streams. The original signed
priority comparison still applies. Music Off170d:08aa calls0c4a(0), stops whatever
is playing, then sets4348=1; Music On clears4348 without starting a stream.
Sound Off170d:08e7 calls0c4a(1), clearing434e and stopping playback. Sound On sets
434e=1. Original dialogs3512/3520 say "Do you want the Music/Sound on?" and use
No/Yes indices0/1. Native checkboxes expose the same independent gates.

Opening routine1a4e:00b4 (1a594) repeatedly requests stream0 while waiting on
the title/credits. Native title ticks now request0, respecting playback/priority
and switches. Existing recovered ending/script sound triggers use the same gate.
This does not complete original opening credits/animation or establish perceptual
audio parity. The52 existing PC-speaker approximations are unchanged.

## Message data and state

All18 original strings come from the far-pointer table DS136b in the immutable
unpacked analysis EXE, SHA256
ff2e0d28e0a6aa8bcf86db1ea8a2980d2ccb1e10dd793bc15ab1bb929697b464.
export_tutorials.py regenerates only the runtime Swift array and source-offset
JSON. Original CR line breaks/keycap characters remain in source text. Native
dialogs substitute readable bracketed key names for the original bitmap keycaps.
This is accessible macOS presentation, not DOS dialog pixel parity.

Original5bd7..5be8 contains18 state bytes:0 unseen,1 queued,ff acknowledged.
5bef enables messages. Both ranges lie within the103-byte saved adventure block
5b8a..5bf0;1a01:000f/0070 restore/save this block. Optional native session state
preserves these fields and reads old saves without them. Native pending idle
deadlines are also retained for resumed native input; that is native persistence
infrastructure rather than a byte-compatible DOS save format.

170d:02f6 queues only an unseen message. 022a scans only indices0..12, in order,
and shows at most one when actors are settled. 029a shows an enabled message
unless already acknowledged and marks it after dismissal. 030a replaces the
single timed request;032e checks strictly after its deadline. 035a cancels the
request and marks it seen even when disabled. Selecting Yes in the original
New User Messages option clears all18 states; selecting No preserves states.
New trainees start enabled. Practice uses a separate native state so it cannot
change the suspended adventure, consistent with native practice isolation.

## Recovered triggers connected natively

-0: clock reaches9:02 PM. Queued11: an energy update below6. Queued12: a clock update after10:00 PM when
  the player still lacks any code or any room clues.
-1/2/6: thrown trick/Telly body/LiveWire collisions. Queue4: empty energy supply.
 5: room entry. 3: captured code after drill return. 13: first decoder opening.
-9/10: entering a room challenge without/with calculator. 7/14: leaving a
 resolved correct/failed challenge with earned room clues.
-8:720IRQ ticks of idle drill input, canceled by first input. 15/16:1200IRQ
 ticks of idle custom game/practice settings, canceled by input. Native settings
 use a modal run-loop timer with the recovered nominal duration.
-17: trainee welcome during native player selection, corresponding to the
 original sign-in welcome's direct use of the trainee text.

Native reference checkpoints suppress automatic messages. Existing mechanics
fixtures explicitly disable automatic presentation; separate injected-presenter
checks exercise the production message/state/pause/save path without opening
headless Cocoa alerts. Real native-window observations are a separate gate.

## Limits still preventing full-game completion

The queue's exact actor-settled timing will need refinement with original
knockback/transition animations. Native settings/dialogs and welcome/sign-in
presentation differ from DOS pixels and keyboard focus. Opening credits, full
File lifecycle, practice interstitials, timed activity effects, transitions,
palette/masking, ending/rank refinements, calibrated sound and a complete natural
playthrough remain required. Original ZIP/video inputs are never modified.

Resetting messages does not replay past clock/energy events without a new update.
Practice guidance persists across sets for the selected player while remaining
separate from adventure flags; nested practice-setup messages do not pause or
rewrite the suspended clock state.

Native-window verification caught and removed an unnecessary save from practice
guidance. Final checks compare both session values and the actual adventure file
bytes. Practice guidance never writes the suspended adventure.
