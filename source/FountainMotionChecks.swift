import Foundation

func nativeFountainMotionChecks(root: URL,output: URL) throws -> [String:Bool] {
    var checks: [String:Bool] = [:]
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent("outnumbered-fountain-motion-"+UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    func view(_ name: String) throws -> NativeGameView {
        let game = try NativeGameView(root: root,saveDirectory: directory.appendingPathComponent(name),automaticallyPresentMessages: false)
        game.timer?.invalidate();game.zapTimer?.invalidate();game.soundEnabled = false;game.referenceMode = true;game.screen = .world
        game.referenceEnergy();game.session.position = NativePosition(scene: 1,playerUnit: 65,cameraUnit: 59,facing: -1)
        return game
    }
    let game = try view("source")
    let object = game.world.objects(scene: 1,energyMachineSlot: 6)[2]
    let target = 38+object.startUnit+1
    var expected = game.session.generator
    for _ in 0..<(abs(65-target)+10) { _ = expected.nextRandomValue() }
    game.beginFountain(object)
    let action = game.session.activeFountain!,frames = action.frames
    checks["fountain_source_unpaced_approach_native_four_irq"] = action.origin != nil && action.alignmentTicks == action.distance*4 && frames.prefix(action.distance).allSatisfy { $0.ticks == 4 && $0.position.facing == -1 }
    checks["fountain_source_rear_pose_y_and_animation15"] = frames.filter { $0.phase == .entering }.map(\.ordinal) == [9,10,11,12,203] && frames.filter { $0.phase == .entering }.map(\.y) == [78,75,72,69,66]
    checks["fountain_source_front_pose_y_and_animation29"] = frames.filter { $0.phase == .leaving }.map(\.ordinal) == [14,15,16,17,18] && frames.filter { $0.phase == .leaving }.map(\.y) == [69,72,75,78,81]
    game.advanceFountain(irqTicks: action.dispenseStart)
    let camera = game.session.position.cameraUnit
    checks["fountain_source_approach_scrolls_to_screen_six"] = game.session.position.playerUnit == target && target-camera == 6 && camera < 59 && game.session.position.facing == 1 && game.session.valid
    checks["fountain_source_dispenses_at_original_player_y66"] = game.session.activeFountain?.playerY == 66 && game.session.activeFountain?.playerFrame == 203 && game.session.energy == 14 && game.session.pendingRecharge == 0
    let rng = game.session.generator.randomState
    game.advanceFountain(irqTicks: 269)
    checks["fountain_dispense_wait_does_not_step_auxiliary_actors"] = game.session.generator.randomState == rng && game.session.activeFountain?.machineSprite == 196
    game.lastSoundIndex = 35 // silent marker; no listening claim
    game.advanceFountain(irqTicks: 1)
    checks["fountain_stops_dispense_sound_before_front_poses"] = game.lastSoundIndex == nil && game.session.activeFountain?.phase == .leaving
    game.lastSoundIndex = 17 // represent a following actor sound request
    let encoder = JSONEncoder();encoder.outputFormatting = .sortedKeys
    game.session = try JSONDecoder().decode(NativeSession.self,from: encoder.encode(game.session!))
    game.advanceFountain(irqTicks: 10_000)
    checks["fountain_completion_does_not_stop_following_actor_sound"] = game.lastSoundIndex == 17
    checks["fountain_exact_alignment_plus_ten_absent_enemy_draws"] = game.session.generator.randomState == expected.randomState && game.session.activeFountain == nil
    checks["fountain_completion_keeps_scrolled_camera_and_facing"] = game.session.position.playerUnit == target && game.session.position.cameraUnit == camera && game.session.position.facing == -1 && game.session.energy == 14 && game.session.valid
    try game.render();try game.canvas.writePNG(to: output.appendingPathComponent("native-fountain-scrolled-return.png"))
    let coarse = try view("coarse"),fine = try view("fine")
    coarse.beginFountain(object);fine.beginFountain(object);coarse.advanceFountain(irqTicks: 10_000)
    var count = 0
    while fine.session.activeFountain != nil && count < 2_000 { fine.advanceFountain(irqTicks: 1);count += 1 }
    checks["fountain_batching_preserves_rng_position_and_credit"] = coarse.session.generator.randomState == fine.session.generator.randomState && coarse.session.position == fine.session.position && coarse.session.energy == fine.session.energy && fine.session.activeFountain == nil
    checks["fountain_batching_preserves_auxiliary_actor_state"] = try encoder.encode(coarse.session.telly) == encoder.encode(fine.session.telly)
    let resumed = try view("resume");resumed.beginFountain(object);resumed.advanceFountain(irqTicks: 5)
    let before = resumed.session.generator.randomState
    resumed.session = try JSONDecoder().decode(NativeSession.self,from: encoder.encode(resumed.session!));resumed.advanceFountain(irqTicks: 0)
    checks["fountain_resume_does_not_repeat_current_actor_frame"] = resumed.session.generator.randomState == before && resumed.session.valid
    var legacy = NativeFountain(initialPlayerUnit: 50,targetPlayerUnit: 53,machineWorldUnit: 52,initialFacing: -1,credits: 4)
    _ = legacy.advance(irqTicks: 24)
    checks["fountain_legacy_action_retains_prior_pacing_and_pose"] = legacy.origin == nil && legacy.playerUnit == 51 && legacy.playerY == 81 && legacy.dispenseStart == 192 && legacy.valid
    return checks
}
