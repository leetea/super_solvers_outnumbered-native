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
        guard automaticallyPresentMessages,!referenceMode,decoderPanel == nil,originalNotice == nil,
              OriginalNewUserText.messages.indices.contains(id),welcome || tutorialState.canShow(id) else { return }
        let pause = modalDepth == 0 && !tutorialPracticeContext && session != nil && [.world,.question,.drill,.decoder].contains(screen)
        if pause { session.clock.pause() }
        held.removeAll();sound?.stop();lastSoundIndex = nil
        let practiceContext = tutorialPracticeContext || screen == .practice
        let finish: () -> Void = { [weak self] in
            guard let self else { return }
            if !welcome { var state = self.tutorialState;state.acknowledge(id);self.tutorialState = state }
            if pause { self.session.clock.resume() }
            if !practiceContext { self.save() }
            self.needsDisplay = true
        }
        if let messagePresenter {
            modalDepth += 1
            messagePresenter(id,OriginalNewUserText.accessible(OriginalNewUserText.messages[id]))
            modalDepth -= 1;finish()
        } else {
            showOriginalNotice(OriginalNotice(text: OriginalNewUserText.messages[id],title: "New User Message")) { _ in finish() }
        }
    }
    func processTutorials() {
        guard automaticallyPresentMessages,!referenceMode,modalDepth == 0,originalNotice == nil else { return }
        var state = tutorialState
        if let id = state.takeExpired(now: tutorialIRQ) { tutorialState = state; showNewUserMessage(id) }
        else { tutorialState = state }
        guard modalDepth == 0,screen == .world,session != nil,session.outcome == "active",session.activeZap == nil,session.activeFountain == nil else { return }
        let minuteChanged = tutorialLastMinute != session.clock.elapsedMinutes
        let energyChanged = tutorialLastEnergy != session.energy
        tutorialLastMinute = session.clock.elapsedMinutes; tutorialLastEnergy = session.energy
        if energyChanged && session.energy < 6 { queueTutorial(11) }
        if minuteChanged && session.clock.elapsedMinutes >= 60 && (session.decoder.capturedCount == 0 || session.completed.isEmpty) { queueTutorial(12) }
        if minuteChanged && session.clock.elapsedMinutes == 2 { showNewUserMessage(0) }
        guard modalDepth == 0 else { return }
        if let id = tutorialState.nextQueued(actorsSettled: playerMotion.settled) { showNewUserMessage(id) }
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
        guard decoderPanel == nil,screen != .practice,confirmation == nil,originalNotice == nil,settingsEditor == nil else { return }
        showConfirmation(.messages(tutorialState.enabled)) { [weak self] choice in
            if choice >= 0 { self?.setNewUserMessages(choice == 1) }
        }
    }
}
