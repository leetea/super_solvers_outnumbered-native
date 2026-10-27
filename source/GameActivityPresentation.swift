import Cocoa

extension NativeGameView {
    var isActivityPresenting: Bool { session?.activityPresentation != nil }
    func startActivityPresentation(_ challenge: OriginalChallenge) throws {
        session.activityPresentation = nil
        guard NativeActivityPlan.hotspots.contains(challenge.hotspot) else { return }
        session.activityPresentation = NativeActivityPresentation(challenge)
        lastZapPulse = ProcessInfo.processInfo.systemUptime;zapFraction = 0
        try advanceActivityPresentation(irqTicks: 0)
    }
    func advanceActivityPresentation(irqTicks: Int) throws {
        guard let challenge = session.activeChallenge,var presentation = session.activityPresentation else { return }
        let plan = try NativeActivityPlan(challenge)
        let ticks = min(max(0,irqTicks),plan.duration-presentation.elapsedIRQTicks)
        session.clock.pollAfterIRQTicks(UInt64(ticks),processMinute: false)
        for cue in presentation.advance(irqTicks: ticks,plan: plan) {
            if let index = cue.index { effect(index) }
            else { sound?.stop();lastSoundIndex = nil }
        }
        session.activityPresentation = presentation
        if presentation.elapsedIRQTicks == plan.duration {
            session.activityPresentation = nil;save()
            showNewUserMessage(usesCalculator ? 10 : 9)
        }
        needsDisplay = true
    }
    func pulseActivityPresentation() {
        let now = ProcessInfo.processInfo.systemUptime
        defer { lastZapPulse = now }
        guard modalDepth == 0,screen == .question,isActivityPresenting else { return }
        let ticks = max(0,now-lastZapPulse)*VerifiedClock.pitInputHz/VerifiedClock.pitDivisor+zapFraction
        zapFraction = ticks-ticks.rounded(.down)
        do { try advanceActivityPresentation(irqTicks: Int(min(ticks.rounded(.down),10_000))) }
        catch { present(error) }
    }
    func activityPresentationFrame(_ challenge: OriginalChallenge) throws -> NativeActivityPlan.Frame? {
        guard let presentation = session.activityPresentation else { return nil }
        return try NativeActivityPlan(challenge).frame(at: presentation.elapsedIRQTicks)
    }
}
