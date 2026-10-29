import Foundation

func nativeDrillPresentationChecks(root: URL,output: URL) throws -> [String:Bool] {
    var checks: [String:Bool] = [:]
    var intro = NativeDrillPresentation(), sounds: [NativeDrillPresentation.Sound] = [], sprites: [Int] = []
    sounds += intro.advance(irqTicks: 0).sounds
    for _ in 0..<160 { sprites.append(intro.sprite);sounds += intro.advance(irqTicks: 1).sounds }
    checks["drill_intro_eight_twenty_IRQ_original_frames"] = sprites == (0..<8).flatMap { Array(repeating: 10+$0%2,count: 20) } && intro.stage == .questions && intro.valid
    checks["drill_intro_eight_sound23_requests_then_stop"] = sounds == Array(repeating: .play(23),count: 8)+[.stop]
    var capture = NativeDrillPresentation();capture.beginResult(success: true)
    sounds = [];sprites = []
    for _ in 0..<350 { sprites.append(capture.sprite);sounds += capture.advance(irqTicks: 1).sounds }
    checks["drill_capture_seven_fifty_IRQ_original_frames"] = sprites == (3...9).flatMap { Array(repeating: $0,count: 50) } && capture.stage == .result && capture.valid
    checks["drill_capture_seven_sound48_requests_without_extra_stop"] = sounds == Array(repeating: .play(48),count: 7)
    var batched = NativeDrillPresentation();batched.beginResult(success: true)
    let batch = batched.advance(irqTicks: 999)
    checks["drill_capture_coarse_pulse_retains_remaining_time"] = batch.consumed == 350 && batch.sounds == sounds && batched.stage == capture.stage
    var partial = NativeDrillPresentation();partial.beginResult(success: true);_ = partial.advance(irqTicks: 175)
    partial = try JSONDecoder().decode(NativeDrillPresentation.self,from: JSONEncoder().encode(partial))
    checks["drill_partial_capture_does_not_repeat_frame_sound"] = partial.valid && partial.sprite == 6 && partial.advance(irqTicks: 0).sounds.isEmpty && partial.advance(irqTicks: 25).sounds == [.play(48)]
    partial.elapsedIRQTicks = 350
    checks["drill_invalid_animation_cursor_rejected"] = !partial.valid
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent("outnumbered-drill-presentation-"+UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let view = try NativeGameView(root: root,saveDirectory: directory,automaticallyPresentMessages: false)
    view.timer?.invalidate();view.zapTimer?.invalidate();view.soundEnabled = false;view.referenceDrill()
    let before = view.session.generator.randomState
    try view.render();try view.canvas.writePNG(to: output.appendingPathComponent("native-telly-introduction.png"))
    try view.advanceDrill(irqTicks: 159)
    checks["drill_intro_has_no_question_timer_or_rng_updates"] = view.session.activeDrill?.presentation?.elapsedIRQTicks == 159 && view.session.activeDrill?.ticksRemaining == 240 && view.session.generator.randomState == before && view.session.valid
    try view.advanceDrill(irqTicks: 240)
    checks["drill_first_question_wait_follows_intro_without_lost_tick"] = view.session.activeDrill?.presentation?.stage == .questions && view.session.activeDrill?.phase == .between && view.session.activeDrill?.ticksRemaining == 1
    try view.advanceDrill(irqTicks: 1)
    checks["drill_first_question_at_four_hundred_IRQ"] = view.session.activeDrill?.phase == .asking
    func answer(_ correct: Bool) throws {
        var drill = view.session.activeDrill!, generator = view.session.generator
        drill.input = String(correct ? drill.question.expected : 999)
        _ = drill.submit(nextRandom: { generator.nextRandomValue() })
        view.session.activeDrill = drill;view.session.generator = generator
        try view.advanceDrill(irqTicks: correct ? 480 : 1200)
    }
    for i in 0..<6 { try answer(true);if i < 5 { try view.advanceDrill(irqTicks: 120) } }
    checks["drill_success_starts_card_before_secret_or_hundred_point_award"] = view.session.activeDrill?.presentation?.stage == .capture && view.session.activeDrill?.presentation?.elapsedIRQTicks == 0 && view.session.score == 900 && view.session.decoder.capturedCount == 0 && view.session.valid
    try view.advanceDrill(irqTicks: 175)
    try view.render();try view.canvas.writePNG(to: output.appendingPathComponent("native-telly-spinning-code.png"))
    checks["drill_card_clear_rectangle_uses_video_black_background"] = view.canvas.pixels[53*320+152] == 1 && view.canvas.pixels[54*320+191] == 1
    let stable = JSONEncoder();stable.outputFormatting = .sortedKeys
    let enemy = try stable.encode(view.session.telly), wire = try stable.encode(view.session.liveWire), rng = view.session.generator.randomState
    view.session = try JSONDecoder().decode(NativeSession.self,from: stable.encode(view.session!))
    try view.advanceDrill(irqTicks: 174)
    checks["drill_partial_capture_restore_waits_last_IRQ_before_reward"] = view.session.activeDrill?.presentation?.elapsedIRQTicks == 349 && view.session.score == 900 && view.session.decoder.capturedCount == 0 && view.session.valid
    try view.advanceDrill(irqTicks: 1)
    checks["drill_card_completion_awards_once_then_full_720_IRQ_wait"] = view.session.score == 1000 && view.session.decoder.capturedCount == 1 && view.session.activeDrill?.capturedSymbol == 11 && view.session.activeDrill?.resultTicksRemaining == 720 && view.session.valid
    checks["drill_capture_freezes_world_actors_and_rng"] = try stable.encode(view.session.telly) == enemy && stable.encode(view.session.liveWire) == wire && view.session.generator.randomState == rng
    view.finishDrill();view.session = try JSONDecoder().decode(NativeSession.self,from: stable.encode(view.session!));view.finishDrill()
    checks["drill_reward_not_repeated_after_result_restore"] = view.session.score == 1000 && view.session.decoder.capturedCount == 1
    try view.advanceDrill(irqTicks: 719)
    checks["drill_success_result_keeps_last_IRQ"] = view.screen == .drill && view.session.activeDrill?.resultTicksRemaining == 1
    try view.advanceDrill(irqTicks: 1)
    checks["drill_success_returns_to_world_at_deadline"] = view.screen == .world && view.session.activeDrill == nil
    view.referenceDrill();try view.advanceDrill(irqTicks: 400);view.session.activeDrill?.abort();try view.advanceDrill(irqTicks: 0)
    checks["drill_escape_starts_rejection_intro_before_message"] = view.session.activeDrill?.presentation?.stage == .rejection && view.session.activeDrill?.rewardApplied == false && view.session.valid
    try view.advanceDrill(irqTicks: 159);view.finishDrill()
    checks["drill_rejection_cannot_award_or_skip_animation"] = view.session.activeDrill?.rewardApplied == false && view.session.activeDrill?.resultTicksRemaining == 0
    try view.advanceDrill(irqTicks: 1)
    checks["drill_rejection_muted_sound_gate_and_full_480_IRQ_wait_after_intro"] = view.lastSoundIndex == nil && view.session.activeDrill?.rewardApplied == true && view.session.activeDrill?.resultTicksRemaining == 480 && view.session.score == 600 && view.session.valid
    try view.render();try view.canvas.writePNG(to: output.appendingPathComponent("native-telly-no-code.png"))
    if let event = GameInputEvent.keyEvent(with: .keyDown,location: .zero,modifierFlags: [],timestamp: 0,windowNumber: 0,context: nil,characters: "\r",charactersIgnoringModifiers: "\r",isARepeat: false,keyCode: 36) { view.keyDown(with: event) }
    checks["drill_return_does_not_skip_source_result_wait"] = view.session.activeDrill?.resultTicksRemaining == 480 && view.screen == .drill
    try view.advanceDrill(irqTicks: 479)
    checks["drill_rejection_last_IRQ_preserved"] = view.session.activeDrill?.resultTicksRemaining == 1
    try view.advanceDrill(irqTicks: 1)
    checks["drill_rejection_returns_without_code_or_points"] = view.screen == .world && view.session.activeDrill == nil && view.session.decoder.capturedCount == 0 && view.session.score == 600
    var legacy = try NativeDrill(tier: 0,nextRandom: { 0 });_ = try legacy.advance(irqTicks: 240,nextRandom: { 0 })
    legacy = try JSONDecoder().decode(NativeDrill.self,from: stable.encode(legacy))
    checks["drill_legacy_missing_presentation_keeps_question_phase"] = legacy.valid && legacy.presentation == nil && legacy.phase == .asking
    var practice = try NativeDrill(tier: 0,nextRandom: { 0 },practice: true);_ = try practice.advance(irqTicks: 240,nextRandom: { 0 })
    checks["drill_practice_does_not_gain_second_adventure_intro"] = practice.valid && practice.presentation == nil && practice.phase == .asking
    view.session = NativeSession(profileID: UUID(),seed: 1);view.screen = .world
    var moving = NativePlayerMotion();moving.walk(true);view.playerMotion = moving
    view.beginZap();view.session.activeZap?.elapsedIRQTicks = 90;view.pulseZap()
    checks["zap_completion_resets_requested_walk_motion_before_next_frame"] = view.playerMotion.animation == 1 && view.playerMotion.horizontal == 0 && view.playerMotion.vertical == 0 && view.session.activeZap == nil && view.session.energy == 11 && view.session.valid
    return checks
}
