import Cocoa

// Native macOS controls expose the original settings record and validation.
// These controls deliberately do not claim pixel parity with the DOS dialogs.
final class NativeSettingsPanel: NSObject {
    let original: OriginalGameSettings
    let tier: Int
    let practice: Bool
    let view = NSView(frame: NSRect(x: 0,y: 0,width: 440,height: 350))
    var operations: [NSButton] = [], numbers: [NSButton] = [], formats: [NSButton] = []
    let selection = NSPopUpButton()
    init(settings: OriginalGameSettings,tier: Int,practice: Bool) {
        original = settings; self.tier = tier; self.practice = practice
        super.init()
        func label(_ text: String,_ x: CGFloat,_ y: CGFloat) {
            let field = NSTextField(labelWithString: text); field.frame = NSRect(x: x,y: y,width: 420-x,height: 22); view.addSubview(field)
        }
        func check(_ title: String,_ x: CGFloat,_ y: CGFloat,_ width: CGFloat) -> NSButton {
            let button = NSButton(checkboxWithTitle: title,target: nil,action: nil)
            button.frame = NSRect(x: x,y: y,width: width,height: 24); view.addSubview(button); return button
        }
        label("Type of Problems",0,325)
        for (i,title) in ["Addition","Multiplication","Subtraction","Division"].enumerated() {
            operations.append(check(title,CGFloat(i%2)*220,CGFloat(298-i/2*26),210))
        }
        label("Numbers Used in Drill Problems",0,236)
        for i in 0...12 { numbers.append(check(String(i),CGFloat(i%7)*62,CGFloat(208-i/7*26),60)) }
        label("Format of Drill Problems",0,146)
        for (i,title) in ["3 + 5 = ?","? + 5 = 8","3 + ? = 8"].enumerated() {
            formats.append(check(title,CGFloat(i)*145,118,140))
        }
        label(practice ? "Number of Problems in Each Set" : "Select Settings for Level",0,80)
        selection.frame = NSRect(x: 0,y: 46,width: 200,height: 28)
        selection.addItems(withTitles: practice ? ["5","10","15","20"] : ["1","2","3","4 (selects all)"])
        view.addSubview(selection)
        let undo = NSButton(title: "Undo",target: self,action: #selector(undoChanges))
        undo.frame = NSRect(x: 220,y: 0,width: 80,height: 28); view.addSubview(undo)
        let defaults = NSButton(title: "Standard Settings",target: self,action: #selector(standardSettings))
        defaults.frame = NSRect(x: 302,y: 0,width: 138,height: 28); view.addSubview(defaults)
        display(settings)
    }
    func display(_ settings: OriginalGameSettings) {
        for i in operations.indices { operations[i].state = settings.enabled(i,mask: 16) ? .on : .off }
        for i in numbers.indices { numbers[i].state = settings.enabled(i,mask: 4) ? .on : .off }
        for i in formats.indices { formats[i].state = settings.enabled(i,mask: 8) ? .on : .off }
        selection.selectItem(at: settings.selection)
    }
    var settings: OriginalGameSettings {
        var value = original
        for i in operations.indices { value.set(i,mask: 16,enabled: operations[i].state == .on) }
        for i in numbers.indices { value.set(i,mask: 4,enabled: numbers[i].state == .on) }
        for i in formats.indices { value.set(i,mask: 8,enabled: formats[i].state == .on) }
        value.selection = selection.indexOfSelectedItem
        return value
    }
    @objc func undoChanges() { display(original) }
    @objc func standardSettings() { display(.defaults(tier: tier)) }
    func run() -> OriginalGameSettings? {
        let alert = NSAlert(); alert.messageText = practice ? "Customize Drill for Skill Settings" : "Customize Game Settings"
        alert.accessoryView = view; alert.addButton(withTitle: "OK"); alert.addButton(withTitle: "Cancel")
        while alert.runModal() == .alertFirstButtonReturn {
            let result = settings
            if let error = result.validationMessage {
                let warning = NSAlert(); warning.messageText = error; warning.runModal()
            } else { return result }
        }
        return nil
    }
}

extension NativeGameView {
    var selectedProfile: NativeProfile? {
        profileStore.document.profiles.first { $0.id == profileStore.document.selectedProfileID }
    }
    @objc func showPlayerMenu() {
        if screen == .help { closeHelp() }
        if screen == .scores { closeScores() }
        guard session?.activeZap == nil, session?.activeFountain == nil, screen != .ending else { return }
        save(); held.removeAll(); sound?.stop(); lastSoundIndex = nil
        if screen != .menu && screen != .practice { menuReturn = screen }
        practice = nil; screen = .menu; menuSelection = 0; needsDisplay = true
        if selectedProfile == nil { choosePlayer() }
    }
    @objc func choosePlayer() {
        if isTransitioning || screen == .ending { return }
        if screen == .help { closeHelp() }
        if screen == .scores { closeScores() }
        save();held.removeAll();sound?.stop();lastSoundIndex = nil
        signIn = NativeMemberSignIn(memberCount: profileStore.document.profiles.count)
        screen = .signin;needsDisplay = true
    }
    func configure(practice: Bool) -> OriginalGameSettings? {
        guard let profile = selectedProfile else { choosePlayer(); return nil }
        let tier = VerifiedRank.allCases.firstIndex(of: VerifiedRank.forLifetimePoints(profile.lifetimePoints ?? 0))! >> 1
        let current = (practice ? profile.practiceSettings : profile.customGameSettings) ?? .defaults(tier: tier)
        let previousContext = tutorialPracticeContext; tutorialPracticeContext = practice
        let (tutorialTimer,monitor) = settingsTutorialTimer(practice: practice)
        modalDepth += 1; defer {
            tutorialTimer.invalidate(); if let monitor { NSEvent.removeMonitor(monitor) }
            tutorialPracticeContext = previousContext; modalDepth -= 1
        }
        return NativeSettingsPanel(settings: current,tier: tier,practice: practice).run()
    }
    @objc func playGame() { playGame(custom: false) }
    @objc func playCustomGame() { playGame(custom: true) }
    func playGame(custom: Bool) {
        save()
        guard let profile = selectedProfile else { choosePlayer(); return }
        do {
            let saved = try saves.load(profile.id)
            if let saved, saved.outcome == "active" {
                modalDepth += 1
                let alert = NSAlert(); alert.messageText = "You have an unfinished game."
                alert.addButton(withTitle: "Continue Game"); alert.addButton(withTitle: "New Game"); alert.addButton(withTitle: "Cancel")
                let choice = alert.runModal(); modalDepth -= 1
                if choice == .alertFirstButtonReturn { practice = nil; begin(); return }
                if choice != .alertSecondButtonReturn { return }
            }
            var settings: OriginalGameSettings?
            if custom {
                guard let result = configure(practice: false) else { return }; settings = result
                try profileStore.saveSettings(profileID: profile.id,settings: result,practice: false)
            }
            var previous = session?.profileID == profile.id && !referenceMode ? session?.generator : saved?.generator
            let seed: Int
            if previous != nil { seed = previous!.nextRandomValue() }
            else { seed = Int.random(in: 0...65535) }
            let messages = session?.profileID == profile.id && !referenceMode ? session?.newUserMessages : menuMessages
            let roomCamera = session?.profileID == profile.id && !referenceMode ? session?.roomCamera : saved?.roomCamera
            session = NativeSession(profileID: profile.id,seed: UInt32(seed),lifetimePoints: profile.lifetimePoints ?? 0,settings: settings,previousGenerator: previous,previousRoomCamera: roomCamera)
            session.newUserMessages = messages ?? menuMessages
            referenceMode = false; practice = nil; screen = .world; held.removeAll(); status = ""
            save(); needsDisplay = true
        } catch { present(error) }
    }
    @objc func startPractice() {
        if screen == .help { closeHelp() }
        if screen == .scores { closeScores() }
        save()
        preparePracticeMessages()
        guard let profile = selectedProfile, let settings = configure(practice: true) else { return }
        do {
            try profileStore.saveSettings(profileID: profile.id,settings: settings,practice: true)
            try launchPractice(settings: settings,seed: UInt32.random(in: 0...65535))
        } catch { present(error) }
    }
    func launchPractice(settings: OriginalGameSettings,seed: UInt32) throws {
        // Practice has its own stream and counters. The suspended adventure
        // and its save, score, clock, decoder and energy are never repurposed.
        practice = try NativePractice(settings: settings,seed: seed)
        practiceIRQ = 0; preparePracticeMessages()
        held.removeAll(); screen = .practice; needsDisplay = true
    }
    func practiceKey(_ event: NSEvent) {
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
        if !enabled { sound?.stop(); lastSoundIndex = nil }
        musicEnabled = enabled; needsDisplay = true
    }
    func setSoundEnabled(_ enabled: Bool) {
        if !enabled { sound?.stop(); lastSoundIndex = nil }
        soundEnabled = enabled; needsDisplay = true
    }
    @objc func toggleSound() { setSoundEnabled(!soundEnabled) }
    @objc func showOptions() {
        guard session?.activeZap == nil, session?.activeFountain == nil, screen != .ending else { return }
        modalDepth += 1; defer { modalDepth -= 1 }
        let alert = NSAlert(); alert.messageText = "Options"
        let container = NSView(frame: NSRect(x: 0,y: 0,width: 260,height: 128))
        let messages = NSButton(title: "New User Messages…",target: self,action: #selector(showNewUserOptions))
        messages.frame = NSRect(x: 0,y: 100,width: 260,height: 26); messages.isHidden = screen == .practice; container.addSubview(messages)
        let music = NSButton(checkboxWithTitle: "Music",target: nil,action: nil)
        music.frame = NSRect(x: 0,y: 68,width: 260,height: 26); music.state = musicEnabled ? .on : .off
        container.addSubview(music)
        let sound = NSButton(checkboxWithTitle: "Sound",target: nil,action: nil)
        sound.frame = NSRect(x: 0,y: 34,width: 260,height: 26); sound.state = soundEnabled ? .on : .off
        let calculator = NSButton(checkboxWithTitle: "Use Calculator",target: nil,action: nil)
        calculator.frame = NSRect(x: 0,y: 0,width: 260,height: 26)
        calculator.state = session?.calculatorEnabled == false ? .off : .on; calculator.isEnabled = session != nil; calculator.isHidden = screen == .practice
        container.addSubview(sound); container.addSubview(calculator); alert.accessoryView = container
        alert.addButton(withTitle: "OK"); alert.addButton(withTitle: "Cancel")
        if alert.runModal() == .alertFirstButtonReturn {
            setMusicEnabled(music.state == .on)
            setSoundEnabled(sound.state == .on)
            if session != nil && usesCalculator != (calculator.state == .on) {
                let sender = NSMenuItem(); toggleCalculator(sender)
            }
        }
    }
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
        canvas.fill(4,162,205,36,11); canvas.fill(5,163,203,34,0)
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
