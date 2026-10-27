import Cocoa

extension NativeGameView {
    var playerScreenUnit: Int { session.position.scene < 10 ? session.position.playerUnit-session.position.cameraUnit : session.position.playerUnit }
    func clearTelly() {
        session.telly?.remove(); session.telly?.removeProjectile(); session.telly?.beginFrame()
    }
    func updateTelly() {
        var enemy = session.telly ?? (try! OriginalTelly(tier: session.decoder.difficulty))
        enemy.beginFrame()
        var generator = session.generator
        let context = OriginalTellyContext(hallway: session.position.scene < 10,allowSpawning: true,playerHasMoved: session.playerHasMoved ?? false,cameraSegment: session.position.cameraUnit/38,playerScreenUnit: playerScreenUnit,capturedCodePieces: session.decoder.capturedCount)
        let events = enemy.step(context: context,nextRandom: { generator.nextRandomValue() })
        session.generator = generator; session.telly = enemy
        for sound in events.sounds { effect(sound) }
    }
    func updateTellyProjectileAndCollision() {
        guard var enemy = session.telly else { return }
        for sound in enemy.stepProjectile().sounds { effect(sound) }
        if !playerMotion.airborne && session.activeCollision == nil && session.position.scene < 10 {
            let actor = world.actors[3]
            let left = playerScreenUnit+actor.collisionLeftOffsetUnits, width = actor.collisionWidthUnits
            var collision: OriginalCollisionEffect?
            if let projectile = enemy.projectile, !projectile.pendingRemoval,
               OriginalCollisionEffect.horizontalGap(leftA: left,widthA: width,leftB: projectile.xUnits,widthB: projectile.collisionWidthUnits) < 1 {
                collision = .forActor(5,sameFacing: session.position.facing == enemy.facing,projectileKind: projectile.kind)
            } else if enemy.hittable && OriginalCollisionEffect.horizontalGap(leftA: left,widthA: width,leftB: enemy.collisionLeftUnit,widthB: enemy.collisionWidthUnits) < 1 {
                collision = .forActor(4,sameFacing: session.position.facing == enemy.facing)
            }
            if let collision {
                session.telly = enemy
                beginCollisionFlash(actor: collision.timePenaltyMinutes > 0 ? 5 : 4,sameFacing: session.position.facing == enemy.facing,projectileKind: enemy.projectile?.kind ?? 22)
            }
        }
        session.telly = enemy
    }
    func beginZap() {
        guard playerMotion.settled else { return }
        session.playerHasMoved = true
        let enemy = session.telly, target = enemy?.hittable == true ? enemy : nil
        let hallway = session.position.scene < 10
        let wire = session.liveWire?.collisionEnabled == true ? session.liveWire : nil
        let left = hallway ? target?.collisionLeftUnit : wire?.collisionLeftUnit
        let width = hallway ? (target?.collisionWidthUnits ?? 0) : (wire?.collisionWidthUnits ?? 0)
        let schedule = OriginalZapSchedule(playerX: playerScreenUnit,playerY: 81,facing: session.position.facing,energy: session.energy,targetLeft: left,targetWidth: width)
        let effect = originalZapHitEffect(playerAnimation: 1,energy: session.energy,hit: schedule.hit,hallway: hallway,tellyLit: target?.bellyLit ?? false,liveWireState: wire?.state.rawValue ?? 0)
        session.activeZap = NativeZap(playerX: playerScreenUnit,playerY: 81,facing: session.position.facing,initialEnergy: session.energy,targetLeft: left,targetWidth: width,hitEffect: effect.rawValue)
        lastZapPulse = ProcessInfo.processInfo.systemUptime; zapFraction = 0
    }
    func pulseZap() {
        if isActivityPresenting { pulseActivityPresentation();return }
        if session != nil && session.activeCollision != nil { pulseCollision();return }
        if session != nil && session.activeElevator != nil { pulseElevator(); return }
        if session != nil && session.activeDoor != nil { pulseDoor(); return }
        if session != nil && session.activeFountain != nil { pulseFountain(); return }
        let now = ProcessInfo.processInfo.systemUptime
        defer { lastZapPulse = now }
        guard modalDepth == 0, session != nil, screen == .world, var zap = session.activeZap else { return }
        let ticks = max(0,now-lastZapPulse)*VerifiedClock.pitInputHz/VerifiedClock.pitDivisor+zapFraction
        let whole = min(90-zap.elapsedIRQTicks,Int(ticks.rounded(.down)))
        zapFraction = ticks-ticks.rounded(.down)
        zap.elapsedIRQTicks += whole
        session.clock.pollAfterIRQTicks(UInt64(whole),processMinute: false)
        if zap.elapsedIRQTicks >= zap.schedule.soundStartIRQTicks && !zap.soundStarted { effect(zap.schedule.sound); zap.soundStarted = true }
        session.activeZap = zap
        if zap.elapsedIRQTicks >= zap.schedule.totalDurationIRQTicks {
            session.energy = VerifiedEnergy.applying(-zap.schedule.energyCost,to: session.energy)!
            session.activeZap = nil; session.clock.pollAfterIRQTicks(0)
            var motion = playerMotion;motion.request(1,count: 1);playerMotion = motion
            if zap.hitEffect == OriginalZapHitEffect.startDrill.rawValue { startDrill() }
            else if zap.hitEffect == OriginalZapHitEffect.stunTelly.rawValue, var enemy = session.telly {
                effect(enemy.stun()); session.telly = enemy
            } else if zap.hitEffect == OriginalZapHitEffect.disperseLiveWire.rawValue {
                session.liveWire?.disperseFromZap()
            }
            save()
        }
        needsDisplay = true
    }
    func ensureEnergyMachine() {
        guard session.energyMachineSlot == nil else { return }
        session.energyMachineSlot = OriginalWorld.energyMachineCandidates[session.generator.nextRandomValue()%9]
    }
    func beginFountain(_ object: OriginalWorldObject) {
        let machineUnit = session.position.scene*38+object.startUnit
        if session.pendingRecharge == 0 { queueTutorial(4) }
        session.activeFountain = NativeFountain(initialPlayerUnit: session.position.playerUnit,targetPlayerUnit: machineUnit+1,machineWorldUnit: machineUnit,initialFacing: session.position.facing,credits: session.pendingRecharge,origin: session.position)
        held.removeAll(); status = ""; session.playerMotion = nil
        lastZapPulse = ProcessInfo.processInfo.systemUptime; zapFraction = 0
        advanceFountain(irqTicks: 0)
        save()
    }
    func advanceFountain(irqTicks: Int) {
        guard var fountain = session.activeFountain else { return }
        let first = fountain.auxiliaryFramesApplied ?? fountain.currentFrameIndex+1
        let ticks = min(max(0,irqTicks),fountain.duration-fountain.elapsedIRQTicks)
        session.clock.pollAfterIRQTicks(UInt64(ticks),processMinute: false)
        let award = fountain.advance(irqTicks: ticks)
        var rewarded = false
        func issueAward() {
            session.energy = VerifiedEnergy.applying(fountain.credits,to: session.energy)!
            session.pendingRecharge = 0;effect(fountain.sound);rewarded = true
        }
        if fountain.origin != nil {
            let frames = fountain.frames,last = fountain.currentFrameIndex
            if first <= last { for i in first...last {
                let frame = frames[i]
                if award && !rewarded && frame.phase == .dispensing { issueAward() }
                if frame.phase == .leaving && i > 0 && frames[i-1].phase == .dispensing {
                    sound?.stop();lastSoundIndex = nil
                }
                if frame.updatesActors {
                    var prior = i == 0 ? fountain.origin! : frames[i-1].position
                    session.telly?.shiftForCamera(by: frame.position.cameraUnit-prior.cameraUnit)
                    prior.cameraUnit = frame.position.cameraUnit
                    updateTransitionActors(at: prior,playerStepSound: transitionWalkSound(at: frame.position,ordinal: frame.ordinal))
                }
            } }
            fountain.auxiliaryFramesApplied = last+1
            session.position = fountain.currentFrame.position
            session.position.facing = fountain.facing
        } else {
            session.position.playerUnit = fountain.playerUnit;session.position.facing = fountain.facing
        }
        if award && !rewarded { issueAward() }
        session.activeFountain = fountain
        if fountain.phase == .finished {
            if fountain.origin == nil { sound?.stop();lastSoundIndex = nil }
            session.activeFountain = nil;session.clock.pollAfterIRQTicks(0);save()
        }
        needsDisplay = true
    }
    func pulseFountain() {
        let now = ProcessInfo.processInfo.systemUptime
        defer { lastZapPulse = now }
        guard modalDepth == 0, screen == .world, session.activeFountain != nil else { return }
        let ticks = max(0,now-lastZapPulse)*VerifiedClock.pitInputHz/VerifiedClock.pitDivisor+zapFraction
        let whole = Int(min(ticks.rounded(.down),10_000))
        zapFraction = ticks-ticks.rounded(.down)
        advanceFountain(irqTicks: whole)
    }
    func attemptLiveWire() {
        var wire = session.liveWire ?? (try! OriginalLiveWire(tier: session.decoder.difficulty))
        var generator = session.generator
        _ = wire.attemptSpawn(playerScreenUnit: playerScreenUnit,nextRandom: { generator.nextRandomValue() })
        session.generator = generator; session.liveWire = wire
    }
    func updateLiveWireAndCollision() {
        guard session.activeCollision == nil, session.position.scene >= 10, var wire = session.liveWire else { return }
        wire.beginFrame()
        for sound in wire.step().sounds { effect(sound) }
        if !playerMotion.airborne && wire.collisionEnabled && OriginalCollisionEffect.horizontalGap(leftA: playerScreenUnit+1,widthA: 4,leftB: wire.collisionLeftUnit,widthB: wire.collisionWidthUnits) < 1 {
            let collision = OriginalCollisionEffect.forActor(1,sameFacing: session.position.facing == wire.facing)!
            session.energy = VerifiedEnergy.applying(-collision.energyCost,to: session.energy)!
            for sound in collision.sounds { effect(sound) }
            startPlayerCollision(collision)
            wire.collideWithPlayer(); queueTutorial(6)
        }
        session.liveWire = wire
    }
    func drawLiveWire() throws {
        guard session.position.scene >= 10, let wire = session.liveWire, wire.collisionEnabled, let sprite = wire.sprite else { return }
        canvas.draw(try content.bitmap(String(format: "ROOMS.GRA.%03d",sprite-10000)),x: wire.xUnits*8,y: OriginalLiveWire.yPixels,transparent: true,flipped: wire.renderMirrored)
    }
    @objc func referenceEnergy() {
        session = NativeSession(profileID: UUID(),seed: 1)
        session.energyMachineSlot = 6
        let object = world.objects(scene: 1,energyMachineSlot: 6)[2]
        session.position = NativePosition(scene: 1,playerUnit: 38+object.startUnit+1,cameraUnit: 38,facing: 1)
        session.energy = 10; session.pendingRecharge = 4
        referenceMode = true; screen = .world; held.removeAll(); status = "Up to recharge"; needsDisplay = true
    }
    @objc func referenceLiveWire() {
        session = NativeSession(profileID: UUID(),seed: 1)
        session.position = NativePosition(scene: 10,playerUnit: 12,cameraUnit: 0,facing: 1)
        session.returnPosition = NativePosition(scene: 1,playerUnit: 52,cameraUnit: 38,facing: 1)
        _ = session.liveWire?.attemptSpawn(playerScreenUnit: 12,nextRandom: { 0 })
        referenceMode = true; screen = .world; held.removeAll(); status = "Space to zap LiveWire"; needsDisplay = true
    }
    func startDrill(reference: Bool = false) {
        do {
            var generator = session.generator
            session.activeDrill = try NativeDrill(tier: session.decoder.difficulty,nextRandom: { generator.nextRandomValue() },reference: reference,settings: session.gameSettings)
            session.activeDrill?.presentation = NativeDrillPresentation()
            session.generator = generator; clearTelly(); held.removeAll(); screen = .drill; status = ""
            try advanceDrill(irqTicks: 0);save()
        } catch { present(error) }
    }
    @objc func referenceDrill() {
        // Selected native checkpoint seed matches three observed symbols and
        // the Equipment hideout; it is not an inferred historical DOS seed.
        session = NativeSession(profileID: UUID(),seed: 6908,lifetimePoints: 30_000)
        // Keep this isolated video checkpoint fixed as campaign setup gains
        // the original question draws before decoder generation.
        var checkpoint = DecoderGenerator(seed: 6908)
        session.decoder = checkpoint.makePuzzle(difficulty: 1)
        sound?.stop(); lastSoundIndex = nil
        session.score = 600
        for _ in 0..<12 { session.clock.pollAfterIRQTicks(781) }
        referenceMode = true; startDrill(reference: true); needsDisplay = true
    }
    func advanceDrill(irqTicks: Int) throws {
        var remaining = max(0,irqTicks)
        while var drill = session.activeDrill {
            if var presentation = drill.presentation, presentation.animated {
                let result = presentation.advance(irqTicks: remaining)
                remaining -= result.consumed;drill.presentation = presentation
                session.activeDrill = drill
                for sound in result.sounds {
                    switch sound {
                    case .play(let index): effect(index)
                    case .stop: self.sound?.stop();lastSoundIndex = nil
                    }
                }
                if presentation.stage == .result { finishDrill() }
                if remaining == 0 { return }
                continue
            }
            if drill.phase != .finished {
                let previous = drill.phase
                var generator = session.generator, unused = remaining
                let award = try drill.advance(irqTicks: remaining,remainingIRQTicks: &unused,nextRandom: { generator.nextRandomValue() })
                remaining = unused;session.score = VerifiedScore.adding(award,to: session.score)
                session.generator = generator;session.activeDrill = drill
                if previous != drill.phase && drill.phase == .asking { scheduleTutorial(8,ticks: 720) }
                if drill.phase != .finished { return }
            }
            if var presentation = drill.presentation, presentation.stage == .questions {
                presentation.beginResult(success: drill.entitledToCode)
                drill.presentation = presentation;session.activeDrill = drill
                //Even at an exact boundary, draw and sound the first frame.
                continue
            }
            finishDrill()
            guard var result = session.activeDrill, result.rewardApplied else { return }
            result.resultTicksRemaining = max(0,result.resultTicksRemaining-remaining)
            session.activeDrill = result
            if result.resultTicksRemaining == 0 {
                let captured = result.capturedSymbol != nil
                session.activeDrill = nil;screen = .world;save()
                if captured { showNewUserMessage(3) }
            }
            return
        }
    }
    func finishDrill() {
        guard var drill = session.activeDrill, !drill.rewardApplied,
              drill.presentation == nil || drill.presentation?.stage == .result else { return }
        drill.rewardApplied = true
        if drill.entitledToCode, let symbol = session.decoder.collectSecret() {
            session.score = VerifiedScore.adding(100,to: session.score)
            drill.capturedSymbol = symbol; drill.resultTicksRemaining = 720
        } else { effect(9); drill.resultTicksRemaining = 480 }
        session.activeDrill = drill; save()
    }
    func drawTellyAndProjectile() throws {
        guard session.position.scene < 10, let enemy = session.telly else { return }
        if enemy.state != .absent && enemy.state != .removed, let frame = enemy.sprite {
            try sprite(frame,x: enemy.xUnits*8,y: enemy.yPixels,flipped: enemy.facing > 0)
            if enemy.bellyLit { try sprite(enemy.bellySprite,x: enemy.xUnits*8,y: enemy.yPixels+enemy.bellyOffsetY,flipped: enemy.facing > 0) }
        }
        if let projectile = enemy.projectile, !projectile.pendingRemoval, let frame = projectile.sprite {
            try sprite(frame,x: projectile.xUnits*8,y: projectile.yPixels,flipped: enemy.facing > 0)
        }
    }
    func drawDrill() throws {
        guard let drill = session.activeDrill else { return }
        try drawDrill(drill)
    }
    func drawDrill(_ drill: NativeDrill) throws {
        canvas.draw(try content.bitmap("DMOCKET.GRA.157c"),x: 0,y: 15)
        let presentation = drill.presentation
        let animated = presentation?.animated == true
        let capture = presentation?.stage == .capture
        let tv = capture || (presentation?.stage == .result && drill.capturedSymbol == nil) ? 12 : (presentation?.sprite ?? 12)
        canvas.draw(try content.bitmap(String(format: "DRILL.GRA.%03d",tv)),x: 76,y: 28,transparent: true)
        if capture {
            //104b:04c0 uses eight-pixel byte columns, unlike bitmap X/4.
            canvas.fill(152,53,40,37,0)
            canvas.draw(try content.bitmap(String(format: "DRILL.GRA.%03d",presentation!.sprite)),x: 152,y: 55,transparent: true)
        }
        let font = try content.font("MOCKET.DAT.1394"), small = try content.font("MOCKET.DAT.1396"), ui = try content.font("MOCKET.DAT.1393")
        if animated { /*Original synchronous animation accepts no answers.*/ }
        else if drill.phase == .finished && drill.practice != true {
            if let symbol = drill.capturedSymbol { try sprite(Int(symbol)+78,x: 156,y: 65,transparent: true) }
            else { canvas.text("No Code. Catch me again!",font: small,x: 102,y: 70,color: 15) }
        } else if drill.phase != .between && drill.phase != .finished {
            let parts = drill.displayParts, widths = parts.map { font.width(of: $0) }
            let total = widths.reduce(0,+)+27
            let left = 164-total/2
            let positions = [left,left+widths[0]+5,left+widths[0]+widths[1]+10,left+widths[0]+widths[1]+widths[2]+15,left+widths[0]+widths[1]+widths[2]+27]
            for i in parts.indices {
                let highlighted = i == [4,0,2][drill.question.blank.rawValue] && drill.phase == .showCorrect
                canvas.text(parts[i],font: font,x: positions[i],y: 70,color: highlighted ? 12 : 15)
            }
            if drill.phase == .correctFeedback || drill.phase == .correctPause { canvas.text(drill.acknowledgement,font: small,x: 162-small.width(of: drill.acknowledgement)/2,y: 104,color: 15) }
            if drill.phase == .wrongFeedback { canvas.text("That's incorrect.",font: small,x: 120,y: 104,color: 15) }
        }
        if drill.practice != true && presentation?.stage != .capture && !(presentation?.stage == .result && drill.capturedSymbol != nil) { canvas.text("\u{84} to Explore TV Station",font: ui,x: 8,y: 184,color: 15) }
    }
}
