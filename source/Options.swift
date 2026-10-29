import Foundation

struct NativeOptionsMenu {
    let backdrop: [UInt8]
    let practice: Bool
    var selection = 0
    var items: [String] { practice ? ["Music","Sound"] : ["New User Messages","Music","Sound","Calculator"] }
    mutating func move(_ delta: Int) { selection = (selection+delta+items.count)%items.count }
}

extension OriginalConfirmation {
    static func music(_ enabled: Bool) -> Self { Self(text: "Do you want the\nMusic on?",title: "Music",selection: enabled ? 1 : 0) }
    static func sound(_ enabled: Bool) -> Self { Self(text: "Do you want the\nSound on?",title: "Sound",selection: enabled ? 1 : 0) }
    static func messages(_ enabled: Bool) -> Self {
        Self(text: "The New User Messages\nhelp you learn how to play\nthe game.\n\nDo you want to see the\nNew User Messages\nas you play the game?",title: "New User Messages",selection: enabled ? 1 : 0)
    }
    static func calculator(_ enabled: Bool) -> Self {
        Self(text: "You can work out math\nchallenges with paper and\npencil or use the on-screen\ncalculator.\n\nDo you want to use the\ncalculator to do the math\nchallenges?",title: "Calculator",selection: enabled ? 1 : 0)
    }
}

extension NativeGameView {
    #if canImport(AppKit) && !OUTNUMBERED_PORTABLE
    @objc
    #endif
    func showOptions() {
        guard decoderPanel == nil,confirmation == nil,settingsEditor == nil,originalNotice == nil,optionsMenu == nil,!isTransitioning,
              session?.activeZap == nil,session?.activeFountain == nil,![.title,.signin,.ending,.results].contains(screen) else { return }
        if screen == .file { closeFileMenu() }
        if screen == .help { closeHelp() }
        if screen == .scores { closeScores() }
        do {
            try render()
            optionsMenu = NativeOptionsMenu(backdrop: canvas.pixels,practice: screen == .practice)
            modalDepth += 1;keyboard.flush();held.removeAll();needsDisplay = true
        } catch { present(error) }
    }
    func closeOptions() {
        guard optionsMenu != nil else { return }
        optionsMenu = nil;modalDepth -= 1;keyboard.flush();held.removeAll();needsDisplay = true
    }
    func optionsKey(_ event: GameInputEvent) {
        guard confirmation == nil,originalNotice == nil,optionsMenu != nil,
              event.modifierFlags.intersection([.control,.command,.option]).isEmpty else { return }
        switch event.keyCode {
        case 53: closeOptions()
        case 125: optionsMenu!.move(1)
        case 126: optionsMenu!.move(-1)
        case 123,120: closeOptions();showFileMenu()
        case 124,122: closeOptions();toggleHelp()
        case 36,76: activateOption()
        default: break //F3 on the current tab and Tab are ignored.
        }
        needsDisplay = true
    }
    func activateOption() {
        guard let menu = optionsMenu,confirmation == nil,originalNotice == nil else { return }
        //17620 restores the parent BEFORE the callback. Return0 ends the
        //17570 menu loop; only a nonzero callback rebuilds the Help menu.
        closeOptions()
        switch menu.items[menu.selection] {
        case "New User Messages": showNewUserOptions()
        case "Music":
            showConfirmation(.music(musicEnabled)) { [weak self] choice in
                if choice >= 0 { self?.setMusicEnabled(choice == 1) }
            }
        case "Sound":
            showConfirmation(.sound(soundEnabled)) { [weak self] choice in
                if choice >= 0 { self?.setSoundEnabled(choice == 1) }
            }
        default:
            let enabled = session?.calculatorEnabled ?? menuCalculatorEnabled
            showConfirmation(.calculator(enabled)) { [weak self] choice in
                guard let self,choice >= 0,(choice == 1) != enabled else { return }
                self.chooseCalculator(choice == 1)
            }
        }
    }
    func chooseCalculator(_ enabled: Bool) {
        let challenge = session?.activeChallenge
        //DS4c70 is the source editor's nonempty-input flag. An operator may
        //leave the entry string empty while the calculator still owns a number.
        let hasInput = challenge.map { session.attempts[$0.hotspot]?.input.isEmpty == false } == true || (session?.calculator.map { $0.phase != .empty } ?? false)
        if challenge != nil && hasInput {
            let text = enabled ? "If you turn the calculator\non while working on a\nchallenge, any numbers you\nhave already put in the\nanswer box will be removed.\n\nPress \u{85} to continue." : "If you turn the calculator\noff while working on a\nchallenge, any numbers in\nthe calculator will be lost.\n\nPress \u{85} to continue."
            showOriginalNotice(OriginalNotice(text: text,title: "Warning",style: 7)) { [weak self] key in
                if key == 36 || key == 76 { self?.applyCalculatorChoice(enabled) }
            }
        } else { applyCalculatorChoice(enabled) }
    }
    func applyCalculatorChoice(_ enabled: Bool) {
        menuCalculatorEnabled = enabled
        guard session != nil else { needsDisplay = true;return }
        session.calculatorEnabled = enabled
        if let challenge = session.activeChallenge {
            session.calculator = NativeCalculator()
            if session.attempts[challenge.hotspot]?.result == .editing { session.attempts[challenge.hotspot]?.input = "" }
        }
        if screen != .practice { save() };needsDisplay = true
    }
    func optionsClick(x: Int,y: Int) {
        guard let menu = optionsMenu,let font = try? content.font("MOCKET.DAT.1393") else { return }
        if y < 12 {
            if x < 52 { closeOptions();toggleHelp() }
            else if x < 104 { closeOptions();showFileMenu() }
            return
        }
        let width = max(123,menu.items.map { font.width(of: $0)+14 }.max()!)
        if (108...104+width-6).contains(x),(17..<17+12*menu.items.count).contains(y) {
            optionsMenu!.selection = (y-17)/12;activateOption();needsDisplay = true
        }
    }
    func drawOptions(_ menu: NativeOptionsMenu) throws {
        canvas.clip = nil;canvas.restoreEndingRect(menu.backdrop,x: 0,y: 0,right: 319,bottom: 199)
        try sprite(57,x: 0,y: 0,transparent: false);try sprite(63,x: 96,y: 0,transparent: false)
        let font = try content.font("MOCKET.DAT.1393")
        let width = max(123,menu.items.map { font.width(of: $0)+14 }.max()!)
        canvas.originalHelpPanel(left: 104,top: 12,right: 104+width,bottom: 12+menu.items.count*12+25,title: nil,footer: "\u{84} to Go Back",font: font,bottomSeparator: 18)
        for (index,item) in menu.items.enumerated() { canvas.text(item,font: font,x: 110,y: 17+index*12,color: 1) }
        canvas.invert(108,16+menu.selection*12,width-9,13)
    }
}
