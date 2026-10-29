import Foundation

func nativeScoreChecks(root: URL,output: URL) throws -> [String:Bool] {
    var checks: [String:Bool] = [:]
    func entry(_ name: String,_ score: UInt16) -> NativeHighGameScore {
        NativeHighGameScore(name: name,score: score,rank: .trainee,runID: UUID())
    }
    var scores: [NativeHighGameScore] = []
    for i in 1...12 { scores = OriginalScoreTable.adding(entry("Game\(i)",UInt16(i*100)),to: scores) }
    checks["high_games_keeps_original_top_ten_descending"] = scores.map(\.score) == [1200,1100,1000,900,800,700,600,500,400,300]
    let tied = OriginalScoreTable.adding(entry("Tie",1000),to: scores)
    checks["high_game_equal_score_follows_existing_entries"] = tied[2].name == "Game10" && tied[3].name == "Tie" && tied.count == 10
    checks["high_game_tie_with_tenth_does_not_qualify"] = OriginalScoreTable.adding(entry("Last",300),to: scores).map(\.runID) == scores.map(\.runID)
    checks["zero_game_does_not_enter_empty_table"] = OriginalScoreTable.adding(entry("Zero",0),to: []).isEmpty
    let maximum = OriginalScoreTable.adding(entry("Max",65535),to: scores)
    checks["high_game_unsigned_word_score_not_signed"] = maximum.first?.score == 65535 && maximum.count == 10
    checks["high_game_repeated_run_not_inserted_again"] = OriginalScoreTable.adding(maximum[0],to: maximum).count == 10 && OriginalScoreTable.adding(maximum[0],to: maximum).map(\.runID) == maximum.map(\.runID)
    checks["original_score_comma_format"] = [0,999,1000,65535,999999,1000000,9999999].map(OriginalScoreTable.formatted) == ["0","999","1,000","65,535","999,999","1,000,000","9,999,999"]
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent("outnumbered-scores-"+UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let view = try NativeGameView(root: root,saveDirectory: directory,automaticallyPresentMessages: false)
    view.timer?.invalidate(); view.zapTimer?.invalidate(); view.soundEnabled = false
    let profile = try view.profileStore.create(name: "Player")
    let run = UUID()
    _ = try view.profileStore.recordFinishedSession(profileID: profile.id,runID: run,score: 5000,won: true,lifetimeBefore: 0)
    checks["high_game_records_pre_award_rank_on_promotion"] = view.profileStore.document.highGameScores?.first?.rank == .trainee && view.profileStore.document.profiles[0].lifetimePoints == 5000
    let first = try Data(contentsOf: view.profileStore.file)
    _ = try view.profileStore.recordFinishedSession(profileID: profile.id,runID: run,score: 5000,won: true,lifetimeBefore: 0)
    checks["score_commit_recovery_does_not_duplicate_table_or_write"] = try first == Data(contentsOf: view.profileStore.file) && view.profileStore.document.highGameScores?.count == 1
    _ = try view.profileStore.recordFinishedSession(profileID: profile.id,runID: UUID(),score: 65535,won: false,lifetimeBefore: 5000)
    checks["loss_does_not_enter_high_games_or_add_lifetime"] = view.profileStore.document.highGameScores?.count == 1 && view.profileStore.document.profiles[0].lifetimePoints == 5000
    _ = try view.profileStore.recordFinishedSession(profileID: profile.id,runID: UUID(),score: 55000,won: true,lifetimeBefore: 5000)
    let reopened = try NativeProfileStore(directory: directory)
    checks["high_games_persist_in_atomic_profile_document"] = reopened.document.highGameScores?.map(\.score) == [55000,5000] && reopened.document.highGameScores?.first?.rank == .junior && reopened.document.profiles[0].lifetimePoints == 60000
    let another = try view.profileStore.create(name: "Another")
    _ = try view.profileStore.recordFinishedSession(profileID: another.id,runID: UUID(),score: 6000,won: true,lifetimeBefore: 0)
    checks["high_game_history_shared_across_players"] = view.profileStore.document.highGameScores?.map(\.name) == ["Player","Another","Player"]
    var tieProfiles = view.profileStore.document.profiles
    tieProfiles.append(NativeProfile(id: UUID(),name: "Third",createdAt: Date(),updatedAt: Date(),lifetimePoints: 100000))
    tieProfiles[0].lifetimePoints = 100; tieProfiles[1].lifetimePoints = 100
    checks["lifetime_pairwise_swap_preserves_original_tie_behavior"] = OriginalScoreTable.lifetimeOrder(tieProfiles).map(\.name) == ["Third","Another","Player"]
    view.showHighGameScores(); try view.render()
    try view.canvas.writePNG(to: output.appendingPathComponent("native-high-game-scores.png"))
    let pixels = view.canvas.pixels; try view.render()
    checks["high_score_screen_renders_original_panel_repeatably"] = view.screen == .scores && pixels == view.canvas.pixels && pixels[161*320+19] == 1 && pixels[158*320+20] == 15
    view.closeScores()
    checks["scores_available_before_active_adventure"] = view.screen == .title && view.session == nil
    view.begin(); view.showLifetimeScores()
    let encoder = JSONEncoder(); encoder.outputFormatting = .sortedKeys
    let paused = try encoder.encode(view.session!)
    for _ in 0..<50 { view.step() }
    checks["score_screen_pauses_adventure_without_rng_or_state_changes"] = try view.screen == .scores && view.session.clock.pauseDepth == 1 && encoder.encode(view.session!) == paused
    view.toggleHelp(); view.closeHelp(); view.closeScores()
    checks["help_over_scores_restores_only_owned_pause"] = view.screen == .world && view.session.clock.pauseDepth == 0
    view.showHighGameScores(); view.showPlayerMenu()
    checks["f2_score_exit_cleans_transient_pause"] = view.screen == .menu && view.session.clock.pauseDepth == 0
    for i in 0..<10 { _ = try view.profileStore.create(name: "Extra\(i)") }
    view.showLifetimeScores(); view.scorePage = 1; try view.render()
    checks["native_extra_profiles_paginate_ten_rows_without_mutation"] = view.scorePage == 1 && view.profileStore.document.profiles.count == 12
    try view.canvas.writePNG(to: output.appendingPathComponent("native-lifetime-scores.png"))
    var legacy = try JSONSerialization.jsonObject(with: Data(contentsOf: view.profileStore.file)) as! [String:Any]
    legacy.removeValue(forKey: "highGameScores")
    try JSONSerialization.data(withJSONObject: legacy).write(to: view.profileStore.file)
    checks["pre_history_native_profiles_remain_readable"] = try NativeProfileStore(directory: directory).document.highGameScores == nil
    legacy["highGameScores"] = try JSONSerialization.jsonObject(with: encoder.encode([entry("Lower",1),entry("Higher",2)]))
    let invalid = try JSONSerialization.data(withJSONObject: legacy); try invalid.write(to: view.profileStore.file)
    do { _ = try NativeProfileStore(directory: directory); checks["invalid_unsorted_score_history_rejected_and_preserved"] = false }
    catch { checks["invalid_unsorted_score_history_rejected_and_preserved"] = try Data(contentsOf: view.profileStore.file) == invalid }
    return checks
}
