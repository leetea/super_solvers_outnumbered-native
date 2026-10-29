import Foundation

func nativeAdviceChecks(root: URL,output: URL) throws -> [String:Bool] {
    var checks: [String:Bool] = [:]
    func key(_ code: UInt16,_ text: String = "",shift: Bool = false) -> GameInputEvent {
        GameInputEvent.keyEvent(with: .keyDown,location: .zero,modifierFlags: shift ? [.shift] : [],timestamp: 0,windowNumber: 0,context: nil,characters: text,charactersIgnoringModifiers: text,isARepeat: false,keyCode: code)!
    }
    let directory = output.appendingPathComponent("advice-players-"+UUID().uuidString)
    let view = try NativeGameView(root: root,saveDirectory: directory,automaticallyPresentMessages: false)
    view.timer?.invalidate();view.zapTimer?.invalidate();view.soundEnabled = false
    let profile = try view.profileStore.create(name: "Advice");view.begin()
    let weather = view.bank.cases.first { $0.id == 9078 && $0.seed == 2 && $0.variant == 3 }!
    view.open(weather);view.session.activityPresentation = nil
    let encoder = JSONEncoder();encoder.outputFormatting = [.sortedKeys]
    let font = try view.content.font("MOCKET.DAT.1393")
    checks["advice_source_calculator_keycaps_and_exact_double_spacing"] = NativeCalculator.notices.count == 8 && NativeCalculator.notices[0].contains("\u{85}") && NativeCalculator.notices[5].contains("\u{8c}") && NativeCalculator.notices[3].contains("remainders).  Try again.")
    let beforeNotices = try encoder.encode(view.session!)
    for id in 0..<8 {
        view.calculatorNotice(id)
        let layout = view.originalNotice!.original.layout(font: font)
        try view.render();let pixels = view.canvas.pixels;try view.render()
        checks["advice_calculator_original_notice_\(id)_renders_without_title"] = view.originalNotice?.original.title == nil && view.originalNotice?.original.style == 2 && layout.left >= 0 && layout.right < 320 && layout.top >= 0 && layout.bottom < 200 && pixels == view.canvas.pixels
        if [0,3,5].contains(id) { try view.canvas.writePNG(to: output.appendingPathComponent("native-calculator-advice-\(id).png")) }
        view.keyDown(with: key(53))
    }
    checks["advice_Escape_dismisses_all_advice_without_answer_score_rng_or_pause_change"] = try view.originalNotice == nil && view.modalDepth == 0 && encoder.encode(view.session!) == beforeNotices
    view.calculatorKey(.clear)
    for d in [9,9,9,9] { view.calculatorKey(.digit(d)) }
    view.calculatorKey(.operation(.add));view.calculatorKey(.digit(1))
    let beforeError = try encoder.encode(view.session!)
    view.calculatorKey(.equals)
    checks["advice_arithmetic_error_keeps_visible_editor_until_dismissal"] = try view.originalNotice?.original.text == NativeCalculator.notices[1] && view.session.calculator?.phase == .second && encoder.encode(view.session!) == beforeError
    view.calculatorKey(.digit(8));view.keyDown(with: key(18,"1"));view.step()
    checks["advice_error_owns_input_and_freezes_parent_session"] = try encoder.encode(view.session!) == beforeError && view.originalNotice != nil
    view.keyDown(with: key(36))
    checks["advice_error_dismissal_clears_calculator_without_wrong_answer"] = view.session.calculator?.phase == .empty && view.session.attempts[weather.hotspot]?.input == "" && view.session.attempts[weather.hotspot]?.wrongAnswers == 0 && view.session.score == 0 && view.session.clock.pauseDepth == 1
    for d in [1,3] { view.calculatorKey(.digit(d)) }
    view.calculatorKey(.operation(.divide));view.calculatorKey(.digit(5));view.calculatorKey(.equals)
    checks["advice_remainder_has_original_untitled_notice_and_footer_values"] = view.originalNotice?.original.text == NativeCalculator.notices[3] && view.originalNotice?.original.title == nil && view.calculatorRemainder?.quotient == 2 && view.calculatorRemainder?.remainder == 3
    try view.render();try view.canvas.writePNG(to: output.appendingPathComponent("native-calculator-remainder-footer.png"))
    view.keyDown(with: key(76))
    checks["advice_remainder_keypad_Enter_restores_empty_editor_without_penalty"] = view.calculatorRemainder == nil && view.session.calculator?.phase == .empty && view.session.score == 0 && view.session.attempts[weather.hotspot]?.wrongAnswers == 0 && view.modalDepth == 0
    view.session.activeChallenge = nil;view.session.activityPresentation = nil
    while view.session.clock.pauseDepth > 0 { view.session.clock.resume() }
    view.screen = .world;view.selectedRoom = 4;view.decoderButton = 2
    view.openDecoder()
    checks["decoder_entry_resets_room_and_bottom_button_to_zero"] = view.screen == .decoder && view.selectedRoom == 0 && view.decoderButton == 0 && view.session.clock.pauseDepth == 1
    view.keyDown(with: key(36))
    checks["decoder_default_Enter_activates_GoBack_not_Decide"] = view.screen == .world && view.session.clock.pauseDepth == 0 && view.decoderPanel == nil
    view.openDecoder();view.keyDown(with: key(48));let forward = view.decoderButton
    view.keyDown(with: key(48,shift: true));let backward = view.decoderButton
    view.keyDown(with: key(123));let left = view.decoderButton;view.keyDown(with: key(124))
    checks["decoder_Tab_ShiftTab_Left_Right_cycle_three_source_buttons"] = forward == 1 && backward == 0 && left == 2 && view.decoderButton == 0
    view.keyDown(with: key(126));let up = view.selectedRoom;view.keyDown(with: key(125))
    checks["decoder_Up_Down_wrap_five_room_rows_independently_of_buttons"] = up == 4 && view.selectedRoom == 0 && view.decoderButton == 0
    view.decoderBlinkIRQ = 100;try view.render();let selected = view.canvas.pixels
    view.selectedRoom = 1;try view.render();let other = view.canvas.pixels
    var replaced = 0,onlySourceColor = true
    for y in 17...43 { for x in 172...308 {
        let i = y*320+x
        if selected[i] != other[i] { replaced += 1;onlySourceColor = onlySourceColor && other[i] == 3 && selected[i] == 12 }
    } }
    checks["decoder_selected_room_uses_source_cyan_to_red_replacement"] = replaced > 0 && onlySourceColor
    view.decoderBlinkIRQ = 0;try view.render();let blink = view.canvas.pixels
    view.decoderBlinkIRQ = 99;try view.render();let stillOn = view.canvas.pixels == blink
    view.decoderBlinkIRQ = 100;try view.render()
    checks["decoder_source_FASTLOAD98_button_marker_holds_first100IRQ"] = stillOn && view.canvas.pixels != blink
    view.decoderButton = 2;view.keyDown(with: key(36))
    checks["decoder_ineligible_Decide_uses_original_explanation_including_final_CR"] = view.originalNotice?.original.text == OriginalDecoderDialog.ineligible && OriginalDecoderDialog.ineligible.hasSuffix("\n") && view.session.activeEnding == nil
    view.keyDown(with: key(53))
    for tier in [0,2,3] {
        var generator = DecoderGenerator(seed: 17);view.session.decoder = generator.makePuzzle(difficulty: tier)
        view.showMatchRule();let state = try encoder.encode(view.session!)
        try view.render();try view.canvas.writePNG(to: output.appendingPathComponent("native-decoder-rule-\(tier).png"))
        view.keyDown(with: key(53));view.keyDown(with: key(122));view.step();view.showOptions()
        checks["decoder_rule_\(tier)_Enter_only_and_parent_commands_frozen"] = try view.decoderPanel != nil && view.optionsMenu == nil && encoder.encode(view.session!) == state
        view.keyDown(with: key(76))
    }
    checks["decoder_rule_return_retains_decoder_pause_and_releases_modal"] = view.decoderPanel == nil && view.screen == .decoder && view.session.clock.pauseDepth == 1 && view.modalDepth == 0
    try view.render();let firstReturn = view.canvas.pixels
    checks["decoder_rule_first_blink_retains_original_blue_blank_footer"] = view.decoderFooterBlank && view.decoderBlinkIRQ == 0 && firstReturn[170*320+200] == 0 && firstReturn[162*320+4] == 1
    for _ in 0..<4 { view.step() }
    let beforeOff = view.decoderFooterBlank
    view.step();try view.render()
    checks["decoder_rule_100IRQ_off_phase_restores_saved_buttons"] = beforeOff && !view.decoderFooterBlank && view.decoderBlinkIRQ == 120 && view.canvas.pixels != firstReturn
    view.showMatchRule();view.keyDown(with: key(36));view.keyDown(with: key(125))
    checks["decoder_rule_keyboard_input_restores_footer_before_dispatch"] = !view.decoderFooterBlank && view.decoderPanel == nil
    for _ in 0..<4 { _ = view.session.decoder.collectSecret();_ = view.session.decoder.collectClues(room: 0) }
    view.selectedRoom = view.session.decoder.hideoutRoom
    let beforeChoice = try encoder.encode(view.session!)
    view.confirmDecision()
    var firstDefaultNo = false
    if case .decision(_,let model)? = view.decoderPanel?.mode { firstDefaultNo = model.selection == 0 }
    checks["decoder_eligible_Decide_first_asks_inline_with_default_No"] = firstDefaultNo && view.confirmation == nil && view.modalDepth == 1
    try view.render();try view.canvas.writePNG(to: output.appendingPathComponent("native-decoder-inline-decision.png"))
    view.keyDown(with: key(36))
    checks["decoder_first_default_No_returns_without_ending_or_rng_draws"] = try view.decoderPanel == nil && view.confirmation == nil && encoder.encode(view.session!) == beforeChoice
    view.confirmDecision();view.keyDown(with: key(16,"y"))
    checks["decoder_inline_Yes_then_original_AreYouSure_defaults_Yes"] = view.decoderPanel == nil && view.confirmation?.original.selection == 1 && view.confirmation?.original.title == nil && view.confirmation?.original.text == OriginalDecoderDialog.confirmPrefix+DecoderPuzzle.roomNames[view.selectedRoom].uppercased()+"?" && view.decoderConfirmationPending
    try view.render();try view.canvas.writePNG(to: output.appendingPathComponent("native-decoder-final-confirm.png"))
    view.keyDown(with: key(53))
    checks["decoder_second_confirmation_Escape_restores_footer_without_award"] = try view.confirmation == nil && !view.decoderConfirmationPending && view.session.activeEnding == nil && encoder.encode(view.session!) == beforeChoice
    view.confirmDecision();view.keyDown(with: key(16,"y"));view.keyDown(with: key(45,"n"))
    checks["decoder_second_confirmation_No_retains_source_working_state"] = try view.session.activeEnding == nil && encoder.encode(view.session!) == beforeChoice
    let room = view.selectedRoom
    view.confirmDecision();view.keyDown(with: key(16,"y"));view.selectedRoom = (room+1)%5;view.keyDown(with: key(36))
    checks["decoder_both_Yes_begin_ending_for_captured_room_without_early_score_award"] = view.screen == .ending && view.session.activeEnding?.room == room && view.session.activeEnding?.won == true && view.session.score == 0 && (view.profileStore.document.profiles.first { $0.id == profile.id }?.lifetimePoints ?? 0) == 0
    return checks
}
