import Cocoa

func nativeActivityEffectsChecks(root: URL,output: URL) throws -> [String:Bool] {
    var checks: [String:Bool] = [:]
    let bank = try JSONDecoder().decode(ChallengeBank.self,from: Data(contentsOf: root.appendingPathComponent("challenges.json")))
    let prize = bank.cases.first { $0.id == 9100 && $0.seed == 1 && $0.variant == 0 }!
    let plan = try NativeActivityPlan(prize)
    let expectedStates: [UInt32] = [4187371143,3359393392,471225640,4130111844,1287908961,260785394,3202116729,1865599700,2715325925,908527603,3639521104,600944149]
    checks["prize_original_eight_flashes_four_reveals_240_IRQ_fixture"] = plan.duration == 240 && plan.randomSteps.map(\.drawCount) == [4,9,17,21,26,31,34,37,38,40,41,54] && plan.randomSteps.map(\.state) == expectedStates
    checks["prize_original_random_selection_text_outline_fixture"] = (0..<8).map { plan.frame(at: $0*20).marks[4] } == [3,0,1,2,3,1,3,1] && (0..<8).map { plan.frame(at: $0*20).marks[5] } == [6,12,6,12,3,11,12,2]
    checks["prize_no_later_random_draws_before_next_flash"] = plan.randomSteps.last(where: { $0.at <= 19 })?.drawCount == 4 && plan.randomSteps.last(where: { $0.at <= 20 })?.drawCount == 9
    checks["prize_final_unique_reveal_order_retains_first_exclusion"] = plan.frame(at: 160).marks.prefix(4) == [0,15,15,15] && plan.frame(at: 180).marks.prefix(4) == [0,15,15,0] && plan.frame(at: 200).marks.prefix(4) == [0,15,0,0] && plan.frame(at: 220).marks.prefix(4) == [0,0,0,0]
    checks["prize_requests31_per_flash_reveal_without_extra_stop"] = plan.sounds.count == 12 && plan.sounds.allSatisfy { $0.index == 31 } && plan.sounds.map(\.at) == Array(stride(from: 0,to: 240,by: 20))
    let content = OriginalContent(root: root),a = NativeCanvas(),b = NativeCanvas()
    for hotspot in [2,3,4,7] {
        var endpoints = 0,valid = true
        for challenge in bank.cases where challenge.hotspot == hotspot {
            let timeline = try NativeActivityPlan(challenge)
            var rng = DecoderGenerator(seed: challenge.post_generation_rng_state!)
            let state = [4,7].contains(hotspot) ? try OriginalActivityState.make(challenge,nextRandom: { rng.nextRandomValue() }) : nil
            a.clear();b.clear()
            if hotspot == 2 {
                _ = try ActivityTemplates(content: content).draw(challenge,on: a)
                _ = try ActivityTemplates(content: content).draw(challenge,on: b,progress: timeline.frame(at: timeline.duration))
            } else {
                _ = try ActivityFinal(content: content).draw(challenge,state: state,on: a)
                _ = try ActivityFinal(content: content).draw(challenge,state: state,on: b,progress: timeline.frame(at: timeline.duration))
            }
            if a.pixels == b.pixels { endpoints += 1 }
            var cursor = NativeActivityPresentation(challenge)
            _ = cursor.advance(irqTicks: timeline.duration,plan: timeline)
            valid = valid && cursor.valid(for: challenge)
            if hotspot == 2 {
                let flashing = timeline.frames.filter { $0.marks[4] >= 0 }
                valid = valid && (5...8).contains(flashing.count) && flashing.allSatisfy { ![0,1,4,8,9,10,14,15].contains($0.marks[5]) } && zip(flashing,flashing.dropFirst()).allSatisfy { $0.marks[4] != $1.marks[4] }
            }
        }
        checks["effect_\(hotspot)_all_320_endpoints_equal_original_static_content"] = endpoints == 320
        checks["effect_\(hotspot)_all_320_saved_cursors_and_source_constraints"] = valid
    }
    let spinner = bank.cases.first { $0.id == 9120 && $0.seed == 1 && $0.variant == 0 }!
    let spin = try NativeActivityPlan(spinner)
    checks["spinner_source_minimum_fourteen_steps_then_selected_six"] = spin.duration == 340 && spin.frame(at: 0).marks == [0] && spin.frame(at: 19).marks == [0] && spin.frame(at: 20).marks == [1] && spin.frame(at: 320).marks == [6]
    checks["spinner_start30_stop_after_selected_wait_without_rng"] = spin.sounds == [.init(at: 0,index: 30),.init(at: 340,index: nil)] && spin.randomSteps.isEmpty
    let music = bank.cases.first { $0.id == 9050 && $0.seed == 1 && $0.variant == 0 }!
    let flash = try NativeActivityPlan(music)
    checks["music_exact_sixteen_header_color_holds_and_720_IRQ"] = flash.duration == 720 && flash.frames.map(\.at) == [0,60,120,140,160,180,200,220,240,300,360,420,480,540,600,660] && flash.frames.map { $0.marks[0] } == (0..<16).map { $0%2 == 0 ? 12 : 14 }
    checks["music_source_sound33_and_stop_without_extra_rng"] = flash.sounds == [.init(at: 0,index: 33),.init(at: 720,index: nil)] && flash.randomSteps.isEmpty
    let supplies = bank.cases.first { $0.id == 9040 && $0.seed == 1 && $0.variant == 0 }!
    let color = try NativeActivityPlan(supplies)
    checks["equipment_eight_fifty_IRQ_phases_no_forced_final_stop"] = color.duration == 400 && color.frames.map(\.at) == [0,50,100,150,200,250,300,350] && color.sounds == [.init(at: 0,index: 34)] && color.randomSteps.isEmpty
    var musicalRNG = DecoderGenerator(seed: music.post_generation_rng_state!)
    let musicRows = try OriginalActivityState.make(music,nextRandom: { musicalRNG.nextRandomValue() })
    a.clear();b.clear();_ = try ActivityFinal(content: content).draw(music,state: musicRows,on: a)
    _ = try ActivityFinal(content: content).draw(music,state: musicRows,on: b,progress: flash.frame(at: 0))
    var changed = 0,outside = false
    for y in 0..<200 { for x in 0..<320 where a.pixels[y*320+x] != b.pixels[y*320+x] {
        changed += 1;if !(12...98).contains(x) || !(36...54).contains(y) || a.pixels[y*320+x] != 14 || b.pixels[y*320+x] != 12 { outside = true }
    } }
    checks["music_flash_replaces_only_original_yellow_in_source_rectangle"] = changed > 0 && !outside
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent("outnumbered-activity-effects-"+UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let view = try NativeGameView(root: root,saveDirectory: directory,automaticallyPresentMessages: false)
    view.timer?.invalidate();view.zapTimer?.invalidate();view.soundEnabled = false;view.referenceMode = true
    view.session = NativeSession(profileID: UUID(),seed: 1,lifetimePoints: 30000);view.session.position = NativePosition(scene: 12,playerUnit: 15,cameraUnit: 0,facing: 1)
    view.open(prize)
    checks["prize_open_applies_only_first_source_rng_checkpoint"] = view.session.generator.randomState == expectedStates[0] && view.session.activityPresentation?.appliedRandomCount == 4 && view.session.valid
    try view.render();try view.canvas.writePNG(to: output.appendingPathComponent("native-prize-first-flash.png"))
    let before = view.session.generator.randomState;try view.render();try view.render()
    checks["prize_repaint_never_consumes_future_rng"] = view.session.generator.randomState == before
    try view.advanceActivityPresentation(irqTicks: 19)
    checks["prize_rng_waits_for_exact_next_phase_deadline"] = view.session.generator.randomState == before && view.session.activityPresentation?.elapsedIRQTicks == 19
    view.session = try JSONDecoder().decode(NativeSession.self,from: JSONEncoder().encode(view.session!))
    try view.advanceActivityPresentation(irqTicks: 1)
    checks["prize_partial_restore_consumes_next_rng_batch_once"] = view.session.generator.randomState == expectedStates[1] && view.session.activityPresentation?.appliedRandomCount == 9 && view.session.valid
    try view.advanceActivityPresentation(irqTicks: 200)
    checks["prize_final_reveal_has_original54_draw_state_before_final_wait"] = view.session.generator.randomState == 600944149 && view.session.activityPresentation?.elapsedIRQTicks == 220 && view.session.activityPresentation?.appliedRandomCount == 54
    try view.advanceActivityPresentation(irqTicks: 20)
    checks["prize_completion_unlocks_with_final_rng_no_reward"] = !view.isActivityPresenting && view.session.generator.randomState == 600944149 && view.session.score == 0 && view.session.valid
    var next = view.session.generator
    checks["prize_next_gameplay_draw_follows_original_effect_stream"] = next.nextRandomValue() == 5589
    for (name,challenge) in [("spinner",spinner),("music",music),("equipment",supplies)] {
        view.session = NativeSession(profileID: UUID(),seed: 1,lifetimePoints: 30000)
        view.session.position = NativePosition(scene: name == "spinner" ? 12 : (name == "music" ? 15 : 14),playerUnit: 15,cameraUnit: 0,facing: 1)
        view.open(challenge);let rng = view.session.generator.randomState
        try view.render();try view.canvas.writePNG(to: output.appendingPathComponent("native-"+name+"-effect-start.png"))
        try view.advanceActivityPresentation(irqTicks: 10000)
        checks["native_\(name)_effect_retains_prepared_row_rng_and_unlocks"] = !view.isActivityPresenting && view.session.generator.randomState == rng && view.session.valid
    }
    return checks
}
