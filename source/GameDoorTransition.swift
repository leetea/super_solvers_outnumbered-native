import Cocoa

extension NativeGameView {
    func beginDoor(_ object: OriginalWorldObject) {
        let origin = session.position
        let entering = origin.scene < 10
        let hall = entering ? origin.scene : session.returnPosition?.scene
        guard let hall, let door = world.scenes[hall].first(where: { $0.kind == 1 }) else { return }
        var hallway = entering ? origin : session.returnPosition!
        hallway.playerUnit = hall*38+door.startUnit+1
        hallway.facing = 1
        session.activeDoor = NativeDoorTransition(entering: entering,origin: origin,hallway: hallway,doorStartUnit: door.startUnit)
        held.removeAll(); jumpStep = nil; status = ""
        if entering { effect(3) }
        lastZapPulse = ProcessInfo.processInfo.systemUptime; zapFraction = 0
        save(); needsDisplay = true
    }
    func advanceDoor(irqTicks: Int) {
        guard var door = session.activeDoor else { return }
        let ticks = max(0,min(irqTicks,door.duration-door.elapsedIRQTicks))
        door.elapsedIRQTicks += ticks
        session.clock.pollAfterIRQTicks(UInt64(ticks),processMinute: false)
        if !door.destinationApplied && door.currentFrame.destination {
            door.destinationApplied = true
            session.position = door.destination
            session.returnPosition = door.entering ? door.hallway : nil
            clearTelly(); session.liveWire?.clear()
            if door.entering { attemptLiveWire() }
            else { effect(door.hallway.scene < 5 ? 1 : 2) }
        }
        session.activeDoor = door
        if door.elapsedIRQTicks >= door.duration {
            session.activeDoor = nil
            session.clock.pollAfterIRQTicks(0)
            save()
            if door.entering { showNewUserMessage(5) }
        }
        needsDisplay = true
    }
    func pulseDoor() {
        let now = ProcessInfo.processInfo.systemUptime
        defer { lastZapPulse = now }
        guard modalDepth == 0, screen == .world, session.activeDoor != nil else { return }
        let ticks = max(0,now-lastZapPulse)*VerifiedClock.pitInputHz/VerifiedClock.pitDivisor+zapFraction
        let whole = Int(min(ticks.rounded(.down),10_000))
        zapFraction = ticks-ticks.rounded(.down)
        advanceDoor(irqTicks: whole)
    }
}
