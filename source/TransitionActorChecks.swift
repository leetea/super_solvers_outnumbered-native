import Cocoa

func nativeTransitionActorChecks(root: URL,output: URL) throws -> [String:Bool] {
    var checks: [String:Bool] = [:]
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent("outnumbered-transition-actors-"+UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    func view(_ suffix: String) throws -> NativeGameView {
        let result = try NativeGameView(root: root,saveDirectory: directory.appendingPathComponent(suffix),automaticallyPresentMessages: false)
        result.timer?.invalidate();result.zapTimer?.invalidate();result.soundEnabled = false;result.referenceMode = true;result.screen = .world
        result.session = NativeSession(profileID: UUID(),seed: 1)
        return result
    }
    for entering in [true,false] {
        let game = try view("door-\(entering)")
        let hall = NativePosition(scene: 1,playerUnit: 53,cameraUnit: 38,facing: 1)
        game.session.position = entering ? hall : NativePosition(scene: 10,playerUnit: 5,cameraUnit: 0,facing: -1)
        game.session.returnPosition = entering ? nil : hall
        var expected = game.session.generator
        //Source loops:5rear+3panels+4smallRear+4smallFront+5front.
        //Entry additionally calls135d:06ee exactly once for LiveWire.
        for _ in 0..<(21+(entering ? 1 : 0)) { _ = expected.nextRandomValue() }
        game.interact();game.advanceDoor(irqTicks: 10_000)
        checks["transition_door_absent_enemy_exact_rng_\(entering)"] = game.session.generator.randomState == expected.randomState && game.session.telly?.state == .absent
    }
    for hall in [0,4,5,9] {
        let game = try view("elevator-\(hall)")
        let object = game.world.scenes[hall].first { $0.kind == 2 }!
        game.session.position = NativePosition(scene: hall,playerUnit: hall*38+object.startUnit+5,cameraUnit: hall*38,facing: -1)
        var expected = game.session.generator
        //5rear+4open+4smallRear+4close+1cleanup+4open+4smallFront+5front+4close.
        //The8scroll bands themselves never call1559.
        for _ in 0..<35 { _ = expected.nextRandomValue() }
        game.interact();game.advanceElevator(irqTicks: 10_000)
        checks["transition_elevator_absent_enemy_exact_rng_\(hall)"] = game.session.generator.randomState == expected.randomState && game.session.telly?.state == .absent
    }
    let game = try view("moving-telly")
    game.session.position = NativePosition(scene: 1,playerUnit: 53,cameraUnit: 38,facing: 1)
    var enemy = try OriginalTelly(tier: 0), values = [0,99].makeIterator()
    _ = enemy.step(context: OriginalTellyContext(hallway: true,allowSpawning: true,playerHasMoved: true,cameraSegment: 1,playerScreenUnit: 15,capturedCodePieces: 4),nextRandom: { values.next()! })
    checks["transition_active_telly_fixture_is_far_walking"] = enemy.state == .walking && enemy.xUnits == 35
    game.session.telly = enemy
    var expected = game.session.generator
    for _ in 0..<24 { _ = expected.nextRandomValue() } //12walking updates, stop/throw draws each.
    let energy = game.session.energy
    game.interact()
    let midpoint = game.session.activeDoor!.frames.prefix { !$0.destination }.reduce(0) { $0+$1.ticks }
    game.advanceDoor(irqTicks: midpoint-1)
    checks["transition_active_telly_moves_during_door_poses"] = game.session.telly?.xUnits == 23 && game.session.telly?.state == .walking
    checks["transition_active_telly_original_rng_draw_count"] = game.session.generator.randomState == expected.randomState
    checks["transition_pose_updates_do_not_run_main_collisions"] = game.session.energy == energy
    try game.render();try game.canvas.writePNG(to: output.appendingPathComponent("native-transition-moving-telly.png"))

    let projectileGame = try view("projectile")
    projectileGame.session.position = NativePosition(scene: 1,playerUnit: 53,cameraUnit: 38,facing: 1)
    let encoder = JSONEncoder();encoder.outputFormatting = .sortedKeys
    var object = try JSONSerialization.jsonObject(with: encoder.encode(OriginalTelly(tier: 0))) as! [String:Any]
    object["projectile"] = ["kind":22,"xUnits":10,"yPixels":81,"collisionWidthUnits":5,"velocityUnits":1,"ticksRemaining":100,"pendingRemoval":false,"sprite":115]
    projectileGame.session.telly = try JSONDecoder().decode(OriginalTelly.self,from: JSONSerialization.data(withJSONObject: object))
    projectileGame.interact();projectileGame.advanceDoor(irqTicks: midpoint-1)
    checks["transition_projectile_advances_once_per_source_update"] = projectileGame.session.telly?.projectile?.xUnits == 22 && projectileGame.session.telly?.projectile?.ticksRemaining == 88
    checks["transition_projectile_crossing_does_not_apply_world_collision"] = projectileGame.session.energy == VerifiedEnergy.initial

    let wireGame = try view("livewire")
    wireGame.session.position = NativePosition(scene: 10,playerUnit: 5,cameraUnit: 0,facing: 1)
    wireGame.session.returnPosition = NativePosition(scene: 1,playerUnit: 53,cameraUnit: 38,facing: 1)
    _ = wireGame.session.liveWire?.attemptSpawn(playerScreenUnit: 5,nextRandom: { 0 })
    wireGame.interact()
    let exitMidpoint = wireGame.session.activeDoor!.frames.prefix { !$0.destination }.reduce(0) { $0+$1.ticks }
    wireGame.advanceDoor(irqTicks: exitMidpoint-1)
    checks["transition_livewire_walks_during_room_exit"] = wireGame.session.liveWire?.xUnits == 21 && wireGame.session.energy == VerifiedEnergy.initial

    for elevator in [false,true] {
        let coarse = try view("coarse-\(elevator)"), fine = try view("fine-\(elevator)")
        let position = elevator ? NativePosition(scene: 0,playerUnit: 9,cameraUnit: 0,facing: -1) : NativePosition(scene: 1,playerUnit: 50,cameraUnit: 38,facing: -1)
        coarse.session.position = position;fine.session.position = position
        coarse.interact();fine.interact()
        if elevator { coarse.advanceElevator(irqTicks: 10_000) }
        else { coarse.advanceDoor(irqTicks: 10_000) }
        var count = 0
        while fine.isTransitioning && count < 2_000 {
            if elevator { fine.advanceElevator(irqTicks: 1) } else { fine.advanceDoor(irqTicks: 1) }; count += 1
        }
        checks["transition_batching_preserves_rng_\(elevator)"] = coarse.session.generator.randomState == fine.session.generator.randomState && coarse.session.position == fine.session.position
        checks["transition_batching_preserves_enemy_state_\(elevator)"] = try encoder.encode(coarse.session.telly) == encoder.encode(fine.session.telly)
    }
    let legacy = try view("legacy")
    legacy.session.position = NativePosition(scene: 1,playerUnit: 53,cameraUnit: 38,facing: 1)
    legacy.interact();legacy.advanceDoor(irqTicks: 24)
    let state = legacy.session.generator.randomState
    var saved = try JSONSerialization.jsonObject(with: encoder.encode(legacy.session)) as! [String:Any]
    var savedDoor = saved["activeDoor"] as! [String:Any];savedDoor.removeValue(forKey: "auxiliaryFramesApplied");saved["activeDoor"] = savedDoor
    legacy.session = try JSONDecoder().decode(NativeSession.self,from: JSONSerialization.data(withJSONObject: saved))
    legacy.advanceDoor(irqTicks: 0)
    checks["transition_legacy_save_does_not_replay_past_actor_draws"] = legacy.session.valid && legacy.session.generator.randomState == state
    let marked = legacy.session.activeDoor!.auxiliaryFramesApplied
    legacy.advanceDoor(irqTicks: 1)
    checks["transition_subframe_resume_does_not_duplicate_actor_update"] = legacy.session.activeDoor?.auxiliaryFramesApplied == marked && legacy.session.generator.randomState == state
    return checks
}
