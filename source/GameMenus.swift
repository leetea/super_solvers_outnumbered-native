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
        save(); modalDepth += 1; defer { modalDepth -= 1; needsDisplay = true }
        let alert = NSAlert(); alert.messageText = "Start New Player"
        let field = NSTextField(frame: NSRect(x: 0,y: 0,width: 300,height: 26)); field.placeholderString = "New player name"
        field.setAccessibilityLabel("New player name")
        let picker = NSPopUpButton(frame: NSRect(x: 0,y: 44,width: 300,height: 28))
        let profiles = profileStore.document.profiles
        picker.addItems(withTitles: profiles.map(\.name)); picker.isEnabled = !profiles.isEmpty
        if let index = profiles.firstIndex(where: { $0.id == profileStore.document.selectedProfileID }) { picker.selectItem(at: index) }
        picker.setAccessibilityLabel("Saved players")
        let container = NSView(frame: NSRect(x: 0,y: 0,width: 300,height: 78)); container.addSubview(field); container.addSubview(picker)
        alert.accessoryView = container
        alert.addButton(withTitle: profiles.isEmpty ? "Create Player" : "Select Player")
        alert.addButton(withTitle: "Create New Player"); alert.addButton(withTitle: "Cancel")
        let response = alert.runModal()
        do {
            if response == .alertSecondButtonReturn || (response == .alertFirstButtonReturn && profiles.isEmpty) {
                _ = try profileStore.create(name: field.stringValue)
            } else if response == .alertFirstButtonReturn && profiles.indices.contains(picker.indexOfSelectedItem) {
                try profileStore.select(profiles[picker.indexOfSelectedItem].id)
            } else { return }
            session = nil; practice = nil; referenceMode = false; screen = .menu
            menuMessages = NativeNewUserMessages(enabled: (selectedProfile?.lifetimePoints ?? 0) < 5000)
            if menuMessages.enabled { showNewUserMessage(17,welcome: true) }
            status = ""; held.removeAll()
        } catch { present(error) }
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
            session = NativeSession(profileID: profile.id,seed: UInt32(seed),lifetimePoints: profile.lifetimePoints ?? 0,settings: settings,previousGenerator: previous)
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
                if practice!.drill.phase == .finished { try practice!.nextSet() }
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
    static let playerMenuItems = ["Play Game","Customized Game","Customized Drill for Skill","Start New Player","Lifetime Scores","High Game Scores","Sound","Return"]
    func activatePlayerMenu(_ index: Int) {
        switch index {
        case 0: playGame()
        case 1: playCustomGame()
        case 2: startPractice()
        case 3: choosePlayer()
        case 4: showLifetimeScores()
        case 5: showHighGameScores()
        case 6: toggleSound()
        default:
            if session != nil && menuReturn != .title && menuReturn != .practice { screen = menuReturn }
            else { screen = .title }
        }
        needsDisplay = true
    }
    func drawPlayerMenu() throws {
        canvas.fill(0,0,320,200,1); canvas.fill(22,12,276,176,15); canvas.border(24,14,272,172,0)
        let font = try content.font("MOCKET.DAT.1393"), small = try content.font("MOCKET.DAT.1396")
        canvas.text("OUTNUMBERED!",font: font,x: 92,y: 23,color: 1)
        let profile = selectedProfile
        let name = profile?.name ?? "Choose a player"
        canvas.clip = (38,40,178,14)
        canvas.text(name,font: small,x: 38,y: 40,color: 0)
        canvas.clip = nil
        if let profile { canvas.text(VerifiedRank.forLifetimePoints(profile.lifetimePoints ?? 0).rawValue,font: small,x: 220,y: 40,color: 0) }
        for (i,label) in Self.playerMenuItems.enumerated() {
            let y = 60+i*14, selected = i == menuSelection
            if selected { canvas.fill(34,y-2,252,13,1) }
            canvas.text(label == "Sound" ? "Sound: \(soundEnabled ? "On" : "Off")" : label,font: font,x: 42,y: y,color: selected ? 15 : 0)
        }
        canvas.text("Choose an item and press Enter.",font: small,x: 38,y: 172,color: 0)
    }
    func drawPractice() throws {
        guard let practice else { return }
        canvas.draw(try content.bitmap("FASTLOAD.GRA.057"),x: 0,y: 0)
        try drawDrill(practice.drill)
        let ui = try content.font("MOCKET.DAT.1393"), small = try content.font("MOCKET.DAT.1396")
        canvas.fill(0,160,320,40,1)
        canvas.text("Drill for Skill",font: ui,x: 8,y: 163,color: 15)
        canvas.text("Problems: \(practice.attempts)   Correct: \(practice.correctAnswers)",font: small,x: 8,y: 176,color: 15)
        canvas.text("Esc / F2: Play Another Game",font: small,x: 8,y: 188,color: 15)
        if practice.drill.phase == .finished {
            canvas.fill(100,65,144,48,0)
            canvas.text("\(practice.drill.correct) of \(practice.drill.questionCount) correct.",font: ui,x: 110,y: 70,color: 15)
            canvas.text("Enter for another set.",font: small,x: 110,y: 92,color: 15)
        }
    }
}
