import Cocoa

func nativeElevatorTransitionChecks(root: URL,output: URL) throws -> [String:Bool] {
    var checks: [String:Bool] = [:]
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent("outnumbered-elevator-"+UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let view = try NativeGameView(root: root,saveDirectory: directory,automaticallyPresentMessages: false)
    view.timer?.invalidate(); view.zapTimer?.invalidate(); view.soundEnabled = false; view.referenceMode = true; view.screen = .world
    for hall in [0,4,5,9] {
        let object = view.world.scenes[hall].first { $0.kind == 2 }!
        view.session = NativeSession(profileID: UUID(),seed: 1)
        view.session.position = NativePosition(scene: hall,playerUnit: hall*38+object.startUnit+2,cameraUnit: hall*38,facing: -1)
        view.interact()
        let elevator = view.session.activeElevator!
        checks["elevator_starts_in_original_hall_\(hall)"] = elevator.valid && view.session.position.scene == hall
        let frames = elevator.frames
        let opening = frames.filter { $0.drawsPanels && !$0.destination && $0.ordinal == 13 }
        checks["elevator_original_open_order_and_wait_\(hall)"] = opening.map(\.panel) == [177,176,175,nil] && opening.allSatisfy { $0.ticks == 23 && $0.playerInFront }
        let closing = frames.filter { $0.drawsPanels && !$0.destination && $0.ordinal == 22 && $0.panel != nil }
        checks["elevator_rear_occluded_by_closing_panels_\(hall)"] = closing.map(\.panel) == [175,176,177,178] && closing.allSatisfy { !$0.playerInFront && $0.ticks == 23 }
        let travel = frames.filter { $0.scrollPixels > 0 }
        checks["elevator_eight_original_bands_\(hall)"] = travel.map(\.scrollPixels) == [18,36,54,72,90,108,126,146] && travel.allSatisfy { $0.ticks == 23 && $0.ordinal == nil }
        let travelStart = frames.prefix { $0.scrollPixels == 0 }.reduce(0) { $0+$1.ticks }
        view.advanceElevator(irqTicks: travelStart)
        checks["elevator_sound_and_position_at_travel_\(hall)"] = view.session.activeElevator?.travelSoundStarted == true && view.session.activeElevator?.destinationApplied == false && view.session.position.scene == hall
        try view.render();try view.canvas.writePNG(to: output.appendingPathComponent("native-elevator-\(hall)-scroll-first.png"))
        let menu = NSEvent.keyEvent(with: .keyDown,location: .zero,modifierFlags: [],timestamp: 0,windowNumber: 0,context: nil,characters: "\t",charactersIgnoringModifiers: "\t",isARepeat: false,keyCode: 48)!
        view.keyDown(with: menu)
        checks["elevator_decoder_locked_during_travel_\(hall)"] = view.screen == .world
        let encoder = JSONEncoder();encoder.outputFormatting = .sortedKeys
        let generator = try encoder.encode(view.session.generator)
        try view.saves.save(view.session)
        view.session = try view.saves.load(view.session.profileID)!
        var malformed = view.session!
        malformed.activeElevator?.elapsedIRQTicks = -1
        checks["elevator_invalid_saved_progress_rejected_\(hall)"] = !malformed.valid
        malformed = view.session!
        malformed.activeElevator?.destinationApplied = true
        checks["elevator_inconsistent_saved_destination_rejected_\(hall)"] = !malformed.valid
        view.advanceElevator(irqTicks: 23*4)
        let restoredGenerator = try encoder.encode(view.session.generator)
        checks["elevator_resume_preserves_travel_and_rng_\(hall)"] = view.session.activeElevator?.currentFrame.scrollPixels == 90 && view.session.valid && restoredGenerator == generator
        try view.render();try view.canvas.writePNG(to: output.appendingPathComponent("native-elevator-\(hall)-scroll-middle.png"))
        let seamY = hall < 5 ? 104 : 70
        checks["elevator_scroll_includes_original_viewport_border_\(hall)"] = (seamY-2...seamY).allSatisfy { row in (8..<312).allSatisfy { view.canvas.pixels[row*320+$0] == 1 } }
        let untilExit = frames.prefix { !$0.destination }.reduce(0) { $0+$1.ticks }
        view.advanceElevator(irqTicks: untilExit-view.session.activeElevator!.elapsedIRQTicks)
        checks["elevator_destination_applied_after_full_scroll_\(hall)"] = view.session.position == elevator.exitPosition && view.session.activeElevator?.currentFrame.panel == 177
        checks["elevator_irq_time_not_polled_as_game_minutes_\(hall)"] = view.session.clock.counterTicks == UInt64(untilExit) && view.session.clock.elapsedMinutes == 0
        try view.render();try view.canvas.writePNG(to: output.appendingPathComponent("native-elevator-\(hall)-exit-panel.png"))
        view.advanceElevator(irqTicks: 10_000)
        checks["elevator_final_idle_position_facing_\(hall)"] = view.session.activeElevator == nil && view.session.position == elevator.finalPosition && view.session.valid
    }
    // Independent row-address examples from135d:039b: bottom18 target rows
    //142..159 enter at14; reverse travel copies target14..31 to142..159.
    let canvas = NativeCanvas()
    var source = [UInt8](repeating: 0,count: 64_000), destination = source
    for row in 0..<200 { for x in 0..<320 { source[row*320+x] = UInt8(row%16);destination[row*320+x] = UInt8((row+7)%16) } }
    canvas.clear(15);canvas.compositeElevatorViewport(source: source,destination: destination,insertedPixels: 18,movingDown: true)
    checks["elevator_scroll_down_row_addresses"] = canvas.pixels[14*320] == destination[142*320] && canvas.pixels[31*320+311] == destination[159*320+311] && canvas.pixels[32*320] == source[14*320] && canvas.pixels[159*320] == source[141*320]
    canvas.clear(15);canvas.compositeElevatorViewport(source: source,destination: destination,insertedPixels: 18,movingDown: false)
    checks["elevator_scroll_up_row_addresses"] = canvas.pixels[14*320] == source[32*320] && canvas.pixels[141*320+311] == source[159*320+311] && canvas.pixels[142*320] == destination[14*320] && canvas.pixels[159*320] == destination[31*320]
    checks["elevator_scroll_preserves_hud_menu_and_right_margin"] = canvas.pixels[13*320] == 15 && canvas.pixels[160*320] == 15 && canvas.pixels[14*320+312] == 15
    for down in [false,true] {
        canvas.compositeElevatorViewport(source: source,destination: destination,insertedPixels: 146,movingDown: down)
        checks["elevator_full_scroll_equals_destination_\(down)"] = (14..<160).allSatisfy { row in canvas.pixels[(row*320)..<(row*320+312)].elementsEqual(destination[(row*320)..<(row*320+312)]) }
    }
    let p175 = try view.content.bitmap("FASTLOAD.GRA.175"), p178 = try view.content.bitmap("FASTLOAD.GRA.178"),base = try view.content.bitmap("FASTLOAD.GRA.179")
    checks["elevator_original_panel_extents"] = p175.width == 16 && p178.width == 48 && base.width == 96 && base.height == 62
    let encoder = JSONEncoder()
    var legacy = try JSONSerialization.jsonObject(with: encoder.encode(view.session)) as! [String:Any]
    legacy.removeValue(forKey: "activeElevator")
    let decoded = try JSONDecoder().decode(NativeSession.self,from: JSONSerialization.data(withJSONObject: legacy))
    checks["elevator_legacy_session_without_transition_field"] = decoded.valid && decoded.activeElevator == nil
    return checks
}
