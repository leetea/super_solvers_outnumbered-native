import Foundation

func nativeSettingsEditorChecks(root: URL,output: URL) throws -> [String:Bool] {
    var checks: [String:Bool] = [:]
    let standard = OriginalGameSettings.defaults(tier: 1)
    var model = OriginalSettingsEditor(settings: standard,practice: false)
    checks["settings_original_thirty_rows_and_OK_initial_focus"] = model.controls.count == 30 && model.focus == 28 && model.controls[0].text == "Type of Problems:" && model.controls[1].x == 55 && model.controls[1].y == 53 && model.controls[29].x == 220 && model.controls[29].y == 156
    checks["settings_all_recovered_neighbor_links_skip_static_labels"] = model.controls.filter { $0.kind != 0 }.allSatisfy { $0.neighbors.count == 6 && $0.neighbors.allSatisfy { (0..<30).contains($0) && model.controls[$0].kind != 0 } }
    var groupCycle: [Int] = []
    for _ in 0..<6 { _ = model.key(48);groupCycle.append(model.focus) }
    checks["settings_original_Tab_cycles_groups_and_buttons"] = groupCycle == [29,24,1,6,20,28]
    _ = model.key(48,shift: true)
    checks["settings_original_ShiftTab_returns_previous_group"] = model.focus == 20
    model.focus = 1;_ = model.key(123);let left = model.focus;_ = model.key(125);let down = model.focus;_ = model.key(126)
    checks["settings_original_arrow_links_follow_grid_not_linear_list"] = left == 2 && down == 4 && model.focus == 2
    model.focus = 1;let beforeToggle = model.value;_ = model.key(49)
    var expected = beforeToggle;expected.set(0,mask: 16,enabled: !beforeToggle.enabled(0,mask: 16))
    checks["settings_Space_changes_only_focused_operation_bit"] = model.value == expected && model.focus == 1
    model.focus = 27;_ = model.key(36)
    checks["settings_game_level_selection_reloads_all_standard_defaults"] = model.value == .defaults(tier: 3) && model.focus == 28
    model.value.set(12,mask: 4,enabled: false);model.focus = 27;_ = model.key(49)
    checks["settings_reselecting_game_level_also_restores_standard_record"] = model.value == .defaults(tier: 3) && model.focus == 28
    checks["settings_custom_level_mutates_shared_source_record_before_OK"] = model.sourceRecord == .defaults(tier: 3)
    model.focus = 29;_ = model.key(36)
    checks["settings_Undo_restores_entry_snapshot_and_OK_focus"] = model.value == standard && model.sourceRecord == standard && model.focus == 28
    var legacy = OriginalSettingsEditor(settings: standard,practice: false)
    legacy.value.bytes[3] |= 8;legacy.value.bytes[12] = 31
    var canonical: OriginalGameSettings?
    if case let .accepted(value)? = legacy.activate() { canonical = value }
    checks["settings_OK_rebuilds_visible_bits_and_clears_source_unused_flags"] = canonical?.bytes[12] == 4 && canonical!.bytes[3]&8 == 0 && canonical?.selection == standard.selection
    var practice = OriginalSettingsEditor(settings: standard,practice: true);practice.focus = 27;_ = practice.key(49)
    var practiceExpected = standard;practiceExpected.selection = 3
    checks["settings_practice_count_preserves_checkboxes_and_radio_focus"] = practice.value == practiceExpected && practice.value.practiceQuestionCount == 20 && practice.focus == 27
    checks["settings_practice_and_game_have_original_top_row_labels"] = practice.label(23) == "Number of Problems in Each Set:" && practice.label(27) == "20" && model.label(23) == "Select Settings for Level:" && model.label(27) == "4 (selects all)"
    var accepted: OriginalGameSettings?
    if case let .accepted(value)? = model.key(36) { accepted = value }
    checks["settings_OK_returns_valid_exact_configuration"] = accepted == standard
    if case .cancelled? = model.key(53) { checks["settings_Escape_is_cancellation_without_acceptance"] = true } else { checks["settings_Escape_is_cancellation_without_acceptance"] = false }
    model = OriginalSettingsEditor(settings: OriginalGameSettings(bytes: [UInt8](repeating: 0,count: 13)),practice: false)
    _ = model.key(36);let firstWarning = model.warning
    _ = model.advance(1000);_ = model.key(36)
    checks["settings_empty_operation_warning_then_focus_first_checkbox"] = firstWarning != nil && model.warning == nil && model.focus == 1 && model.phase == 0
    _ = model.activate();model.focus = 28;_ = model.activate();_ = model.key(53)
    checks["settings_empty_numbers_warning_then_focus_zero"] = model.focus == 6 && model.warning == nil
    _ = model.activate();model.focus = 28;_ = model.activate();_ = model.key(36)
    checks["settings_empty_format_warning_then_focus_first_blank"] = model.focus == 20 && model.warning == nil
    model.value = .init(bytes: [12,0,0,16,0,0,0,0,0,0,0,0,0]);model.focus = 28;_ = model.activate();let divisionWarning = model.warning;_ = model.key(36)
    checks["settings_division_zero_warning_returns_to_number_group"] = divisionWarning == "You need to choose more numbers to do division." && model.focus == 6
    model = OriginalSettingsEditor(settings: standard,practice: false)
    _ = model.advance(22);let on = model.cursorVisible;_ = model.advance(1);let off = !model.cursorVisible;_ = model.advance(39);let stillOff = !model.cursorVisible;let ready = model.advance(1)
    checks["settings_cursor_23_selected_40_unselected_IRQ_and_poll"] = on && off && stillOff && ready && model.cursorVisible && model.value == standard
    let directory = output.appendingPathComponent("settings-editor-players-"+UUID().uuidString)
    let view = try NativeGameView(root: root,saveDirectory: directory,automaticallyPresentMessages: false)
    view.timer?.invalidate();view.zapTimer?.invalidate();view.soundEnabled = false
    let member = try view.profileStore.create(name: "Settings");try view.profileStore.select(member.id)
    view.session = NativeSession(profileID: member.id,seed: 1);view.screen = .world
    let encoder = JSONEncoder();encoder.outputFormatting = [.sortedKeys];encoder.dateEncodingStrategy = .iso8601
    let adventure = try encoder.encode(view.session!)
    var result: OriginalGameSettings?
    view.configure(practice: false) { result = $0 }
    for _ in 0..<40 { view.step() }
    checks["settings_editor_freezes_adventure_rng_score_clock_and_actors"] = try view.settingsEditor != nil && view.modalDepth == 1 && encoder.encode(view.session!) == adventure
    func event(_ code: UInt16) -> GameInputEvent { GameInputEvent.keyEvent(with: .keyDown,location: .zero,modifierFlags: [],timestamp: 0,windowNumber: 0,context: nil,characters: "",charactersIgnoringModifiers: "",isARepeat: false,keyCode: code)! }
    view.settingsEditor!.model.phase = 0;view.keyDown(with: event(123));view.keyDown(with: event(124));view.step();view.step()
    checks["settings_keyboard_waits_until_original_idle_poll"] = view.settingsEditor!.model.focus == 28
    view.step()
    checks["settings_keyboard_drain_latest_uses_final_queued_direction"] = view.settingsEditor!.model.focus == 29 && view.keyboard.values.isEmpty
    view.settingsEditor!.model.phase = 0;try view.render();try view.canvas.writePNG(to: output.appendingPathComponent("native-original-game-settings.png"))
    view.settingsKey(event(53))
    checks["settings_cancel_discards_draft_without_changing_save_or_session"] = try view.settingsEditor == nil && view.modalDepth == 0 && result == nil && encoder.encode(view.session!) == adventure && view.selectedProfile?.customGameSettings == nil
    view.configure(practice: false) { result = $0 }
    view.settingsEditor!.model.focus = 27;view.settingsKey(event(36));view.settingsEditor!.model.focus = 1;view.settingsKey(event(49));view.settingsKey(event(53))
    checks["settings_cancel_retains_selected_level_defaults_but_not_checkbox_draft"] = try view.selectedProfile?.customGameSettings == .defaults(tier: 3) && encoder.encode(view.session!) == adventure && view.screen == .world
    view.beginSettingsEditor(standard,practice: true) { result = $0 }
    view.settingsEditor!.model.focus = 6;view.settingsClick(x: 56,y: 92)
    checks["settings_native_mouse_toggles_recovered_checkbox"] = view.settingsEditor?.model.checked(6) == !standard.enabled(0,mask: 4)
    view.settingsEditor!.model.phase = 0;try view.render();try view.canvas.writePNG(to: output.appendingPathComponent("native-original-practice-settings.png"))
    view.settingsEditor!.model.value = .init(bytes: [UInt8](repeating: 0,count: 13));view.settingsEditor!.model.focus = 28;view.settingsKey(event(36));try view.render();try view.canvas.writePNG(to: output.appendingPathComponent("native-original-settings-warning.png"))
    view.keyDown(with: event(36));view.keyDown(with: event(49));view.step()
    checks["settings_warning_Enter_can_leave_child_notice_without_deadlock"] = view.settingsEditor?.model.warning == nil && view.settingsEditor?.model.focus == 1
    checks["settings_notice_FIFO_Enter_precedes_later_Space_and_flushes_it"] = view.keyboard.values.isEmpty && view.settingsEditor?.model.checked(1) == false
    view.settingsKey(event(53))
    //Separate profile with no unfinished game exercises the real custom path.
    let newMember = try view.profileStore.create(name: "Custom");try view.profileStore.select(newMember.id);view.session = nil;view.screen = .menu
    view.playGame(custom: true)
    checks["settings_custom_game_waits_for_editor_instead_of_starting"] = view.settingsEditor != nil && view.session == nil
    view.settingsEditor!.model.focus = 27;view.settingsKey(event(49));view.settingsKey(event(36))
    checks["settings_custom_accept_persists_and_applies_level_to_new_game"] = try view.settingsEditor == nil && view.screen == .world && view.session.gameSettings == .defaults(tier: 3) && view.selectedProfile?.customGameSettings == .defaults(tier: 3) && view.saves.load(newMember.id)?.gameSettings == .defaults(tier: 3)
    let customAdventure = try encoder.encode(view.session!)
    view.startPractice();view.settingsEditor!.model.focus = 27;view.settingsKey(event(49));view.settingsEditor!.model.focus = 28;view.settingsKey(event(36))
    checks["settings_practice_accept_uses_twenty_problem_set_and_separate_record"] = view.screen == .practice && view.practice?.drill.questionCount == 20 && view.selectedProfile?.practiceSettings?.selection == 3 && view.selectedProfile?.customGameSettings == .defaults(tier: 3)
    checks["settings_practice_configuration_keeps_unfinished_custom_adventure"] = try encoder.encode(view.session!) == customAdventure && view.saves.load(newMember.id)?.gameSettings == .defaults(tier: 3)
    //Use an injected message presenter to verify source idle guidance safely.
    let guide = try NativeGameView(root: root,saveDirectory: directory.appendingPathComponent("guidance"),automaticallyPresentMessages: true)
    guide.timer?.invalidate();guide.zapTimer?.invalidate();guide.soundEnabled = false
    guide.menuMessages = NativeNewUserMessages(enabled: true);var shown: [Int] = [];guide.messagePresenter = { id,_ in shown.append(id) }
    guide.beginSettingsEditor(standard,practice: false) { _ in }
    for _ in 0..<52 { guide.step() }
    checks["settings_idle_guidance_waits_source_poll_after_1200_IRQ"] = shown.isEmpty
    guide.step();guide.step()
    checks["settings_idle_game_guidance_shows_once_and_keeps_editor"] = shown == [15] && guide.settingsEditor != nil && guide.modalDepth == 1
    guide.settingsKey(event(53))
    return checks
}
