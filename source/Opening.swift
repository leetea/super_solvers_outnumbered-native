import Cocoa

//Original1a4e:00b4, DS:3ae0..3ed0. Data translated; no DOS code executes.
enum OriginalOpening {
    static let lines = ["The Master of Mischief", "is planning to take", "over the Shady Glen", "TV (SGTV) station", "and is hiding out in ", "one of the rooms.", "You must find his", "hideout and stop him by", "midnight! Collect clues about", "each room by solving the math", "challenges he has cleverly", "placed there.", "Capture secret code in the", "halls by zapping his", "robot Telly and", "answering the drill", "questions that", "follow. Then use", "your decoder to match", "the clues with the secret", "code to find the room where", "the Master of Mischief has", "concealed his hideout. Decide", "correctly and you win the game!"]
    static let pageWait = 12000
    static let wipeWait = 24
    static let frameWait = 40
    static let scripts: [[OriginalEndingData.Command]] = [
        [
            .init(resource: 1,x: 70,y: 14,right: 73,bottom: 23,restoreCommand: 0,flags: 64,waitFrames: 1),
            .init(resource: 2,x: 70,y: 12,right: 75,bottom: 21,restoreCommand: 1,flags: 64,waitFrames: 1),
            .init(resource: 3,x: 68,y: 4,right: 77,bottom: 28,restoreCommand: 2,flags: 64,waitFrames: 1),
            .init(resource: -2,x: 11,y: 0,right: 0,bottom: 0,restoreCommand: 0,flags: 0,waitFrames: 0),
            .init(resource: 4,x: 66,y: 1,right: 77,bottom: 32,restoreCommand: 3,flags: 64,waitFrames: 0),
            .init(resource: 7,x: 62,y: 20,right: 73,bottom: 79,restoreCommand: 0,flags: 64,waitFrames: 1),
            .init(resource: 5,x: 70,y: 10,right: 75,bottom: 19,restoreCommand: 5,flags: 64,waitFrames: 0),
            .init(resource: 7,x: 62,y: 20,right: 73,bottom: 79,restoreCommand: 0,flags: 64,waitFrames: 0),
            .init(resource: 7,x: 54,y: 80,right: 65,bottom: 139,restoreCommand: 0,flags: 64,waitFrames: 1),
            .init(resource: 6,x: 68,y: 8,right: 75,bottom: 21,restoreCommand: 7,flags: 64,waitFrames: 0),
            .init(resource: 7,x: 62,y: 20,right: 73,bottom: 79,restoreCommand: 0,flags: 64,waitFrames: 0),
            .init(resource: 7,x: 46,y: 140,right: 57,bottom: 199,restoreCommand: 0,flags: 64,waitFrames: 3),
        ],
        [
            .init(resource: -2,x: 11,y: 0,right: 0,bottom: 0,restoreCommand: 0,flags: 0,waitFrames: 0),
            .init(resource: 8,x: 48,y: 26,right: 79,bottom: 199,restoreCommand: 0,flags: 64,waitFrames: 0),
            .init(resource: 9,x: 32,y: 152,right: 79,bottom: 199,restoreCommand: 0,flags: 64,waitFrames: 1),
            .init(resource: 8,x: 46,y: 56,right: 79,bottom: 199,restoreCommand: 0,flags: 64,waitFrames: 0),
            .init(resource: 10,x: 34,y: 152,right: 79,bottom: 199,restoreCommand: 3,flags: 64,waitFrames: 1),
            .init(resource: 8,x: 44,y: 86,right: 79,bottom: 199,restoreCommand: 0,flags: 64,waitFrames: 0),
            .init(resource: 11,x: 34,y: 149,right: 79,bottom: 199,restoreCommand: 5,flags: 64,waitFrames: 1),
            .init(resource: 8,x: 42,y: 116,right: 79,bottom: 199,restoreCommand: 0,flags: 64,waitFrames: 0),
            .init(resource: 12,x: 34,y: 140,right: 79,bottom: 199,restoreCommand: 7,flags: 64,waitFrames: 1),
        ],
        [
            .init(resource: 27,x: 0,y: 0,right: 79,bottom: 199,restoreCommand: 0,flags: 0,waitFrames: 0),
            .init(resource: 13,x: 32,y: 147,right: 79,bottom: 199,restoreCommand: 0,flags: 64,waitFrames: 1),
            .init(resource: 14,x: 32,y: 147,right: 79,bottom: 199,restoreCommand: 2,flags: 64,waitFrames: 1),
            .init(resource: 15,x: 34,y: 147,right: 79,bottom: 199,restoreCommand: 3,flags: 64,waitFrames: 1),
            .init(resource: 14,x: 32,y: 147,right: 79,bottom: 199,restoreCommand: 4,flags: 64,waitFrames: 1),
            .init(resource: 13,x: 32,y: 147,right: 79,bottom: 199,restoreCommand: 5,flags: 64,waitFrames: 1),
            .init(resource: 16,x: 34,y: 148,right: 79,bottom: 199,restoreCommand: 6,flags: 64,waitFrames: 1),
            .init(resource: 17,x: 34,y: 148,right: 79,bottom: 199,restoreCommand: 7,flags: 64,waitFrames: 4),
            .init(resource: 18,x: 34,y: 148,right: 79,bottom: 199,restoreCommand: 8,flags: 64,waitFrames: 7),
            .init(resource: 17,x: 34,y: 148,right: 79,bottom: 199,restoreCommand: 9,flags: 64,waitFrames: 1),
            .init(resource: 19,x: 34,y: 147,right: 79,bottom: 199,restoreCommand: 10,flags: 64,waitFrames: 1),
            .init(resource: 20,x: 34,y: 147,right: 79,bottom: 199,restoreCommand: 11,flags: 64,waitFrames: 1),
            .init(resource: 21,x: 36,y: 146,right: 79,bottom: 199,restoreCommand: 12,flags: 64,waitFrames: 1),
            .init(resource: 22,x: 36,y: 145,right: 79,bottom: 199,restoreCommand: 13,flags: 64,waitFrames: 1),
            .init(resource: 23,x: 38,y: 142,right: 79,bottom: 199,restoreCommand: 14,flags: 64,waitFrames: 1),
            .init(resource: 24,x: 36,y: 139,right: 79,bottom: 199,restoreCommand: 15,flags: 64,waitFrames: 1),
            .init(resource: 25,x: 34,y: 121,right: 79,bottom: 199,restoreCommand: 16,flags: 64,waitFrames: 1),
            .init(resource: 26,x: 34,y: 121,right: 79,bottom: 199,restoreCommand: 17,flags: 64,waitFrames: 1),
            .init(resource: 27,x: 0,y: 0,right: 79,bottom: 199,restoreCommand: 0,flags: 0,waitFrames: 1),
        ],
    ]
    static let scriptDurations = [320,160,1080]
}

struct NativeOpeningPresentation {
    enum Stage { case title, objectiveWipe, objective, tellyWipe, telly, animationWipe, animation, finished }
    enum Cue: Equatable { case sound(Int), stop, finished }
    var stage = Stage.title
    var elapsed = 0
    var appliedSounds = 0
    var showingPage: Bool { [.title,.objective,.telly].contains(stage) }
    var animating: Bool { [.animationWipe,.animation].contains(stage) }
    var duration: Int {
        switch stage {
        case .title,.objective,.telly: return OriginalOpening.pageWait
        case .objectiveWipe,.tellyWipe,.animationWipe: return OriginalOpening.wipeWait
        case .animation: return OriginalOpening.scriptDurations.reduce(0,+)
        case .finished: return 0
        }
    }
    var sounds: [(at: Int,cue: Cue)] {
        var events: [(Int,Cue)] = [],time = 0
        for (index,script) in OriginalOpening.scripts.enumerated() {
            if index > 0 { events += [(time,.stop),(time,.sound(0))] }
            for command in script {
                if command.resource == -2 { events += [(time,.stop),(time,.sound(command.x))] }
                if command.resource >= 0 { time += command.waitFrames*OriginalOpening.frameWait }
            }
        }
        events += [(time,.stop)]
        return events
    }
    mutating func enter() {
        switch stage {
        case .title: stage = .objectiveWipe
        case .objective: stage = .tellyWipe
        case .telly: stage = .animationWipe
        default: return
        }
        elapsed = 0
    }
    mutating func restartWait() { if showingPage { elapsed = 0 } }
    mutating func advance(_ ticks: Int) -> [Cue] {
        var remaining = max(0,ticks),cues: [Cue] = []
        while stage != .finished {
            let amount = min(remaining,duration-elapsed)
            elapsed += amount;remaining -= amount
            if stage == .animation {
                let end = sounds.prefix(while: { $0.at <= elapsed }).count
                cues += sounds[appliedSounds..<end].map(\.cue);appliedSounds = end
            }
            if elapsed < duration { break }
            switch stage {
            case .title: stage = .objectiveWipe
            case .objectiveWipe: stage = .objective
            case .objective: stage = .tellyWipe
            case .tellyWipe: stage = .telly
            case .telly: stage = .title
            case .animationWipe: stage = .animation
            case .animation: stage = .finished;cues.append(.finished)
            case .finished: break
            }
            elapsed = 0
            if remaining == 0 && stage != .animation { break }
        }
        return cues
    }
}

extension NativeGameView {
    func resetOpening() {
        opening = NativeOpeningPresentation();openingLastPulse = ProcessInfo.processInfo.systemUptime;openingFraction = 0
    }
    func openingKey(_ event: NSEvent) {
        if event.keyCode == 36 && !event.isARepeat && opening.showingPage { opening.enter() }
        else if event.keyCode == 53 && opening.showingPage {
            modalDepth += 1
            let alert = NSAlert();alert.messageText = "Exit Program?"
            alert.addButton(withTitle: "No");alert.addButton(withTitle: "Yes")
            let choice = alert.runModal();modalDepth -= 1
            opening.restartWait()
            if choice == .alertSecondButtonReturn { NSApplication.shared.terminate(nil) }
        } else { return }
        openingLastPulse = ProcessInfo.processInfo.systemUptime;openingFraction = 0;needsDisplay = true
    }
    func advanceOpening(_ ticks: Int) {
        for cue in opening.advance(ticks) {
            switch cue {
            case let .sound(index): effect(index)
            case .stop: sound?.stop();lastSoundIndex = nil
            case .finished: choosePlayer()
            }
        }
        needsDisplay = true
    }
    func pulseOpening() {
        let now = ProcessInfo.processInfo.systemUptime
        defer { openingLastPulse = now }
        guard modalDepth == 0 else { return }
        let value = max(0,now-openingLastPulse)*VerifiedClock.pitInputHz/VerifiedClock.pitDivisor+openingFraction
        let whole = min(Int(value.rounded(.down)),100_000);openingFraction = value-Double(whole)
        advanceOpening(whole)
    }
    func drawOpening() throws {
        let bitmap = try content.bitmap("OPENING.GRA.000")
        canvas.draw(bitmap,x: 0,y: 0)
        let font = try content.font("MOCKET.DAT.1393"),prompt = "Press \u{85} to continue."
        switch opening.stage {
        case .title:
            canvas.text(prompt,font: font,x: 40,y: 146,color: 1)
        case .objectiveWipe,.tellyWipe,.animationWipe:
            canvas.fill(18,16,219,144,7)
        case .objective,.telly:
            canvas.fill(18,16,219,144,15)
            let first = opening.stage == .objective ? 0 : 12
            for row in 0..<12 { canvas.text(OriginalOpening.lines[first+row],font: font,x: 26,y: 18+row*10,color: 1) }
            canvas.draw(try content.bitmap(opening.stage == .objective ? "OPENING.GRA.028" : "OPENING.GRA.029"),x: 160,y: 30,transparent: true)
            canvas.text(prompt,font: font,x: 40,y: 145,color: 1)
        case .animation:
            var index = 0,time = opening.elapsed
            while index < 2 && time >= OriginalOpening.scriptDurations[index] { time -= OriginalOpening.scriptDurations[index];index += 1 }
            let background = try content.bitmap(index == 0 ? "OPENING.GRA.000" : "OPENING.GRA.027")
            let backing = NativeCanvas();backing.draw(background,x: 0,y: 0)
            let original = backing.pixels
            canvas.draw(background,x: 0,y: 0)
            var at = 0
            let commands = OriginalOpening.scripts[index]
            for command in commands {
                if at > time { break }
                if command.resource == -1 {
                    backing.restoreEndingRect(original,x: command.x*4,y: command.y,right: command.right*4+3,bottom: command.bottom)
                } else if command.resource >= 0 {
                    if command.restoreCommand > 0 {
                        let prior = commands[command.restoreCommand-1]
                        backing.restoreEndingRect(original,x: prior.x*4,y: prior.y,right: prior.right*4+3,bottom: prior.bottom)
                    }
                    backing.draw(try content.bitmap(String(format: "OPENING.GRA.%03d",command.resource)),x: command.x*4,y: command.y,transparent: command.flags & 64 != 0)
                    if command.waitFrames > 0 {
                        //Original callbacks copy right136 pixels for script0,
                        //then left312×199 for the station arrival/door scripts.
                        canvas.restoreEndingRect(backing.pixels,x: index == 0 ? 184 : 0,y: 0,right: index == 0 ? 319 : 311,bottom: index == 0 ? 199 : 198)
                        at += command.waitFrames*OriginalOpening.frameWait
                    }
                }
            }
        case .finished: canvas.draw(try content.bitmap("OPENING.GRA.027"),x: 0,y: 0)
        }
    }
}
