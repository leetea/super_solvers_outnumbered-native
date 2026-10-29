import Foundation

func nativeActivityPresentationChecks(root: URL,output: URL) throws -> [String:Bool] {
    var checks: [String:Bool] = [:]
    let bank = try JSONDecoder().decode(ChallengeBank.self,from: Data(contentsOf: root.appendingPathComponent("challenges.json")))
    let content = OriginalContent(root: root),renderer = ActivityMore(content: content),a = NativeCanvas(),b = NativeCanvas()
    for hotspot in [1,5,8,9] {
        var complete = 0,ordered = true
        for challenge in bank.cases where challenge.hotspot == hotspot {
            let plan = try NativeActivityPlan(challenge)
            a.clear();b.clear()
            _ = try renderer.draw(challenge,on: a)
            _ = try renderer.draw(challenge,on: b,progress: plan.frame(at: plan.duration))
            if a.pixels == b.pixels { complete += 1 }
            ordered = ordered && plan.frames.map(\.at) == plan.frames.map(\.at).sorted() && plan.sounds.map(\.at) == plan.sounds.map(\.at).sorted() && plan.duration > 0
        }
        checks["activity_\(hotspot)_all_320_timeline_endpoints_equal_static_content"] = complete == 320
        checks["activity_\(hotspot)_all_320_timeline_events_ordered_and_bounded"] = ordered
    }
    let bar = bank.cases.first { $0.id == 9010 && $0.seed == 1 && $0.variant == 0 }!
    let bars = try NativeActivityPlan(bar)
    checks["bar_original_32_16_48_16_row_fixture_duration_668_IRQ"] = bars.duration == 668 && bars.frame(at: 0).marks == [1,0,0,0] && bars.frame(at: 14).marks == [1,0,0,0] && bars.frame(at: 15).marks == [2,0,0,0]
    checks["bar_scanline_wait_precedes_outline_and_next_bar"] = bars.frame(at: 186).completed == 0 && bars.frame(at: 187).completed == 1 && bars.frame(at: 187).marks == [32,1,0,0]
    checks["bar_sound27_stop_order_at_original_row_boundaries"] = bars.sounds == [.init(at: 0,index: 27),.init(at: 187,index: nil),.init(at: 187,index: 27),.init(at: 294,index: nil),.init(at: 294,index: 27),.init(at: 561,index: nil),.init(at: 561,index: 27),.init(at: 668,index: nil)]
    let sliders = bank.cases.first { $0.id == 9145 && $0.seed == 9 && $0.variant == 3 }!
    let slider = try NativeActivityPlan(sliders)
    checks["slider_waits_before_first_needle_then_accelerates"] = slider.frame(at: 89).marks == [-1,-1,-1] && slider.frame(at: 90).marks == [0,-1,-1] && slider.frame(at: 134).marks == [0,-1,-1] && slider.frame(at: 135).marks == [1,-1,-1]
    checks["slider_original_873_fixture_endpoint"] = try (24...26).map { try sliders.originalWord(at: $0) } == [8,7,3] && slider.frame(at: slider.duration).marks == [72,63,27]
    let chart = bank.cases.first { $0.id == 9068 && $0.seed == 7 && $0.variant == 3 }!
    let plot = try NativeActivityPlan(chart)
    checks["plot_first_two_points_precede_first_150_IRQ_wait"] = plot.frame(at: 0).marks == [2,0] && plot.frame(at: 149).marks == [2,0] && plot.frame(at: 150).marks == [3,0]
    checks["plot_second_series_starts_after_four_waits"] = plot.frame(at: 599).marks == [5,0] && plot.frame(at: 600).marks == [5,2] && plot.duration == 1200 && plot.sounds.filter { $0.index == 29 }.count == 8
    let tapes = bank.cases.first { $0.id == 9130 && $0.seed == 1 && $0.variant == 0 }!
    let tape = try NativeActivityPlan(tapes)
    checks["cassette_original_D_C_B_A_reveal_deadlines"] = tape.duration == 180 && tape.frame(at: 0).marks == [0,0,0,1] && tape.frame(at: 59).marks == [0,0,0,1] && tape.frame(at: 60).marks == [0,0,1,1] && tape.frame(at: 110).marks == [0,1,1,1] && tape.frame(at: 150).marks == [1,1,1,1]
    checks["cassette_original_sound32_then_stop_per_row"] = tape.sounds == [.init(at: 0,index: 32),.init(at: 60,index: nil),.init(at: 60,index: 32),.init(at: 110,index: nil),.init(at: 110,index: 32),.init(at: 150,index: nil),.init(at: 150,index: 32),.init(at: 180,index: nil)]
    var cursor = NativeActivityPresentation(chart),allSounds = cursor.advance(irqTicks: 0,plan: plot)
    for _ in 0..<1200 { allSounds += cursor.advance(irqTicks: 1,plan: plot) }
    var coarse = NativeActivityPresentation(chart)
    checks["activity_one_IRQ_and_coarse_pulses_issue_identical_sound_order"] = coarse.advance(irqTicks: 10000,plan: plot) == allSounds && coarse.elapsedIRQTicks == 1200 && coarse.appliedSoundCount == cursor.appliedSoundCount
    var saved = NativeActivityPresentation(chart);_ = saved.advance(irqTicks: 175,plan: plot)
    saved = try JSONDecoder().decode(NativeActivityPresentation.self,from: JSONEncoder().encode(saved))
    checks["activity_restore_does_not_reissue_current_sound"] = saved.valid(for: chart) && saved.advance(irqTicks: 0,plan: plot).isEmpty && saved.advance(irqTicks: 125,plan: plot) == [.init(at: 300,index: nil),.init(at: 300,index: 29)]
    saved.appliedSoundCount = 0
    checks["activity_inconsistent_saved_sound_cursor_rejected"] = !saved.valid(for: chart)
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent("outnumbered-activity-presentation-"+UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let view = try NativeGameView(root: root,saveDirectory: directory,automaticallyPresentMessages: false)
    view.timer?.invalidate();view.zapTimer?.invalidate();view.soundEnabled = false;view.referenceMode = true
    view.session = NativeSession(profileID: UUID(),seed: 1,lifetimePoints: 30000)
    view.session.position = NativePosition(scene: 13,playerUnit: 15,cameraUnit: 0,facing: 1);view.screen = .world
    view.open(chart)
    let rng = view.session.generator.randomState,minute = view.session.clock.elapsedMinutes
    let stable = JSONEncoder();stable.outputFormatting = .sortedKeys
    let telly = try stable.encode(view.session.telly),wire = try stable.encode(view.session.liveWire),camera = try stable.encode(view.session.roomCamera)
    checks["activity_open_runs_native_timeline_and_defers_answer_panel"] = view.isActivityPresenting && view.isTransitioning && view.session.valid && view.session.activityPresentation?.elapsedIRQTicks == 0
    view.questionCharacter("9");view.submitQuestion();view.calculatorKey(.digit(2))
    if let escape = GameInputEvent.keyEvent(with: .keyDown,location: .zero,modifierFlags: [],timestamp: 0,windowNumber: 0,context: nil,characters: "\u{1b}",charactersIgnoringModifiers: "\u{1b}",isARepeat: false,keyCode: 53) { view.keyDown(with: escape) }
    checks["activity_blocks_early_answers_calculator_and_escape"] = view.session.attempts[8]?.input == "" && view.session.attempts[8]?.wrongAnswers == 0 && view.screen == .question && view.session.score == 0
    try view.render();try view.canvas.writePNG(to: output.appendingPathComponent("native-cartoon-plot-start.png"))
    checks["activity_question_side_stays_black_during_source_intro"] = (19..<158).allSatisfy { y in (188..<312).allSatisfy { x in view.canvas.pixels[y*320+x] == 1 } }
    let initial = view.canvas.pixels
    try view.advanceActivityPresentation(irqTicks: 600)
    try view.render();try view.canvas.writePNG(to: output.appendingPathComponent("native-cartoon-plot-second-series.png"))
    checks["activity_timed_repaint_changes_chart_before_question_panel"] = initial != view.canvas.pixels && view.session.activityPresentation?.elapsedIRQTicks == 600
    view.session = try JSONDecoder().decode(NativeSession.self,from: stable.encode(view.session!))
    checks["activity_partial_session_save_valid_at_second_series"] = view.session.valid && view.session.activityPresentation?.elapsedIRQTicks == 600 && view.session.activityPresentation?.appliedSoundCount == 9
    try view.advanceActivityPresentation(irqTicks: 599)
    checks["activity_question_remains_locked_through_last_wait_IRQ"] = view.isActivityPresenting && view.session.activityPresentation?.elapsedIRQTicks == 1199
    try view.advanceActivityPresentation(irqTicks: 1)
    checks["activity_completion_unlocks_question_without_advancing_game_minutes"] = !view.isActivityPresenting && !view.isTransitioning && view.screen == .question && view.session.clock.elapsedMinutes == minute && view.session.valid
    checks["activity_timeline_has_no_actor_or_rng_updates"] = try stable.encode(view.session.telly) == telly && stable.encode(view.session.liveWire) == wire && stable.encode(view.session.roomCamera) == camera && view.session.generator.randomState == rng
    try view.render();try view.canvas.writePNG(to: output.appendingPathComponent("native-cartoon-plot-ready.png"))
    view.session.calculatorEnabled = false;view.questionCharacter("0");view.submitQuestion()
    checks["activity_answer_after_presentation_awards_original_300_once"] = view.session.score == 300 && view.session.attempts[8]?.result == .correct
    view.leaveQuestion()
    checks["activity_departure_clears_presentation_state"] = view.session.activeChallenge == nil && view.session.activityPresentation == nil && view.session.valid
    view.open(bar);view.session.activityPresentation = nil
    let legacy = try JSONDecoder().decode(NativeSession.self,from: stable.encode(view.session!))
    checks["activity_legacy_save_without_timeline_does_not_replay_intro"] = legacy.valid && legacy.activeChallenge?.id == 9010 && legacy.activityPresentation == nil
    return checks
}
