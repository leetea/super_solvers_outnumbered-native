import Cocoa

func nativeEndingPresentationChecks(root: URL,output: URL) throws -> [String:Bool] {
    var checks: [String:Bool] = [:]
    func key(_ code: UInt16,_ text: String = "") -> NSEvent {
        NSEvent.keyEvent(with: .keyDown,location: .zero,modifierFlags: [],timestamp: 0,windowNumber: 0,context: nil,characters: text,charactersIgnoringModifiers: text,isARepeat: false,keyCode: code)!
    }
    let data = try JSONDecoder().decode(OriginalEndingData.self,from: Data(contentsOf: root.appendingPathComponent("ending-sequences.json")))
    let rank = OriginalRankTimeline(lifetime: 64275,data: data)
    checks["ending_rank_source_750IRQ_reveal_then_four_120IRQ_rank_flashes"] = rank.duration == 1230
    let lines = rank.events.compactMap { e -> Int? in if case .line(let y) = e.action { return y };return nil }
    checks["ending_rank_source_separator_rows_have_no_triangle_overlap"] = lines.count == 60 && lines.first == 24 && lines.last == 161 && !lines.contains(43) && !lines.contains(163)
    let colors = rank.events.compactMap { e -> UInt8? in if case .band(_,let c) = e.action { return c };return nil }
    checks["ending_rank_original_red_cyan_red_flash_order"] = colors == Array(repeating: [UInt8(12),11,12],count: 4).flatMap { $0 }
    let champion = OriginalRankTimeline(lifetime: 500000,data: data)
    checks["ending_champion_adds_only_original_16_command_script"] = champion.events.filter { if case .command = $0.action { return true };return false }.count == 22 && champion.duration > 1710
    let directory = output.appendingPathComponent("ending-presentation-players-"+UUID().uuidString)
    let view = try NativeGameView(root: root,saveDirectory: directory,automaticallyPresentMessages: false)
    view.timer?.invalidate();view.zapTimer?.invalidate();view.soundEnabled = false
    let profile = try view.profileStore.create(name: "Ending")
    view.session = NativeSession(profileID: profile.id,seed: 6908,lifetimePoints: 52595)
    view.session.score = 2650;view.session.energy = 17;view.session.clock.applyMinutePenalty(52)
    view.startEnding(room: view.session.decoder.hideoutRoom)
    let timeline = EndingTimeline(view.session.activeEnding!,data: data)
    let energyStart = timeline.events.first { if case .bonus("Energy Left",_) = $0.action { return true };return false }!.ticks
    try view.advanceEnding(energyStart);try view.render();let startPanel = view.canvas.pixels
    try view.advanceEnding(290);try view.render();let fullPanel = view.canvas.pixels
    checks["ending_bonus_source_slide_in_crops_bottom_rows_at_fixed_top"] = startPanel[16*320+64] == fullPanel[74*320+64] && startPanel[17*320+160] == fullPanel[75*320+160] && startPanel[54*320+160] != fullPanel[54*320+160]
    let closing = timeline.events.first { if case .bonusClosing = $0.action { return true };return false }!.ticks
    try view.advanceEnding(closing-view.session.activeEnding!.elapsedTicks);try view.render();let closingPixels = view.canvas.pixels
    try view.advanceEnding(5);try view.render()
    checks["ending_bonus_source_slide_out_advances_crop_each_five_IRQ"] = view.canvas.pixels[16*320+160] == closingPixels[17*320+160] && view.canvas.pixels != closingPixels
    let departure = data.scripts.first { $0.name == "departure" }!
    checks["ending_departure_preserves_original_horizontal_flip_flag32"] = departure.commands.contains { $0.resource == 34 && $0.flags == 96 } && departure.commands.filter { $0.resource >= 0 }.allSatisfy { [64,96].contains($0.flags) }
    checks["ending_bonus_repeated_sound_requests_follow_original_59_step_loops"] = timeline.sounds(after: -1,through: timeline.duration).filter { $0.index == 46 }.count == 59 && timeline.sounds(after: -1,through: timeline.duration).filter { $0.index == 47 }.count == 118
    let beginRank = timeline.events.first { if case .rankStart = $0.action { return true };return false }!.ticks
    try view.advanceEnding(beginRank-view.session.activeEnding!.elapsedTicks)
    let encoder = JSONEncoder();encoder.outputFormatting = [.sortedKeys]
    let before = try encoder.encode(view.session!)
    try view.render();let pixels = view.canvas.pixels;try view.render()
    checks["ending_tower_render_is_pure_and_uses_post_award_total_without_early_commit"] = try pixels == view.canvas.pixels && encoder.encode(view.session!) == before && view.session.activeEnding?.committed == false && view.session.lifetimePoints == 52595 && view.endingFinalLifetime(view.session.activeEnding!) == 64275
    try view.canvas.writePNG(to: output.appendingPathComponent("native-ending-trophy-intro.png"))
    view.keyDown(with: key(53));view.keyDown(with: key(36));view.keyDown(with: key(122))
    checks["ending_tower_ignores_input_before_source_completion"] = try view.screen == .ending && view.confirmation == nil && encoder.encode(view.session!) == before
    try view.advanceEnding(750+40)
    try view.render();let cyan = view.canvas.pixels[170*320+160]
    try view.advanceEnding(40);try view.render();let red = view.canvas.pixels[170*320+160]
    checks["ending_tower_visible_band_cycles_cyan_back_to_red"] = cyan == 11 && red == 12
    try view.advanceEnding(timeline.duration);try view.render()
    checks["ending_trophy_final_fills_through_promoted_Pro_rank"] = view.canvas.pixels[173*320+160] == 12 && view.canvas.pixels[125*320+160] == 12 && view.canvas.pixels[103*320+160] == 11 && view.session.lifetimePoints == 64275
    try view.canvas.writePNG(to: output.appendingPathComponent("native-ending-trophy-complete.png"))
    view.continueAfterResults()
    checks["ending_win_replay_uses_original_untitled_default_Yes"] = view.confirmation?.original.text == OriginalConfirmation.replay(won: true).text && view.confirmation?.original.title == nil && view.confirmation?.original.selection == 1
    let layout = view.confirmation!.original.layout(font: try view.content.font("MOCKET.DAT.1393"))
    checks["ending_common_confirmation_Yes_left_No_right_source7314_7312"] = layout.yesX+60 == layout.noX
    try view.render();try view.canvas.writePNG(to: output.appendingPathComponent("native-ending-replay-win.png"))
    view.keyDown(with: key(36))
    checks["ending_replay_Yes_returns_to_SignIn_with_single_committed_award"] = view.screen == .signin && view.confirmation == nil && view.profileStore.document.profiles.first?.lifetimePoints == 64275
    //A fresh loss independently verifies No/Exit/Cancel and immediate midnight replay.
    view.session = NativeSession(profileID: profile.id,seed: 1,lifetimePoints: 64275)
    view.session.score = 1800;view.session.clock.applyMinutePenalty(180);view.screen = .world
    view.startEnding(room: 0,reason: .midnight)
    try view.advanceEnding(0);try view.render();let first = view.canvas.pixels
    try view.advanceEnding(100);try view.render()
    checks["ending_midnight_100IRQ_original_meter_sprites_alternate"] = first != view.canvas.pixels && view.session.score == 0 && view.session.energy == 0
    let midnight = EndingTimeline(view.session.activeEnding!,data: data)
    checks["ending_midnight_five_meter_cycles_ten_sound49_cues"] = midnight.duration == 1000 && midnight.sounds(after: -1,through: 1000).filter { $0.index == 49 }.count == 10
    try view.advanceEnding(900)
    checks["ending_midnight_opens_loss_replay_without_extra_Enter"] = view.screen == .results && view.confirmation?.original.text == OriginalConfirmation.replay(won: false).text && view.session.lifetimePoints == 64275
    try view.render();try view.canvas.writePNG(to: output.appendingPathComponent("native-ending-replay-loss.png"))
    view.keyDown(with: key(45,"n"))
    checks["ending_replay_No_opens_original_nonsaving_Exit_default_No"] = view.confirmation?.original.text == OriginalConfirmation.exit(saving: false).text && view.confirmation?.original.selection == 0
    view.keyDown(with: key(53))
    checks["ending_declining_replay_Exit_returns_to_SignIn"] = view.screen == .signin && view.confirmation == nil && view.profileStore.document.profiles.first?.lifetimePoints == 64275
    view.screen = .results;view.continueAfterResults();view.keyDown(with: key(53))
    checks["ending_replay_Escape_returns_to_SignIn_without_exit_prompt"] = view.screen == .signin && view.confirmation == nil
    view.screen = .results;view.continueAfterResults();view.keyDown(with: key(45,"n"))
    var exits = 0;view.requestApplicationExit = { exits += 1 };view.keyDown(with: key(16,"y"))
    checks["ending_replay_Exit_Yes_requests_one_native_application_exit"] = exits == 1 && view.modalDepth == 0
    return checks
}
