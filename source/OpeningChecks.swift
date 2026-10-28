import Cocoa

func nativeOpeningChecks(root: URL,output: URL) throws -> [String:Bool] {
    var checks: [String:Bool] = [:],opening = NativeOpeningPresentation()
    checks["opening_original24_lines_and40_commands"] = OriginalOpening.lines.count == 24 && OriginalOpening.lines[0] == "The Master of Mischief" && OriginalOpening.lines[23] == "correctly and you win the game!" && OriginalOpening.scripts.map(\.count) == [12,9,19]
    checks["opening_original_script_wait_sums320_160_1080"] = OriginalOpening.scripts.map { script in script.filter { $0.resource >= 0 }.reduce(0) { $0+$1.waitFrames*40 } } == [320,160,1080]
    _ = opening.advance(11999)
    checks["opening_title_original12000IRQ_hold"] = opening.stage == .title && opening.elapsed == 11999
    _ = opening.advance(1)
    checks["opening_title_timeout_enters_gray_wipe"] = opening.stage == .objectiveWipe && opening.elapsed == 0
    _ = opening.advance(23)
    checks["opening_gray_wipe_last24IRQ"] = opening.stage == .objectiveWipe
    _ = opening.advance(1)
    checks["opening_objective_after_wipe"] = opening.stage == .objective && opening.elapsed == 0
    _ = opening.advance(12024)
    checks["opening_objective_timeout_enters_telly_page"] = opening.stage == .telly
    _ = opening.advance(12000)
    checks["opening_third_timeout_repeats_title_without_skipping_intro"] = opening.stage == .title && opening.elapsed == 0
    opening.enter();_ = opening.advance(24);opening.enter();_ = opening.advance(24);opening.enter()
    checks["opening_three_enters_start_animation_wipe"] = opening.stage == .animationWipe
    _ = opening.advance(24)
    checks["opening_animation_begins_after_gray_wipe"] = opening.stage == .animation && opening.elapsed == 0
    let sounds = opening.sounds
    checks["opening_original_music_stop_restart_and_sound11_boundaries"] = sounds.map(\.at) == [120,120,320,320,320,320,480,480,1560] && sounds.map(\.cue) == [.stop,.sound(11),.stop,.sound(0),.stop,.sound(11),.stop,.sound(0),.stop]
    opening.enter()
    checks["opening_animation_ignores_enter"] = opening.stage == .animation && opening.elapsed == 0
    _ = opening.advance(119)
    checks["opening_first_flight_sound_waits_for_frame_boundary"] = opening.appliedSounds == 0
    let firstSound = opening.advance(1)
    checks["opening_first_flight_sound_at120_once"] = firstSound == [.stop,.sound(11)] && opening.advance(0).isEmpty
    var precise = opening,batched = opening
    var fineCues: [NativeOpeningPresentation.Cue] = []
    for _ in 0..<1440 { fineCues += precise.advance(1) }
    let batchCues = batched.advance(1440)
    checks["opening_coarse_fine_pulses_same_completion_cues"] = precise.stage == .finished && batched.stage == .finished && fineCues == batchCues && batchCues.last == .finished
    checks["opening_finished_cannot_repeat_sound_or_completion"] = batched.advance(10000).isEmpty
    var cancel = NativeOpeningPresentation();_ = cancel.advance(7000);cancel.restartWait()
    checks["opening_cancel_exit_restarts_same_page_deadline"] = cancel.stage == .title && cancel.elapsed == 0
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent("outnumbered-opening-"+UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let view = try NativeGameView(root: root,saveDirectory: directory,automaticallyPresentMessages: false)
    view.timer?.invalidate();view.zapTimer?.invalidate();view.soundEnabled = false
    _ = try view.profileStore.create(name: "Opening Check")
    view.referenceQuestion();let sessionBefore = try JSONEncoder().encode(view.session!)
    let randomBefore = view.session.generator.randomState
    view.screen = .title;view.resetOpening();try view.render()
    try view.canvas.writePNG(to: output.appendingPathComponent("native-opening-title.png"))
    let titleBase = NativeCanvas();titleBase.draw(try view.content.bitmap("OPENING.GRA.000"),x: 0,y: 0)
    var promptPixels = 0
    for y in 146..<156 { for x in 40..<220 where view.canvas.pixels[y*320+x] != titleBase.pixels[y*320+x] { promptPixels += 1 } }
    checks["opening_title_has_original_enter_keycap_prompt"] = promptPixels > 100
    view.opening.enter();try view.render()
    checks["opening_gray_wipe_exact_original_panel_bounds"] = view.canvas.pixels[16*320+18] == 7 && view.canvas.pixels[159*320+236] == 7 && view.canvas.pixels[160*320+236] != 7
    view.advanceOpening(24);try view.render();try view.canvas.writePNG(to: output.appendingPathComponent("native-opening-objective.png"))
    let firstPage = view.canvas.pixels
    view.opening.enter();view.advanceOpening(24);try view.render();try view.canvas.writePNG(to: output.appendingPathComponent("native-opening-telly.png"))
    checks["opening_two_story_pages_distinct_and_fixed_white_panel"] = firstPage != view.canvas.pixels && view.canvas.pixels[158*320+235] == 15
    view.opening.enter();view.advanceOpening(24)
    let priorPulse = view.openingLastPulse
    view.keyDown(with: NSEvent.keyEvent(with: .keyDown,location: .zero,modifierFlags: [],timestamp: 0,windowNumber: 0,context: nil,characters: "x",charactersIgnoringModifiers: "x",isARepeat: false,keyCode: 7)!)
    checks["opening_ignored_animation_keys_do_not_reset_real_time_clock"] = view.openingLastPulse == priorPulse
    for ticks in [0,120,320,480,1080,1559] {
        view.opening.elapsed = ticks;try view.render();let before = view.canvas.pixels;try view.render()
        checks["opening_animation_repaint_stable_at_\(ticks)"] = before == view.canvas.pixels && view.session.generator.randomState == randomBefore
        try view.canvas.writePNG(to: output.appendingPathComponent("native-opening-animation-\(ticks).png"))
    }
    view.opening.elapsed = 0;view.opening.appliedSounds = 0
    view.advanceOpening(1560)
    checks["opening_finishes_in_signin_without_adventure_changes"] = view.screen == .signin && view.session.generator.randomState == randomBefore && view.session.score == 0 && view.session.clock.elapsedMinutes == 0
    let restoredBefore = try JSONDecoder().decode(NativeSession.self,from: sessionBefore)
    checks["opening_preserves_prior_question_and_decoder"] = view.session.activeChallenge?.id == restoredBefore.activeChallenge?.id && view.session.decoder == restoredBefore.decoder
    view.screen = .menu;view.activatePlayerMenu(-1)
    checks["opening_play_menu_escape_returns_to_signin"] = view.screen == .signin
    return checks
}
