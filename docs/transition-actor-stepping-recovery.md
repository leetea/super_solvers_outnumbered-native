# Transition actor stepping (0.17 candidate)

Read-only evidence: game-pseudocode.c11b0:148a,1559,1732;135d:072b,0a1c,039b,0243,09af;1592:0078. No original executable is run or modified.

1559(0) disables new Telly spawning but still performs the initial rand(1,1000) whenever Telly is absent. Existing Telly walks/animates/throws; the player updates next, then any projectile, LiveWire and energy-machine actor. The existing OriginalTelly engine already implements the unconditional draw; the native transition loops previously omitted calling it.

Room entry/exit has one1559 call per alignment frame,21 pose/panel calls, and one additional room-entry LiveWire spawn attempt. For an absent Telly, entry therefore draws alignmentCount+22 random values, exit alignmentCount+21. Existing Telly can draw more according to recovered standing/walking/throw rules; an independently forced far-walking test stays outside its stop interval for12 updates, moves35 to23 and consumes24 values.

Elevators have alignmentCount+34 pose/panel updates.039b additionally clears Telly/projectile and calls148a(0) once after closing and before travel sound. Thus an absent enemy draws alignmentCount+35 values. The eight scroll bands do not call1559. The extra cleanup update is coalesced at the first scroll boundary; its unpaced memory copy introduces no new native timed frame. This preserves the existing saved timeline.

TransitionActors.swift calls Telly with allowSpawning=false, then player step sound, projectile and LiveWire. It does not run the main-loop collision dispatcher during the synchronous sequence. Alignment retains the original facing until the rear pose explicitly forces right, including backwards alignment walking. Actor context uses player X before the pose movement.

NativeDoorTransition and NativeElevatorTransition have an optional auxiliaryFramesApplied cursor. New sequences apply the first update before the first frame is presented, then process each newly crossed frame exactly once, independent of timer batching. The saved cursor prevents duplicate RNG, projectile or wire motion on restore. Missing cursors in0.15/0.16 saves skip already displayed frames; past RNG is not replayed or claimed to be repaired retroactively.

582 checks pass locally, including absent-enemy draw totals for entry/exit and all4elevators; active walking Telly; projectile motion/lifetime crossing the player without a main-loop collision; LiveWire motion during exit; large-vs-small timer-step equivalence; legacy cursor migration; no duplicate sub-frame update. Existing doorway/elevator suites remain green.

Limits: detailed camera/scroll edge behavior, boundary impact, original auxiliary energy-machine eye animation and full actor rendering/occlusion remain separate work. Native profile historical seeds are not claimed to match the recording. These checks are static-source-driven native evidence, not an original DOS runtime trace.
