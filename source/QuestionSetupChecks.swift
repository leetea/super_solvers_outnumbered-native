import Cocoa

func nativeQuestionSetupChecks(root: URL,output: URL) throws -> [String:Bool] {
    var checks: [String:Bool] = [:]
    let bank = try JSONDecoder().decode(ChallengeBank.self,from: Data(contentsOf: root.appendingPathComponent("challenges.json")))
    let expectedSeeds = [7,1,3,1,7,8,6,6,9,7]
    for tier in 0..<4 {
        var random = DecoderGenerator(seed: 1)
        let setup = try OriginalQuestionSetup(tier: tier,settings: .defaults(tier: tier),generator: &random)
        checks["original_setup_tier_\(tier)_seed_one_seed_table"] = setup.seeds == expectedSeeds
        checks["original_setup_tier_\(tier)_variant_and_operation_order"] = setup.variants == (tier < 2 ? [0,3,0,1,1,1,3,1,2,1] : [0,3,0,0,3,3,2,2,0,3]) && setup.operations == (tier < 2 ? [3,0,0,3,3,0,0,3,0,0] : [3,1,0,2,1,2,2,2,1,0])
        checks["original_setup_tier_\(tier)_eligible_slots_and_rng"] = setup.enabled.indices.filter { setup.enabled[$0] } == (tier < 2 ? [1,3,5,6,9] : Array(0..<10)) && random.randomState == (tier < 2 ? 3639521104 : 1298662723)
    }
    var allSettings = true, allRecords = true
    let keys = Set(bank.cases.map { "\($0.id)-\($0.seed)-\($0.variant)" })
    // Every nonempty operation selection and math level, including custom
    // settings which differ from rank. Defaults alone miss these combinations.
    for tier in 0..<4 { for level in 0..<4 { for mask in 1..<16 {
        var random = DecoderGenerator(seed: UInt32(tier*1000+level*100+mask))
        let settings = OriginalQuestionSettings(mathLevel: level,enabledOperationRows: (0..<4).map { mask & (1<<$0) != 0 })
        let setup = try OriginalQuestionSetup(tier: tier,settings: settings,generator: &random)
        allSettings = allSettings && setup.valid && setup.enabled.filter { $0 }.count == (tier < 2 ? 5 : 10)
        for hotspot in 0..<10 {
            let offset = [[0,0,0,0],[5,0,0,5],[5,0,0,5],[5,5,5,5]][level][setup.operations[hotspot]]
            allSettings = allSettings && setup.recordID(hotspot: hotspot) == OriginalQuestionSetup.familyBases[hotspot]+offset+setup.operations[hotspot]
            allRecords = allRecords && keys.contains("\(setup.recordID(hotspot: hotspot))-\(setup.seeds[hotspot])-\(setup.variants[hotspot])")
        }
    } } }
    checks["original_question_all_240_rank_custom_settings"] = allSettings
    checks["original_question_all_settings_have_exact_bank_identity"] = allRecords
    var random = DecoderGenerator(seed: 1)
    do {
        _ = try OriginalQuestionSetup(tier: 0,settings: .init(mathLevel: 0,enabledOperationRows: [false,false,false,false]),generator: &random)
        checks["empty_operation_configuration_rejected_without_rejection_loop"] = false
    } catch { checks["empty_operation_configuration_rejected_without_rejection_loop"] = random.randomState == 1 }
    var session = NativeSession(profileID: UUID(),seed: 1)
    checks["junior_inactive_map_has_no_assigned_question"] = try session.question(hotspot: 0,bank: bank) == nil && session.assignedChallenges.isEmpty
    let assigned = try session.question(hotspot: 1,bank: bank)
    checks["junior_active_bar_exact_original_identity"] = assigned?.id == 9010 && assigned?.seed == 1 && assigned?.variant == 3 && assigned?.answer == 165
    checks["assigned_question_does_not_redraw_setup"] = try session.question(hotspot: 1,bank: bank)?.answer == 165 && session.assignedChallenges.count == 1
    let encoded = try JSONEncoder().encode(session)
    let restored = try JSONDecoder().decode(NativeSession.self,from: encoded)
    checks["question_choices_survive_save"] = restored.questionSetup == session.questionSetup && restored.generator.randomState == session.generator.randomState && restored.valid
    var legacy = try JSONSerialization.jsonObject(with: encoded) as! [String:Any]
    legacy.removeValue(forKey: "questionSetup")
    var migrated = try JSONDecoder().decode(NativeSession.self,from: JSONSerialization.data(withJSONObject: legacy))
    let oldDecoder = migrated.decoder
    migrated.ensureQuestionSetup(); let once = migrated.generator.randomState; migrated.ensureQuestionSetup()
    checks["legacy_question_migration_once_keeps_decoder_and_assignment"] = migrated.migratedQuestionSetup == true && migrated.valid && migrated.decoder == oldDecoder && migrated.assignedChallenges[1]?.answer == 165 && migrated.generator.randomState == once
    for tier in 0..<4 {
        let points = VerifiedRank.thresholds[tier*2]
        let game = NativeSession(profileID: UUID(),seed: 1,lifetimePoints: points)
        var stream = DecoderGenerator(seed: 1)
        _ = try OriginalQuestionSetup(tier: game.decoder.difficulty,settings: .defaults(tier: game.decoder.difficulty),generator: &stream)
        let decoder = stream.makePuzzle(difficulty: game.decoder.difficulty)
        let machine = OriginalWorld.energyMachineCandidates[stream.nextRandomValue()%9]
        checks["original_new_game_question_decoder_fountain_order_\(tier)"] = game.decoder.difficulty == tier && game.decoder == decoder && game.energyMachineSlot == machine && game.generator.randomState == stream.randomState
    }
    let aliases = bank.cases.filter { $0.id == 9056 && $0.variant > 0 }
    checks["original_30_cross_group_empty_paragraph_cases_retained"] = aliases.count == 30 && aliases.allSatisfy { $0.question_parts.count == 2 && $0.question_parts[1] == "" && $0.post_generation_rng_state != nil }
    checks["complete_3200_case_matrix_has_post_generation_rng"] = bank.cases.count == 3200 && keys.count == 3200 && bank.cases.allSatisfy { $0.post_generation_rng_state != nil }
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent("outnumbered-question-setup-"+UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let view = try NativeGameView(root: root,saveDirectory: directory)
    view.timer?.invalidate(); view.zapTimer?.invalidate(); view.soundEnabled = false
    view.referenceJuniorQuestions(); try view.render()
    checks["native_interaction_uses_startup_selected_junior_question"] = view.screen == .question && view.session.activeChallenge?.answer == 165 && view.session.generator.randomState == 2613937339
    try view.canvas.writePNG(to: output.appendingPathComponent("native-junior-selected-question.png"))
    view.leaveQuestion(); view.session.position.playerUnit = 26; view.interact()
    checks["native_interaction_rejects_inactive_junior_question"] = view.screen == .world && view.session.activeChallenge == nil
    for hotspot in [4,7] {
        let challenge = bank.cases.first { $0.hotspot == hotspot && $0.seed == 1 && $0.variant == 0 }!
        view.open(challenge)
        let drawing = view.session.activityStates?[hotspot], state = view.session.generator.randomState
        view.leaveQuestion(); _ = view.session.generator.nextRandomValue(); view.open(challenge)
        checks["original_activity_\(hotspot)_reseed_and_auxiliary_stream_repeat"] = drawing == view.session.activityStates?[hotspot] && state == view.session.generator.randomState
        let before = view.session.generator.randomState
        try view.prepareActivityState(challenge)
        checks["original_activity_\(hotspot)_resume_preserves_stream"] = before == view.session.generator.randomState
    }
    return checks
}
