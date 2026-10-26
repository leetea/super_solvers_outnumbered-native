import Cocoa

extension NativeGameView {
    func startEnding(room: Int,reason: NativeEnding.Reason? = nil) {
        guard session.activeEnding == nil, (0..<5).contains(room) else { return }
        let reason = reason ?? (session.decoder.isWinningChoice(room: room) ? .hideout : .wrongHideout)
        let playerLine = reason == .midnight ? 0 : (session.generator.nextRandomValue()%101 < 50 ? 0 : 1)
        let masterLine = reason == .midnight ? 0 : (session.generator.nextRandomValue()%101 < 50 ? 0 : 1)
        session.activeEnding = NativeEnding(reason: reason,room: room,tier: session.decoder.difficulty,initialEnergy: session.energy,initialMinutes: session.clock.elapsedMinutes,initialScore: session.score,initialLifetime: session.lifetimePoints,playerDialogue: playerLine,masterDialogue: masterLine)
        if session.runID == nil { session.runID = UUID() }
        session.activeChallenge = nil; session.activeDrill = nil; session.activeZap = nil
        session.activeFountain = nil; session.liveWire?.clear(); clearTelly()
        while session.clock.pauseDepth > 0 { session.clock.resume() }
        session.clock.pause(); held.removeAll(); screen = .ending; status = ""
        if reason == .midnight { effect(49) } else { effect(3) }
        save(); needsDisplay = true
    }
    func advanceEnding(_ ticks: Int = OriginalWorld.frameIRQTicks) throws {
        guard var ending = session.activeEnding else { return }
        let timeline = EndingTimeline(ending,data: endingData), old = ending.elapsedTicks
        ending.elapsedTicks = min(timeline.duration,old+max(0,ticks))
        session.activeEnding = ending
        for cue in timeline.sounds(after: old,through: ending.elapsedTicks) {
            if cue.interrupt { sound?.stop(); lastSoundIndex = nil }
            effect(cue.index)
        }
        let totals = timeline.totals(at: ending.elapsedTicks)
        session.energy = totals.energy; session.score = totals.score
        session.clock.applyMinutePenalty(max(0,totals.minutes-session.clock.elapsedMinutes))
        if ending.elapsedTicks == timeline.duration {
            session.outcome = ending.won ? "won" : "lost"; screen = .results
            try commitEndingResult()
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
        session = NativeSession(profileID: session.profileID,seed: seed,lifetimePoints: session.lifetimePoints,previousGenerator: stream)
        if let messages { session.newUserMessages = messages }
        screen = .world; held.removeAll(); status = ""; save(); needsDisplay = true
    }
    func continueAfterResults() {
        do {
            try commitEndingResult()
            let alert = NSAlert(); alert.messageText = referenceMode ? "Checkpoint complete" : "Your score and rank have been saved."
            alert.informativeText = referenceMode ? "Play a new isolated game?" : "Do you or someone else want to play again?"
            alert.addButton(withTitle: "Yes"); alert.addButton(withTitle: "No")
            if alert.runModal() == .alertFirstButtonReturn { try beginNextGame() }
            else { screen = .title; needsDisplay = true }
        } catch { present(error) }
    }
    @objc func referenceEnding() {
        session = NativeSession(profileID: UUID(),seed: 6908,lifetimePoints: 52_595)
        var checkpoint = DecoderGenerator(seed: 6908)
        session.decoder = checkpoint.makePuzzle(difficulty: 1)
        session.score = 2650; session.energy = 17; session.clock.applyMinutePenalty(52)
        referenceMode = true
        startEnding(room: session.decoder.hideoutRoom)
    }
}
