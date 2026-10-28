import Cocoa

extension NativeGameView {
    var playerMotion: NativePlayerMotion {
        get { session?.playerMotion ?? NativePlayerMotion() }
        set { session.playerMotion = newValue }
    }
    func beginJump(direction: Int) {
        if direction != 0 { session.position.facing = direction }
        var motion = playerMotion
        if motion.request(8,horizontal: direction == 0 ? 0 : 2,vertical: -12) { playerMotion = motion;session.playerHasMoved = true }
    }
    func preparePlayerFrame() -> OriginalMovement {
        let direction = held.contains(124) ? 1 : (held.contains(123) ? -1 : 0)
        if direction != 0 {
            if !physicalKeyboard.leftFlip && !physicalKeyboard.rightFlip { session.position.facing = direction }
            session.playerHasMoved = true
        }
        var motion = playerMotion;motion.walk(direction != 0);playerMotion = motion
        let movement = OriginalMovement.frame(from: session.position,horizontal: motion.horizontal,facing: session.position.facing)
        session.position = movement.scrolled;session.telly?.shiftForCamera(by: movement.cameraShift)
        return movement
    }
    func finishPlayerFrame(_ movement: OriginalMovement) {
        var motion = playerMotion
        for sound in motion.advance(horizontalArgument: movement.horizontalArgument,position: movement.scrolled) { effect(sound) }
        session.position = movement.destination;playerMotion = motion
    }
    func startPlayerCollision(_ collision: OriginalCollisionEffect) {
        var motion = playerMotion
        motion.request(collision.playerAnimation,horizontal: collision.playerHorizontalStep)
        playerMotion = motion
    }
    func beginCollisionFlash(actor: Int,sameFacing: Bool,projectileKind: Int = 22) {
        let x = actor == 4 ? min(playerScreenUnit,session.telly!.xUnits)+1 : playerScreenUnit
        session.activeCollision = NativeCollisionFlash(actor: actor,sameFacing: sameFacing,projectileKind: projectileKind,xUnit: x)
        if actor == 4 { effect(51) }
        lastZapPulse = ProcessInfo.processInfo.systemUptime;zapFraction = 0
        save();needsDisplay = true
    }
    func advanceCollision(irqTicks: Int) {
        guard var flash = session.activeCollision else { return }
        let ticks = min(max(0,irqTicks),200-flash.elapsedIRQTicks)
        flash.elapsedIRQTicks += ticks;session.clock.pollAfterIRQTicks(UInt64(ticks),processMinute: false)
        session.activeCollision = flash
        if flash.elapsedIRQTicks == 200 {
            //14fe removes an ordinary Telly after the word wait, preserving
            //stunned/disappearing states.160c then selects the reaction.
            if session.telly?.state != .stunned && session.telly?.state != .disappearing { session.telly?.remove() }
            let collision = flash.effect
            startPlayerCollision(collision)
            if flash.actor == 4 { session.telly?.collideWithPlayer() }
            else { session.telly?.removeProjectile() }
            effect(20);queueTutorial(collision.warningID)
            if collision.energyCost > 0 { session.energy = VerifiedEnergy.applying(-collision.energyCost,to: session.energy)! }
            session.clock.applyMinutePenalty(collision.timePenaltyMinutes)
            session.activeCollision = nil;session.clock.pollAfterIRQTicks(0);save()
        }
        needsDisplay = true
    }
    func pulseCollision() {
        let now = ProcessInfo.processInfo.systemUptime
        defer { lastZapPulse = now }
        guard modalDepth == 0, screen == .world, session.activeCollision != nil else { return }
        let ticks = max(0,now-lastZapPulse)*VerifiedClock.pitInputHz/VerifiedClock.pitDivisor+zapFraction
        let whole = Int(min(ticks.rounded(.down),10_000));zapFraction = ticks-ticks.rounded(.down)
        advanceCollision(irqTicks: whole)
    }
    func drawPlayerSprite(_ ordinal: Int,x: Int,y: Int,flipped: Bool) throws {
        if ordinal >= 10000 {
            canvas.draw(try content.bitmap(String(format:"ROOMS.GRA.%03d",ordinal-10000)),x: x,y: y,transparent: true,flipped: flipped)
        } else { try sprite(ordinal,x: x,y: y,flipped: flipped) }
    }
}
