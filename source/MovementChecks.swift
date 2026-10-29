import Foundation

func nativeMovementChecks(root: URL,output: URL) throws -> [String:Bool] {
    var checks: [String:Bool] = [:]
    func position(_ player: Int,_ camera: Int,_ facing: Int = 1) -> NativePosition {
        NativePosition(scene: player/38,playerUnit: player,cameraUnit: camera,facing: facing)
    }
    let left = OriginalMovement.frame(from: position(82,76),horizontal: 1,facing: -1)
    checks["movement_left_scroll_before_player"] = left.scrolled == position(82,75,-1) && left.destination == position(81,75,-1) && left.cameraShift == -1
    let right = OriginalMovement.frame(from: position(102,76),horizontal: 2,facing: 1)
    checks["movement_right_two_unit_scroll"] = right.scrolled == position(102,78) && right.destination == position(104,78) && right.cameraShift == 2
    let threshold = OriginalMovement.frame(from: position(101,76),horizontal: 1,facing: 1)
    checks["movement_exact_right_threshold_no_shift"] = threshold.cameraShift == 0 && threshold.destination.playerUnit == 102
    let belowLeft = OriginalMovement.frame(from: position(6,1),horizontal: 1,facing: -1)
    checks["movement_below_left_threshold_does_not_scroll"] = belowLeft.cameraShift == 0 && belowLeft.destination.playerUnit == 5
    let leftEdge = OriginalMovement.frame(from: position(7,1),horizontal: 2,facing: -1)
    checks["movement_left_jump_requires_full_camera_room"] = leftEdge.cameraShift == 0 && leftEdge.destination == position(5,1,-1)
    let overshoot = OriginalMovement.frame(from: position(177,151),horizontal: 2,facing: 1)
    checks["movement_original_right_camera_overshoot"] = overshoot.cameraShift == 2 && overshoot.destination == position(179,153) && overshoot.destination.valid
    let edge = OriginalMovement.frame(from: position(185,153),horizontal: 2,facing: 1)
    checks["movement_original_overshoot_edge_screen33"] = edge.cameraShift == 0 && edge.destination == position(186,153) && edge.horizontalArgument == 1 && edge.destination.valid
    let blocked = OriginalMovement.frame(from: position(186,153),horizontal: 1,facing: 1)
    checks["movement_blocked_original_argument_zero"] = blocked.horizontalArgument == 0 && blocked.destination == position(186,153)
    let backwards = OriginalMovement.frame(from: position(53,47),horizontal: -1,facing: 1)
    checks["movement_signed_alignment_preserves_facing"] = backwards.destination == position(52,46) && backwards.horizontalArgument == -1
    let clamp = OriginalMovement.frame(from: NativePosition(scene: 10,playerUnit: 2,cameraUnit: 0,facing: -1),horizontal: 2,facing: -1)
    checks["movement_interior_two_unit_clamp"] = clamp.destination.playerUnit == 1 && clamp.cameraShift == 0 && clamp.destination.valid
    for floor in 0...1 { for magnitude in 1...2 {
        var p = position(floor*190+96,floor*190+76)
        var valid = true
        for _ in 0..<240 { p = OriginalMovement.frame(from: p,horizontal: magnitude,facing: 1).destination; valid = valid && p.valid && p.scene/5 == floor }
        checks["movement_floor_\(floor)_right_\(magnitude)_bounded"] = valid && p.playerUnit == floor*190+(p.cameraUnit-floor*190)+33
        for _ in 0..<240 { p = OriginalMovement.frame(from: p,horizontal: magnitude,facing: -1).destination; valid = valid && p.valid && p.scene/5 == floor }
        checks["movement_floor_\(floor)_left_\(magnitude)_bounded"] = valid && p.playerUnit-p.cameraUnit == 1
    } }
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent("outnumbered-motion-"+UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let game = try NativeGameView(root: root,saveDirectory: directory,automaticallyPresentMessages: false)
    game.timer?.invalidate();game.zapTimer?.invalidate();game.soundEnabled = false;game.referenceMode = true;game.screen = .world
    func reset(_ p: NativePosition) { game.session = NativeSession(profileID: UUID(),seed: 1);game.session.position = p }
    for facing in [-1,1] {
        //Off-centre News approach: three-unit retreat, camera follows all three
        //of those units; aligned return retains the resulting viewport.
        reset(position(56,50,facing));game.interact()
        let transition = game.session.activeDoor!
        checks["movement_door_alignment_scrolls_\(facing)"] = transition.hallway == position(53,47) && transition.frames[0].position == position(55,49,facing)
        game.advanceDoor(irqTicks: 10_000);game.interact();game.advanceDoor(irqTicks: 10_000)
        checks["movement_door_return_keeps_scrolled_camera_\(facing)"] = game.session.position == position(53,47) && game.session.valid
    }
    reset(position(17,11,-1))
    let elevator = NativeElevatorTransition(origin: game.session.position,startUnit: 6)
    checks["movement_elevator_alignment_scrolls"] = elevator.aligned == position(11,5) && elevator.frames[0].position == position(16,10,-1)
    var legacy = elevator;legacy.usesOriginalMovement = nil
    checks["movement_legacy_elevator_keeps_old_camera"] = legacy.aligned == position(11,11) && legacy.frames[0].position == position(16,11,-1)
    reset(position(56,50));game.interact()
    var oldDoor = game.session.activeDoor!;oldDoor.usesOriginalMovement = nil
    checks["movement_legacy_door_keeps_old_camera"] = oldDoor.frames[0].position.cameraUnit == 50
    reset(position(82,76,-1))
    var enemy = try OriginalTelly(tier: 0), values = [0,99].makeIterator()
    _ = enemy.step(context: OriginalTellyContext(hallway: true,allowSpawning: true,playerHasMoved: true,cameraSegment: 2,playerScreenUnit: 6,capturedCodePieces: 4),nextRandom: { values.next()! })
    game.session.telly = enemy
    let oldX = enemy.xUnits
    let prepared = game.prepareMovement(-1)
    checks["movement_preparation_shifts_enemy_before_update"] = game.session.position == prepared.scrolled && game.playerScreenUnit == 7 && game.session.telly?.xUnits == oldX+1
    var expectedEnemy = game.session.telly!, generator = game.session.generator
    expectedEnemy.beginFrame()
    _ = expectedEnemy.step(context: OriginalTellyContext(hallway: true,allowSpawning: true,playerHasMoved: true,cameraSegment: 1,playerScreenUnit: 7,capturedCodePieces: game.session.decoder.capturedCount),nextRandom: { generator.nextRandomValue() })
    game.updateTelly()
    checks["movement_enemy_sees_post_scroll_pre_player_context"] = game.session.generator.randomState == generator.randomState && game.session.telly?.xUnits == expectedEnemy.xUnits && game.session.telly?.state == expectedEnemy.state
    game.session.position = prepared.destination
    checks["movement_player_commits_after_enemy_update"] = game.playerScreenUnit == 6 && game.session.position == position(81,75,-1)
    return checks
}
