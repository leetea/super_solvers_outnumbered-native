import Foundation

extension NativeGameView {
    func startEnding(room: Int,reason: NativeEnding.Reason? = nil) {
        guard session.activeEnding == nil, (0..<5).contains(room) else { return }
        let reason = reason ?? (session.decoder.isWinningChoice(room: room) ? .hideout : .wrongHideout)
        let playerLine = reason == .midnight ? 0 : (session.generator.nextRandomValue()%101 < 50 ? 0 : 1)
        let masterLine = reason == .midnight ? 0 : (session.generator.nextRandomValue()%101 < 50 ? 0 : 1)
        session.activeEnding = NativeEnding(reason: reason,room: room,tier: session.decoder.difficulty,initialEnergy: session.energy,initialMinutes: session.clock.elapsedMinutes,initialScore: session.score,initialLifetime: session.lifetimePoints,playerDialogue: playerLine,masterDialogue: masterLine)
        if session.runID == nil { session.runID = UUID() }
        session.activeChallenge = nil;session.activityPresentation = nil; session.activeDrill = nil; session.activeZap = nil
        session.activeFountain = nil; session.activeCollision = nil; session.playerMotion = nil; session.liveWire?.clear(); clearTelly()
        if reason != .midnight { disableRoomCamera() }
        while session.clock.pauseDepth > 0 { session.clock.resume() }
        session.clock.pause(); held.removeAll(); screen = .ending; status = ""
        lastEndingPulse = ProcessInfo.processInfo.systemUptime;endingFraction = 0
        endingStartedAt = lastEndingPulse;endingFinishedWallSeconds = nil
        endingLastDraw = nil;endingMaxDrawGap = 0;endingDrawCount = 0;endingReportWritten = false
        if reason == .midnight { effect(49) } else { effect(3) }
        save(); needsDisplay = true
    }
    func pulseEnding(now: Double = ProcessInfo.processInfo.systemUptime) {
        let delta = max(0,now-lastEndingPulse);lastEndingPulse = now
        guard screen == .ending,modalDepth == 0 else { endingFraction = 0;return }
        let ticks = delta*VerifiedClock.pitInputHz/VerifiedClock.pitDivisor+endingFraction
        let whole = Int(min(10_000,ticks.rounded(.down)))
        endingFraction = ticks-ticks.rounded(.down)
        guard whole > 0 else { return }
        do { try advanceEnding(whole) } catch { present(error) }
    }
    func advanceEnding(_ ticks: Int = OriginalWorld.frameIRQTicks) throws {
        guard var ending = session.activeEnding else { return }
        let timeline = EndingTimeline(ending,data: endingData), old = ending.elapsedTicks
        ending.elapsedTicks = min(timeline.duration,old+max(0,ticks))
        session.activeEnding = ending
        for cue in timeline.sounds(after: old,through: ending.elapsedTicks) {
            if cue.interrupt { stopSound() }
            if cue.index >= 0 { effect(cue.index) }
        }
        let totals = timeline.totals(at: ending.elapsedTicks)
        session.energy = totals.energy; session.score = totals.score
        session.clock.applyMinutePenalty(max(0,totals.minutes-session.clock.elapsedMinutes))
        if ending.elapsedTicks == timeline.duration {
            if endingFinishedWallSeconds == nil { endingFinishedWallSeconds = ProcessInfo.processInfo.systemUptime-endingStartedAt }
            session.outcome = ending.won ? "won" : "lost"; screen = .results
            try commitEndingResult()
            if ending.reason == .midnight { continueAfterResults() }
        }
        if tick-lastSaveTick >= 20 { save(); lastSaveTick = tick }
        needsDisplay = true
    }
    func commitEndingResult() throws {
        guard let ending = session.activeEnding, !ending.committed else { return }
        let timeline = EndingTimeline(ending,data: endingData)
        guard ending.elapsedTicks >= timeline.duration else { return }
        let total: Int
        if referenceMode { total = timeline.totals(at: timeline.duration).lifetime }
        else {
            total = try profileStore.recordFinishedSession(profileID: session.profileID,runID: session.runID!,score: session.score,won: ending.won,lifetimeBefore: ending.initialLifetime)
        }
        session.lifetimePoints = total; session.activeEnding?.committed = true; save()
    }
    func beginNextGame() throws {
        try commitEndingResult()
        guard session.activeEnding?.committed == true else { return }
        var stream = session.generator
        let seed = UInt32(stream.nextRandomValue())
        let messages = session.newUserMessages
        session = NativeSession(profileID: session.profileID,seed: seed,lifetimePoints: session.lifetimePoints,previousGenerator: stream,previousRoomCamera: session.roomCamera)
        if let messages { session.newUserMessages = messages }
        screen = .world; held.removeAll(); status = ""; save(); needsDisplay = true
    }
    func continueAfterResults() {
        guard confirmation == nil,session.activeEnding != nil else { return }
        do {
            try commitEndingResult()
            //17beb returns every nonzero result, including Escape, to Sign-In.
            //No first offers ordinary Exit; declining that also reaches Sign-In.
            showConfirmation(.replay(won: session.activeEnding!.won)) { [weak self] choice in
                guard let self else { return }
                if choice == 0 {
                    self.showConfirmation(.exit(saving: false)) { [weak self] exitChoice in
                        guard let self else { return }
                        if exitChoice == 1 { self.save();self.requestApplicationExit() }
                        else { self.choosePlayer() }
                    }
                } else { self.choosePlayer() }
            }
        } catch { present(error) }
    }
    #if canImport(AppKit) && !OUTNUMBERED_PORTABLE
    @objc
    #endif
    func referenceEnding() {
        session = NativeSession(profileID: UUID(),seed: 6908,lifetimePoints: 52_595)
        var checkpoint = DecoderGenerator(seed: 6908)
        session.decoder = checkpoint.makePuzzle(difficulty: 1)
        session.score = 2650; session.energy = 17; session.clock.applyMinutePenalty(52)
        referenceMode = true
        startEnding(room: session.decoder.hideoutRoom)
    }
}
