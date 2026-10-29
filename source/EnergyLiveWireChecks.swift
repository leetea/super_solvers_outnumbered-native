import Foundation

func nativeEnergyLiveWireChecks(root: URL, output: URL) throws -> [String: Bool] {
    var checks: [String: Bool] = [:]
    let world = try OriginalWorld(resource: Data(contentsOf: root.appendingPathComponent("catalog/decoded/MOCKET.DAT.1388.bin")))
    for candidate in OriginalWorld.energyMachineCandidates {
        let scene = candidate/4, slot = candidate%4
        let objects = world.objects(scene: scene,energyMachineSlot: candidate)
        let original = world.scenes[scene][slot], machine = objects[slot]
        checks["fountain_original_candidate_\(candidate)"] = machine.kind == 9 && machine.startUnit == original.startUnit && machine.endUnit == original.startUnit+12 && machine.drawY == 37 && machine.sprite == 195 && world.scenes[scene][slot].kind == 0
    }
    var action = NativeFountain(initialPlayerUnit: 50,targetPlayerUnit: 53,machineWorldUnit: 52,initialFacing: -1,credits: 4)
    checks["fountain_walks_to_start_plus_one"] = !action.advance(irqTicks: 72) && action.playerUnit == 53 && action.phase == .entering
    checks["fountain_no_award_before_approach_animation"] = !action.advance(irqTicks: 119)
    checks["fountain_award_at_dispense_start"] = action.advance(irqTicks: 1) && action.phase == .dispensing && action.machineSprite == 196
    _ = action.advance(irqTicks: 30)
    checks["fountain_alternates_original_sprite_after_30_IRQ"] = action.machineSprite == 197
    let restoredAction = try JSONDecoder().decode(NativeFountain.self,from: JSONEncoder().encode(action))
    action = restoredAction
    checks["fountain_partial_restore_does_not_repeat_credit"] = !action.advance(irqTicks: 240) && action.phase == .leaving && action.playerFrame == 14
    _ = action.advance(irqTicks: 120)
    checks["fountain_restores_facing_at_end"] = action.phase == .finished && action.facing == -1 && action.valid
    var empty = NativeFountain(initialPlayerUnit: 53,targetPlayerUnit: 53,machineWorldUnit: 52,initialFacing: 1,credits: 0)
    _ = empty.advance(irqTicks: 120)
    var emptyFrames = [empty.machineSprite]
    for _ in 0..<3 { _ = empty.advance(irqTicks: 30); emptyFrames.append(empty.machineSprite) }
    checks["empty_machine_four_original_frames"] = emptyFrames == [199,200,201,199] && empty.sound == 36

    let directory = FileManager.default.temporaryDirectory.appendingPathComponent("outnumbered-energy-"+UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let view = try NativeGameView(root: root,saveDirectory: directory,automaticallyPresentMessages: false)
    view.timer?.invalidate(); view.zapTimer?.invalidate(); view.soundEnabled = false
    view.referenceEnergy(); try view.render()
    let machineBefore = view.canvas.pixels
    try view.canvas.writePNG(to: output.appendingPathComponent("native-energy-machine.png"))
    view.interact()
    checks["up_at_energy_machine_starts_original_action"] = view.session.activeFountain != nil && view.session.energy == 10 && view.session.pendingRecharge == 4
    // Drive the real view pulse while preserving its source-derived duration.
    view.lastZapPulse = ProcessInfo.processInfo.systemUptime-1
    view.pulseFountain()
    checks["fountain_adds_all_credits_and_clears_pending"] = view.session.energy == 14 && view.session.pendingRecharge == 0 && view.session.activeFountain?.awardIssued == true
    try view.render()
    let machineX = (view.session.activeFountain!.machineWorldUnit-view.session.position.cameraUnit)*8
    var lowerBodyPreserved = true
    for y in 61..<124 { for x in (machineX+64)..<(machineX+88) {
        if view.canvas.pixels[y*320+x] != machineBefore[y*320+x] { lowerBodyPreserved = false }
    } }
    checks["recharge_animation_preserves_lower_machine_body"] = lowerBodyPreserved
    try view.canvas.writePNG(to: output.appendingPathComponent("native-energy-dispensing.png"))
    let saved = try JSONDecoder().decode(NativeSession.self,from: JSONEncoder().encode(view.session!))
    checks["native_mid_recharge_session_valid"] = saved.valid && saved.activeFountain?.credits == 4
    view.session = saved
    view.lastZapPulse = ProcessInfo.processInfo.systemUptime-4; view.pulseFountain()
    checks["native_recharge_resume_no_duplicate_award"] = view.session.energy == 14 && view.session.activeFountain == nil
    view.interact(); view.lastZapPulse = ProcessInfo.processInfo.systemUptime-4; view.pulseFountain()
    checks["empty_reuse_does_not_grant_free_energy"] = view.session.energy == 14 && view.session.pendingRecharge == 0 && view.session.activeFountain == nil

    view.referenceLiveWire()
    checks["reference_room_wire_original_spawn"] = view.session.liveWire?.xUnits == 30 && view.session.liveWire?.sprite == 10000
    try view.render(); try view.canvas.writePNG(to: output.appendingPathComponent("native-livewire-room.png"))
    view.beginZap()
    checks["native_room_zap_targets_livewire_width_nine"] = view.session.activeZap?.targetWidth == 9 && view.session.activeZap?.valid == true && view.session.activeZap?.hitEffect == OriginalZapHitEffect.disperseLiveWire.rawValue
    view.session.activeZap?.elapsedIRQTicks = 90; view.pulseZap()
    checks["native_energized_room_zap_disperses_wire"] = view.session.liveWire?.state == .dissipating && view.session.energy == 11 && view.session.activeDrill == nil
    for _ in 0..<6 { view.updateLiveWireAndCollision() }
    checks["native_dissipation_completes_without_energy_award"] = view.session.liveWire?.state == .removed && view.session.energy == 11
    view.referenceLiveWire(); view.session.energy = 0; view.beginZap()
    view.session.activeZap?.elapsedIRQTicks = 90; view.pulseZap()
    checks["native_empty_zap_cannot_disperse_livewire"] = view.session.liveWire?.state == .walking && view.session.energy == 0
    view.session.position.playerUnit = 25; view.updateLiveWireAndCollision()
    checks["native_room_wire_horizontal_collision_removes_once"] = view.session.liveWire?.state == .removed && view.session.energy == 0
    view.referenceLiveWire(); view.session.position.playerUnit = 25; view.beginJump(direction: 0); view.updateLiveWireAndCollision()
    checks["native_jump_excludes_livewire_collision"] = view.session.liveWire?.state == .walking && view.session.energy == 12
    view.session.playerMotion = nil; view.updateLiveWireAndCollision()
    checks["native_wire_collision_cost_one_energy"] = view.session.energy == 11 && view.session.liveWire?.state == .removed && view.playerMotion.animation == 30 && view.playerMotion.horizontal == -2
    let reaction = view.preparePlayerFrame();view.finishPlayerFrame(reaction)
    try view.render();try view.canvas.writePNG(to: output.appendingPathComponent("native-player-wire-reaction.png"))
    var legacy = try JSONSerialization.jsonObject(with: JSONEncoder().encode(NativeSession(profileID: UUID(),seed: 1))) as! [String:Any]
    for key in ["energyMachineSlot","activeFountain","liveWire"] { legacy.removeValue(forKey: key) }
    view.session = try JSONDecoder().decode(NativeSession.self,from: JSONSerialization.data(withJSONObject: legacy))
    checks["version03_session_without_new_fields_reads"] = view.session.valid && view.session.energyMachineSlot == nil && view.session.liveWire == nil
    view.ensureEnergyMachine()
    checks["legacy_session_gains_valid_machine_location"] = view.session.valid && OriginalWorld.energyMachineCandidates.contains(view.session.energyMachineSlot!)
    return checks
}
