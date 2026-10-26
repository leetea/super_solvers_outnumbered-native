import Cocoa

extension NativeGameView {
    var tutorialState: NativeNewUserMessages {
        get {
            if tutorialPracticeContext || screen == .practice { return practiceMessages }
            return session?.newUserMessages ?? menuMessages
        }
        set {
            if tutorialPracticeContext || screen == .practice { practiceMessages = newValue }
            else if session != nil { session.newUserMessages = newValue }
            else { menuMessages = newValue }
        }
    }
    var tutorialIRQ: UInt64 { screen == .practice ? practiceIRQ : (session?.clock.counterTicks ?? 0) }
    func queueTutorial(_ id: Int) {
        guard automaticallyPresentMessages,!referenceMode else { return }
        var state = tutorialState; state.queue(id); tutorialState = state
    }
    func scheduleTutorial(_ id: Int,ticks: UInt64) {
        guard automaticallyPresentMessages,!referenceMode else { return }
        var state = tutorialState; state.schedule(id,after: ticks,now: tutorialIRQ); tutorialState = state
    }
    func cancelTutorialTimer() {
        guard automaticallyPresentMessages,!referenceMode else { return }
        var state = tutorialState; state.cancelTimed(); tutorialState = state
    }
    func showNewUserMessage(_ id: Int,welcome: Bool = false) {
        guard automaticallyPresentMessages,!referenceMode,OriginalNewUserText.messages.indices.contains(id),
              welcome || tutorialState.canShow(id) else { return }
        modalDepth += 1
        let pause = modalDepth == 1 && !tutorialPracticeContext && session != nil && [.world,.question,.drill,.decoder].contains(screen)
        if pause { session.clock.pause() }
        held.removeAll(); sound?.stop(); lastSoundIndex = nil
        let text = OriginalNewUserText.accessible(OriginalNewUserText.messages[id])
        if let messagePresenter { messagePresenter(id,text) }
        else {
            let alert = NSAlert(); alert.messageText = "New User Message"; alert.informativeText = text
            alert.addButton(withTitle: "Continue"); alert.runModal()
        }
        if !welcome { var state = tutorialState; state.acknowledge(id); tutorialState = state }
        if pause { session.clock.resume() }
        modalDepth -= 1
        if !tutorialPracticeContext && screen != .practice { save() }
        needsDisplay = true
    }
    func processTutorials() {
        guard automaticallyPresentMessages,!referenceMode,modalDepth == 0 else { return }
        var state = tutorialState
        if let id = state.takeExpired(now: tutorialIRQ) { tutorialState = state; showNewUserMessage(id) }
        else { tutorialState = state }
        guard screen == .world,session != nil,session.outcome == "active",session.activeZap == nil,session.activeFountain == nil else { return }
        let minuteChanged = tutorialLastMinute != session.clock.elapsedMinutes
        let energyChanged = tutorialLastEnergy != session.energy
        tutorialLastMinute = session.clock.elapsedMinutes; tutorialLastEnergy = session.energy
        if energyChanged && session.energy < 6 { queueTutorial(11) }
        if minuteChanged && session.clock.elapsedMinutes >= 60 && (session.decoder.capturedCount == 0 || session.completed.isEmpty) { queueTutorial(12) }
        if minuteChanged && session.clock.elapsedMinutes == 2 { showNewUserMessage(0) }
        if let id = tutorialState.nextQueued(actorsSettled: jumpStep == nil) { showNewUserMessage(id) }
    }
    func preparePracticeMessages() {
        let enabled = session?.profileID == selectedProfile?.id ? (session?.newUserMessages?.enabled ?? menuMessages.enabled) : menuMessages.enabled
        if practiceMessagesProfileID != selectedProfile?.id { practiceMessages = NativeNewUserMessages(enabled: enabled); practiceMessagesProfileID = selectedProfile?.id }
        else { practiceMessages.enabled = enabled }
    }
    func setNewUserMessages(_ enabled: Bool) {
        var state = tutorialState; state.chooseEnabled(enabled); tutorialState = state; save()
    }
    @objc func showNewUserOptions() {
        guard screen != .practice else { return }
        modalDepth += 1; defer { modalDepth -= 1 }
        let alert = NSAlert(); alert.messageText = "New User Messages"
        alert.informativeText = "The New User Messages help you learn how to play the game.\n\nDo you want to see the New User Messages as you play the game?"
        alert.addButton(withTitle: "Yes"); alert.addButton(withTitle: "No"); alert.addButton(withTitle: "Cancel")
        let result = alert.runModal()
        if result == .alertFirstButtonReturn { setNewUserMessages(true) }
        else if result == .alertSecondButtonReturn { setNewUserMessages(false) }
    }
    func settingsTutorialTimer(practice: Bool) -> (Timer,Any?) {
        let id = practice ? 16 : 15
        let timer = Timer(timeInterval: 1200*VerifiedClock.pitDivisor/VerifiedClock.pitInputHz,repeats: false) { [weak self] _ in self?.showNewUserMessage(id) }
        RunLoop.current.add(timer,forMode: .modalPanel)
        let monitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown,.leftMouseDown]) { [weak self] event in
            let wasWaiting = timer.isValid; timer.invalidate()
            if wasWaiting && self?.automaticallyPresentMessages == true { var state = self!.tutorialState; state.acknowledge(id); self!.tutorialState = state }
            return event
        }
        return (timer,monitor)
    }
}
