import Foundation

extension NativeGameView {
    var selectedProfile: NativeProfile? {
        profileStore.document.profiles.first { $0.id == profileStore.document.selectedProfileID }
    }
    #if canImport(AppKit) && !OUTNUMBERED_PORTABLE
    @objc
    #endif
    func showPlayerMenu() {
        guard decoderPanel == nil,confirmation == nil,settingsEditor == nil,originalNotice == nil,optionsMenu == nil else { return }
        if screen == .help { closeHelp() }
        if screen == .scores { closeScores() }
        guard session?.activeZap == nil, session?.activeFountain == nil, screen != .ending else { return }
        keyboard.flush();save();
        if screen == .practice || (screen == .file && fileReturn == .practice) { session = nil }
        held.removeAll(); stopSound()
        if screen != .menu && screen != .practice { menuReturn = screen }
        practice = nil; screen = .menu; menuSelection = 0; needsDisplay = true
        if selectedProfile == nil { choosePlayer() }
    }
    #if canImport(AppKit) && !OUTNUMBERED_PORTABLE
    @objc
    #endif
    func choosePlayer() {
        guard decoderPanel == nil,confirmation == nil,settingsEditor == nil,originalNotice == nil,optionsMenu == nil else { return }
        if isTransitioning || screen == .ending { return }
        if screen == .help { closeHelp() }
        if screen == .scores { closeScores() }
        keyboard.flush();save();
        if screen == .practice || (screen == .file && fileReturn == .practice) { session = nil }
        held.removeAll();stopSound()
        signIn = NativeMemberSignIn(memberCount: profileStore.document.profiles.count)
        screen = .signin;needsDisplay = true
    }
    func configure(practice: Bool,completion: @escaping (OriginalGameSettings?) -> Void) {
        guard decoderPanel == nil,settingsEditor == nil,confirmation == nil else { return }
        guard let profile = selectedProfile else { choosePlayer();return }
        let tier = VerifiedRank.allCases.firstIndex(of: VerifiedRank.forLifetimePoints(profile.lifetimePoints ?? 0))! >> 1
        let current = (practice ? profile.practiceSettings : profile.customGameSettings) ?? .defaults(tier: tier)
        beginSettingsEditor(current,practice: practice,profileID: profile.id,completion: completion)
    }
    #if canImport(AppKit) && !OUTNUMBERED_PORTABLE
    @objc
    #endif
    func playGame() { playGame(custom: false) }
    #if canImport(AppKit) && !OUTNUMBERED_PORTABLE
    @objc
    #endif
    func playCustomGame() { playGame(custom: true) }
    func playGame(custom: Bool,discardSaved: Bool = false) {
        guard decoderPanel == nil,confirmation == nil,settingsEditor == nil,originalNotice == nil,optionsMenu == nil else { return }
        save()
        guard let profile = selectedProfile else { choosePlayer(); return }
        do {
            let saved = try saves.load(profile.id)
            if !discardSaved,let saved,saved.outcome == "active" {
                showConfirmation(.continueSaved) { [weak self] choice in
                    guard let self else { return }
                    if choice == 1 { self.practice = nil;self.begin() }
                    else if choice == 0 { self.playGame(custom: custom,discardSaved: true) }
                }
                return
            }
            if custom {
                configure(practice: false) { [weak self] result in
                    guard let self,let result else { return }
                    do {
                        try self.profileStore.saveSettings(profileID: profile.id,settings: result,practice: false)
                        self.startNewGame(profile: profile,saved: saved,settings: result)
                    } catch { self.present(error) }
                }
            } else { startNewGame(profile: profile,saved: saved,settings: nil) }
        } catch { present(error) }
    }
    func startNewGame(profile: NativeProfile,saved: NativeSession?,settings: OriginalGameSettings?) {
        var previous = session?.profileID == profile.id && !referenceMode ? session?.generator : saved?.generator
        let seed = previous != nil ? previous!.nextRandomValue() : Int.random(in: 0...65535)
        let messages = session?.profileID == profile.id && !referenceMode ? session?.newUserMessages : menuMessages
        let roomCamera = session?.profileID == profile.id && !referenceMode ? session?.roomCamera : saved?.roomCamera
        session = NativeSession(profileID: profile.id,seed: UInt32(seed),lifetimePoints: profile.lifetimePoints ?? 0,settings: settings,previousGenerator: previous,previousRoomCamera: roomCamera)
        session.newUserMessages = messages ?? menuMessages
        session.calculatorEnabled = menuCalculatorEnabled
        referenceMode = false;practice = nil;screen = .world;held.removeAll();status = ""
        save();needsDisplay = true
    }
    #if canImport(AppKit) && !OUTNUMBERED_PORTABLE
    @objc
    #endif
    func startPractice() {
        guard decoderPanel == nil,confirmation == nil,settingsEditor == nil,originalNotice == nil,optionsMenu == nil else { return }
        if screen == .help { closeHelp() }
        if screen == .scores { closeScores() }
        save();preparePracticeMessages()
        guard let profile = selectedProfile else { choosePlayer();return }
        configure(practice: true) { [weak self] result in
            guard let self,let result else { return }
            do {
                try self.profileStore.saveSettings(profileID: profile.id,settings: result,practice: true)
                try self.launchPractice(settings: result,seed: UInt32.random(in: 0...65535))
            } catch { self.present(error) }
        }
    }
    func launchPractice(settings: OriginalGameSettings,seed: UInt32) throws {
        // Practice has its own stream and counters. The suspended adventure
        // and its save, score, clock, decoder and energy are never repurposed.
        practice = try NativePractice(settings: settings,seed: seed)
        practiceIRQ = 0; preparePracticeMessages()
        held.removeAll(); screen = .practice; needsDisplay = true
    }
    func practiceKey(_ event: GameInputEvent) {
        guard practice != nil else { return }
        do {
            if event.keyCode == 53 { showPlayerMenu(); return }
            if event.keyCode == 36 {
                if practice!.presentation == .continuePrompt { try practice!.nextSet() }
                else if let accepted = practice!.submit() { effect(accepted ? 6 : 8) }
            } else if event.keyCode == 51 || event.keyCode == 117 { practice!.drill.erase() }
            else if let characters = event.charactersIgnoringModifiers, characters.count == 1, let digit = Int(characters) { practice!.drill.digit(digit) }
        } catch { present(error) }
        needsDisplay = true
    }
    func setMusicEnabled(_ enabled: Bool) {
        if !enabled { stopSound() }
        musicEnabled = enabled; needsDisplay = true
    }
    func setSoundEnabled(_ enabled: Bool) {
        if !enabled { stopSound() }
        soundEnabled = enabled; needsDisplay = true
    }
    #if canImport(AppKit) && !OUTNUMBERED_PORTABLE
    @objc
    #endif
    func toggleSound() { setSoundEnabled(!soundEnabled) }
    static let playerMenuItems = ["Regular Game","Customized Game","Customized Drill for Skill"]
    func activatePlayerMenu(_ index: Int) {
        switch index {
        case 0: playGame()
        case 1: playCustomGame()
        case 2: startPractice()
        default: choosePlayer()
        }
        needsDisplay = true
    }
    func drawPlayerMenu() throws {
        let font = try content.font("MOCKET.DAT.1393")
        canvas.fill(0,0,320,200,9)
        try sprite(57,x: 0,y: 0,transparent: false)
        canvas.fill(0,12,320,188,9)
        canvas.fill(0,189,320,11,1)
        canvas.text("\u{80}\u{81} to Cycle",font: font,x: 0,y: 190,color: 15)
        let enter = "\u{85} to Select"
        canvas.text(enter,font: font,x: 319-font.width(of: enter),y: 190,color: 15)
        let title = "What do you want to play?",left = 46,top = 57
        let width = max(123,max(Self.playerMenuItems.map { font.width(of: $0)+14 }.max()!,font.width(of: title)+36))
        let right = left+width,bottom = top+3*12+39
        canvas.originalHelpPanel(left: left,top: top,right: right,bottom: bottom,title: title,footer: "\u{84} to Go Back",font: font,bottomSeparator: 18)
        for (i,label) in Self.playerMenuItems.enumerated() { canvas.text(label,font: font,x: left+6,y: top+19+i*12,color: 1) }
        canvas.xorMemberSelection(left+4,top+18+menuSelection*12,width-9,13)
    }
    func drawPractice() throws {
        guard let practice else { return }
        canvas.draw(try content.bitmap("FASTLOAD.GRA.057"),x: 0,y: 0)
        if practice.presentation == .questions { try drawDrill(practice.drill) }
        else { canvas.draw(try content.bitmap("DMOCKET.GRA.157c"),x: 0,y: 15) }
        // Practice replaces the adventure footer with its original counter art.
        canvas.fill(4,162,205,36,11); canvas.fill(5,163,203,34,1)
        canvas.draw(try content.bitmap("DRILL.GRA.013"),x: 208,y: 162)
        if practice.elapsedSeconds > 0 {
            let minutes = practice.elapsedSeconds/60
            for (place,digit) in String(minutes).reversed().enumerated() where minutes > 0 {
                try sprite(64+Int(String(digit))!,x: (70-place*2)*4,y: 166,transparent: false)
            }
            canvas.text(":",font: try content.font("MOCKET.DAT.1396"),x: 290,y: 164,color: 14)
            for (digit,x) in [(practice.elapsedSeconds%60/10,292),(practice.elapsedSeconds%10,300)] {
                try sprite(64+digit,x: x,y: 166,transparent: false)
            }
        }
        for (value,y) in [(practice.attempts,177),(practice.correctAnswers,188)] {
            for (place,digit) in String(value).reversed().enumerated() {
                try sprite(64+Int(String(digit))!,x: (75-place*2)*4,y: y,transparent: false)
            }
        }
        if practice.presentation == .introduction {
            let index = 10+(practice.presentationTicks/20)%2
            canvas.draw(try content.bitmap(String(format: "DRILL.GRA.%03d",index)),x: 76,y: 28,transparent: true)
        } else if practice.presentation != .questions {
            canvas.draw(try content.bitmap("DRILL.GRA.012"),x: 76,y: 28,transparent: true)
        }
        if [.response,.waitingForSound,.continuePrompt].contains(practice.presentation) {
            let base = canvas.pixels
            let commands = OriginalPracticePresentation.scripts[practice.resultVariant]
            var time = 0
            func restore(_ command: OriginalEndingData.Command) {
                canvas.restoreEndingRect(base,x: command.x*4,y: command.y,right: command.right*4+3,bottom: command.bottom)
            }
            for command in commands {
                guard time <= practice.presentationTicks else { break }
                if command.resource == -1 { restore(command) }
                else if command.resource >= 0 {
                    if command.restoreCommand > 0 { restore(commands[command.restoreCommand-1]) }
                    try sprite(command.resource,x: command.x*4,y: command.y,transparent: command.flags & 64 != 0,flipped: command.flags & 32 != 0)
                }
                time += command.waitFrames*OriginalPracticePresentation.frameTicks
            }
        }
        if practice.presentation == .continuePrompt {
            canvas.text("\u{85}",font: try content.font("MOCKET.DAT.1393"),x: 105,y: 105,color: 15)
            canvas.text("to Continue",font: try content.font("MOCKET.DAT.1396"),x: 164,y: 105,color: 15)
        }
    }
}
