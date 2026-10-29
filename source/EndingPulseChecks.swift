import Foundation

func nativeEndingPulseChecks(root: URL,output: URL) throws -> [String:Bool] {
    var checks: [String:Bool] = [:]
    let view = try NativeGameView(root: root,saveDirectory: output.appendingPathComponent("ending-pulse-"+UUID().uuidString),automaticallyPresentMessages: false)
    view.timer?.invalidate();view.zapTimer?.invalidate();view.soundEnabled = false
    view.referenceEnding()
    let state = view.session.generator.randomState,secondsPerTick = VerifiedClock.pitDivisor/VerifiedClock.pitInputHz
    view.lastEndingPulse = 100;view.endingFraction = 0
    view.pulseEnding(now: 100+5.2*secondsPerTick)
    checks["ending_fast_presentation_advances_five_IRQ_without_gameplay_frame"] = view.session.activeEnding?.elapsedTicks == 5
    let before = view.session.activeEnding!.elapsedTicks;view.step()
    checks["ending_gameplay_step_does_not_double_advance_fast_pulse"] = view.session.activeEnding?.elapsedTicks == before
    view.pulseEnding(now: 100+10.4*secondsPerTick)
    checks["ending_fast_pulse_retains_fractional_IRQ_ticks"] = view.session.activeEnding?.elapsedTicks == 10 && abs(view.endingFraction-0.4) < 0.00001
    view.modalDepth = 1;view.pulseEnding(now: 200)
    checks["ending_modal_pause_discards_blocked_wall_time"] = view.session.activeEnding?.elapsedTicks == 10 && view.endingFraction == 0
    view.modalDepth = 0;view.pulseEnding(now: 200+3.2*secondsPerTick)
    checks["ending_resume_does_not_catch_up_modal_time_or_consume_rng"] = view.session.activeEnding?.elapsedTicks == 13 && view.session.generator.randomState == state
    let encoded = try JSONEncoder().encode(view.session!)
    view.session = try JSONDecoder().decode(NativeSession.self,from: encoded)
    view.lastEndingPulse = 300;view.endingFraction = 0
    view.pulseEnding(now: 300+5.1*secondsPerTick)
    checks["ending_fast_clock_resumes_saved_elapsed_without_restarting_timeline"] = view.session.activeEnding?.elapsedTicks == 18 && view.session.valid
    let snapshot = view.session.activeEnding!.elapsedTicks
    view.pulseEnding(now: 299)
    checks["ending_fast_clock_rejects_negative_wall_time"] = view.session.activeEnding?.elapsedTicks == snapshot
    return checks
}
