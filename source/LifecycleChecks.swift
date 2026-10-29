import Cocoa

func nativeLifecycleChecks(root: URL,output: URL) throws -> [String:Bool] {
    var checks: [String:Bool] = [:]
    func event(_ key: UInt16,_ text: String = "") -> NSEvent {
        NSEvent.keyEvent(with: .keyDown,location: .zero,modifierFlags: [],timestamp: 0,windowNumber: 0,context: nil,characters: text,charactersIgnoringModifiers: text,isARepeat: false,keyCode: key)!
    }
    let directory = output.appendingPathComponent("lifecycle-players-"+UUID().uuidString)
    let view = try NativeGameView(root: root,saveDirectory: directory,automaticallyPresentMessages: false)
    view.timer?.invalidate();view.zapTimer?.invalidate();view.soundEnabled = false
    let profile = try view.profileStore.create(name: "Life")
    let encoder = JSONEncoder();encoder.outputFormatting = [.sortedKeys]
    func start() {
        view.session = NativeSession(profileID: profile.id,seed: 42)
        view.session.score = 600;view.screen = .world;view.referenceMode = false;view.practice = nil
        view.save()
    }
    func file(_ row: Int) { view.showFileMenu();view.fileSelection = row;view.activateFileItem() }
    start()
    let original = try encoder.encode(view.session!),profileBytes = try Data(contentsOf: view.profileStore.file)
    try view.render();let toolbar = Array(view.canvas.pixels.prefix(320*12))
    file(2)
    checks["lifecycle_game_PlayAnother_original_body_defaultNo_no_File_popup"] = view.confirmation?.original.title == "Play New Game" && view.confirmation?.original.text.hasPrefix("If you start another game,") == true && view.confirmation?.original.selection == 0 && view.screen == .world && view.modalDepth == 1
    for _ in 0..<20 { view.step() }
    checks["lifecycle_PlayAnother_question_score_rng_clock_remain_frozen"] = try encoder.encode(view.session!) == original
    try view.render();try view.canvas.writePNG(to: output.appendingPathComponent("native-play-another-confirm.png"))
    checks["lifecycle_confirmation_backdrop_has_neutral_parent_toolbar"] = Array(view.canvas.pixels.prefix(320*12)) == toolbar
    view.keyDown(with: event(36))
    checks["lifecycle_PlayAnother_defaultNo_returns_game_and_preserves_save"] = try view.confirmation == nil && view.screen == .world && encoder.encode(view.saves.load(profile.id)!) == original
    file(2);view.keyDown(with: event(53))
    checks["lifecycle_PlayAnother_Escape_does_not_discard"] = try view.screen == .world && view.session.outcome == "active" && encoder.encode(view.session!) == original
    file(3)
    checks["lifecycle_game_NewPlayer_original_saved_game_wording_defaultNo"] = view.confirmation?.original.title == "Start New Player" && view.confirmation?.original.selection == 0 && view.confirmation?.original.text.contains("Your game, score, and rank") == true
    try view.render();try view.canvas.writePNG(to: output.appendingPathComponent("native-new-player-confirm.png"))
    view.keyDown(with: event(45,"n"))
    checks["lifecycle_NewPlayer_No_keeps_identity_adventure_and_profile_bytes"] = try view.screen == .world && view.session.profileID == profile.id && encoder.encode(view.session!) == original && Data(contentsOf: view.profileStore.file) == profileBytes
    file(3);view.keyDown(with: event(16,"y"))
    checks["lifecycle_NewPlayer_Yes_saves_exact_unfinished_game_and_opens_signin"] = try view.screen == .signin && view.confirmation == nil && encoder.encode(view.saves.load(profile.id)!) == original && view.profileStore.document.profiles.count == 1
    start();file(2);view.keyDown(with: event(16,"y"))
    checks["lifecycle_PlayAnother_Yes_marks_native_autosave_abandoned"] = try view.screen == .menu && view.session.outcome == "abandoned" && view.saves.load(profile.id)?.outcome == "abandoned" && view.session.valid
    checks["lifecycle_abandon_never_awards_lifetime_rank_or_high_score"] = try Data(contentsOf: view.profileStore.file) == profileBytes && view.profileStore.document.highGameScores?.isEmpty != false
    let reopened = try NativeGameView(root: root,saveDirectory: directory,automaticallyPresentMessages: false)
    reopened.timer?.invalidate();reopened.zapTimer?.invalidate();reopened.soundEnabled = false;reopened.screen = .menu
    reopened.playGame(custom: false)
    checks["lifecycle_cold_reopen_abandoned_save_starts_fresh_without_continue_prompt"] = reopened.screen == .world && reopened.confirmation == nil && reopened.session.score == 0 && reopened.session.outcome == "active" && reopened.session.profileID == profile.id
    start()
    let weather = view.bank.cases.first { $0.id == 9078 && $0.seed == 2 && $0.variant == 3 }!
    view.open(weather);view.session.activityPresentation = nil;view.session.attempts[weather.hotspot]?.input = "6";view.save()
    let question = try encoder.encode(view.session!)
    file(2);view.keyDown(with: event(45,"n"))
    checks["lifecycle_cancel_new_game_retains_partial_answer_and_question_pause"] = try view.screen == .question && view.session.clock.pauseDepth == 1 && encoder.encode(view.session!) == question
    file(3);view.keyDown(with: event(16,"y"))
    checks["lifecycle_new_player_from_question_persists_parent_pause_and_answer"] = try view.screen == .signin && encoder.encode(view.saves.load(profile.id)!) == question && view.saves.load(profile.id)?.attempts[weather.hotspot]?.input == "6"
    start();let adventure = try Data(contentsOf: view.saves.file(profile.id))
    try view.launchPractice(settings: .defaults(tier: 0),seed: 5)
    let practice = view.practice!
    view.save();file(0)
    checks["lifecycle_practice_PlayAnother_has_original_stop_drill_wording"] = view.confirmation?.original.text == "Are you sure you want\nto stop playing Drill for\nSkill?" && view.confirmation?.original.selection == 0 && view.screen == .practice
    try view.render();try view.canvas.writePNG(to: output.appendingPathComponent("native-practice-play-another-confirm.png"))
    view.keyDown(with: event(53))
    checks["lifecycle_practice_No_Escape_and_explicit_save_do_not_write_adventure"] = try encoder.encode(view.practice!.drill) == encoder.encode(practice.drill) && view.practice!.generator.randomState == practice.generator.randomState && view.practice!.presentation == practice.presentation && view.practice!.presentationTicks == practice.presentationTicks && view.practice!.attempts == practice.attempts && Data(contentsOf: view.saves.file(profile.id)) == adventure
    file(1)
    checks["lifecycle_practice_NewPlayer_original_settings_wording"] = view.confirmation?.original.text.contains("Your settings will be saved") == true && view.confirmation?.original.text.contains("Your game, score, and rank") == false
    view.keyDown(with: event(16,"y"));view.save()
    checks["lifecycle_practice_NewPlayer_Yes_clears_transient_session_preserves_save_bytes"] = try view.screen == .signin && view.session == nil && Data(contentsOf: view.saves.file(profile.id)) == adventure
    start();let resumedFile = try Data(contentsOf: view.saves.file(profile.id))
    try view.launchPractice(settings: .defaults(tier: 0),seed: 6)
    file(0);view.keyDown(with: event(16,"y"))
    checks["lifecycle_practice_PlayAnother_Yes_opens_choices_without_abandoning_adventure"] = try view.screen == .menu && view.session == nil && view.practice == nil && Data(contentsOf: view.saves.file(profile.id)) == resumedFile && view.saves.load(profile.id)?.outcome == "active"
    view.playGame(custom: false)
    checks["lifecycle_after_practice_original_adventure_still_offers_continue"] = view.confirmation?.original.text == OriginalConfirmation.continueSaved.text && view.confirmation?.original.selection == 1
    view.keyDown(with: event(36))
    checks["lifecycle_after_practice_continue_keeps_adventure_score"] = view.session.score == 600 && view.screen == .world
    try view.launchPractice(settings: .defaults(tier: 0),seed: 7)
    let beforeQuit = try Data(contentsOf: view.saves.file(profile.id))
    var exits = 0;view.requestApplicationExit = { exits += 1 };file(2)
    checks["lifecycle_practice_exit_uses_non_adventure_saving_text"] = view.confirmation?.original.text == OriginalConfirmation.exit(saving: false).text
    view.keyDown(with: event(16,"y"));view.save()
    checks["lifecycle_practice_exit_and_termination_save_guard_leave_adventure_bytes"] = try exits == 1 && Data(contentsOf: view.saves.file(profile.id)) == beforeQuit
    start();let shortcutFile = try Data(contentsOf: view.saves.file(profile.id))
    try view.launchPractice(settings: .defaults(tier: 0),seed: 8)
    view.choosePlayer();view.save()
    checks["lifecycle_native_new_player_shortcut_also_preserves_practice_adventure"] = try view.screen == .signin && view.session == nil && Data(contentsOf: view.saves.file(profile.id)) == shortcutFile
    start();file(0)
    let scoreScreen = try encoder.encode(view.session!)
    for code: UInt16 in [122,120,99] { view.keyDown(with: event(code)) }
    checks["lifecycle_scores_wait_ignores_function_menu_keys"] = try view.screen == .scores && encoder.encode(view.session!) == scoreScreen
    view.keyDown(with: event(76))
    checks["lifecycle_score_keypad_Enter_returns_parent_without_File_menu"] = view.screen == .world && view.helpBrowser == nil && view.optionsMenu == nil && view.session.clock.pauseDepth == 0
    view.toggleHelp();view.helpBrowser?.selectedTopic = 7;view.keyDown(with: event(36))
    try view.render()
    let neutral = try view.content.bitmap("FASTLOAD.GRA.057")
    checks["lifecycle_Help_page_restores_neutral_toolbar_before_callback"] = view.screen == .help && view.helpBrowser?.topic == 7 && neutral.width == 320 && Array(view.canvas.pixels.prefix(320*12)) == Array(neutral.pixels.prefix(320*12))
    for code: UInt16 in [120,99] { view.keyDown(with: event(code)) }
    checks["lifecycle_Help_page_ignores_F2_F3_without_losing_parent"] = view.screen == .help && view.helpBrowser?.topic == 7 && view.session.clock.pauseDepth == 1
    view.keyDown(with: event(36))
    checks["lifecycle_Help_Done_return1_rebuilds_topic_menu_selection_zero"] = view.screen == .help && view.helpBrowser?.topic == nil && view.helpBrowser?.selectedTopic == 0 && view.session.clock.pauseDepth == 1
    view.keyDown(with: event(36));view.keyDown(with: event(122))
    checks["lifecycle_Help_page_F1_matches_Done_rebuilds_topics"] = view.screen == .help && view.helpBrowser?.topic == nil && view.helpBrowser?.selectedTopic == 0
    view.keyDown(with: event(36));view.keyDown(with: event(53))
    checks["lifecycle_Help_Escape_return0_closes_all_Help_and_resumes_game"] = view.screen == .world && view.helpBrowser == nil && view.session.clock.pauseDepth == 0
    return checks
}
