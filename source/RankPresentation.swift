import Cocoa

//147d:01cf,0000,006a,00b5. Original data is composed natively.
struct OriginalRankTimeline {
    enum Action { case command(OriginalEndingData.Command,[OriginalEndingData.Command]), line(Int), band(Int,UInt8), sound(Int), stop }
    struct Event { let ticks: Int;let action: Action }
    static let textY = [163,148,132,115,93,69,43,13]
    static let bottom = [174,159,143,126,104,80,54,23]
    static let top = [162,147,131,114,92,68,42,11]
    let events: [Event],duration: Int
    init(lifetime: Int,data: OriginalEndingData) {
        var events: [Event] = [],time = 0
        func add(_ action: Action) { events.append(Event(ticks: time,action: action)) }
        func script(_ name: String) {
            let s = data.scripts.first { $0.name == name }!
            for c in s.commands {
                add(.command(c,s.commands));if c.resource >= 0 { time += c.waitFrames*s.frame_ticks }
            }
        }
        add(.sound(16));script("trophy_intro")
        for level in stride(from: 7,through: 1,by: -1) {
            for row in (Self.bottom[level]+1)..<Self.top[level-1] { add(.line(row));time += 10 }
        }
        let rank = VerifiedRank.allCases.firstIndex(of: VerifiedRank.forLifetimePoints(lifetime))!
        for level in 0...rank {
            add(.sound(26))
            for color in [UInt8(12),11,12] { add(.band(level,color));time += 40 }
            add(.stop)
        }
        if rank == 7 { script("trophy_champion") }
        self.events = events;duration = time
    }
}

extension NativeGameView {
    func endingFinalLifetime(_ ending: NativeEnding) -> Int {
        let score = VerifiedScore.winningScore(sessionScore: ending.initialScore,rank: VerifiedRank.allCases[ending.tier*2],energy: ending.initialEnergy,minutesRemaining: 180-ending.initialMinutes)!
        return VerifiedScore.lifetimeAfterSession(current: ending.initialLifetime,sessionScore: score,won: true)
    }
    func drawTrophyBase(_ ending: NativeEnding) throws {
        canvas.clip = nil;canvas.clear(1)
        for (index,y) in [(0,0),(16,45),(17,90),(18,134)] {
            canvas.draw(try content.bitmap(String(format: "TROPHY.GRA.%03d",index)),x: 0,y: y)
        }
        canvas.fill(0,175,320,2,12)
        let font = try content.font("MOCKET.DAT.1393")
        canvas.text("Points",font: font,x: 212,y: 0,color: 15);canvas.text("Rank",font: font,x: 267,y: 0,color: 14)
        canvas.fill(191,11,129,1,14)
        for i in 0..<8 {
            let points = OriginalScoreTable.formatted(VerifiedRank.thresholds[i])
            canvas.text(points,font: font,x: 250-font.width(of: points)-1,y: OriginalRankTimeline.textY[i],color: 15)
            canvas.text(VerifiedRank.allCases[i].rawValue,font: font,x: 255,y: OriginalRankTimeline.textY[i],color: 14)
        }
        let name = profileStore.document.profiles.first { $0.id == session.profileID }?.name ?? "Player"
        canvas.text(name,font: font,x: 28+(90-font.width(of: name)-1)/2,y: 113,color: 1)
        let score = EndingTimeline(ending,data: endingData).totals(at: 200_000).score
        for (label,value,y) in [("Game",Int(score),129),("Total",endingFinalLifetime(ending),141)] {
            canvas.text(label,font: font,x: 22,y: y,color: 1)
            let text = OriginalScoreTable.formatted(value)
            canvas.text(text,font: font,x: 123-font.width(of: text)-1,y: y,color: 1)
        }
    }
    func drawRankPresentation(_ ending: NativeEnding,ticks: Int,showPrompt: Bool) throws {
        try drawTrophyBase(ending)
        let originalBase = canvas.pixels
        let timeline = OriginalRankTimeline(lifetime: endingFinalLifetime(ending),data: endingData)
        for event in timeline.events where event.ticks <= ticks {
            switch event.action {
            case .line(let y): canvas.fill(160,y,1,1,12)
            case .band(let level,let color):
                let bottom = OriginalRankTimeline.bottom[level],top = OriginalRankTimeline.top[level]
                for y in stride(from: bottom-1,through: top+1,by: -1) {
                    let row = bottom-1-y;canvas.fill(160-row,y,1+2*row,1,color)
                }
            case .command(let c,let commands):
                let restore: OriginalEndingData.Command?
                if c.resource == -1 { restore = c }
                else if c.resource >= 0,c.restoreCommand > 0 { restore = commands[c.restoreCommand-1] }
                else { restore = nil }
                if let r = restore { canvas.restoreEndingRect(originalBase,x: r.x*4,y: r.y,right: r.right*4+3,bottom: r.bottom) }
                if c.resource >= 0 { canvas.draw(try content.bitmap(String(format: "TROPHY.GRA.%03d",c.resource-10000)),x: c.x*4,y: c.y,transparent: c.flags&64 != 0) }
            case .sound,.stop: break
            }
        }
        if showPrompt {
            //158e4 uses fixed x20, not centered text.
            canvas.text("Press \u{85} to continue.",font: try content.font("MOCKET.DAT.1393"),x: 20,y: 180,color: 15)
        }
    }
    func drawEndingMeter(ticks: Int) throws {
        //12b0c saves75 at252,163 and alternates its interior with74.
        if (ticks/100)%2 == 1 { try sprite(74,x: 252,y: 163,transparent: true) }
        else {
            canvas.clip = (256,164,56,14)
            try sprite(75,x: 252,y: 163,transparent: true);canvas.clip = nil
        }
    }
}
