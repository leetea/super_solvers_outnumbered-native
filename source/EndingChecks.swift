import Cocoa

func nativeEndingChecks(root: URL,output: URL) throws -> [String:Bool] {
    var checks: [String:Bool] = [:]
    let data = try JSONDecoder().decode(OriginalEndingData.self,from: Data(contentsOf: root.appendingPathComponent("ending-sequences.json")))
    checks["original_ending_14_scripts_403_commands"] = data.scripts.count == 14 && data.scripts.map { $0.commands.count }.reduce(0,+) == 403
    checks["original_ending_hallway_table_and_victory_steps"] = data.hallways == [1,3,6,7,8] && data.victory_steps == [50,100,150,250]
    checks["original_room_backgrounds_cartoon_equipment_sound"] = [13,14,15].map { OriginalWorld.backgroundSelector(forRoom: $0)! } == [196,197,198]
    let content = OriginalContent(root: root)
    var resources = true
    for script in data.scripts {
        for command in script.commands {
            if command.resource >= 0 {
                let file = command.resource < 10000 ? "FASTLOAD.GRA" : (script.name == "loss" || script.name == "room_wrong" ? "CLOSE2.GRA" : "CLOSE1.GRA")
                let bitmap = try content.bitmap(String(format: "%@.%03d",file,command.resource < 10000 ? command.resource : command.resource-10000))
                resources = resources && bitmap.width > 0 && bitmap.height > 0 && command.restoreCommand <= script.commands.count
            }
        }
    }
    checks["every_original_ending_sprite_and_restore_reference_available"] = resources
    let fixture = NativeEnding(reason: .hideout,room: 3,tier: 1,initialEnergy: 17,initialMinutes: 52,initialScore: 2650,initialLifetime: 52595,playerDialogue: 0,masterDialogue: 0)
    let timeline = EndingTimeline(fixture,data: data)
    let final = timeline.totals(at: timeline.duration)
    checks["video_ending_2650_to_11680_and_total_64275"] = final.score == 11680 && final.lifetime == 64275 && final.energy == 0 && final.minutes == 180 && VerifiedRank.forLifetimePoints(final.lifetime) == .pro
    var labels: [String:Int] = [:], times: [String:Int] = [:]
    for event in timeline.events { if case let .bonus(label,amount) = event.action { labels[label] = amount; times[label] = event.ticks } }
    checks["video_original_bonus_components_2550_4480_2000"] = labels == ["Energy Left":2550,"Time Left":4480,"Winning Game":2000]
    checks["original_bonus_award_stages_not_immediate_win"] = timeline.totals(at: 0).score == 2650 && timeline.totals(at: times["Time Left"]!).score == 5200 && timeline.totals(at: times["Winning Game"]!).score == 9680
    let cues = timeline.sounds(after: -1,through: timeline.duration)
    checks["script_sound_cues_interrupt_but_tally_cues_use_priority"] = cues.contains { $0.index == 26 && $0.interrupt } && cues.contains { $0.index == 37 && !$0.interrupt }
    var allTiers = true
    for tier in 0..<4 {
        let ending = NativeEnding(reason: .hideout,room: tier,tier: tier,initialEnergy: 127,initialMinutes: 0,initialScore: 65000,initialLifetime: 9_999_000,playerDialogue: 1,masterDialogue: 1)
        let program = EndingTimeline(ending,data: data), total = program.totals(at: program.duration)
        allTiers = allTiers && total.score == VerifiedScore.winningScore(sessionScore: 65000,rank: VerifiedRank.allCases[tier*2],energy: 127,minutesRemaining: 180) && total.lifetime <= 9_999_999 && total.energy == 0 && total.minutes == 180
    }
    checks["ending_all_tiers_preserve_uint16_score_and_lifetime_cap"] = allTiers
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent("outnumbered-ending-"+UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let view = try NativeGameView(root: root,saveDirectory: directory,automaticallyPresentMessages: false)
    view.timer?.invalidate(); view.zapTimer?.invalidate(); view.soundEnabled = false
    view.referenceEnding()
    checks["video_checkpoint_enters_equipment_reveal_without_early_win"] = view.session.activeEnding?.room == 3 && view.session.outcome == "active" && view.screen == .ending && view.session.score == 2650
    for (label,time) in times.sorted(by: { $0.value < $1.value }) {
        try view.advanceEnding(time-(view.session.activeEnding?.elapsedTicks ?? 0)); try view.render()
        let filename = label.replacingOccurrences(of: " ",with: "-").lowercased()
        try view.canvas.writePNG(to: output.appendingPathComponent("native-ending-"+filename+".png"))
    }
    let mid = try JSONEncoder().encode(view.session!)
    let resumed = try JSONDecoder().decode(NativeSession.self,from: mid)
    checks["ending_mid_tally_round_trip_preserves_progress"] = resumed.valid && resumed.activeEnding?.elapsedTicks == view.session.activeEnding?.elapsedTicks && resumed.score == 9680
    view.session = resumed
    let before = view.session.score; try view.advanceEnding(0)
    checks["ending_repaint_resume_does_not_duplicate_tally"] = view.session.score == before
    try view.advanceEnding(timeline.duration); try view.render()
    checks["native_ending_finishes_tally_before_committing_win"] = view.screen == .results && view.session.outcome == "won" && view.session.score == 11680 && view.session.lifetimePoints == 64275 && view.session.activeEnding?.committed == true && view.session.valid
    try view.canvas.writePNG(to: output.appendingPathComponent("native-ending-results.png"))
    let run = view.session.runID
    try view.beginNextGame()
    checks["next_game_retains_lifetime_and_rank_resets_game_progress"] = view.session.rank == .pro && view.session.lifetimePoints == 64275 && view.session.score == 0 && view.session.energy == 12 && view.session.clock.elapsedMinutes == 0 && view.session.runID != run && view.session.activeEnding == nil && view.screen == .world
    view.session = NativeSession(profileID: UUID(),seed: 1,lifetimePoints: 5000)
    view.session.score = 900; view.session.clock.applyMinutePenalty(52)
    let wrong = (view.session.decoder.hideoutRoom+1)%5
    view.startEnding(room: wrong)
    checks["wrong_hideout_starts_original_loss_sequence"] = view.session.activeEnding?.reason == .wrongHideout && view.session.outcome == "active"
    try view.advanceEnding(100000); try view.render()
    checks["wrong_hideout_zero_score_energy_no_lifetime_award"] = view.session.outcome == "lost" && view.session.score == 0 && view.session.energy == 0 && view.session.lifetimePoints == 5000 && view.screen == .results && view.session.valid
    try view.canvas.writePNG(to: output.appendingPathComponent("native-ending-wrong-hideout.png"))
    view.session = NativeSession(profileID: UUID(),seed: 1); view.session.score = 1800
    view.session.clock.applyMinutePenalty(180); view.screen = .world
    let state = view.session.generator.randomState
    view.step()
    checks["midnight_uses_loss_path_without_invented_hideout_search"] = view.session.activeEnding?.reason == .midnight && view.session.generator.randomState == state && view.screen == .ending
    try view.advanceEnding(1000)
    checks["midnight_finishes_with_zero_score_and_no_progression"] = view.session.outcome == "lost" && view.session.score == 0 && view.session.energy == 0 && view.session.lifetimePoints == 0 && view.session.clock.elapsedMinutes == 180
    let store = try NativeProfileStore(directory: directory.appendingPathComponent("profile-commit"))
    let player = try store.create(name: "Test player"), runID = UUID()
    let first = try store.recordFinishedSession(profileID: player.id,runID: runID,score: 11680,won: true,lifetimeBefore: 52595)
    let reloaded = try NativeProfileStore(directory: directory.appendingPathComponent("profile-commit"))
    let repeatResult = try reloaded.recordFinishedSession(profileID: player.id,runID: runID,score: 11680,won: true,lifetimeBefore: 52595)
    checks["profile_result_commit_idempotent_after_restart"] = first == 64275 && repeatResult == first
    let lost = try reloaded.recordFinishedSession(profileID: player.id,runID: UUID(),score: 0,won: false,lifetimeBefore: 64275)
    checks["profile_loss_does_not_add_lifetime_points"] = lost == 64275
    // Exercise normal autosave/profile code as well as the isolated checkpoint.
    // Every file is created under this test's temporary directory.
    let normalDirectory = directory.appendingPathComponent("normal-resume")
    let normal = try NativeGameView(root: root,saveDirectory: normalDirectory,automaticallyPresentMessages: false)
    normal.timer?.invalidate(); normal.zapTimer?.invalidate(); normal.soundEnabled = false
    let normalProfile = try normal.profileStore.create(name: "Resume test")
    normal.session = NativeSession(profileID: normalProfile.id,seed: 6908,lifetimePoints: 52595)
    normal.session.score = 2650; normal.session.energy = 17; normal.session.clock.applyMinutePenalty(52)
    normal.startEnding(room: normal.session.decoder.hideoutRoom)
    let normalTimeline = EndingTimeline(normal.session.activeEnding!,data: data)
    let halfway = normalTimeline.events.first { if case .bonus("Time Left",_) = $0.action { return true }; return false }!.ticks
    try normal.advanceEnding(halfway); normal.save()
    let reopened = try NativeGameView(root: root,saveDirectory: normalDirectory,automaticallyPresentMessages: false)
    reopened.timer?.invalidate(); reopened.zapTimer?.invalidate(); reopened.soundEnabled = false; reopened.begin()
    checks["normal_ending_autosave_resumes_at_saved_tally"] = reopened.screen == .ending && reopened.session.score == 5200 && reopened.session.clock.pauseDepth == 1 && reopened.session.activeEnding?.elapsedTicks == halfway
    try reopened.advanceEnding(normalTimeline.duration)
    checks["normal_ending_commits_session_and_profile_once"] = reopened.session.outcome == "won" && reopened.session.score == 11680 && reopened.session.lifetimePoints == 64275 && reopened.profileStore.document.profiles.first?.lifetimePoints == 64275 && reopened.session.activeEnding?.committed == true
    // Simulate the commit boundary: profile updated, session still carrying
    // the pre-commit marker. Restart must recognize the same run ID.
    var interrupted = reopened.session!
    interrupted.activeEnding?.committed = false; interrupted.lifetimePoints = 52595
    try reopened.saves.save(interrupted)
    let afterCommit = try NativeGameView(root: root,saveDirectory: normalDirectory,automaticallyPresentMessages: false)
    afterCommit.timer?.invalidate(); afterCommit.zapTimer?.invalidate(); afterCommit.soundEnabled = false; afterCommit.begin()
    try afterCommit.commitEndingResult()
    checks["restart_between_profile_and_session_commit_no_duplicate_award"] = afterCommit.screen == .results && afterCommit.session.lifetimePoints == 64275 && afterCommit.profileStore.document.profiles.first?.lifetimePoints == 64275 && afterCommit.session.activeEnding?.committed == true
    try afterCommit.beginNextGame()
    let next = try NativeGameView(root: root,saveDirectory: normalDirectory,automaticallyPresentMessages: false)
    next.timer?.invalidate(); next.zapTimer?.invalidate(); next.soundEnabled = false; next.begin()
    checks["normal_replay_persists_new_session_and_earned_rank"] = next.screen == .world && next.session.rank == .pro && next.session.lifetimePoints == 64275 && next.session.score == 0 && next.session.energy == 12 && next.session.activeEnding == nil && next.session.clock.pauseDepth == 0 && next.session.valid
    return checks
}
