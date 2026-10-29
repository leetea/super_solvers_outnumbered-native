import Foundation

func nativeRoomCameraChecks(root: URL,output: URL) throws -> [String:Bool] {
    var checks: [String:Bool] = [:]
    let world = try OriginalWorld(resource: Data(contentsOf: root.appendingPathComponent("catalog/decoded/MOCKET.DAT.1388.bin")))
    checks["room_camera_original_actor_and_row"] = world.actors[2].xUnits == 19 && world.actors[2].yPixels == 24 && world.animations[14].frames == NativeRoomCamera.frames.map { $0+10000 } && world.animations[14].initialTicksRemaining == 4 && world.animations[14].ticksPerFrame == 4
    var camera = NativeRoomCamera();camera.start();var sprites: [Int] = []
    for _ in 0..<32 { camera.step();sprites.append(camera.sprite) }
    checks["room_camera_exact_four_update_holds_and_full_pan"] = sprites == NativeRoomCamera.frames.flatMap { Array(repeating: $0,count: 4) } && camera.nextFrame == 0 && camera.ticksLeft == 4
    camera.step();camera.stop()
    checks["room_camera_exit_resets_index_keeps_partial_hold"] = !camera.active && camera.nextFrame == 0 && camera.ticksLeft == 3
    camera.step();camera.start();camera.step();camera.step();camera.step()
    checks["room_camera_reentry_consumes_retained_hold"] = camera.sprite == 3 && camera.nextFrame == 1 && camera.ticksLeft == 4
    camera.step();camera.disable()
    let nextGame = NativeSession(profileID: UUID(),seed: 1,previousRoomCamera: camera)
    checks["room_camera_next_game_disables_without_resetting_phase"] = nextGame.roomCamera?.active == false && nextGame.roomCamera?.nextFrame == 1 && nextGame.roomCamera?.ticksLeft == 3 && nextGame.valid
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent("outnumbered-room-camera-"+UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let game = try NativeGameView(root: root,saveDirectory: directory,automaticallyPresentMessages: false)
    game.timer?.invalidate();game.zapTimer?.invalidate();game.soundEnabled = false;game.referenceMode = true;game.screen = .world
    for hall in [1,3,6,7,8] {
        game.session = NativeSession(profileID: UUID(),seed: 1)
        let object = game.world.scenes[hall].first { $0.kind == 1 }!
        game.session.position = NativePosition(scene: hall,playerUnit: hall*38+object.startUnit+1,cameraUnit: hall*38,facing: 1)
        game.interact();game.advanceDoor(irqTicks: 10_000)
        checks["room_camera_entry_nine_front_pose_updates_\(hall)"] = game.session.roomCamera?.active == true && game.session.roomCamera?.sprite == 5 && game.session.roomCamera?.nextFrame == 2 && game.session.roomCamera?.ticksLeft == 3
        let encoded = try JSONEncoder().encode(game.session!)
        game.session = try JSONDecoder().decode(NativeSession.self,from: encoded)
        checks["room_camera_active_phase_survives_session_restore_\(hall)"] = game.session.valid && game.session.roomCamera?.nextFrame == 2 && game.session.roomCamera?.ticksLeft == 3
        game.interact();game.advanceDoor(irqTicks: 10_000)
        checks["room_camera_exit_updates_and_retains_two_ticks_\(hall)"] = game.session.roomCamera?.active == false && game.session.roomCamera?.nextFrame == 0 && game.session.roomCamera?.ticksLeft == 2
    }
    game.session = NativeSession(profileID: UUID(),seed: 1);game.session.position = NativePosition(scene: 14,playerUnit: 5,cameraUnit: 0,facing: 1)
    game.ensureRoomCamera();var expected = game.session.generator;_ = expected.nextRandomValue()
    game.step()
    checks["room_camera_main_frame_has_no_extra_random_draw"] = game.session.roomCamera?.ticksLeft == 3 && game.session.generator.randomState == expected.randomState
    let stable = JSONEncoder();stable.outputFormatting = .sortedKeys
    let before = try stable.encode(game.session.roomCamera)
    game.screen = .decoder;game.session.clock.pause();for _ in 0..<12 { game.step() }
    checks["room_camera_decoder_pause_preserves_phase"] = try stable.encode(game.session.roomCamera) == before
    game.screen = .world;game.session.clock.resume()
    for _ in 0..<3 { game.updateRoomCamera(at: game.session.position) }
    try game.render();let first = game.canvas.pixels
    for _ in 0..<8 { game.updateRoomCamera(at: game.session.position) }
    try game.render();let second = game.canvas.pixels
    var changed = 0, outsideChanged = false
    for y in 0..<200 { for x in 0..<320 where first[y*320+x] != second[y*320+x] {
        changed += 1;if !(152..<184).contains(x) || !(24..<50).contains(y) { outsideChanged = true }
    } }
    checks["room_camera_changes_only_original_actor_rectangle"] = changed > 0 && !outsideChanged
    try game.canvas.writePNG(to: output.appendingPathComponent("native-room-camera-pan.png"))
    game.session.roomCamera = nil;game.ensureRoomCamera()
    checks["room_camera_legacy_room_initializes_without_invented_phase"] = game.session.roomCamera?.active == true && game.session.roomCamera?.sprite == 3 && game.session.roomCamera?.nextFrame == 0 && game.session.roomCamera?.ticksLeft == 4
    return checks
}
