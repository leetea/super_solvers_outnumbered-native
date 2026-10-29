import Foundation

struct OriginalEndingData: Decodable {
    struct Command: Decodable {
        let resource: Int, x: Int, y: Int, right: Int, bottom: Int
        let restoreCommand: Int, flags: Int, waitFrames: Int
    }
    struct Script: Decodable { let name: String, frame_ticks: Int; let commands: [Command] }
    let scripts: [Script]
    let hallways: [Int], victory_steps: [Int], dialogues: [String]
}

struct NativeEnding: Codable {
    enum Reason: String,Codable { case hideout, wrongHideout, midnight }
    let reason: Reason
    let room: Int, tier: Int, initialEnergy: Int, initialMinutes: Int
    let initialScore: UInt16
    let initialLifetime: Int
    let playerDialogue: Int, masterDialogue: Int
    var elapsedTicks = 0
    var committed = false
    var won: Bool { reason == .hideout }
    var valid: Bool {
        (0..<5).contains(room) && (0..<4).contains(tier) && (0...127).contains(initialEnergy) &&
        (0...180).contains(initialMinutes) && (0...9_999_999).contains(initialLifetime) &&
        (0..<2).contains(playerDialogue) && (0..<2).contains(masterDialogue) && (0...200_000).contains(elapsedTicks)
    }
}

struct EndingTimeline {
    enum Action {
        case command(OriginalEndingData.Command,[OriginalEndingData.Command])
        case snapshot, restoreAll, restorePeek
        case sprite(Int,Int,Int), caption(String,Int,Int), clearCaption
        case bonus(String,Int), hideBonus
        case tally(energy: Int,minutes: Int,score: Int)
        case sound(Int), clip(Int), meterStart, rankStart, stopSound, bonusClosing
    }
    struct Event { let ticks: Int; let action: Action }
    struct Totals {
        var energy: Int, minutes: Int, score: UInt16
        let lifetime: Int
    }
    let events: [Event]
    let duration: Int
    let ending: NativeEnding
    init(_ ending: NativeEnding,data: OriginalEndingData) {
        self.ending = ending
        var events: [Event] = [], time = 0
        func add(_ action: Action) { events.append(Event(ticks: time,action: action)) }
        func wait(_ ticks: Int) { time += ticks }
        func script(_ name: String) {
            let script = data.scripts.first { $0.name == name }!
            for command in script.commands {
                add(.command(command,script.commands))
                if command.resource >= 0 { wait(script.frame_ticks*command.waitFrames) }
            }
        }
        func update(energy: Int = 0,minutes: Int = 0,score: Int = 0,sound: Int? = 37) {
            add(.tally(energy: energy,minutes: minutes,score: score))
            if let sound { add(.sound(sound)) }
            // Original11b0:0f87 iterates quotient+1 times: a change followed
            // by a zero remainder. Both iterations wait ten IRQ ticks.
            wait(20)
        }
        if ending.reason == .midnight {
            // Original11b0:109e clears score/energy, flashes the empty meter
            // five times (100 ticks per half), then opens the replay prompt.
            add(.tally(energy: -ending.initialEnergy,minutes: 0,score: -Int(ending.initialScore)))
            add(.meterStart)
            for _ in 0..<10 { add(.sound(49)); wait(100) }
            self.events = events; duration = time; return
        }
        add(.sound(3)); script("enter_room"); add(.snapshot)
        add(.sprite(ending.won ? 10027 : 10013,24,20))
        add(.caption(data.dialogues[ending.playerDialogue],ending.playerDialogue == 0 ? 106 : 108,ending.playerDialogue == 0 ? 25 : 28))
        wait(960); add(.clearCaption); add(.restorePeek)
        script(ending.won ? "room_correct" : "room_wrong")
        add(.sound(17))
        if ending.won {
            script("found"); add(.snapshot); add(.clip(308)); script("reveal"); add(.clip(316))
            add(.sprite(10043,48,25))
            add(.caption(data.dialogues[2+ending.masterDialogue],210,ending.masterDialogue == 0 ? 31 : 29))
            wait(700); add(.clearCaption); add(.restoreAll)
            script("bonus_draw")
            let tuning = VerifiedScore.tuning[ending.tier]
            add(.bonus("Energy Left",ending.initialEnergy*tuning.perEnergy))
            for _ in 0..<59 { add(.sound(46));wait(5) }
            wait(240)
            for _ in 0..<ending.initialEnergy { update(energy: -1); update(score: tuning.perEnergy) }
            script("bonus_switch")
            add(.bonus("Time Left",(180-ending.initialMinutes)*tuning.perMinute)); wait(240)
            var minutes = 180-ending.initialMinutes
            while minutes > 0 {
                let step = min(15,minutes); update(minutes: step); update(score: step*tuning.perMinute); minutes -= step
            }
            script("bonus_switch"); add(.bonus("Winning Game",tuning.victoryBonus)); wait(240)
            // Original rank function runs before lifetime points are committed.
            let increment = data.victory_steps[ending.tier]
            for _ in stride(from: 0,to: tuning.victoryBonus,by: increment) { update(score: increment) }
            add(.bonusClosing)
            for _ in 0..<59 { add(.sound(47));add(.sound(47));wait(5) }
            add(.hideBonus);script("bonus_close")
            let finalScore = VerifiedScore.winningScore(sessionScore: ending.initialScore,rank: VerifiedRank.allCases[ending.tier*2],energy: ending.initialEnergy,minutesRemaining: 180-ending.initialMinutes)!
            let lifetime = VerifiedScore.lifetimeAfterSession(current: ending.initialLifetime,sessionScore: finalScore,won: true)
            if lifetime >= 500_000 { script("champion"); script("champion_transform"); script("champion_return") }
            else { script("congratulate") }
            script("departure")
            add(.rankStart)
            let rank = OriginalRankTimeline(lifetime: lifetime,data: data),start = time
            for event in rank.events {
                switch event.action {
                case .sound(let index): events.append(Event(ticks: start+event.ticks,action: .sound(index)))
                case .stop: events.append(Event(ticks: start+event.ticks,action: .stopSound))
                case .command(let c,_): if c.resource == -2 { events.append(Event(ticks: start+event.ticks,action: .command(c,[]))) }
                default: break
                }
            }
            wait(rank.duration)
        } else {
            script("loss")
            add(.caption(data.dialogues[4+ending.masterDialogue],ending.masterDialogue == 0 ? 31 : 33,ending.masterDialogue == 0 ? 50 : 51))
            for _ in 0..<ending.initialEnergy { update(energy: -1,sound: nil) }
            let hour = 9+ending.initialMinutes/60, minute = ending.initialMinutes%60
            let clockAdvance = max(0,(11-hour)*60+minute)
            for index in 0...clockAdvance/10 {
                add(.tally(energy: 0,minutes: index == clockAdvance/10 ? clockAdvance%10 : 10,score: 0)); wait(20)
            }
            add(.tally(energy: 0,minutes: 0,score: -Int(ending.initialScore)))
            add(.meterStart)
            for _ in 0..<10 { add(.sound(49));wait(100) }
        }
        self.events = events; duration = time
    }
    func totals(at ticks: Int) -> Totals {
        var energy = ending.initialEnergy, minutes = ending.initialMinutes, score = ending.initialScore
        for event in events where event.ticks <= ticks {
            if case let .tally(e,m,s) = event.action { energy += e; minutes += m; score = VerifiedScore.adding(s,to: score) }
        }
        return Totals(energy: energy,minutes: min(180,minutes),score: score,lifetime: VerifiedScore.lifetimeAfterSession(current: ending.initialLifetime,sessionScore: score,won: ending.won && ticks >= duration))
    }
    func sounds(after old: Int,through new: Int) -> [(index: Int,interrupt: Bool)] {
        events.compactMap { event in
            guard event.ticks > old && event.ticks <= new else { return nil }
            if case let .sound(index) = event.action { return (index,false) }
            if case .stopSound = event.action { return (-1,true) }
            if case let .command(command,_) = event.action, command.resource == -2 { return (command.x,true) }
            return nil
        }
    }
}
