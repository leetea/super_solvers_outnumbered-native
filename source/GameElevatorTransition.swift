import Cocoa

extension NativeGameView {
    var isTransitioning: Bool { session?.activeDoor != nil || session?.activeElevator != nil }
    func beginElevator(_ object: OriginalWorldObject) {
        session.activeElevator = NativeElevatorTransition(origin: session.position,startUnit: object.startUnit)
        held.removeAll(); jumpStep = nil; status = ""
        lastZapPulse = ProcessInfo.processInfo.systemUptime; zapFraction = 0
        save(); needsDisplay = true
    }
    func advanceElevator(irqTicks: Int) {
        guard var elevator = session.activeElevator else { return }
        let ticks = max(0,min(irqTicks,elevator.duration-elevator.elapsedIRQTicks))
        elevator.elapsedIRQTicks += ticks
        session.clock.pollAfterIRQTicks(UInt64(ticks),processMinute: false)
        let frame = elevator.currentFrame
        if !elevator.travelSoundStarted && (frame.scrollPixels > 0 || frame.destination) {
            effect(elevator.origin.scene < 5 ? 22 : 21); elevator.travelSoundStarted = true
        }
        if !elevator.destinationApplied && frame.destination {
            session.position = elevator.exitPosition; clearTelly()
            elevator.destinationApplied = true
        }
        session.activeElevator = elevator
        if elevator.elapsedIRQTicks >= elevator.duration {
            session.position = elevator.finalPosition
            session.activeElevator = nil; session.clock.pollAfterIRQTicks(0); save()
        }
        needsDisplay = true
    }
    func pulseElevator() {
        let now = ProcessInfo.processInfo.systemUptime
        defer { lastZapPulse = now }
        guard modalDepth == 0, screen == .world, session.activeElevator != nil else { return }
        let ticks = max(0,now-lastZapPulse)*VerifiedClock.pitInputHz/VerifiedClock.pitDivisor+zapFraction
        let whole = Int(min(ticks.rounded(.down),10_000)); zapFraction = ticks-ticks.rounded(.down)
        advanceElevator(irqTicks: whole)
    }
    func drawElevatorPanels(_ elevator: NativeElevatorTransition,_ frame: NativeElevatorTransition.Frame) throws {
        let x = (frame.position.scene*38+elevator.startUnit-frame.position.cameraUnit+2)*8
        if let panel = frame.panel {
            let bitmap = try content.bitmap(String(format: "FASTLOAD.GRA.%03d",panel))
            try sprite(panel,x: x,y: 53)
            try sprite(panel,x: x+96-bitmap.width,y: 53,flipped: true)
        }
    }
    func drawElevatorBase(_ elevator: NativeElevatorTransition,_ frame: NativeElevatorTransition.Frame) throws {
        let x = (frame.position.scene*38+elevator.startUnit-frame.position.cameraUnit+2)*8
        try sprite(179,x: x,y: 53,transparent: false)
    }
    func drawElevatorScroll(_ elevator: NativeElevatorTransition,_ pixels: Int) throws {
        try drawWorldBackdrop(elevator.aligned)
        canvas.border(4,14,312,146,0); let source = canvas.pixels
        try drawWorldBackdrop(elevator.exitPosition)
        canvas.border(4,14,312,146,0); let destination = canvas.pixels
        canvas.compositeElevatorViewport(source: source,destination: destination,insertedPixels: pixels,movingDown: elevator.origin.scene < 5)
        canvas.clip = nil; canvas.border(4,14,312,146,0)
    }
}
