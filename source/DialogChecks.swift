import Cocoa

func nativeDialogChecks(root: URL,output: URL) throws -> [String:Bool] {
    var checks: [String:Bool] = [:]
    func event(_ code: UInt16,_ text: String = "") -> NSEvent {
        NSEvent.keyEvent(with: .keyDown,location: .zero,modifierFlags: [],timestamp: 0,windowNumber: 0,context: nil,characters: text,charactersIgnoringModifiers: text,isARepeat: false,keyCode: code)!
    }
    let font = try OriginalContent(root: root).font("MOCKET.DAT.1393")
    var dialog = OriginalConfirmation.exit(saving: false)
    checks["dialog_exit_defaults_No_saved_game_defaults_Yes"] = dialog.selection == 0 && OriginalConfirmation.continueSaved.selection == 1
    checks["dialog_Enter_activates_default_No"] = dialog.key(36,characters: nil) == 0
    checks["dialog_Escape_returns_cancel_separate_from_No"] = dialog.key(53,characters: nil) == -1
    for code: UInt16 in [48,123,124,125,126] {
        dialog.selection = 0
        checks["dialog_source_key_\(code)_toggles_both_ways"] = dialog.key(code,characters: nil) == nil && dialog.selection == 1 && dialog.key(code,characters: nil) == nil && dialog.selection == 0
    }
    checks["dialog_Y_and_N_activate_without_another_Enter"] = dialog.key(16,characters: "Y") == 1 && dialog.key(45,characters: "n") == 0
    checks["dialog_F1_Space_digits_do_not_activate"] = dialog.key(122,characters: nil) == nil && dialog.key(49,characters: " ") == nil && dialog.key(18,characters: "1") == nil
    checks["dialog_keypad_Enter_uses_original_ASCII_return"] = dialog.key(76,characters: "\r") == 0
    let longName = OriginalConfirmation.remove(String(repeating: "W",count: 32)).layout(font: font)
    checks["dialog_existing_long_native_names_fit_without_data_truncation"] = longName.left >= 0 && longName.right < 320
    let layout = dialog.layout(font: font)
    checks["dialog_source_exit_center_body_and_button_offsets"] = layout.top == 41 && layout.bottom == 158 && layout.textY == 61 && layout.noX == layout.right-55 && layout.yesX == layout.right-115 && layout.buttonY == 123
    let original = NativeCanvas();original.clear(15);original.originalHelpButton("No",font: font,x: 50,y: 100,selected: false)
    let before = original.pixels
    original.clear(15);original.originalHelpButton("No",font: font,x: 50,y: 100,selected: true)
    var differences = 0,correct = true
    for i in before.indices where before[i] != original.pixels[i] {
        differences += 1;correct = correct && (before[i]^original.pixels[i]) == 14 && [1,15].contains(original.pixels[i])
    }
    checks["dialog_button_original_XOR14_only_black_and_white"] = differences > 0 && correct
    let directory = output.appendingPathComponent("dialog-players-"+UUID().uuidString)
    let view = try NativeGameView(root: root,saveDirectory: directory,automaticallyPresentMessages: false)
    view.timer?.invalidate();view.zapTimer?.invalidate();view.soundEnabled = false
    view.referenceQuestion();view.screen = .world;view.session.activeChallenge = nil;view.session.activityPresentation = nil
    view.session.position = NativePosition();view.session.clock.resume()
    let encoder = JSONEncoder();encoder.outputFormatting = [.sortedKeys];encoder.dateEncodingStrategy = .iso8601
    let snapshot = try encoder.encode(view.session!)
    var exits = 0;view.requestApplicationExit = { exits += 1 }
    view.keyDown(with: event(53));view.step()
    checks["dialog_world_Escape_poll_opens_before_any_world_update"] = try view.confirmation != nil && view.modalDepth == 1 && (try encoder.encode(view.session!)) == snapshot
    view.step();view.keyDown(with: event(18,"1"));view.step()
    checks["dialog_modal_world_rng_score_clock_frozen_and_input_not_queued"] = (try encoder.encode(view.session!)) == snapshot && view.keyboard.values.isEmpty
    view.showPlayerMenu()
    checks["dialog_parent_commands_cannot_replace_visible_confirmation"] = view.screen == .world && view.confirmation != nil
    try view.render();try view.canvas.writePNG(to: output.appendingPathComponent("native-confirm-exit.png"))
    view.keyDown(with: event(45,"n"))
    checks["dialog_No_restores_world_without_exit_or_save_changes"] = try view.confirmation == nil && view.modalDepth == 0 && exits == 0 && (try encoder.encode(view.session!)) == snapshot
    view.confirmNativeExit()
    for flags: NSEvent.ModifierFlags in [.control,.option,.command] {
        let modified = NSEvent.keyEvent(with: .keyDown,location: .zero,modifierFlags: flags,timestamp: 0,windowNumber: 0,context: nil,characters: "y",charactersIgnoringModifiers: "y",isARepeat: false,keyCode: 16)!
        view.keyDown(with: modified)
    }
    checks["dialog_modifier_Y_cannot_silently_confirm_exit"] = exits == 0 && view.confirmation != nil && view.confirmation?.original.selection == 0
    let shiftedTab = NSEvent.keyEvent(with: .keyDown,location: .zero,modifierFlags: [.shift],timestamp: 0,windowNumber: 0,context: nil,characters: "\t",charactersIgnoringModifiers: "\t",isARepeat: false,keyCode: 48)!
    view.keyDown(with: shiftedTab)
    checks["dialog_original_shift_Tab_scan_not_plain_Tab"] = view.confirmation?.original.selection == 0
    view.keyDown(with: event(16,"y"))
    checks["dialog_Yes_requests_exit_once_and_releases_modal"] = exits == 1 && view.confirmation == nil && view.modalDepth == 0
    view.confirmNativeExit();let exitBox = view.confirmation!.original.layout(font: font)
    view.confirmationClick(x: exitBox.noX,y: exitBox.buttonY+5)
    checks["dialog_native_mouse_No_matches_keyboard_choice"] = exits == 1 && view.confirmation == nil
    view.screen = .title;view.resetOpening();view.advanceOpening(100)
    view.openingKey(event(53));view.keyDown(with: event(53))
    checks["dialog_opening_cancel_restarts_original_page_wait"] = view.confirmation == nil && view.opening.elapsed == 0 && view.modalDepth == 0
    let member = try view.profileStore.create(name: "Restore")
    try view.profileStore.select(member.id)
    view.session = NativeSession(profileID: member.id,seed: 9)
    view.referenceMode = false;view.session.score = 300;view.save();let saved = try encoder.encode(view.session!)
    view.screen = .menu;view.playGame(custom: false)
    checks["dialog_saved_game_prompt_selects_Yes_and_retains_original_state"] = try view.confirmation?.original.selection == 1 && (try encoder.encode(view.saves.load(member.id)!)) == saved
    try view.render();try view.canvas.writePNG(to: output.appendingPathComponent("native-confirm-saved-game.png"))
    view.keyDown(with: event(53))
    checks["dialog_saved_game_Escape_does_not_discard_or_start"] = try view.screen == .menu && view.session.score == 300 && view.modalDepth == 0 && (try view.saves.load(member.id))?.score == 300
    view.playGame(custom: false);view.keyDown(with: event(36))
    checks["dialog_saved_game_Enter_continues_same_identity_and_score"] = view.confirmation == nil && view.session.profileID == member.id && view.session.score == 300 && view.screen == .world
    view.choosePlayer();view.signIn.mode = .remove;view.signIn.selection = 0
    view.signInKey(event(36));view.keyDown(with: event(53))
    checks["dialog_remove_Escape_returns_to_remove_picker"] = view.signIn.mode == .remove && view.profileStore.document.profiles.contains { $0.id == member.id }
    view.signInKey(event(36));try view.render();try view.canvas.writePNG(to: output.appendingPathComponent("native-confirm-remove.png"))
    view.keyDown(with: event(16,"y"))
    checks["dialog_remove_Yes_archives_profile_and_keeps_saved_game"] = try view.confirmation == nil && view.profileStore.document.archivedProfiles?.contains { $0.id == member.id } == true && (try view.saves.load(member.id))?.score == 300
    try view.profileStore.restore(member.id)
    checks["dialog_removed_member_remains_recoverable_with_score"] = try view.profileStore.document.profiles.contains { $0.id == member.id } && (try view.saves.load(member.id))?.score == 300
    try view.profileStore.select(member.id);view.screen = .menu;view.playGame(custom: false)
    view.keyDown(with: event(45,"n"))
    checks["dialog_saved_game_No_starts_new_game_only_after_explicit_choice"] = try view.screen == .world && view.confirmation == nil && view.session.profileID == member.id && view.session.score == 0 && view.saves.load(member.id)?.score == 0
    return checks
}
