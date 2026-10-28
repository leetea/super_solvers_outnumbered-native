import Cocoa

func nativePlayerMotionChecks(root: URL,output: URL) throws -> [String:Bool] {
    var checks: [String:Bool] = [:]
    let world = try OriginalWorld(resource: Data(contentsOf: root.appendingPathComponent("catalog/decoded/MOCKET.DAT.1388.bin")))
    for (id,frames) in NativePlayerMotion.frames { checks["player_motion_resource_frames_\(id)"] = world.animations[id].frames == frames && world.animations[id].ticksPerFrame == 1 }
    var motion = NativePlayerMotion(), position = NativePosition(scene: 0,playerUnit: 1,cameraUnit: 0,facing: -1)
    var sprites: [Int] = [], sounds: [[Int]] = []
    for _ in 0..<18 {
        motion.walk(true)
        let frame = OriginalMovement.frame(from: position,horizontal: motion.horizontal,facing: -1)
        sounds.append(motion.advance(horizontalArgument: frame.horizontalArgument,position: frame.scrolled));position = frame.destination;sprites.append(motion.sprite)
    }
    checks["player_boundary_exact_eighteen_display_frames"] = sprites == NativePlayerMotion.frames[9]!+NativePlayerMotion.frames[28]!
    checks["player_boundary_impact_and_recovery_sound_frames"] = sounds.enumerated().filter { $0.element.contains(20) }.map(\.offset) == [5] && sounds[17] == [38] && sounds[0] == [1]
    checks["player_boundary_recovery_returns_idle_without_displacement"] = motion.animation == 1 && motion.y == 81 && position.playerUnit == 1 && motion.valid
    var turn = NativePlayerMotion();turn.request(9)
    checks["player_recovery_rejects_walk_and_jump"] = !turn.request(2,horizontal: 1) && !turn.request(8,horizontal: 2,vertical: -12) && turn.animation == 9
    checks["player_collision_can_interrupt_recovery"] = turn.request(27,horizontal: -2) && turn.animation == 27
    for direction in [-1,0,1] {
        motion = NativePlayerMotion();motion.request(8,horizontal: direction == 0 ? 0 : 2,vertical: -12)
        position = NativePosition();position.facing = direction == -1 ? -1 : 1
        var ys: [Int] = [], jumpSprites: [Int] = [], jumpSounds: [Int] = []
        for _ in 0..<8 {
            let frame = OriginalMovement.frame(from: position,horizontal: motion.horizontal,facing: position.facing)
            jumpSounds += motion.advance(horizontalArgument: frame.horizontalArgument,position: frame.scrolled);position = frame.destination
            ys.append(motion.y);jumpSprites.append(motion.sprite)
        }
        checks["player_flip_source_y_and_frames_\(direction)"] = ys == [69,57,45,33,45,57,69,81] && jumpSprites == NativePlayerMotion.frames[8]!
        checks["player_flip_source_distance_and_completion_\(direction)"] = position.playerUnit == 96+direction*16 && motion.animation == 1 && motion.valid && jumpSounds == [38]
    }
    for type in [9,26,27,28,30] {
        motion = NativePlayerMotion();motion.request(type,horizontal: type == 26 || type == 27 ? 2 : 0)
        position = NativePosition()
        var actual: [Int] = [], events: [Int] = []
        for _ in 0..<NativePlayerMotion.frames[type]!.count {
            let frame = OriginalMovement.frame(from: position,horizontal: motion.horizontal,facing: 1)
            events += motion.advance(horizontalArgument: frame.horizontalArgument,position: frame.scrolled);position = frame.destination;actual.append(motion.sprite)
        }
        checks["player_reaction_exact_source_sequence_\(type)"] = actual == NativePlayerMotion.frames[type]! && motion.animation == ([9,27].contains(type) ? 28 : 1) && motion.valid
        checks["player_reaction_source_completion_sound_\(type)"] = events == (type == 9 ? [20] : ([26,28].contains(type) ? [38] : []))
    }
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent("outnumbered-player-motion-"+UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let game = try NativeGameView(root: root,saveDirectory: directory,automaticallyPresentMessages: false)
    game.timer?.invalidate();game.zapTimer?.invalidate();game.soundEnabled = false;game.referenceMode = true;game.screen = .world
    func reset() { game.session = NativeSession(profileID: UUID(),seed: 1);game.held.removeAll() }
    func enemy(projectileKind: Int? = nil) throws -> OriginalTelly {
        var telly = try OriginalTelly(tier: 0), values = [0,99].makeIterator()
        _ = telly.step(context: OriginalTellyContext(playerScreenUnit: 15,capturedCodePieces: 4),nextRandom: { values.next()! })
        var data = try JSONSerialization.jsonObject(with: JSONEncoder().encode(telly)) as! [String:Any]
        data["xUnits"] = 20
        if let kind = projectileKind { data["projectile"] = ["kind":kind,"xUnits":20,"yPixels":OriginalTelly.projectileY[kind-22],"collisionWidthUnits":OriginalTelly.projectileWidths[kind-22],"velocityUnits":1,"ticksRemaining":100,"pendingRemoval":false,"sprite":115] }
        return try JSONDecoder().decode(OriginalTelly.self,from: JSONSerialization.data(withJSONObject: data))
    }
    for actor in [4,5] { for same in [false,true] { for kind in actor == 4 ? [22] : [22,23,24,25] {
        reset();game.session.position.facing = same ? -1 : 1;game.session.telly = try enemy(projectileKind: actor == 5 ? kind : nil)
        let random = game.session.generator.randomState
        game.updateTellyProjectileAndCollision()
        let name = "\(actor)_\(same)_\(kind)"
        checks["player_collision_word_precedes_penalty_\(name)"] = game.session.activeCollision?.actor == actor && game.session.activeCollision?.xUnit == (actor == 4 ? 21 : 20) && game.session.energy == 12 && game.session.clock.elapsedMinutes == 0
        game.advanceCollision(irqTicks: 199)
        let encoded = try JSONEncoder().encode(game.session!)
        game.session = try JSONDecoder().decode(NativeSession.self,from: encoded)
        checks["player_collision_flash_saved_before_completion_\(name)"] = game.session.valid && game.session.activeCollision?.elapsedIRQTicks == 199 && game.session.energy == 12
        game.advanceCollision(irqTicks: 1);game.advanceCollision(irqTicks: 200)
        let effect = OriginalCollisionEffect.forActor(actor,sameFacing: same,projectileKind: kind)!
        checks["player_collision_original_reaction_and_cost_once_\(name)"] = game.session.activeCollision == nil && game.playerMotion.animation == effect.playerAnimation && game.playerMotion.horizontal == effect.playerHorizontalStep && game.session.energy == 12-effect.energyCost && game.session.clock.elapsedMinutes == effect.timePenaltyMinutes && game.session.generator.randomState == random && game.session.valid
    } } }
    reset();game.session.telly = try enemy();game.beginJump(direction: 0);game.updateTellyProjectileAndCollision()
    checks["player_airborne_avoids_telly_collision"] = game.session.activeCollision == nil && game.session.energy == 12
    reset();game.session.telly = try enemy(projectileKind: 22);game.beginCollisionFlash(actor: 5,sameFacing: false)
    let stable = JSONEncoder();stable.outputFormatting = .sortedKeys
    let before = try stable.encode(game.session.telly)
    let rng = game.session.generator.randomState
    game.held.insert(124);game.step()
    checks["player_collision_word_freezes_main_actors_and_motion"] = try stable.encode(game.session.telly) == before && game.session.position.playerUnit == 96 && game.session.generator.randomState == rng
    game.advanceCollision(irqTicks: 200)
    for _ in 0..<3 { let frame = game.preparePlayerFrame();game.updateTelly();game.finishPlayerFrame(frame) }
    let saved = try JSONEncoder().encode(game.session!)
    let resumed = try JSONDecoder().decode(NativeSession.self,from: saved)
    checks["player_reaction_frame_and_position_survive_resume"] = resumed.valid && resumed.playerMotion?.nextFrame == game.playerMotion.nextFrame && resumed.playerMotion?.sprite == game.playerMotion.sprite && resumed.position == game.session.position
    reset();game.session.position = NativePosition(scene: 0,playerUnit: 1,cameraUnit: 0,facing: -1);game.held.insert(123)
    let boundary = game.preparePlayerFrame();game.finishPlayerFrame(boundary)
    checks["player_boundary_initial_restore_width_eight"] = game.playerMotion.restoreWidth == 8 && game.playerMotion.animation == 9 && game.playerMotion.remaining == 8
    try game.render();try game.canvas.writePNG(to: output.appendingPathComponent("native-player-boundary-impact.png"))
    reset();game.session.telly = try enemy();try game.render()
    let bitmap = try game.content.bitmap("FASTLOAD.GRA.100"), player = try game.content.bitmap("FASTLOAD.GRA.000")
    var compared = 0, correct = true
    for y in 4..<min(bitmap.height,player.height+4) { for x in 0..<min(bitmap.width,player.width) {
        let value = bitmap.pixels[y*bitmap.width+x], underneath = player.pixels[(y-4)*player.width+x]
        if value != 0 && underneath != 0 && value != underneath {
            compared += 1;correct = correct && game.canvas.pixels[(77+y)*320+160+x] == value
        }
    } }
    checks["player_original_telly_foreground_at_opaque_overlap"] = compared > 0 && correct
    try game.canvas.writePNG(to: output.appendingPathComponent("native-player-telly-foreground.png"))
    reset();var legacy = try JSONSerialization.jsonObject(with: JSONEncoder().encode(game.session!)) as! [String:Any]
    legacy.removeValue(forKey:"playerMotion");legacy.removeValue(forKey:"activeCollision")
    game.session = try JSONDecoder().decode(NativeSession.self,from: JSONSerialization.data(withJSONObject: legacy))
    checks["player_legacy_save_defaults_to_idle_without_new_fields"] = game.session.valid && game.playerMotion.animation == 1 && game.playerMotion.sprite == 0
    return checks
}
