import Foundation

final class NativeGameView: NSObject {
    var needsDisplay = true
    var bounds = GameViewport(width:320,height:200)
    func convert(_ point: GamePoint, from: Int?) -> GamePoint { point }
    enum Screen { case title, signin, file, menu, practice, world, question, drill, decoder, help, scores, ending, results }
    let content: OriginalContent
    let world: OriginalWorld
    let renderer: ChallengeRenderer
    let bank: ChallengeBank
    let endingData: OriginalEndingData
    let helpBook: OriginalHelpBook
    let profileStore: NativeProfileStore
    let saves: NativeSessionStore
    let canvas = NativeCanvas()
    var screen = Screen.title
    var signIn = NativeMemberSignIn()
    var fileReturn = Screen.menu
    var fileSelection = 0
    var opening = NativeOpeningPresentation()
    var openingLastPulse = ProcessInfo.processInfo.systemUptime
    var openingFraction = 0.0
    var session: NativeSession!
    var held: Set<UInt16> = []
    var physicalKeyboard = OriginalHeldKeyboard()
    var keyboard = OriginalKeyboardQueue<GameInputEvent>()
    var timer: Timer?
    var zapTimer: Timer?
    var lastZapPulse = ProcessInfo.processInfo.systemUptime
    var zapFraction = 0.0
    var helpReturn = Screen.world
    var helpBrowser: NativeHelpBrowser?
    var helpPausesAdventure = false
    var scoreReturn = Screen.title
    var scoresPauseAdventure = false
    var scoresShowHighGames = false
    var scorePage = 0
    var tick = 0
    var startupReported = false
    var lastEndingPulse = ProcessInfo.processInfo.systemUptime
    var endingFraction = 0.0
    var endingStartedAt = 0.0
    var endingFinishedWallSeconds: Double?
    var endingLastDraw: Double?
    var endingMaxDrawGap = 0.0
    var endingDrawCount = 0
    var endingReportWritten = false
    var selectedRoom = 0
    var status = ""
    var sound: PlatformSound?
    var soundEnabled = true
    var musicEnabled = true
    let automaticallyPresentMessages: Bool
    var messagePresenter: ((Int,String) -> Void)?
    var menuMessages = NativeNewUserMessages(enabled: true)
    var practiceMessages = NativeNewUserMessages(enabled: true)
    var tutorialPracticeContext = false
    var practiceIRQ: UInt64 = 0
    var practiceMessagesProfileID: UUID?
    var tutorialLastMinute: Int?
    var tutorialLastEnergy: Int?
    var lastSoundIndex: Int?
    var lastError: String?
    var activityPlanCache: (key: String,plan: NativeActivityPlan)?
    var referenceMode = false
    var lastSaveTick = 0
    var menuReturn = Screen.title
    var menuSelection = 0
    var calculatorRemainder: (quotient: Int,remainder: Int)?
    var decoderPanel: NativeDecoderPanel?
    var decoderButton = 0
    var decoderBlinkIRQ = 0
    var decoderConfirmationPending = false
    var decoderFooterBlank = false
    var originalNotice: NativeOriginalNotice?
    var optionsMenu: NativeOptionsMenu?
    var menuCalculatorEnabled = true
    var settingsEditor: NativeSettingsEditor?
    var confirmation: NativeConfirmation?
    var requestApplicationExit: () -> Void = { PlatformServices.exit() }
    var modalDepth = 0
    var practice: NativePractice?
    init(root: URL, saveDirectory: URL = NativeProfileStore.defaultDirectory,automaticallyPresentMessages: Bool = true) throws {
        self.automaticallyPresentMessages = automaticallyPresentMessages
        content = OriginalContent(root: root)
        world = try OriginalWorld(resource: Data(contentsOf: root.appendingPathComponent("catalog/decoded/MOCKET.DAT.1388.bin")))
        let coordinates = try JSONDecoder().decode(MapCoordinates.self, from: Data(contentsOf: root.appendingPathComponent("map_coordinates.json")))
        renderer = ChallengeRenderer(content: content, coordinates: coordinates)
        bank = try JSONDecoder().decode(ChallengeBank.self, from: Data(contentsOf: root.appendingPathComponent("challenges.json")))
        endingData = try JSONDecoder().decode(OriginalEndingData.self,from: Data(contentsOf: root.appendingPathComponent("ending-sequences.json")))
        helpBook = try JSONDecoder().decode(OriginalHelpBook.self,from: Data(contentsOf: root.appendingPathComponent("help-pages.json")))
        guard helpBook.valid else { throw ContentError.invalid("Invalid original help pages") }
        profileStore = try NativeProfileStore(directory: saveDirectory)
        saves = NativeSessionStore(directory: saveDirectory)
        super.init()
        if let id = profileStore.document.selectedProfileID,let profile = profileStore.document.profiles.first(where: { $0.id == id }) { menuMessages = NativeNewUserMessages(enabled: (profile.lifetimePoints ?? 0) < 5000) }
        timer = Timer.scheduledTimer(withTimeInterval: Double(OriginalWorld.frameIRQTicks)*VerifiedClock.pitDivisor/VerifiedClock.pitInputHz, repeats: true) { [weak self] _ in self?.step() }
        zapTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60,repeats: true) { [weak self] _ in self?.pulseZap() }
    }
    func begin() {
        do {
            let profile: NativeProfile
            if let selected = profileStore.document.selectedProfileID, let saved = profileStore.document.profiles.first(where: { $0.id == selected }) { profile = saved }
            else { profile = try profileStore.create(name: "Player") }
            session = try saves.load(profile.id) ?? NativeSession(profileID: profile.id, seed: UInt32.random(in: 0...65535),lifetimePoints: profile.lifetimePoints ?? 0)
            menuCalculatorEnabled = session.calculatorEnabled ?? true
            session.ensureQuestionSetup()
            ensureEnergyMachine()
            ensureCalculator()
            ensureRoomCamera()
            if let active = session.activeChallenge { try prepareActivityState(active) }
            lastZapPulse = ProcessInfo.processInfo.systemUptime; zapFraction = 0
            lastEndingPulse = ProcessInfo.processInfo.systemUptime;endingFraction = 0
            screen = session.activeDrill != nil ? .drill : (session.activeChallenge == nil ? .world : .question)
            if let ending = session.activeEnding { screen = ending.elapsedTicks >= EndingTimeline(ending,data: endingData).duration ? .results : .ending }
            tutorialLastMinute = nil; tutorialLastEnergy = nil
            status = ""; referenceMode = false
            practice = nil
            needsDisplay = true
        } catch { present(error) }
    }
    #if canImport(AppKit) && !OUTNUMBERED_PORTABLE
    @objc
    #endif
    func referenceQuestion() {
        // Deterministic video checkpoint, isolated from the player's saved game.
        session = NativeSession(profileID: UUID(), seed: 1, lifetimePoints: 30_000)
        session.position = NativePosition(scene: 10, playerUnit: 23, cameraUnit: 0, facing: 1)
        session.returnPosition = NativePosition(scene: 1, playerUnit: 52, cameraUnit: 38, facing: 1)
        referenceMode = true; screen = .world
        if let fixture = bank.cases.first(where: { $0.id == 9078 && $0.seed == 2 && $0.variant == 3 }) { open(fixture) }
    }
    #if canImport(AppKit) && !OUTNUMBERED_PORTABLE
    @objc
    #endif
    func referenceSongs() {
        session = NativeSession(profileID: UUID(),seed: 1,lifetimePoints: 30_000)
        session.position = NativePosition(scene: 13,playerUnit: 15,cameraUnit: 0,facing: 1)
        session.returnPosition = NativePosition(scene: 6,playerUnit: 248,cameraUnit: 228,facing: 1)
        referenceMode = true; screen = .world
        if let fixture = bank.cases.first(where: { $0.id == 9068 && $0.seed == 7 && $0.variant == 3 }) { open(fixture) }
    }
    #if canImport(AppKit) && !OUTNUMBERED_PORTABLE
    @objc
    #endif
    func referenceBarChart() {
        session = NativeSession(profileID: UUID(),seed: 1,lifetimePoints: 30_000)
        session.position = NativePosition(scene: 10,playerUnit: 15,cameraUnit: 0,facing: 1)
        session.returnPosition = NativePosition(scene: 1,playerUnit: 52,cameraUnit: 38,facing: 1)
        referenceMode = true; screen = .world
        if let fixture = bank.cases.first(where: { $0.id == 9010 && $0.seed == 1 && $0.variant == 0 }) { open(fixture) }
    }
    func save() {
        guard session != nil, !referenceMode else { return }
        //Practice owns separate state; menu/guide/quit paths must never rewrite
        //the suspended adventure, even if its in-memory snapshot is retained.
        guard !tutorialPracticeContext,screen != .practice,
              !(screen == .file && fileReturn == .practice),
              !(screen == .help && helpReturn == .practice),
              !(screen == .scores && scoreReturn == .practice) else { return }
        var snapshot = session!
        // Decoder/help are transient native screens. On relaunch the app opens
        // exploration (or the saved active question), so retain only its pause.
        let retainedPauses = snapshot.activeChallenge == nil && snapshot.activeEnding == nil ? 0 : 1
        while snapshot.clock.pauseDepth > retainedPauses { snapshot.clock.resume() }
        do { try saves.save(snapshot) } catch { present(error) }
    }
    func present(_ error: Error) {
        let message = error.localizedDescription
        guard message != lastError else { return }; lastError = message
        PlatformServices.error(message)
    }
    func effect(_ index: Int) {
        guard OriginalSoundPolicy.accepts(incoming: index,current: lastSoundIndex,playing: sound?.isPlaying == true,soundEnabled: soundEnabled,musicEnabled: musicEnabled) else { return }
        sound?.stop()
        sound = PlatformSound(contentsOf: content.root.appendingPathComponent(String(format: "audio/effect-%02d.wav", index)), byReference: false)
        sound?.play()
        lastSoundIndex = index
    }
    func step() {
        tick += 1
        if originalNotice != nil { return }
        if settingsEditor != nil { stepSettingsEditor();return }
        guard modalDepth == 0 else { return }
        if screen == .world { pollWorldKeyboard() }
        guard modalDepth == 0 else { return }
        if screen == .title { if opening.showingPage { effect(0) };return }
        if screen == .signin { signIn.blinkIRQ += OriginalWorld.frameIRQTicks;needsDisplay = true;return }
        guard ![.signin,.file,.menu,.scores].contains(screen) else { return }
        if screen == .help && !helpPausesAdventure { return }
        if screen == .practice {
            practiceIRQ += UInt64(OriginalWorld.frameIRQTicks)
            let phase = practice?.drill.phase, presentation = practice?.presentation, seconds = practice?.elapsedSeconds, attempts = practice?.attempts, correct = practice?.correctAnswers
            do {
                for event in try practice?.advance(irqTicks: OriginalWorld.frameIRQTicks,soundPlaying: sound?.isPlaying == true) ?? [] {
                    switch event {
                    case let .sound(index): effect(index)
                    case .stop: sound?.stop(); lastSoundIndex = nil
                    }
                }
            }
            catch { present(error) }
            if phase != practice?.drill.phase && practice?.drill.phase == .asking { keyboard.flush();scheduleTutorial(8,ticks: 720) }
            pollPracticeContinue()
            processTutorials()
            if seconds != practice?.elapsedSeconds || presentation != practice?.presentation || practice?.presentation != .questions || phase != practice?.drill.phase || attempts != practice?.attempts || correct != practice?.correctAnswers { needsDisplay = true }
            return
        }
        guard session != nil else { return }
        if screen == .ending {
            return
        }
        if session.activeZap != nil || session.activeFountain != nil || isTransitioning { needsDisplay = true; return }
        // Original IRQ time continues while questions/decoder pause displayed
        // game minutes. Resume restores the remaining minute deadline.
        if screen != .title { session.clock.pollAfterIRQTicks(UInt64(OriginalWorld.frameIRQTicks)) }
        processTutorials()
        if screen == .world && session.outcome == "active" {
            if session.clock.expired { startEnding(room: session.decoder.hideoutRoom,reason: .midnight); return }
            let movement = preparePlayerFrame()
            updateTelly()
            finishPlayerFrame(movement)
            updateTellyProjectileAndCollision()
            updateLiveWireAndCollision()
            updateRoomCamera(at: session.position)
            if tick-lastSaveTick >= 100 { save(); lastSaveTick = tick }
        }
        if screen == .drill && session.outcome == "active" {
            do {
                try advanceDrill(irqTicks: OriginalWorld.frameIRQTicks)
                if session.clock.expired { startEnding(room: session.decoder.hideoutRoom,reason: .midnight); return }
            } catch { present(error) }
        }
        if screen == .decoder {
            let next = decoderBlinkIRQ+OriginalWorld.frameIRQTicks
            if decoderBlinkIRQ < 100 && next >= 100 { decoderFooterBlank = false }
            decoderBlinkIRQ = next%200;needsDisplay = true
        }
        if screen == .world || screen == .drill { needsDisplay = true }
    }
    func move(_ delta: Int) {
        guard delta != 0 else { return }
        session.position = prepareMovement(delta).destination
    }
    func prepareMovement(_ delta: Int) -> OriginalMovement {
        session.playerHasMoved = true
        let direction = delta < 0 ? -1 : 1
        let movement = OriginalMovement.frame(from: session.position,horizontal: min(2,abs(delta)),facing: direction)
        session.position = movement.scrolled
        session.telly?.shiftForCamera(by: movement.cameraShift)
        return movement
    }
    func interact() {
        guard playerMotion.settled else { return }
        session.playerHasMoved = true
        let direction = held.contains(124) ? 1 : (held.contains(123) ? -1 : 0)
        if direction != 0 { beginJump(direction: direction);return }
        let scene = session.position.scene
        let unit = scene < 10 ? session.position.playerUnit-(scene*38) : session.position.playerUnit
        if let object = world.object(scene: scene, overlappingPlayerAt: unit,energyMachineSlot: session.energyMachineSlot) {
            if object.kind == 1 {
                if OriginalWorld.roomScene(throughHallway: scene) != nil || (scene >= 10 && session.returnPosition != nil) { beginDoor(object); return }
            } else if object.kind == 2, OriginalWorld.elevatorDestination(from: scene) != nil {
                beginElevator(object); return
            } else if object.kind == 9 {
                beginFountain(object); return
            } else if let hotspot = object.challengeIndex {
                guard !session.completed.contains(hotspot) else { status = "Clues collected."; return }
                // Other template renderers are still under recovery. Never
                // present a word problem without its required visual evidence.
                guard hotspot == 0 || ActivityTemplates.supportedHotspots.contains(hotspot) || ActivityMore.supportedHotspots.contains(hotspot) || ActivityFinal.supportedHotspots.contains(hotspot) else {
                    present(ContentError.invalid("This activity is not available in this development build.")); return
                }
                do {
                    if let challenge = try session.question(hotspot: hotspot,bank: bank) { open(challenge) }
                    else { status = "There is no question here in this game." }
                } catch { present(error) }
                return
            }
        }
        beginJump(direction: 0)
    }
    func open(_ challenge: OriginalChallenge) {
        // Upgrade an assigned pre-0.7 question with the same original data and
        // recovered post-generation stream; never change its identity.
        let challenge = bank.cases.first { $0.id == challenge.id && $0.seed == challenge.seed && $0.variant == challenge.variant } ?? challenge
        keyboard.flush();sound?.stop();lastSoundIndex = nil
        if challenge.hotspot == 7 { effect(34) }
        do { try prepareActivityState(challenge,regenerating: true) } catch { present(error); return }
        session.liveWire?.clear()
        session.calculator = NativeCalculator()
        session.activeChallenge = challenge
        if session.attempts[challenge.hotspot] == nil { session.attempts[challenge.hotspot] = RoomAttempt() }
        session.clock.pause(); screen = .question; held.removeAll(); status = ""
        do { try startActivityPresentation(challenge) } catch { present(error);return }
        save(); needsDisplay = true
        if !isActivityPresenting { showNewUserMessage(usesCalculator ? 10 : 9) }
    }
    func leaveQuestion() {
        attemptLiveWire()
        let result = session.activeChallenge.flatMap { session.attempts[$0.hotspot]?.result }
        session.activeChallenge = nil;session.activityPresentation = nil; session.clock.resume(); screen = .world; status = ""; save()
        if result == .correct { showNewUserMessage(7) }
        else if result == .failed { showNewUserMessage(14) }
    }
    func handleKeyDown(_ event: GameInputEvent) {
        let key = event.keyCode
        if screen == .title && key != 122 { openingKey(event);return }
        if isTransitioning { return }
        if [.practice,.drill].contains(screen) { cancelTutorialTimer() }
        if screen == .ending { return }
        if screen == .signin { signInKey(event);return }
        if screen == .file { fileKey(event);return }
        if screen == .scores { scoresKey(event);return }
        if screen == .help && helpBrowser?.topic != nil { helpKey(event);return }
        if key == 120 { showFileMenu(); return }
        if key == 99 { showOptions(); return }
        if key == 122 { toggleHelp(); return }
        if screen == .help { helpKey(event); return }
        if screen == .scores { scoresKey(event); return }
        if screen == .practice { practiceKey(event); return }
        if screen == .menu {
            if key == 125 { menuSelection = (menuSelection+1)%Self.playerMenuItems.count }
            else if key == 126 { menuSelection = (menuSelection+Self.playerMenuItems.count-1)%Self.playerMenuItems.count }
            else if key == 36 { activatePlayerMenu(menuSelection) }
            else if key == 53 { activatePlayerMenu(-1) }
            needsDisplay = true; return
        }
        if screen == .results {
            if key == 36 || key == 76 { continueAfterResults() }
            else if key == 53 {
                showConfirmation(.exit(saving: false)) { [weak self] choice in
                    guard let self else { return }
                    if choice == 1 { self.save();self.requestApplicationExit() }
                    else { self.choosePlayer() }
                }
            }
            return
        }
        if screen == .title { if key == 36 { showPlayerMenu() }; return }
        guard session != nil else { return }
        if session.activeZap != nil || session.activeFountain != nil { return }
        switch screen {
        case .title, .signin, .file, .menu, .practice, .ending, .results: break
        case .world:
            if key == 126 && !event.isARepeat && session.outcome == "active" { interact() }
            else if key == 49 && !event.isARepeat && playerMotion.settled && session.outcome == "active" {
                beginZap()
            } else if key == 48 { openDecoder() }
            else if key == 53 { confirmNativeExit() }
        case .question:
            guard let challenge = session.activeChallenge else { return }
            if key == 53 { leaveQuestion(); return }
            if key == 36 { submitQuestion() }
            else if key == 51 || key == 117 {
                if usesCalculator { calculatorKey(.delete) }
                else if session.attempts[challenge.hotspot]?.result == .editing && session.attempts[challenge.hotspot]?.input.isEmpty == false { session.attempts[challenge.hotspot]?.input.removeLast() }
            } else if let chars = event.characters, chars.count == 1 { questionCharacter(chars) }
        case .drill:
            if let presentation = session.activeDrill?.presentation, presentation.stage != .questions { return }
            if key == 53 {
                session.activeDrill?.abort()
                if session.activeDrill?.phase == .finished { try? advanceDrill(irqTicks: 0);save() }
            } else if key == 36, session.activeDrill?.phase == .finished {
                session.activeDrill = nil; screen = .world; save()
            } else if key == 36 {
                var drill = session.activeDrill!, generator = session.generator
                if let accepted = drill.submit(nextRandom: { generator.nextRandomValue() }) { effect(accepted ? 6 : 8) }
                session.generator = generator; session.activeDrill = drill
                save()
            } else if key == 51 || key == 117 { session.activeDrill?.erase() }
            else if let chars = event.charactersIgnoringModifiers, chars.count == 1, let digit = Int(chars) { session.activeDrill?.digit(digit) }
        case .decoder: decoderKey(event)
        case .help, .scores: break
        }
        needsDisplay = true
    }
    #if canImport(AppKit) && !OUTNUMBERED_PORTABLE
    @objc
    #endif
    func toggleHelp() {
        if decoderPanel != nil || originalNotice != nil || confirmation != nil || settingsEditor != nil { return }
        if optionsMenu != nil { closeOptions() }
        if screen == .ending || screen == .results { return }
        if screen == .file { closeFileMenu() }
        if session?.activeZap != nil || session?.activeFountain != nil { return }
        if screen == .help { if helpBrowser?.topic != nil { helpBrowser?.returnToTopics();helpBrowser?.selectedTopic = 0;needsDisplay = true }; return }
        helpReturn = screen
        helpBrowser = NativeHelpBrowser(practice: screen == .practice)
        helpPausesAdventure = session != nil && [.world,.question,.drill,.decoder].contains(screen)
        if helpPausesAdventure { session.clock.pause() }
        screen = .help; held.removeAll()
        needsDisplay = true
    }
    func mouseDown(with event: GameInputEvent) {
        if originalNotice != nil { return }
        if decoderPanel != nil {
            let point = convert(event.locationInWindow,from: nil)
            decoderPanelClick(x: Int(point.x/bounds.width*320),y: Int(point.y/bounds.height*200));return
        }
        if optionsMenu != nil && confirmation == nil {
            let point = convert(event.locationInWindow,from: nil)
            optionsClick(x: Int(point.x/bounds.width*320),y: Int(point.y/bounds.height*200));return
        }
        if settingsEditor != nil {
            let point = convert(event.locationInWindow,from: nil)
            settingsClick(x: Int(point.x/bounds.width*320),y: Int(point.y/bounds.height*200));return
        }
        if confirmation != nil {
            let point = convert(event.locationInWindow,from: nil)
            confirmationClick(x: Int(point.x/bounds.width*320),y: Int(point.y/bounds.height*200));return
        }
        if isTransitioning { return }
        if screen == .ending { return }
        if screen == .results { continueAfterResults(); return }
        if session != nil && (session.activeZap != nil || session.activeFountain != nil) { return }
        let p = convert(event.locationInWindow, from: nil)
        let x = Int(p.x/bounds.width*320), y = Int(p.y/bounds.height*200)
        if screen == .help {
            if y < 12 && x < 50 { closeHelp() }
            else if y < 12 && x < 104 { showFileMenu() }
            else if y < 12 && x < 170 { showOptions() }
            else { helpClick(x: x,y: y) }
            return
        }
        if screen == .scores { closeScores(); return }
        if screen == .signin || screen == .file { return }
        if screen == .title { opening.enter();needsDisplay = true;return }
        if screen == .menu {
            if x >= 50 && x < 286 && y >= 75 && y < 111 { menuSelection = min(Self.playerMenuItems.count-1,(y-75)/12); activatePlayerMenu(menuSelection) }
            return
        }
        if y < 12 && x >= 52 && x < 104 { showFileMenu(); return }
        if y < 12 && x >= 104 && x < 170 { showOptions(); return }
        if screen == .practice { return }
        if y < 12 && x < 50 { toggleHelp(); return }
        if screen == .decoder {
            if x >= 172 && y >= 17 && y < 157 { selectedRoom = min(4,(y-17)/28) }
            if y >= 162 {
                if x < 56 { closeDecoder() }
                else if x < 108 { decoderButton = 1;showMatchRule() }
                else if x < 160 {
                    decoderButton = 2;confirmDecision()
                }
            }
        }
        if screen == .question, let challenge = session.activeChallenge {
            if let button = NativeCalculator.button(atX: x,y: y) {
                if button == 10 { submitQuestion() }
                else if button < 10 { questionCharacter(String(button)) }
                else if usesCalculator, let operation = NativeCalculator.Operation(rawValue: button) { calculatorKey(.operation(operation)) }
                else if usesCalculator && button == 15 { calculatorKey(.equals) }
                else if button == 16 {
                    if usesCalculator { calculatorKey(.clear) }
                    else if session.attempts[challenge.hotspot]?.result == .editing { session.attempts[challenge.hotspot]?.input = "" }
                }
            }
        }
        needsDisplay = true
    }
    func sprite(_ index: Int, x: Int, y: Int, transparent: Bool = true, flipped: Bool = false) throws {
        canvas.draw(try content.bitmap(String(format: "FASTLOAD.GRA.%03d", index)),x: x,y: y,transparent: transparent,flipped: flipped)
    }
    func drawHUD(for visibleScreen: Screen? = nil) throws {
        let visibleScreen = visibleScreen ?? screen
        canvas.fill(0,160,320,40,0)
        canvas.draw(try content.bitmap("FASTLOAD.GRA.057"),x: 0,y: 0)
        try sprite(56,x: 216,y: 162,transparent: false)
        let font = try content.font("MOCKET.DAT.1393")
        let minute = session.clock.elapsedMinutes
        let hour = (21+minute/60)%12
        let time = session.clock.expired ? "12:00A.M." : "\(hour == 0 ? 12 : hour):\(String(format: "%02d",minute%60))P.M."
        canvas.fill(254,163,58,10,1)
        canvas.text(session.clock.roomChallengeActive && visibleScreen != .ending && visibleScreen != .results ? "Pause" : time,font: try content.font("MOCKET.DAT.1396"),x: 256,y: 164,color: 14)
        canvas.fill(256,176,48,8,1)
        canvas.fill(256,176,min(48,max(0,session.energy)*2),8,14)
        canvas.fill(254,188,58,8,1)
        canvas.text(String(format: "%06d", Int(session.score)),font: font,x: 254,y: 187,color: 14)
        if visibleScreen == .world {
            let prompt = status.isEmpty ? "\u{86} to See Decoder" : status
            canvas.text(prompt,font: font,x: 8,y: 176,color: 15,wrapWidth: 201)
        }
    }
    func drawWorldBackdrop(_ p: NativePosition) throws {
        canvas.fill(0,12,320,148,0)
        canvas.fill(5,15,310,143,8)
        // Local elevator footage has two black bottom rows158/159; the room
        // bitmap ends at157. Leaving158 blue exposes a seam during scrolling.
        canvas.fill(5,158,310,1,1)
        canvas.clip = (8,15,304,143)
        if p.scene < 10 {
            canvas.fill(8,15,304,16,1)
            for i in 0..<38 { try sprite(137+(p.cameraUnit+i)%38,x: 8+i*8,y: 31,transparent: false) }
            let floor = p.scene/5
            for scene in floor*5..<floor*5+5 {
                let origin = (scene*38-p.cameraUnit)*8
                for object in world.objects(scene: scene,energyMachineSlot: session.energyMachineSlot) where object.kind >= 0 {
                    let x = origin+object.pixelX
                    if x > 312 || x+128 < 8 { continue }
                    if object.kind == 1 { try sprite(124,x: x,y: 48) }
                    try sprite(object.sprite,x: x,y: object.drawY,flipped: object.kind == 6 && scene%5 == 4)
                    //196..201 replace only the top24 rows, not the whole
                    //88x87 machine. Original1b03:013f backs up this strip.
                    if object.kind == 9, let fountain = session.activeFountain, fountain.phase == .dispensing {
                        try sprite(fountain.machineSprite,x: x,y: object.drawY)
                    }
                }
            }
        } else if let selector = OriginalWorld.backgroundSelector(forRoom: p.scene) {
            canvas.draw(try content.bitmap(String(format: "DMOCKET.GRA.%04x",selector)),x: 0,y: 15)
        }
    }
    func drawWorld() throws {
        let doorFrame = session.activeDoor?.currentFrame
        let elevator = session.activeElevator
        let elevatorFrame = elevator?.currentFrame
        if let elevator, let frame = elevatorFrame, frame.scrollPixels > 0 { try drawElevatorScroll(elevator,frame.scrollPixels); return }
        let p = elevatorFrame?.position ?? doorFrame?.position ?? session.position
        try drawWorldBackdrop(p)
        if let elevator, let frame = elevatorFrame, frame.drawsPanels { try drawElevatorBase(elevator,frame) }
        try drawLiveWire()
        try drawRoomCamera(at: p)
        var frame = playerMotion.sprite
        var y = playerMotion.y
        if let fountain = session.activeFountain { frame = fountain.playerFrame;y = fountain.playerY }
        var x = (p.scene < 10 ? p.playerUnit-p.cameraUnit : p.playerUnit)*8
        if let doorFrame {
            frame = doorFrame.ordinal; y = doorFrame.y
            if let ordinal = doorFrame.doorOrdinal, let door = session.activeDoor {
                try sprite(ordinal,x: (door.hallway.scene*38+door.doorStartUnit-door.hallway.cameraUnit)*8,y: 49)
            }
        }
        if let zap = session.activeZap {
            let frames = zap.schedule.playerFrames
            let firing = frames[min(2,zap.elapsedIRQTicks/10)]
            frame = firing.ordinal; x = firing.xUnits*8; y = firing.yPixels
        }
        if let elevatorFrame {
            frame = elevatorFrame.ordinal ?? 0; y = elevatorFrame.y
            if let elevator, elevatorFrame.drawsPanels && elevatorFrame.playerInFront { try drawElevatorPanels(elevator,elevatorFrame) }
        }
        try drawPlayerSprite(frame,x: x,y: y,flipped: p.facing < 0)
        try drawTellyAndProjectile()
        if let elevator, let elevatorFrame, elevatorFrame.drawsPanels && !elevatorFrame.playerInFront { try drawElevatorPanels(elevator,elevatorFrame) }
        if let zap = session.activeZap, zap.elapsedIRQTicks >= 30, !zap.schedule.beamFrames.isEmpty {
            let index = min(5,(zap.elapsedIRQTicks-30)/10), beam = zap.schedule.beamFrames[index]
            try sprite(beam.ordinal,x: beam.xUnits*8,y: beam.yPixels,flipped: p.facing < 0)
        }
        if let flash = session.activeCollision, let word = flash.effect.impactSprite { try sprite(word,x: flash.xUnit*8,y: 52) }
        canvas.clip = nil
        canvas.border(4,14,312,146,1)
    }
    func drawQuestion() throws {
        guard let challenge = session.activeChallenge else { return }
        let attempt = session.attempts[challenge.hotspot] ?? RoomAttempt()
        canvas.fill(4,14,isActivityPresenting ? 312 : 184,146,1)
        if challenge.hotspot == 0 { try renderer.draw(challenge,on: canvas) }
        else if ActivityTemplates.supportedHotspots.contains(challenge.hotspot) { _ = try ActivityTemplates(content: content).draw(challenge,on: canvas,progress: activityPresentationFrame(challenge)) }
        else if ActivityMore.supportedHotspots.contains(challenge.hotspot) { _ = try ActivityMore(content: content).draw(challenge,on: canvas,progress: activityPresentationFrame(challenge)) }
        else { _ = try ActivityFinal(content: content).draw(challenge,state: session.activityStates?[challenge.hotspot],on: canvas,progress: activityPresentationFrame(challenge)) }
        if isActivityPresenting { return }
        canvas.draw(try content.bitmap("ROOMS.GRA.017"),x: 188,y: 15)
        let small = try content.font("MOCKET.DAT.1396"), ui = try content.font("MOCKET.DAT.1393")
        canvas.text(challenge.question,font: small,x: 200,y: 32,color: 1,wrapWidth: 105,lineHeight: 9)
        if attempt.result == .editing {
            if usesCalculator {
                canvas.draw(try content.bitmap("ROOMS.GRA.016"),x: 188,y: 138)
                let calculator = session.calculator ?? NativeCalculator()
                let display = calculatorRemainder.map { String($0.quotient) } ?? calculator.display
                canvas.text(display,font: ui,x: 229-ui.width(of: display),y: 148,color: 1)
                if calculatorRemainder == nil,let operation = calculator.operation { canvas.text(operation.glyph,font: ui,x: 237,y: 148,color: 1) }
            } else { canvas.text(attempt.input,font: ui,x: 208,y: 141,color: 1) }
            if let remainder = calculatorRemainder {
                canvas.text("This answer has a",font: ui,x: 12,y: 163,color: 15)
                canvas.text("remainder of \(remainder.remainder).",font: ui,x: 12,y: 173,color: 15)
            } else if attempt.wrongAnswers == 1 {
                canvas.text("That's not correct.",font: ui,x: 12,y: 163,color: 15)
                canvas.text("Read the question.",font: ui,x: 12,y: 173,color: 15)
            } else if attempt.awaitingHintAcknowledgement {
                canvas.text("That's not correct.",font: ui,x: 12,y: 163,color: 15)
                canvas.text("Press \u{85} for a hint.",font: ui,x: 12,y: 183,color: 15)
            } else if attempt.wrongAnswers == 2 {
                canvas.fill(10,157,174,41,15)
                canvas.text(challenge.hint,font: small,x: 12,y: 158,color: 1,wrapWidth: 170,lineHeight: 8)
            }
        } else {
            canvas.text(attempt.input,font: ui,x: 208,y: 141,color: 1)
            canvas.text(attempt.result == .correct ? "That's correct." : "That's not correct.",font: ui,x: 12,y: 163,color: 15)
            if attempt.result == .failed { canvas.text("The correct answer is \(challenge.answer).",font: ui,x: 12,y: 173,color: 15) }
        }
        if attempt.result != .editing || attempt.wrongAnswers != 2 {
            canvas.text(attempt.result == .editing ? "\u{84} to Explore TV Station" : "\u{85} to Explore TV Station",font: ui,x: 8,y: 185,color: 15)
        }
    }
    func drawDecoder() throws {
        canvas.draw(try content.bitmap("DMOCKET.GRA.1770"),x: 8,y: 17)
        for i in 0..<4 {
            let value = session.decoder.secret[i]
            if value & 0x80 == 0 { try sprite(Int(value & 0x3f)+78,x: 32+i*28,y: 110) }
        }
        for room in 0..<5 {
            for i in 0..<4 {
                let value = session.decoder.roomClues[room][i]
                if value & 0x80 == 0 { try sprite(Int(value & 0x3f)+78,x: 184+i*28,y: 24+room*28) }
            }
        }
        canvas.replaceActivityColor(left: 172,top: 17+selectedRoom*28,right: 308,bottom: 43+selectedRoom*28,from: 3,to: 12)
        canvas.fill(5,163,211,34,0);canvas.border(4,162,213,36,1)
        if decoderConfirmationPending { return }
        canvas.clip = (4,162,212,36)
        if !decoderFooterBlank { canvas.draw(try content.bitmap("DMOCKET.GRA.1771"),x: 4,y: 162,transparent: true) }
        if decoderBlinkIRQ < 100 { try sprite(98,x: (decoderButton*13+2)*4,y: 165,transparent: true) }
        canvas.clip = nil
    }
    func render(_ visibleScreen: Screen? = nil) throws {
        if visibleScreen == nil,let originalNotice { try drawOriginalNotice(originalNotice);return }
        if visibleScreen == nil,let confirmation { try drawConfirmation(confirmation);return }
        if visibleScreen == nil,let decoderPanel { try drawDecoderPanel(decoderPanel);return }
        if visibleScreen == nil,let optionsMenu { try drawOptions(optionsMenu);return }
        if visibleScreen == nil,let settingsEditor { try drawSettingsEditor(settingsEditor);return }
        let visibleScreen = visibleScreen ?? screen
        canvas.clip = nil; canvas.clear(1)
        if visibleScreen == .help { try render(helpReturn); try drawOriginalHelp(); return }
        if visibleScreen == .scores { try render(scoreReturn); try drawScores(); return }
        if visibleScreen == .title { try drawOpening(); return }
        if visibleScreen == .signin { try drawSignIn();return }
        if visibleScreen == .file { try render(fileReturn);try drawFileMenu();return }
        if visibleScreen == .menu { try drawPlayerMenu(); return }
        if visibleScreen == .practice { try drawPractice(); return }
        try drawHUD(for: visibleScreen)
        switch visibleScreen {
        case .title, .signin, .file, .menu, .practice: break
        case .world: try drawWorld()
        case .question: try drawQuestion()
        case .drill: try drawDrill()
        case .decoder: try drawDecoder()
        case .ending: try drawEnding()
        case .results: try drawResults()
        case .help, .scores: break
        }
    }
    func recordPresentedFrame() throws {
            if let path = ProcessInfo.processInfo.environment["OUTNUMBERED_NATIVE_ENDING_REPORT"],let ending = session?.activeEnding,screen == .ending || screen == .results {
                let now = ProcessInfo.processInfo.systemUptime
                if let previous = endingLastDraw { endingMaxDrawGap = max(endingMaxDrawGap,now-previous) }
                endingLastDraw = now;endingDrawCount += 1
                if screen == .results,!endingReportWritten,let finished = endingFinishedWallSeconds {
                    endingReportWritten = true
                    let duration = EndingTimeline(ending,data: endingData).duration
                    let report: [String:Any] = ["sourceDurationIRQ":duration,"sourceDurationSeconds":Double(duration)*VerifiedClock.pitDivisor/VerifiedClock.pitInputHz,"completionEventWallSeconds":finished,"resultsDrawWallSeconds":now-endingStartedAt,"endingFrameDrawCount":endingDrawCount,"maximumDrawGapSeconds":endingMaxDrawGap,"finalElapsedIRQ":ending.elapsedTicks,"finalScore":Int(session.score),"finalLifetime":session.lifetimePoints]
                    try JSONSerialization.data(withJSONObject: report,options: [.prettyPrinted,.sortedKeys]).write(to: URL(fileURLWithPath: path),options: .atomic)
                }
            }
            if !startupReported,let path = ProcessInfo.processInfo.environment["OUTNUMBERED_NATIVE_STARTUP_REPORT"] {
                startupReported = true
                let report: [String:Any] = ["firstDrawUTC":ISO8601DateFormatter().string(from: Date()),"secondsSinceNativeMain":ProcessInfo.processInfo.systemUptime-NativeApplication.startedAt,"architecture":NativeApplication.architecture,"firstFrameDrawn":true]
                try JSONSerialization.data(withJSONObject: report,options: [.prettyPrinted,.sortedKeys]).write(to: URL(fileURLWithPath: path),options: .atomic)
            }
    }

}
