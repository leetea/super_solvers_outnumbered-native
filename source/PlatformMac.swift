#if canImport(AppKit) && !OUTNUMBERED_PORTABLE
import AppKit
final class MacGameView: NSView {
    let game: NativeGameView
    init(_ game: NativeGameView) { self.game = game;super.init(frame: NSRect(x:0,y:0,width:960,height:600));setAccessibilityLabel("Outnumbered native game") }
    required init?(coder: NSCoder) { fatalError("Not used") }
    override var acceptsFirstResponder: Bool { true }
    override var isFlipped: Bool { true }
    override func keyDown(with event: NSEvent) { game.keyDown(with: GameInputEvent(event)) }
    override func keyUp(with event: NSEvent) { game.keyUp(with: GameInputEvent(event)) }
    override func resignFirstResponder() -> Bool { game.resignFirstResponder() }
    override func mouseDown(with event: NSEvent) {
        let p = convert(event.locationInWindow,from:nil)
        game.mouseDown(with: GameInputEvent(keyCode:0,location:GamePoint(x:p.x/bounds.width*320,y:p.y/bounds.height*200)))
    }
    override func draw(_ dirtyRect: NSRect) {
        do {
            try game.render()
            let image = NSImage(size: NSSize(width: 320,height: 200)); image.addRepresentation(try game.canvas.macRepresentation())
            NSGraphicsContext.current?.imageInterpolation = .none
            image.draw(in: bounds,from: .zero,operation: .copy,fraction: 1,respectFlipped: true,hints: [.interpolation: NSImageInterpolation.none.rawValue])
            try game.recordPresentedFrame()
        } catch { game.present(error) }
    }
}
final class NativeApplicationDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var game: NativeGameView!
    func applicationDidFinishLaunching(_ notification: Notification) {
        do {
            game = try NativeGameView(root: NativeApplication.assets)
            window = NSWindow(contentRect: NSRect(x: 0,y: 0,width: 960,height: 600),styleMask: [.titled,.closable,.miniaturizable],backing: .buffered,defer: false)
            window.title = NativeApplication.developmentBuild ? "Outnumbered — Native Development Build" : "Outnumbered!"
            let view = MacGameView(game);window.contentView = view;
            Timer.scheduledTimer(withTimeInterval: 1.0/60,repeats:true) { _ in if self.game.needsDisplay { view.needsDisplay = true;self.game.needsDisplay = false } }; window.center(); window.makeKeyAndOrderFront(nil); window.makeFirstResponder(view)
            let root = NSMenu(), application = NSMenuItem(), menu = NSMenu()
            root.addItem(application); application.submenu = menu
            menu.addItem(withTitle: "Quit Outnumbered",action: #selector(NSApplication.terminate(_:)),keyEquivalent: "q")
            let gameItem = NSMenuItem(), gameMenu = NSMenu(title: "Game")
            root.addItem(gameItem); gameItem.submenu = gameMenu
            let players = NSMenuItem(title: "Play Another Game",action: #selector(NativeGameView.showPlayerMenu),keyEquivalent: "p"); players.target = game; gameMenu.addItem(players)
            let newPlayer = NSMenuItem(title: "Start New Player",action: #selector(NativeGameView.choosePlayer),keyEquivalent: "n"); newPlayer.target = game; gameMenu.addItem(newPlayer)
            let restore = NSMenuItem(title: "Restore Removed Member…",action: #selector(NativeGameView.restoreMember),keyEquivalent: "");restore.target = game;gameMenu.addItem(restore)
            let practice = NSMenuItem(title: "Drill for Skill",action: #selector(NativeGameView.startPractice),keyEquivalent: "k"); practice.target = game; gameMenu.addItem(practice)
            let lifetime = NSMenuItem(title: "Lifetime Scores",action: #selector(NativeGameView.showLifetimeScores),keyEquivalent: "7"); lifetime.target = game; gameMenu.addItem(lifetime)
            let highScores = NSMenuItem(title: "High Game Scores",action: #selector(NativeGameView.showHighGameScores),keyEquivalent: "8"); highScores.target = game; gameMenu.addItem(highScores)
            let options = NSMenuItem(title: "Options",action: #selector(NativeGameView.showOptions),keyEquivalent: ","); options.target = game; gameMenu.addItem(options)
            if NativeApplication.developmentBuild {
            gameMenu.addItem(.separator())
            let reference = NSMenuItem(title: "Reference Rainfall Question",action: #selector(NativeGameView.referenceQuestion),keyEquivalent: "r"); reference.target = game
            gameMenu.addItem(reference)
            let songs = NSMenuItem(title: "Reference Cartoon Songs Question",action: #selector(NativeGameView.referenceSongs),keyEquivalent: "g"); songs.target = game; gameMenu.addItem(songs)
            let bars = NSMenuItem(title: "Bar Chart Checkpoint",action: #selector(NativeGameView.referenceBarChart),keyEquivalent: "b"); bars.target = game; gameMenu.addItem(bars)
            let spinner = NSMenuItem(title: "Spinner Checkpoint",action: #selector(NativeGameView.referenceSpinner),keyEquivalent: "1"); spinner.target = game; gameMenu.addItem(spinner)
            let television = NSMenuItem(title: "Television Checkpoint",action: #selector(NativeGameView.referenceTelevision),keyEquivalent: "t"); television.target = game; gameMenu.addItem(television)
            let music = NSMenuItem(title: "Music Chart Checkpoint",action: #selector(NativeGameView.referenceMusic),keyEquivalent: "2"); music.target = game; gameMenu.addItem(music)
            let supplies = NSMenuItem(title: "Equipment List Checkpoint",action: #selector(NativeGameView.referenceSupplies),keyEquivalent: "3"); supplies.target = game; gameMenu.addItem(supplies)
            let questions = NSMenuItem(title: "Junior Questions Checkpoint",action: #selector(NativeGameView.referenceJuniorQuestions),keyEquivalent: "4"); questions.target = game; gameMenu.addItem(questions)
            let ending = NSMenuItem(title: "Ending Checkpoint",action: #selector(NativeGameView.referenceEnding),keyEquivalent: "5"); ending.target = game; gameMenu.addItem(ending)
            let drill = NSMenuItem(title: "Reference Telly Drill",action: #selector(NativeGameView.referenceDrill),keyEquivalent: "d"); drill.target = game
            gameMenu.addItem(drill)
            let energy = NSMenuItem(title: "Energy Machine Checkpoint",action: #selector(NativeGameView.referenceEnergy),keyEquivalent: "e"); energy.target = game; gameMenu.addItem(energy)
            let wire = NSMenuItem(title: "LiveWire Checkpoint",action: #selector(NativeGameView.referenceLiveWire),keyEquivalent: "l"); wire.target = game; gameMenu.addItem(wire)
            }
            let help = NSMenuItem(title: "Help",action: #selector(NativeGameView.toggleHelp),keyEquivalent: "h"); help.target = game; gameMenu.addItem(help)
            let calculator = NSMenuItem(title: "Use Calculator",action: #selector(NativeGameView.toggleCalculator(_:)),keyEquivalent: ""); calculator.target = game; calculator.state = .on; gameMenu.addItem(calculator)
            NSApp.mainMenu = root; NSApp.activate(ignoringOtherApps: true)
        } catch { let alert = NSAlert(); alert.messageText = "Outnumbered could not open"; alert.informativeText = error.localizedDescription; alert.runModal(); NSApp.terminate(nil) }
    }
    func applicationWillTerminate(_ notification: Notification) { game?.save() }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
}

extension NativeGameView: NSMenuItemValidation {
    func validateMenuItem(_ item: NSMenuItem) -> Bool { decoderPanel == nil && confirmation == nil && settingsEditor == nil && originalNotice == nil && optionsMenu == nil && !isTransitioning }
}
extension GameInputEvent {
    init(_ event: NSEvent) {
        self.init(keyCode:event.keyCode,characters:event.characters ?? "",repeatKey:event.isARepeat)
        if event.modifierFlags.contains(.shift) { modifierFlags.insert(.shift) }
        if event.modifierFlags.contains(.control) { modifierFlags.insert(.control) }
        if event.modifierFlags.contains(.command) { modifierFlags.insert(.command) }
        if event.modifierFlags.contains(.option) { modifierFlags.insert(.option) }
        charactersIgnoringModifiers = event.charactersIgnoringModifiers
    }
}
extension NativeCanvas {
    func macRepresentation() throws -> NSBitmapImageRep {
        let image = try representation()
        let rep = NSBitmapImageRep(bitmapDataPlanes:nil,pixelsWide:320,pixelsHigh:200,bitsPerSample:8,samplesPerPixel:4,hasAlpha:true,isPlanar:false,colorSpaceName:.deviceRGB,bytesPerRow:1280,bitsPerPixel:32)!
        rep.bitmapData!.update(from:image.bitmapData!,count:320*200*4)
        return rep
    }
}
#endif
#if canImport(AppKit) && !OUTNUMBERED_PORTABLE
func runMacGame() {
    let app=NSApplication.shared;app.setActivationPolicy(.regular)
    let delegate=NativeApplicationDelegate();app.delegate=delegate;app.run()
}
#endif
