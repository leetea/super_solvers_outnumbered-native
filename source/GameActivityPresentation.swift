import Cocoa

extension NativeGameView {
    var isActivityPresenting: Bool { session?.activityPresentation != nil }
    func startActivityPresentation(_ challenge: OriginalChallenge) throws {
        session.activityPresentation = nil
        guard NativeActivityPlan.hotspots.contains(challenge.hotspot) else { return }
        session.activityPresentation = NativeActivityPresentation(challenge,randomState: session.generator.randomState)
        //Source8516 requests34 before preparing its random numeric rows.
        if challenge.hotspot == 7 { session.activityPresentation?.appliedSoundCount = 1 }
        activityPlanCache = nil
        lastZapPulse = ProcessInfo.processInfo.systemUptime;zapFraction = 0
        try advanceActivityPresentation(irqTicks: 0)
    }
    func advanceActivityPresentation(irqTicks: Int) throws {
        guard let challenge = session.activeChallenge,var presentation = session.activityPresentation else { return }
        let plan = try activityPlan(challenge)
        let previousRandomCount = presentation.appliedRandomCount ?? 0
        let ticks = min(max(0,irqTicks),plan.duration-presentation.elapsedIRQTicks)
        session.clock.pollAfterIRQTicks(UInt64(ticks),processMinute: false)
        let cues = presentation.advance(irqTicks: ticks,plan: plan)
        if (presentation.appliedRandomCount ?? 0) != previousRandomCount,
           let checkpoint = plan.randomSteps.last(where: { $0.at <= presentation.elapsedIRQTicks }) {
            session.generator.restoreRandomState(checkpoint.state)
        }
        for cue in cues {
            if let index = cue.index { effect(index) }
            else { sound?.stop();lastSoundIndex = nil }
        }
        session.activityPresentation = presentation
        if presentation.elapsedIRQTicks == plan.duration {
            session.activityPresentation = nil;keyboard.flush();save()
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
    func activityPlan(_ challenge: OriginalChallenge) throws -> NativeActivityPlan {
        let state = session.activityPresentation?.initialRandomState
        let key = "\(challenge.id)/\(challenge.seed)/\(challenge.variant)/\(challenge.hotspot)/\(String(describing: state))"
        if let cache = activityPlanCache, cache.key == key { return cache.plan }
        let plan = try NativeActivityPlan(challenge,randomState: state)
        activityPlanCache = (key,plan);return plan
    }
    func activityPresentationFrame(_ challenge: OriginalChallenge) throws -> NativeActivityPlan.Frame? {
        guard let presentation = session.activityPresentation else { return nil }
        return try activityPlan(challenge).frame(at: presentation.elapsedIRQTicks)
    }
}
