import Cocoa

func nativeEncounterChecks(root: URL, output: URL) throws -> [String: Bool] {
    var checks: [String: Bool] = [:]
    let counts = [240,306,647,663]
    var combinations = 0
    for tier in 0..<4 {
        let deck = try OriginalDrillGenerator(settings: OriginalDrillGenerator.defaults[tier])
        checks["original_drill_pool_count_tier_\(tier)"] = deck.pool.count == counts[tier]
        var valid = true
        for pair in deck.pool {
            for blank in [DrillBlank.result,.left,.right] {
                let q = try OriginalDrillQuestion(encodedPair: pair,blank: blank)
                switch q.operation {
                case .addition: valid = valid && q.left+q.right == q.result
                case .multiplication: valid = valid && q.left*q.right == q.result
                case .subtraction: valid = valid && q.left-q.right == q.result
                case .division: valid = valid && q.right > 0 && q.left%q.right == 0 && q.left/q.right == q.result
                }
                valid = valid && q.accepts(q.expected) && q.valid; combinations += 1
            }
        }
        checks["all_drill_math_identities_tier_\(tier)"] = valid
    }
    checks["5568_pair_blank_combinations_checked"] = combinations == 5568
    let zero = try OriginalDrillQuestion(encodedPair: 0x0100,blank: .left)
    checks["multiply_zero_accepts_any_missing_operand"] = zero.accepts(999)
    let division = try OriginalDrillQuestion(encodedPair: 0x0304,blank: .right)
    checks["division_missing_divisor_avoids_zero_ambiguity"] = division.left == 4 && division.right == 4 && division.result == 1
    do { _ = try OriginalDrillGenerator(settings: Array(repeating: 0,count: 13)); checks["empty_drill_settings_rejected"] = false }
    catch { checks["empty_drill_settings_rejected"] = true }
    var deck = try OriginalDrillGenerator(settings: OriginalDrillGenerator.defaults[0]), rng = DecoderGenerator(seed: 123)
    var seen = Set<UInt16>()
    for _ in 0..<240 { seen.insert(try deck.next(nextRandom: { rng.nextRandomValue() }).encodedPair) }
    checks["drill_pool_without_replacement"] = seen.count == 240 && deck.remaining == 0
    _ = try deck.next(nextRandom: { rng.nextRandomValue() })
    checks["drill_pool_refills"] = deck.remaining == 239

    let directory = FileManager.default.temporaryDirectory.appendingPathComponent("outnumbered-encounters-"+UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let view = try NativeGameView(root: root,saveDirectory: directory)
    view.timer?.invalidate(); view.zapTimer?.invalidate(); view.soundEnabled = false; view.referenceDrill()
    for (index,answer) in [19,12,22,7,22,3].enumerated() {
        var limit = 0
        while view.session.activeDrill?.phase != .asking && limit < 100 { view.step(); limit += 1 }
        guard var drill = view.session.activeDrill else { throw ContentError.invalid("Drill ended before video fixture completed") }
        checks["video_drill_question_\(index+1)"] = drill.question.expected == answer
        if index == 0 { try view.render(); try view.canvas.writePNG(to: output.appendingPathComponent("native-telly-drill-question.png")) }
        for digit in String(answer).compactMap({ $0.wholeNumberValue }) { drill.digit(digit) }
        var generator = view.session.generator
        checks["video_drill_submission_\(index+1)"] = drill.submit(nextRandom: { generator.nextRandomValue() }) == true
        let early = try drill.advance(irqTicks: 239,nextRandom: { generator.nextRandomValue() })
        let award = try drill.advance(irqTicks: 1,nextRandom: { generator.nextRandomValue() })
        checks["drill_50_after_240_IRQ_\(index+1)"] = early == 0 && award == 50
        let newScore = VerifiedScore.adding(award,to: view.session.score)
        view.session.score = newScore; view.session.activeDrill = drill; view.session.generator = generator
        if index == 2 {
            try view.saves.save(view.session)
            let restored = try view.saves.load(view.session.profileID)!
            checks["partial_drill_save_after_award"] = restored.activeDrill?.phase == .correctPause && restored.score == 750 && restored.activeDrill?.question == drill.question
        }
        for _ in 0..<10 { view.step() }
    }
    checks["video_six_answers_plus_code_score_1000"] = view.session.score == 1000 && view.session.decoder.capturedCount == 1
    let finalScore = view.session.score; view.finishDrill()
    checks["code_reward_applied_once"] = view.session.score == finalScore && view.session.decoder.capturedCount == 1
    checks["video_reference_first_piece_lightning"] = view.session.activeDrill?.capturedSymbol == 11
    checks["game_clock_continues_during_drill"] = view.session.clock.elapsedMinutes > 12
    try view.render(); try view.canvas.writePNG(to: output.appendingPathComponent("native-telly-code-capture.png"))
    var failed = try NativeDrill(tier: 0,nextRandom: { 0 })
    _ = try failed.advance(irqTicks: 240,nextRandom: { 0 }); failed.input = "999"; _ = failed.submit(nextRandom: { 0 })
    _ = try failed.advance(irqTicks: 479,nextRandom: { 0 })
    checks["wrong_drill_feedback_480_IRQ"] = failed.phase == .wrongFeedback
    _ = try failed.advance(irqTicks: 1,nextRandom: { 0 })
    checks["wrong_drill_reveals_correct_operand"] = failed.phase == .showCorrect && failed.displayParts[4] == String(failed.question.expected)
    checks["failed_drill_no_code_entitlement"] = !failed.entitledToCode
    view.session = NativeSession(profileID: UUID(),seed: 1); view.session.position.facing = -1; view.screen = .world
    var telly = try OriginalTelly(tier: 0)
    let context = OriginalTellyContext(playerHasMoved: true)
    _ = telly.step(context: context,nextRandom: { 0 })
    for _ in 0..<5 { _ = telly.step(context: context,nextRandom: { 0 }) }
    view.session.telly = telly
    checks["telly_lit_after_recovered_appearance"] = telly.bellyLit && telly.hittable
    view.beginZap()
    checks["zap_uses_original_endpoint_geometry"] = view.session.activeZap?.hitEffect == OriginalZapHitEffect.startDrill.rawValue
    let zapSnapshot = try JSONDecoder().decode(NativeSession.self,from: JSONEncoder().encode(view.session!))
    checks["partial_zap_snapshot_round_trip"] = zapSnapshot.valid && zapSnapshot.activeZap?.schedule.hit == true && zapSnapshot.energy == 12
    view.session.activeZap?.elapsedIRQTicks = 90; view.pulseZap()
    checks["energized_lit_telly_hit_starts_drill"] = view.screen == .drill && view.session.activeDrill != nil && view.session.energy == 11
    checks["sound_equal_priority_does_not_restart"] = !OriginalSoundPolicy.accepts(incoming: 17,current: 17,playing: true)
    checks["sound_higher_priority_interrupts"] = OriginalSoundPolicy.accepts(incoming: 14,current: 17,playing: true)
    checks["original_impact51_has_priority_over_following20"] = !OriginalSoundPolicy.accepts(incoming: 20,current: 51,playing: true)
    let impact = try Data(contentsOf: root.appendingPathComponent("audio/effect-51.wav"))
    let frames = Int((167*VerifiedClock.pitDivisor/VerifiedClock.pitInputHz*22050).rounded())
    checks["original_impact51_PCM_extent"] = impact.prefix(4) == Data("RIFF".utf8) && impact.count == 44+frames*2
    var legacy = try JSONSerialization.jsonObject(with: JSONEncoder().encode(NativeSession(profileID: UUID(),seed: 1))) as! [String:Any]
    for key in ["telly","activeDrill","activeZap","playerHasMoved"] { legacy.removeValue(forKey: key) }
    let legacyData = try JSONSerialization.data(withJSONObject: legacy)
    let restoredLegacy = try JSONDecoder().decode(NativeSession.self,from: legacyData)
    checks["version02_native_sessions_remain_readable"] = restoredLegacy.valid && restoredLegacy.telly == nil && restoredLegacy.activeDrill == nil
    return checks
}
