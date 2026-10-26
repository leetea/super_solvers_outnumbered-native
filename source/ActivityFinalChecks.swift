import Cocoa

func nativeFinalActivityChecks(root: URL,output: URL) throws -> [String:Bool] {
    var checks: [String:Bool] = [:]
    let content = OriginalContent(root: root), canvas = NativeCanvas()
    let bank = try JSONDecoder().decode(ChallengeBank.self,from: Data(contentsOf: root.appendingPathComponent("challenges.json")))
    let renderer = ActivityFinal(content: content)
    let spinnerFixture = bank.cases.first { $0.id == 9120 && $0.seed == 1 && $0.variant == 0 }!
    _ = try renderer.draw(spinnerFixture,state: nil,on: canvas)
    let spinnerBitmap = try content.bitmap("TEMPLATE.GRA.213f")
    var changed = 0, correctHighlight = true
    for rect in [(50,128,60,136),(70,108,82,117)] {
        for y in rect.1...rect.3 { for x in rect.0...rect.2 {
            if spinnerBitmap.pixels[(y-19)*spinnerBitmap.width+x-8] == 14 {
                changed += 1; correctHighlight = correctHighlight && canvas.pixels[y*320+x] == 12
            }
        } }
    }
    checks["original_spinner_final_color_compare_replacement"] = changed > 0 && correctHighlight
    for hotspot in [3,4,7] {
        let cases = bank.cases.filter { $0.hotspot == hotspot }
        var count = 0, repeatable = true, sourceSelections = true
        for challenge in cases {
            var generator = DecoderGenerator(seed: challenge.post_generation_rng_state!)
            let state = hotspot == 3 ? nil : try OriginalActivityState.make(challenge,nextRandom: { generator.nextRandomValue() })
            canvas.clear(); let before = generator.randomState
            if try renderer.draw(challenge,state: state,on: canvas).providesActivityContext { count += 1 }
            let pixels = canvas.pixels
            canvas.clear(); _ = try renderer.draw(challenge,state: state,on: canvas)
            repeatable = repeatable && pixels == canvas.pixels && before == generator.randomState
            if let state {
                let decoded = try JSONDecoder().decode(OriginalActivityState.self,from: JSONEncoder().encode(state))
                repeatable = repeatable && decoded == state && decoded.valid
                if hotspot == 4 {
                    let first = try challenge.originalWord(at: 2), second = try challenge.originalWord(at: 3)
                    sourceSelections = try sourceSelections && state.rows[first].name == challenge.originalString(at: 12) && state.rows[first].first == challenge.originalWord(at: 4) && state.rows[first].second == challenge.originalWord(at: 5) && state.rows[second].name == challenge.originalString(at: 13) && state.rows[second].first == challenge.originalWord(at: 6) && state.rows[second].second == challenge.originalWord(at: 7)
                } else {
                    let name = try challenge.originalString(at: 10), selectedY = 66+(try challenge.originalWord(at: 0))*11
                    let selected = state.rows.first { $0.name == name && $0.labelY == selectedY }
                    sourceSelections = try sourceSelections && selected?.first == challenge.originalWord(at: 1) && selected?.second == challenge.originalWord(at: 2) && selected?.third == challenge.originalWord(at: 3)
                }
            }
        }
        checks["final_activity_\(hotspot)_all_recovered_cases_render"] = count == 320
        checks["final_activity_\(hotspot)_repaint_and_save_stable"] = repeatable
        checks["final_activity_\(hotspot)_preserves_selected_source_values"] = sourceSelections
    }
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent("outnumbered-final-activities-"+UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let view = try NativeGameView(root: root,saveDirectory: directory,automaticallyPresentMessages: false)
    view.timer?.invalidate(); view.zapTimer?.invalidate(); view.soundEnabled = false
    for (name,id,hotspot,scene,answer) in [("spinner",9120,3,12,100),("music",9050,4,15,106),("supplies",9040,7,14,29)] {
        view.activityCheckpoint(id: id,hotspot: hotspot,scene: scene)
        let randomBefore = view.session.generator.randomState
        let drawing = view.session.activityStates?[hotspot]
        checks["native_\(name)_checkpoint_source_answer"] = view.session.activeChallenge?.answer == answer
        try view.render(); try view.canvas.writePNG(to: output.appendingPathComponent("native-"+name+"-activity.png"))
        try view.render()
        checks["native_\(name)_render_does_not_consume_RNG"] = view.session.generator.randomState == randomBefore && view.session.valid
        if let drawing {
            try view.saves.save(view.session)
            let restored = try view.saves.load(view.session.profileID)!
            checks["native_\(name)_drawing_state_persists"] = restored.activityStates?[hotspot] == drawing && restored.valid
            view.session = restored
            view.leaveQuestion(); view.open(bank.cases.first { $0.id == id && $0.seed == 1 && $0.variant == 0 }!)
            checks["native_\(name)_reopen_keeps_original_assigned_drawing"] = view.session.activityStates?[hotspot] == drawing
        }
        for character in String(answer) { view.questionCharacter(String(character)) }
        view.submitQuestion()
        checks["native_\(name)_correct_answer_300_and_clues"] = view.session.score == 300 && view.session.completed.contains(hotspot) && view.session.pendingRecharge == 2 && view.session.decoder.completedRoomCount == 1
    }
    var allRendered = 0
    let scenes = [10,10,12,12,15,15,14,14,13,13]
    for challenge in bank.cases {
        view.session = NativeSession(profileID: UUID(),seed: UInt32(challenge.seed),lifetimePoints: 30_000)
        view.session.position = NativePosition(scene: scenes[challenge.hotspot],playerUnit: 15,cameraUnit: 0,facing: 1)
        view.referenceMode = true; view.open(challenge); try view.render()
        if view.session.valid && view.session.activeChallenge?.id == challenge.id { allRendered += 1 }
    }
    checks["native_view_all_3200_recovered_challenges_render"] = allRendered == 3200
    return checks
}
