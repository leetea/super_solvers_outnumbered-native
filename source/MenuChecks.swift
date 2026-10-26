import Cocoa

func nativeMenuChecks(root: URL,output: URL) throws -> [String:Bool] {
    var checks: [String:Bool] = [:]
    for tier in 0..<4 {
        let defaults = OriginalGameSettings.defaults(tier: tier)
        checks["settings_source_tier_\(tier)_shared_record"] = defaults.valid && defaults.selection == tier && defaults.practiceQuestionCount == [5,10,15,20][tier] && defaults.questionSettings == .defaults(tier: tier)
    }
    var settings = OriginalGameSettings(bytes: [UInt8](repeating: 0,count: 13))
    checks["settings_empty_groups_original_validation"] = settings.validationMessage == "You need to have at least one box checked in each area."
    settings.set(3,mask: 16,enabled: true); settings.set(0,mask: 4,enabled: true); settings.set(2,mask: 8,enabled: true)
    checks["settings_division_only_zero_original_validation"] = settings.validationMessage == "You need to choose more numbers to do division."
    settings.set(12,mask: 4,enabled: true); settings.selection = 3
    checks["settings_division_nonzero_allowed_no_lost_masks"] = settings.valid && settings.bytes[0] == 7 && settings.bytes[2] == 8 && settings.bytes[3] == 16 && settings.bytes[12] == 4 && settings.questionSettings.mathLevel == 3
    for i in 0..<4 {
        var selected = settings; selected.selection = i
        var random = DecoderGenerator(seed: 1)
        let drill = try NativeDrill(tier: 3,nextRandom: { random.nextRandomValue() },settings: selected,practice: true)
        checks["practice_count_\(i)_independent_of_adventure_rank"] = drill.questionCount == [5,10,15,20][i] && drill.valid && !drill.entitledToCode && drill.question.operation == .division && drill.question.blank == .right
    }
    var random = DecoderGenerator(seed: 1)
    let customDrill = try NativeDrill(tier: 0,nextRandom: { random.nextRandomValue() },settings: settings)
    checks["custom_game_uses_selected_drill_pool_retains_rank_set_size"] = customDrill.questionCount == 4 && customDrill.question.operation == .division && customDrill.question.blank == .right
    let custom = NativeSession(profileID: UUID(),seed: 1,settings: settings)
    checks["custom_game_operation_and_math_level_reach_rooms"] = custom.valid && custom.gameSettings == settings && custom.questionSetup!.operations.allSatisfy { $0 == 1 } && custom.questionSetup!.settings.mathLevel == 3
    var invalid = custom; invalid.gameSettings = .init(bytes: [0])
    checks["invalid_custom_settings_rejected_from_session"] = !invalid.valid
    var sourceRNG = DecoderGenerator(seed: 1)
    _ = sourceRNG.makePuzzle(difficulty: 3)
    let seed = UInt32(sourceRNG.nextRandomValue())
    let continued = NativeSession(profileID: UUID(),seed: seed,lifetimePoints: 300000,previousGenerator: sourceRNG)
    var expectedRNG = sourceRNG; expectedRNG.restoreRandomState(seed)
    _ = try OriginalQuestionSetup(tier: 3,settings: .defaults(tier: 3),generator: &expectedRNG)
    let expectedDecoder = expectedRNG.makePuzzle(difficulty: 3)
    checks["new_game_preserves_mutated_decoder_pools_after_srand"] = continued.decoder == expectedDecoder && continued.generator.randomState != seed
    var practice = try NativePractice(settings: .defaults(tier: 0),seed: 1)
    checks["practice_intro_starts_before_first_problem"] = practice.attempts == 0 && practice.correctAnswers == 0 && practice.presentation == .introduction
    let intro = try practice.advance(irqTicks: 160)
    checks["practice_intro_eight_twenty_tick_frames_then_stop"] = intro == Array(repeating: .sound(23),count: 8)+[.stop] && practice.presentation == .questions && practice.attempts == 0
    for index in 0..<5 {
        _ = try practice.advance(irqTicks: 240)
        for c in String(practice.drill.question.expected) { practice.drill.digit(Int(String(c))!) }
        let answer = practice.submit()
        checks["practice_problem_\(index)_answer_accepted"] = answer == true
        _ = try practice.advance(irqTicks: 239)
        let before = practice.correctAnswers
        let sounds = try practice.advance(irqTicks: 1)
        checks["practice_problem_\(index)_correct_count_after_first_wait"] = before == index && practice.correctAnswers == index+1 && sounds == [.sound(37)]
        _ = try practice.advance(irqTicks: 240)
    }
    checks["practice_set_finishes_without_game_rewards"] = practice.attempts == 5 && practice.correctAnswers == 5 && practice.drill.phase == .finished && !practice.drill.entitledToCode && practice.drill.capturedSymbol == nil && practice.resultSound == 40
    let perfectResponse = practice
    try practice.nextSet()
    checks["practice_enter_cannot_skip_response"] = practice.presentation == .response && practice.drill.answered == 5
    _ = try practice.advance(irqTicks: 2131,soundPlaying: true)
    checks["practice_perfect_response_waits_for_sound"] = practice.presentation == .waitingForSound
    _ = try practice.advance(irqTicks: 1,soundPlaying: false)
    checks["practice_finished_sound_reveals_continue_prompt"] = practice.presentation == .continuePrompt
    try practice.nextSet()
    checks["practice_enter_another_set_keeps_running_counters"] = practice.attempts == 5 && practice.correctAnswers == 5 && practice.drill.answered == 0 && practice.presentation == .introduction
    _ = try practice.advance(irqTicks: 279)
    checks["practice_counter_waits_120_ticks_after_intro"] = practice.attempts == 5
    _ = try practice.advance(irqTicks: 1)
    checks["practice_counter_advances_at_source_boundary"] = practice.attempts == 6
    checks["practice_original_script_counts_durations"] = OriginalPracticePresentation.scripts.map(\.count) == [21,25,62] && (0..<3).map { OriginalPracticePresentation.duration($0) } == [900,1020,2130]
    checks["practice_original_script_restore_and_mirror"] = OriginalPracticePresentation.scripts.allSatisfy { commands in
        commands.enumerated().allSatisfy { i,c in c.restoreCommand <= i && c.resource >= 0 && [64,96].contains(c.flags) }
    } && OriginalPracticePresentation.scripts[0][12].flags == 96
    var timerPractice = try NativePractice(settings: .defaults(tier: 0),seed: 1)
    _ = try timerPractice.advance(irqTicks: 160)
    checks["practice_intro_does_not_increment_timer"] = timerPractice.elapsedSeconds == 0
    _ = try timerPractice.advance(irqTicks: 240)
    _ = try timerPractice.advance(irqTicks: 239)
    checks["practice_timer_first_source_deadline"] = timerPractice.elapsedSeconds == 1
    _ = try timerPractice.advance(irqTicks: 1)
    checks["practice_timer_next_source_deadline"] = timerPractice.elapsedSeconds == 2
    var responseFixtures = [2:perfectResponse]
    var variants = Set<Int>(), sounds = Set<Int>()
    for seed in UInt32(1)...32 {
        var response = try NativePractice(settings: .defaults(tier: 0),seed: seed)
        _ = try response.advance(irqTicks: 160)
        for index in 0..<5 {
            _ = try response.advance(irqTicks: 240)
            let answer = index == 4 ? (response.drill.question.expected+1)%1000 : response.drill.question.expected
            for digit in String(answer) { response.drill.digit(Int(String(digit))!) }
            _ = response.submit()
            let before = response.generator
            _ = try response.advance(irqTicks: index == 4 ? 1200 : 480)
            if index == 4 {
                var expected = before
                let sound = [28,34][expected.nextRandomValue()%2], variant = expected.nextRandomValue()%2
                checks["practice_imperfect_seed_\(seed)_two_source_draws"] = response.generator.randomState == expected.randomState && response.resultSound == sound && response.resultVariant == variant
            }
        }
        responseFixtures[response.resultVariant] = response
        variants.insert(response.resultVariant); sounds.insert(response.resultSound)
        _ = try response.advance(irqTicks: OriginalPracticePresentation.duration(response.resultVariant)+1)
        checks["practice_imperfect_seed_\(seed)_response_complete"] = response.presentation == .continuePrompt && response.correctAnswers == 4 && response.attempts == 5
    }
    checks["practice_imperfect_both_sounds_and_scripts_reached"] = variants == [0,1] && sounds == [28,34]
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent("outnumbered-menus-"+UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let view = try NativeGameView(root: root,saveDirectory: directory,automaticallyPresentMessages: false)
    view.timer?.invalidate(); view.zapTimer?.invalidate(); view.soundEnabled = false
    let first = try view.profileStore.create(name: "Practice player"), second = try view.profileStore.create(name: "Other player")
    try view.profileStore.select(first.id)
    try view.profileStore.saveSettings(profileID: first.id,settings: settings,practice: false)
    try view.profileStore.saveSettings(profileID: first.id,settings: .defaults(tier: 1),practice: true)
    let reloaded = try NativeProfileStore(directory: directory)
    checks["profile_separate_game_practice_settings_survive_restart"] = reloaded.document.profiles[0].customGameSettings == settings && reloaded.document.profiles[0].practiceSettings == .defaults(tier: 1) && reloaded.document.profiles[1].customGameSettings == nil && reloaded.document.profiles[1].practiceSettings == nil
    view.session = NativeSession(profileID: first.id,seed: 17); view.session.score = 500
    view.session.energy = 7; view.session.clock.applyMinutePenalty(21); view.screen = .world; view.save()
    let encoder = JSONEncoder(); encoder.outputFormatting = .sortedKeys
    let saved = try Data(contentsOf: view.saves.file(first.id)), snapshot = try encoder.encode(view.session!)
    try view.launchPractice(settings: .defaults(tier: 0),seed: 1)
    for _ in 0..<100 { view.step() }
    checks["practice_does_not_tick_or_modify_suspended_adventure"] = try encoder.encode(view.session!) == snapshot && Data(contentsOf: view.saves.file(first.id)) == saved
    try view.render(); try view.canvas.writePNG(to: output.appendingPathComponent("native-practice-question.png"))
    let questionPixels = view.canvas.pixels
    var blankPractice = try NativePractice(settings: .defaults(tier: 0),seed: 1)
    _ = try blankPractice.advance(irqTicks: 160)
    let activePractice = view.practice; view.practice = blankPractice
    try view.render()
    checks["practice_question_visible_above_original_screen_art"] = view.canvas.pixels != questionPixels
    view.practice = activePractice; try view.render()
    let firstPixels = view.canvas.pixels
    try view.render()
    checks["practice_repaint_preserves_static_labels"] = view.canvas.pixels == firstPixels
    try view.canvas.writePNG(to: output.appendingPathComponent("native-practice-repaint.png"))
    for c in String(view.practice!.drill.question.expected) { view.practice!.drill.digit(Int(String(c))!) }
    _ = view.practice!.submit()
    for _ in 0..<30 { view.step() }
    checks["practice_correct_answer_no_adventure_score_clue_or_energy_award"] = view.session.score == 500 && view.session.energy == 7 && view.session.decoder.capturedCount == 0 && view.session.clock.elapsedMinutes == 21 && view.practice!.correctAnswers == 1
    let suspendedPractice = view.practice
    for variant in 0..<3 {
        view.practice = responseFixtures[variant]!
        try view.render()
        let first = view.canvas.pixels
        _ = try view.practice!.advance(irqTicks: 300)
        try view.render()
        checks["practice_animation_\(variant)_changes_original_pose"] = view.canvas.pixels != first
        try view.canvas.writePNG(to: output.appendingPathComponent("native-practice-response-\(variant).png"))
        let animated = view.canvas.pixels; try view.render()
        checks["practice_animation_\(variant)_repaint_no_trails"] = view.canvas.pixels == animated
        _ = try view.practice!.advance(irqTicks: 3000)
        try view.render()
        checks["practice_animation_\(variant)_continue_prompt_after_end"] = view.practice!.presentation == .continuePrompt
        try view.canvas.writePNG(to: output.appendingPathComponent("native-practice-continue-\(variant).png"))
    }
    checks["practice_response_render_keeps_adventure_file_unchanged"] = try Data(contentsOf: view.saves.file(first.id)) == saved
    view.practice = suspendedPractice
    view.showPlayerMenu(); try view.render()
    try view.canvas.writePNG(to: output.appendingPathComponent("native-player-menu.png"))
    checks["practice_escape_returns_menu_and_keeps_game_saved"] = view.screen == .menu && view.practice == nil && view.session.score == 500 && view.session.clock.elapsedMinutes == 21
    view.begin()
    checks["suspended_adventure_resumes_after_practice"] = view.screen == .world && view.session.score == 500 && view.session.energy == 7 && view.session.clock.elapsedMinutes == 21 && view.session.activeDrill == nil
    try view.profileStore.select(second.id); view.begin()
    checks["select_another_player_has_independent_adventure"] = view.session.profileID == second.id && view.session.score == 0 && view.session.energy == 12
    try view.profileStore.select(first.id); view.begin()
    checks["switch_back_restores_first_player_adventure"] = view.session.profileID == first.id && view.session.score == 500 && view.session.energy == 7
    let before = view.session.clock.counterTicks
    view.modalDepth = 1; view.step(); view.modalDepth = 0
    checks["native_modal_dialog_freezes_adventure_clock"] = view.session.clock.counterTicks == before
    view.showPlayerMenu(); view.step()
    checks["player_menu_freezes_adventure_clock"] = view.session.clock.counterTicks == before
    var legacy = try JSONSerialization.jsonObject(with: JSONEncoder().encode(view.session!)) as! [String:Any]
    legacy.removeValue(forKey: "gameSettings")
    checks["legacy_session_without_shared_settings_still_loads"] = try JSONDecoder().decode(NativeSession.self,from: JSONSerialization.data(withJSONObject: legacy)).valid
    let profileBytes = try Data(contentsOf: reloaded.file)
    var legacyProfile = try JSONSerialization.jsonObject(with: profileBytes) as! [String:Any]
    var profiles = legacyProfile["profiles"] as! [[String:Any]]
    for index in profiles.indices { profiles[index].removeValue(forKey: "customGameSettings"); profiles[index].removeValue(forKey: "practiceSettings") }
    legacyProfile["profiles"] = profiles
    try JSONSerialization.data(withJSONObject: legacyProfile).write(to: reloaded.file)
    checks["legacy_profiles_without_custom_settings_still_load"] = try NativeProfileStore(directory: directory).document.profiles.count == 2
    return checks
}
