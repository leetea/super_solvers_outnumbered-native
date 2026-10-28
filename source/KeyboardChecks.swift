import Cocoa

func nativeKeyboardChecks(root: URL,output: URL) throws -> [String:Bool] {
    var checks: [String:Bool] = [:],q = OriginalKeyboardQueue<Int>()
    q.append(13);q.append(27);q.append(316)
    checks["keyboard_blocking_read_preserves_fifo_order"] = q.read() == 13 && q.values == [27,316]
    checks["keyboard_world_poll_drains_all_returns_only_last"] = q.drainLatest() == 316 && q.values.isEmpty && q.drainLatest() == nil
    q.append(13);q.flush();checks["keyboard_flush_discards_pending_keys"] = q.read() == nil
    var keys = OriginalHeldKeyboard();keys.press(126);keys.press(123)
    checks["keyboard_up_left_combination_latches_original_flip"] = keys.up && keys.left && keys.leftFlip && !keys.rightFlip
    keys.release(126)
    checks["keyboard_up_release_clears_flip_and_keeps_left"] = !keys.up && keys.left && !keys.leftFlip
    keys.press(115);keys.press(7)
    checks["keyboard_home_flip_survives_unrelated_interrupt"] = keys.leftFlip
    keys.release(115);checks["keyboard_home_release_clears_flip"] = !keys.leftFlip
    keys.press(116);checks["keyboard_pageup_selects_right_flip"] = keys.rightFlip
    keys.release(116);keys.press(49)
    checks["keyboard_first_space_make_sets_original_zap_flag"] = keys.space
    keys.press(49,repeatKey: true)
    checks["keyboard_space_repeat_clears_zap_without_new_press"] = !keys.space
    keys.release(49);keys.press(49)
    checks["keyboard_space_release_rearms_first_make"] = keys.space
    keys.release(49);checks["keyboard_space_release_clears_pending_zap"] = !keys.space
    let dir = FileManager.default.temporaryDirectory.appendingPathComponent("outnumbered-keyboard-"+UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: dir) }
    let view = try NativeGameView(root: root,saveDirectory: dir,automaticallyPresentMessages: false)
    view.timer?.invalidate();view.zapTimer?.invalidate();view.soundEnabled = false
    func key(_ code: UInt16,_ text: String = "",repeatKey: Bool = false,up: Bool = false) {
        let event = NSEvent.keyEvent(with: up ? .keyUp : .keyDown,location: .zero,modifierFlags: [],timestamp: 0,windowNumber: 0,context: nil,characters: text,charactersIgnoringModifiers: text,isARepeat: repeatKey,keyCode: code)!
        if up { view.keyUp(with: event) } else { view.keyDown(with: event) }
    }
    func reset() {
        view.referenceMode = true;view.session = NativeSession(profileID: UUID(),seed: 1)
        view.session.position = NativePosition(scene: 2,playerUnit: 90,cameraUnit: 76,facing: 1)
        view.screen = .world;view.held.removeAll();view.physicalKeyboard = OriginalHeldKeyboard();view.keyboard.flush()
    }
    reset();key(120);key(48,"\t")
    checks["keyboard_world_menu_keys_wait_for_original_poll"] = view.screen == .world && view.keyboard.values.count == 2
    view.step()
    checks["keyboard_last_tab_wins_over_earlier_file_key"] = view.screen == .decoder && view.keyboard.values.isEmpty
    var releasedMovementIgnored = true
    for code: UInt16 in [123,124,126,49] {
        reset();key(code);key(code,up: true)
        //In menu/return mode these make codes can still be in the BIOS queue.
        view.keyboard.append(NSEvent.keyEvent(with: .keyDown,location: .zero,modifierFlags: [],timestamp: 0,windowNumber: 0,context: nil,characters: "",charactersIgnoringModifiers: "",isARepeat: false,keyCode: code)!)
        view.step()
        releasedMovementIgnored = releasedMovementIgnored && view.session.position.playerUnit == 90 && view.playerMotion.settled && view.session.activeZap == nil && view.held.isEmpty
    }
    checks["keyboard_queued_released_movement_cannot_synthesize_new_world_press"] = releasedMovementIgnored
    reset();key(120);key(7,"x");view.step()
    checks["keyboard_unknown_last_key_discards_earlier_file_request"] = view.screen == .world && view.keyboard.values.isEmpty
    reset();view.session.position = NativePosition(scene: 1,playerUnit: 50,cameraUnit: 38,facing: -1);view.interact()
    key(48,"\t");view.step()
    checks["keyboard_door_defers_buffered_menu_input"] = view.session.activeDoor != nil && view.screen == .world && view.keyboard.values.count == 1
    view.advanceDoor(irqTicks: 10000);view.step()
    checks["keyboard_door_completion_delivers_last_buffered_key"] = view.screen == .decoder && view.session.position.scene == 10 && view.session.activeDoor == nil
    reset();key(124);view.step();let before = view.session.position.playerUnit
    key(120);view.step();checks["keyboard_file_opens_after_world_poll"] = view.screen == .file
    view.closeFileMenu();view.step()
    checks["keyboard_physical_right_survives_menu_until_release"] = view.session.position.playerUnit > before && view.physicalKeyboard.right
    key(124,up: true);view.step();let stopped = view.session.position.playerUnit;view.step()
    checks["keyboard_release_stops_held_walk_after_menu"] = !view.physicalKeyboard.right && view.session.position.playerUnit == stopped
    reset();key(123);key(124);view.step()
    checks["keyboard_source_right_priority_when_both_arrows_held"] = view.session.position.facing == 1 && view.session.position.playerUnit == 91
    reset();key(123);key(124);key(126);view.step();view.step()
    checks["keyboard_both_flip_flags_original_left_facing_after_right_request"] = view.playerMotion.airborne && view.session.position.facing == -1 && view.session.position.playerUnit == 86
    reset();key(126);view.step()
    checks["keyboard_held_up_requests_jump_on_game_frame"] = view.playerMotion.airborne
    for _ in 0..<8 { view.step() }
    checks["keyboard_held_up_repeats_jump_after_landing"] = view.playerMotion.airborne
    key(126,up: true)
    for _ in 0..<12 { view.step() }
    checks["keyboard_up_release_allows_final_landing"] = view.playerMotion.settled
    reset();key(49," ");key(49," ",up: true);view.step()
    checks["keyboard_space_released_before_poll_does_not_latch_zap"] = view.session.activeZap == nil
    key(49," ");view.step();checks["keyboard_space_held_at_poll_starts_source_zap"] = view.session.activeZap != nil
    key(49," ",up: true)
    reset();view.referenceBarChart();key(120)
    checks["keyboard_activity_editor_discards_keys_before_first_input"] = view.isActivityPresenting && view.keyboard.values.isEmpty && view.screen == .question
    reset();_ = try view.profileStore.create(name: "Keyboard Check")
    try view.launchPractice(settings: .defaults(tier: 0),seed: 1)
    key(122)
    checks["keyboard_practice_intro_does_not_service_help_before_editor_flush"] = view.screen == .practice && view.keyboard.values.isEmpty
    _ = try view.practice!.advance(irqTicks: 160)
    for _ in 0..<5 {
        _ = try view.practice!.advance(irqTicks: 240)
        for c in String(view.practice!.drill.question.expected) { view.practice!.drill.digit(Int(String(c))!) }
        _ = view.practice!.submit();_ = try view.practice!.advance(irqTicks: 480)
    }
    checks["keyboard_practice_fixture_reaches_result_animation"] = view.practice!.presentation == .response
    key(36,"\r");key(36,"\r")
    checks["keyboard_practice_result_queues_early_enter"] = view.keyboard.values.count == 2 && view.practice!.presentation == .response
    _ = try view.practice!.advance(irqTicks: 5000,soundPlaying: false);view.pollPracticeContinue()
    checks["keyboard_early_enter_starts_next_set_only_after_result_wait"] = view.practice!.presentation == .introduction && view.keyboard.values.isEmpty && view.practice!.attempts == 5
    reset();key(120);key(124);_ = view.resignFirstResponder()
    checks["keyboard_native_focus_loss_discards_queue_and_physical_keys"] = view.keyboard.values.isEmpty && !view.physicalKeyboard.right && view.held.isEmpty
    return checks
}
