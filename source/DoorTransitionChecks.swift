import Cocoa

func nativeDoorTransitionChecks(root: URL,output: URL) throws -> [String:Bool] {
    var checks: [String:Bool] = [:]
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent("outnumbered-door-"+UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let view = try NativeGameView(root: root,saveDirectory: directory,automaticallyPresentMessages: false)
    view.timer?.invalidate(); view.zapTimer?.invalidate(); view.soundEnabled = false
    view.referenceMode = true; view.screen = .world
    view.session = NativeSession(profileID: UUID(),seed: 1)
    view.session.position = NativePosition(scene: 1,playerUnit: 50,cameraUnit: 38,facing: -1)
    view.interact()
    let door = view.session.activeDoor!
    checks["door_transition_starts_before_room_swap"] = view.session.position.scene == 1 && door.entering && door.valid
    let phases = door.frames
    checks["door_alignment_walks_to_original_target"] = Array(phases.prefix(3)).map { $0.position.playerUnit } == [51,52,53] && phases[2].position.facing == 1
    let backward = phases.filter { (9...13).contains($0.ordinal) && $0.doorOrdinal == nil }
    checks["door_original_rear_pose_coordinates"] = backward.map(\.ordinal) == [9,10,11,12,13] && backward.map(\.y) == [78,75,72,69,66] && backward.allSatisfy { $0.ticks == 24 }
    checks["door_original_open_panels"] = phases.compactMap(\.doorOrdinal).prefix(3).elementsEqual([134,135,136])
    checks["door_original_small_rear_coordinates"] = phases.filter { (19...22).contains($0.ordinal) }.map(\.y) == [62,58,54,50]
    checks["door_original_small_front_coordinates"] = phases.filter { $0.destination && (23...26).contains($0.ordinal) }.map(\.y) == [54,58,62,66]
    checks["door_original_front_coordinates"] = phases.filter { $0.destination && (14...18).contains($0.ordinal) }.map(\.y) == [69,72,75,78,81]
    let counter = view.session.clock.counterTicks
    let tab = NSEvent.keyEvent(with: .keyDown,location: .zero,modifierFlags: [],timestamp: 0,windowNumber: 0,context: nil,characters: "\t",charactersIgnoringModifiers: "\t",isARepeat: false,keyCode: 48)!
    view.keyDown(with: tab)
    checks["door_blocks_decoder_input_during_sequence"] = view.screen == .world && view.session.activeDoor?.elapsedIRQTicks == 0
    view.step()
    checks["door_main_timer_does_not_double_count_irq"] = view.session.clock.counterTicks == counter
    let midpoint = phases.prefix { !$0.destination }.reduce(0) { $0+$1.ticks }
    view.advanceDoor(irqTicks: midpoint-1)
    checks["door_room_switch_waits_for_rear_sequence"] = view.session.position.scene == 1 && view.session.activeDoor?.currentFrame.ordinal == 22
    try view.render(); try view.canvas.writePNG(to: output.appendingPathComponent("native-door-small-rear.png"))
    view.advanceDoor(irqTicks: 1)
    checks["door_room_switch_sets_return_and_front_pose"] = view.session.position.scene == 10 && view.session.returnPosition?.playerUnit == 53 && view.session.activeDoor?.currentFrame.ordinal == 23
    checks["door_irq_counter_runs_without_displayed_minutes"] = view.session.clock.counterTicks == counter+UInt64(midpoint) && view.session.clock.elapsedMinutes == 0
    let encoder = JSONEncoder(); encoder.outputFormatting = .sortedKeys
    let generator = try encoder.encode(view.session.generator)
    try view.saves.save(view.session)
    let restored = try view.saves.load(view.session.profileID)!
    checks["door_midpoint_save_retains_stage_and_position"] = restored.valid && restored.activeDoor?.elapsedIRQTicks == midpoint && restored.activeDoor?.destinationApplied == true && restored.position == view.session.position
    view.session = restored
    view.advanceDoor(irqTicks: 24)
    checks["door_midpoint_initialization_not_repeated_after_restore"] = try encoder.encode(view.session.generator) == generator
    try view.render(); try view.canvas.writePNG(to: output.appendingPathComponent("native-door-small-front.png"))
    view.advanceDoor(irqTicks: 10_000)
    checks["door_entrance_finishes_idle_at_room_exit"] = view.session.activeDoor == nil && view.session.position == NativePosition(scene: 10,playerUnit: 5,cameraUnit: 0,facing: 1)
    view.interact()
    let exit = view.session.activeDoor!
    checks["door_exit_original_close_panel_order"] = exit.frames.compactMap(\.doorOrdinal).suffix(8).elementsEqual([136,135,134,134,134,134,134,134])
    let close = exit.frames.filter { $0.destination && $0.ordinal == 18 && $0.y == 66 }
    checks["door_exit_closing_keeps_source_front_pose"] = close.map(\.doorOrdinal) == [136,135,134]
    view.advanceDoor(irqTicks: exit.frames.prefix { !$0.destination }.reduce(0) { $0+$1.ticks })
    try view.render(); try view.canvas.writePNG(to: output.appendingPathComponent("native-door-hall-return.png"))
    checks["door_exit_restores_aligned_hallway_midpoint"] = view.session.position == NativePosition(scene: 1,playerUnit: 53,cameraUnit: 38,facing: 1) && view.session.returnPosition == nil
    view.advanceDoor(irqTicks: 10_000)
    checks["door_exit_finishes_without_active_sequence"] = view.session.activeDoor == nil && view.session.valid
    var malformed = restored
    malformed.activeDoor?.elapsedIRQTicks = -1
    checks["door_invalid_saved_stage_rejected"] = !malformed.valid
    // Removing the newly optional key reproduces a legacy session file.
    let data = try encoder.encode(view.session)
    var legacy = try JSONSerialization.jsonObject(with: data) as! [String:Any]
    legacy.removeValue(forKey: "activeDoor")
    let old = try JSONDecoder().decode(NativeSession.self,from: JSONSerialization.data(withJSONObject: legacy))
    checks["door_legacy_sessions_remain_readable"] = old.activeDoor == nil && old.valid
    return checks
}
