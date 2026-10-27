import Cocoa

func nativeIntegrationChecks(root: URL) throws {
    var checks = try OriginalWorld.selfChecks(resource: Data(contentsOf: root.appendingPathComponent("catalog/decoded/MOCKET.DAT.1388.bin")))
    let bank = try JSONDecoder().decode(ChallengeBank.self,from: Data(contentsOf: root.appendingPathComponent("challenges.json")))
    guard let weather = bank.cases.first(where: { $0.id == 9078 && $0.seed == 2 && $0.variant == 3 }) else { throw ContentError.invalid("Missing independently recovered weather fixture") }
    checks["video_weather_numbers"] = weather.strings(group: 4).prefix(3) == ["832 mm","655 mm","915 mm"]
    checks["video_weather_answer"] = weather.answer == 832-123-65 && weather.answer == 644
    checks["video_weather_wording"] = weather.question.contains("cloud seeding") && weather.question.contains("65 mm from thunder storms")
    let content = OriginalContent(root: root), font = try content.font("MOCKET.DAT.1393")
    let activityCanvas = NativeCanvas()
    for hotspot in ActivityMore.supportedHotspots.sorted() {
        let cases = bank.cases.filter { $0.hotspot == hotspot }
        var rendered = 0
        for challenge in cases {
            activityCanvas.clear()
            if try ActivityMore(content: content).draw(challenge,on: activityCanvas).providesActivityContext { rendered += 1 }
        }
        checks["additional_activity_\(hotspot)_all_bank_cases_render"] = cases.count == 320 && rendered == cases.count
    }
    if let songs = bank.cases.first(where: { $0.id == 9068 && $0.seed == 7 && $0.variant == 3 }) {
        let expected = [180,180,210,180,270]
        checks["video_cartoon_songs_both_series_and_answer"] = try (6...10).map { try songs.originalWord(at: $0) } == expected && (11...15).map { try songs.originalWord(at: $0) } == expected && songs.answer == 0
        activityCanvas.clear(); _ = try ActivityMore(content: content).draw(songs,on: activityCanvas)
        let points = [(64,97),(86,97),(108,80),(130,97),(152,46)]
        checks["video_cartoon_songs_original_plot_positions"] = points.allSatisfy { x,y in activityCanvas.pixels[y*320+x] == 0 && activityCanvas.pixels[(y-2)*320+x] == 12 }
    } else { checks["video_cartoon_songs_fixture_present"] = false }
    checks["original_font_fremont_measurement"] = font.width(of: "Fremont") == 51
    checks["original_font_dallas_measurement"] = font.width(of: "Dallas") == 33
    checks["original_font_new_york_measurement"] = font.width(of: "New York") == 63
    var attempt = RoomAttempt()
    checks["blank_answer_does_not_submit"] = attempt.submit(expected: 644) == nil
    for digit in [0,6,4,4,5] { attempt.digit(digit) }
    checks["answer_entry_no_leading_zero_four_digit_limit"] = attempt.input == "6445"
    attempt.input = "644"
    checks["correct_answer_resolves"] = attempt.submit(expected: 644) == true && attempt.result == .correct
    var session = NativeSession(profileID: UUID(),seed: 1,lifetimePoints: 30_000)
    session.position = NativePosition(scene: 10,playerUnit: 23,cameraUnit: 0,facing: 1)
    session.activeChallenge = weather; session.clock.pause()
    session.attempts[0] = RoomAttempt(); session.attempts[0]?.input = "1"
    checks["first_wrong_attempt_advice"] = session.resolve(weather) == false && session.attempts[0]?.wrongAnswers == 1 && session.score == 0 && session.completed.isEmpty
    session.attempts[0]?.input = "2"
    checks["second_wrong_attempt_hint_acknowledgement"] = session.resolve(weather) == false && session.attempts[0]?.wrongAnswers == 2 && session.attempts[0]?.awaitingHintAcknowledgement == true
    checks["hint_waits_for_enter"] = session.resolve(weather) == nil
    session.attempts[0]?.awaitingHintAcknowledgement = false
    session.attempts[0]?.input = "644"
    checks["third_try_original_score_100"] = session.resolve(weather) == true && session.score == 100 && session.pendingRecharge == 2 && session.decoder.completedRoomCount == 1
    checks["resolved_question_no_repeat_award"] = session.resolve(weather) == nil && session.score == 100 && session.pendingRecharge == 2
    var firstTry = NativeSession(profileID: UUID(),seed: 1,lifetimePoints: 30_000)
    firstTry.position = session.position; firstTry.attempts[0] = RoomAttempt(); firstTry.attempts[0]?.input = "644"
    checks["video_first_try_score_300"] = firstTry.resolve(weather) == true && firstTry.score == 300
    var failed = NativeSession(profileID: UUID(),seed: 1)
    failed.position = session.position; failed.attempts[0] = RoomAttempt()
    for _ in 0..<3 { failed.attempts[0]?.awaitingHintAcknowledgement = false; failed.attempts[0]?.input = "1"; _ = failed.resolve(weather) }
    checks["third_wrong_resolves_no_points"] = failed.attempts[0]?.result == .failed && failed.score == 0 && failed.pendingRecharge == 0 && failed.completed.contains(0)
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent("outnumbered-integration-"+UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let store = NativeSessionStore(directory: directory)
    try store.save(session)
    let restored = try store.load(session.profileID)!
    checks["save_partial_question_and_clock_pause"] = restored.activeChallenge?.answer == 644 && restored.attempts[0]?.result == .correct && restored.clock.roomChallengeActive && restored.score == 100 && restored.decoder == session.decoder
    let old = try Data(contentsOf: store.file(session.profileID))
    var object = try JSONSerialization.jsonObject(with: old) as! [String:Any]
    object["formatVersion"] = 99
    let future = try JSONSerialization.data(withJSONObject: object)
    try future.write(to: store.file(session.profileID))
    do { try store.save(session); checks["future_save_rejected"] = false } catch { checks["future_save_rejected"] = true }
    checks["future_save_unchanged"] = try Data(contentsOf: store.file(session.profileID)) == future
    try Data("broken".utf8).write(to: store.file(session.profileID))
    do { try store.save(session); checks["corrupt_save_rejected"] = false } catch { checks["corrupt_save_rejected"] = true }
    checks["corrupt_save_unchanged"] = try Data(contentsOf: store.file(session.profileID)) == Data("broken".utf8)
    var malformed = session
    malformed.returnPosition = NativePosition(scene: -1,playerUnit: 0,cameraUnit: 0,facing: 1)
    checks["invalid_saved_return_position_rejected"] = !malformed.valid
    let view = try NativeGameView(root: root,saveDirectory: directory.appendingPathComponent("render-profile"),automaticallyPresentMessages: false)
    view.timer?.invalidate(); view.zapTimer?.invalidate(); view.soundEnabled = false; view.referenceQuestion(); try view.render()
    let output = URL(fileURLWithPath: ProcessInfo.processInfo.environment["OUTNUMBERED_CHECK_OUTPUT"] ?? FileManager.default.temporaryDirectory.path)
    try FileManager.default.createDirectory(at: output,withIntermediateDirectories: true)
    try view.canvas.writePNG(to: output.appendingPathComponent("native-weather-question.png"))
    view.session.attempts[0]?.input = "644"; _ = view.session.resolve(weather); try view.render()
    try view.canvas.writePNG(to: output.appendingPathComponent("native-weather-correct.png"))
    view.leaveQuestion(); view.session.position = NativePosition(); try view.render()
    try view.canvas.writePNG(to: output.appendingPathComponent("native-hallway.png"))
    let statsBeforeDecoder = view.canvas.pixels
    view.screen = .decoder; try view.render()
    var statsPreserved = true
    for row in 162..<198 {
        for column in 216..<251 {
            let offset = row*320+column
            if view.canvas.pixels[offset] != statsBeforeDecoder[offset] { statsPreserved = false }
        }
    }
    checks["decoder_buttons_preserve_stats_labels"] = statsPreserved
    try view.canvas.writePNG(to: output.appendingPathComponent("native-decoder.png"))
    checks["headless_native_render_completed"] = true
    view.session.clock.pause(); view.session.clock.pollAfterIRQTicks(10000)
    checks["native_question_clock_does_not_advance"] = view.session.clock.elapsedMinutes == 0
    view.session = NativeSession(profileID: UUID(),seed: 1)
    view.screen = .world
    let hallway = NativePosition(scene: 1,playerUnit: 52,cameraUnit: 38,facing: 1)
    let alignedHallway = NativePosition(scene: 1,playerUnit: 53,cameraUnit: 38,facing: 1)
    view.session.position = hallway; view.interact(); view.advanceDoor(irqTicks: 10_000)
    checks["native_news_door_enter"] = view.session.position.scene == 10 && view.session.position.playerUnit == 5 && view.session.returnPosition == alignedHallway
    view.interact(); view.advanceDoor(irqTicks: 10_000)
    checks["native_news_door_return_position"] = view.session.position == alignedHallway && view.session.returnPosition == nil
    // Both facing directions and all five off-centre door approaches must
    // restore the original aligned global/screen position, not the Up key site.
    for hall in [1,3,6,7,8] {
        let door = view.world.scenes[hall].first { $0.kind == 1 }!
        for facing in [-1,1] {
            view.session = NativeSession(profileID: UUID(),seed: 1)
            let camera = hall*38
            view.session.position = NativePosition(scene: hall,playerUnit: hall*38+door.startUnit-4,cameraUnit: camera,facing: facing)
            view.interact(); view.advanceDoor(irqTicks: 10_000)
            let inside = view.session.position.scene == OriginalWorld.roomScene(throughHallway: hall)
            view.interact(); view.advanceDoor(irqTicks: 10_000)
            checks["native_door_aligned_return_hall_\(hall)_facing_\(facing)"] = inside && view.session.position == NativePosition(scene: hall,playerUnit: hall*38+door.startUnit+1,cameraUnit: camera,facing: 1) && view.session.returnPosition == nil
        }
    }
    for hall in [0,4,5,9] {
        let elevator = view.world.scenes[hall].first { $0.kind == 2 }!
        view.session = NativeSession(profileID: UUID(),seed: 1)
        view.session.position = NativePosition(scene: hall,playerUnit: hall*38+elevator.startUnit,cameraUnit: hall*38,facing: hall%5 == 0 ? -1 : 1)
        view.interact(); view.advanceElevator(irqTicks: 10_000)
        checks["native_elevator_exit_facing_hall_\(hall)"] = view.session.position.scene == OriginalWorld.elevatorDestination(from: hall) && view.session.position.facing == (hall%5 == 0 ? 1 : -1)
    }
    view.session.position = NativePosition(scene: 0,playerUnit: 7,cameraUnit: 0,facing: 1)
    view.interact(); view.advanceElevator(irqTicks: 10_000)
    checks["native_left_elevator"] = view.session.position.scene == 5 && view.session.position.playerUnit == 202 && view.session.position.cameraUnit == 190
    view.session.position = NativePosition(scene: 4,playerUnit: 185,cameraUnit: 152,facing: 1)
    view.move(2)
    checks["native_floor_end_does_not_wrap"] = view.session.position.scene == 4 && view.session.position.playerUnit == 185
    view.referenceMode = false
    view.session.clock.pause(); view.save()
    checks["transient_decoder_pause_not_saved_into_exploration"] = try view.saves.load(view.session.profileID)?.clock.pauseDepth == 0
    checks.merge(try nativeTransitionActorChecks(root: root,output: output)) { _,new in new }
    checks.merge(try nativeMovementChecks(root: root,output: output)) { _,new in new }
    checks.merge(try nativePlayerMotionChecks(root: root,output: output)) { _,new in new }
    checks.merge(try nativeElevatorTransitionChecks(root: root,output: output)) { _,new in new }
    checks.merge(try nativeDoorTransitionChecks(root: root,output: output)) { _,new in new }
    checks.merge(try nativeEncounterChecks(root: root,output: output)) { _,new in new }
    checks.merge(try nativeEnergyLiveWireChecks(root: root,output: output)) { _,new in new }
    checks.merge(try nativeCalculatorChecks(root: root,output: output)) { _,new in new }
    checks.merge(try nativeFinalActivityChecks(root: root,output: output)) { _,new in new }
    checks.merge(try nativeQuestionSetupChecks(root: root,output: output)) { _,new in new }
    checks.merge(try nativeEndingChecks(root: root,output: output)) { _,new in new }
    checks.merge(try nativeMenuChecks(root: root,output: output)) { _,new in new }
    checks.merge(try nativeHelpChecks(root: root,output: output)) { _,new in new }
    checks.merge(try nativeScoreChecks(root: root,output: output)) { _,new in new }
    checks.merge(try nativeTutorialChecks(root: root,output: output)) { _,new in new }
    let report: [String:Any] = ["passed": checks.values.allSatisfy { $0 },"checks": checks,"checkCount": checks.count,"guiVerified": false,"completeGame": false,"reference": "Local OutNumbered Gameplay.mkv weather and drill checkpoints; original static data/code"]
    let data = try JSONSerialization.data(withJSONObject: report,options: [.prettyPrinted,.sortedKeys])
    try data.write(to: output.appendingPathComponent("native-integration-checks.json"))
    print(String(data: data,encoding: .utf8)!)
    if !checks.values.allSatisfy({ $0 }) { exit(1) }
}
