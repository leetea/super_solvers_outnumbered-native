import Foundation

func nativeOptionsChecks(root: URL,output: URL) throws -> [String:Bool] {
    var checks: [String:Bool] = [:]
    func event(_ code: UInt16,_ text: String = "") -> GameInputEvent {
        GameInputEvent.keyEvent(with: .keyDown,location: .zero,modifierFlags: [],timestamp: 0,windowNumber: 0,context: nil,characters: text,charactersIgnoringModifiers: text,isARepeat: false,keyCode: code)!
    }
    let directory = output.appendingPathComponent("options-players-"+UUID().uuidString)
    let view = try NativeGameView(root: root,saveDirectory: directory)
    view.timer?.invalidate();view.zapTimer?.invalidate();view.soundEnabled = false
    let profile = try view.profileStore.create(name: "Options")
    view.begin();view.session.newUserMessages = NativeNewUserMessages(enabled: false)
    let encoder = JSONEncoder();encoder.outputFormatting = [.sortedKeys]
    view.save();let before = try encoder.encode(view.session!)
    view.showOptions()
    checks["options_source_four_rows_first_selected_and_world_frozen"] = view.optionsMenu?.items == ["New User Messages","Music","Sound","Calculator"] && view.optionsMenu?.selection == 0 && view.modalDepth == 1
    for _ in 0..<10 { view.step() }
    checks["options_world_clock_rng_actors_do_not_step"] = try encoder.encode(view.session!) == before
    view.keyDown(with: event(126));let last = view.optionsMenu?.selection
    view.keyDown(with: event(125));view.keyDown(with: event(99))
    checks["options_up_wraps_down_wraps_F3_current_tab_ignored"] = last == 3 && view.optionsMenu?.selection == 0
    try view.render();try view.canvas.writePNG(to: output.appendingPathComponent("native-options-game.png"))
    view.keyDown(with: event(125));view.keyDown(with: event(36))
    checks["options_music_dialog_defaults_to_current_gate"] = view.confirmation?.original.title == "Music" && view.confirmation?.original.selection == 1 && view.modalDepth == 1
    view.keyDown(with: event(45,"n"))
    checks["options_music_No_applies_immediately_returns_parent"] = !view.musicEnabled && !view.soundEnabled && view.optionsMenu == nil && view.screen == .world && view.modalDepth == 0
    view.showOptions();view.optionsMenu?.selection = 1;view.activateOption();view.keyDown(with: event(53))
    checks["options_Escape_choice_keeps_gate_closes_menu"] = !view.musicEnabled && view.optionsMenu == nil && view.confirmation == nil && view.modalDepth == 0
    view.showOptions();view.optionsMenu?.selection = 2;view.activateOption();view.keyDown(with: event(16,"y"))
    checks["options_sound_Yes_does_not_reenable_music"] = view.soundEnabled && !view.musicEnabled && view.optionsMenu == nil && view.modalDepth == 0
    view.soundEnabled = false
    view.showOptions();view.optionsMenu?.selection = 0;view.activateOption();view.keyDown(with: event(16,"y"))
    checks["options_messages_Yes_resets_all_flags_returns_parent"] = view.tutorialState.enabled && view.tutorialState.flags == Array(repeating: 0,count: 18) && view.optionsMenu == nil && view.modalDepth == 0
    view.closeOptions();view.showNewUserMessage(0)
    checks["notice_native_message_owns_one_pause_until_dismissal"] = view.originalNotice?.original.text == OriginalNewUserText.messages[0] && view.session.clock.pauseDepth == 1 && view.modalDepth == 1 && view.tutorialState.flags[0] == 0
    let paused = try encoder.encode(view.session!)
    view.keyDown(with: event(18,"1"));view.step()
    checks["notice_ignores_nonclosing_keys_and_freezes_session"] = try view.originalNotice != nil && encoder.encode(view.session!) == paused && view.keyboard.values.isEmpty
    try view.render();try view.canvas.writePNG(to: output.appendingPathComponent("native-new-user-message.png"))
    view.keyDown(with: event(53))
    checks["notice_Escape_acknowledges_and_restores_pause_depth"] = view.originalNotice == nil && view.modalDepth == 0 && view.session.clock.pauseDepth == 0 && view.tutorialState.flags[0] == -1
    view.showNewUserMessage(0)
    checks["notice_seen_message_does_not_reopen"] = view.originalNotice == nil
    let font = try view.content.font("MOCKET.DAT.1393")
    checks["notice_all_eighteen_original_texts_fit_centered_panels"] = OriginalNewUserText.messages.allSatisfy {
        let box = OriginalNotice(text: $0,title: "New User Message").layout(font: font)
        return box.left >= 0 && box.right < 320 && box.top >= 0 && box.bottom < 200
    }
    view.showOptions();view.keyDown(with: event(123))
    checks["menus_left_from_Options_opens_File_without_modal_leak"] = view.optionsMenu == nil && view.screen == .file && view.fileReturn == .world && view.modalDepth == 0
    view.keyDown(with: event(120));view.keyDown(with: event(123))
    checks["menus_F2_current_tab_ignored_left_File_to_Help"] = view.screen == .help && view.helpReturn == .world && view.session.clock.pauseDepth == 1
    view.keyDown(with: event(122))
    checks["menus_F1_current_Help_tab_ignored"] = view.screen == .help && view.helpBrowser?.topic == nil
    view.keyDown(with: event(123))
    checks["menus_left_Help_wraps_Options_releases_Help_pause"] = view.optionsMenu != nil && view.helpBrowser == nil && view.screen == .world && view.session.clock.pauseDepth == 0 && view.modalDepth == 1
    view.keyDown(with: event(124));view.keyDown(with: event(124));view.keyDown(with: event(124))
    checks["menus_right_wraps_all_three_tabs_in_original_order"] = view.optionsMenu != nil && view.screen == .world && view.modalDepth == 1 && view.helpBrowser == nil
    let warningBox = OriginalNotice(text: "one\ntwo\nthree",title: "Warning",style: 7).layout(font: font)
    checks["notice_source_type7_uses_same_extra15_and_minimum150_as_type2"] = warningBox.bottom-warningBox.top == 77 && warningBox.right-warningBox.left >= 150 && warningBox.bottom-18 > warningBox.textY+20+7
    view.closeOptions();view.setNewUserMessages(false)
    let weather = view.bank.cases.first { $0.id == 9078 && $0.seed == 2 && $0.variant == 3 }!
    view.open(weather);view.session.activityPresentation = nil
    view.session.calculatorEnabled = true;view.session.calculator = NativeCalculator();view.calculatorKey(.digit(6))
    view.showOptions();view.optionsMenu?.selection = 3;view.activateOption();view.keyDown(with: event(45,"n"))
    checks["options_calculator_nonempty_input_warns_before_change"] = view.originalNotice?.original.style == 7 && view.usesCalculator && view.session.attempts[weather.hotspot]?.input == "6" && view.modalDepth == 1
    try view.render();try view.canvas.writePNG(to: output.appendingPathComponent("native-calculator-switch-warning.png"))
    view.keyDown(with: event(18,"1"))
    checks["options_calculator_warning_nonEnter_aborts_without_erasing"] = view.originalNotice == nil && view.usesCalculator && view.session.attempts[weather.hotspot]?.input == "6" && view.modalDepth == 0
    view.showOptions();view.optionsMenu?.selection = 3;view.activateOption();view.keyDown(with: event(45,"n"));view.keyDown(with: event(36))
    checks["options_calculator_warning_Enter_switches_clears_only_input"] = !view.usesCalculator && view.session.attempts[weather.hotspot]?.input == "" && view.session.clock.pauseDepth == 1 && view.session.activeChallenge?.answer == weather.answer && view.modalDepth == 0
    view.showOptions();view.optionsMenu?.selection = 3;view.activateOption();view.keyDown(with: event(16,"y"))
    checks["options_calculator_empty_input_switch_needs_no_warning"] = view.originalNotice == nil && view.usesCalculator && view.modalDepth == 0
    view.closeOptions();view.save()
    let adventure = try encoder.encode(view.session!),file = try Data(contentsOf: view.saves.file(profile.id))
    try view.launchPractice(settings: .defaults(tier: 0),seed: 1)
    view.showOptions()
    let items = view.optionsMenu?.items
    try view.render();try view.canvas.writePNG(to: output.appendingPathComponent("native-options-practice.png"))
    view.optionsMenu?.selection = 1;view.activateOption();view.keyDown(with: event(45,"n"))
    checks["options_practice_exposes_only_music_sound_and_preserves_saved_adventure"] = try items == ["Music","Sound"] && view.optionsMenu == nil && encoder.encode(view.session!) == adventure && Data(contentsOf: view.saves.file(profile.id)) == file
    view.closeOptions();view.practiceMessages.enabled = true
    view.showNewUserMessage(8);view.keyDown(with: event(76))
    checks["notice_practice_keypad_Enter_changes_only_practice_guidance"] = try view.originalNotice == nil && view.practiceMessages.flags[8] == -1 && encoder.encode(view.session!) == adventure && Data(contentsOf: view.saves.file(profile.id)) == file
    view.screen = .menu;view.practice = nil;view.tutorialPracticeContext = false
    var accepted = false
    view.beginSettingsEditor(.defaults(tier: 0),practice: true) { _ in accepted = true }
    view.tutorialState = NativeNewUserMessages(enabled: true);view.showNewUserMessage(16)
    let editorPhase = view.settingsEditor!.model.phase
    view.step();view.keyDown(with: event(53))
    checks["notice_settings_guidance_Escape_dismisses_child_keeps_editor"] = view.originalNotice == nil && view.settingsEditor != nil && view.settingsEditor?.model.phase == editorPhase && view.modalDepth == 1 && !accepted && view.practiceMessages.flags[16] == -1
    view.finishSettingsEditor(nil)
    checks["notice_settings_child_leaves_no_modal_or_context_leak"] = view.modalDepth == 0 && !view.tutorialPracticeContext && accepted
    return checks
}
