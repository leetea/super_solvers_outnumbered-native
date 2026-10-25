import Cocoa

extension NativeCanvas {
    func restoreEndingRect(_ source: [UInt8],x: Int,y: Int,right: Int,bottom: Int) {
        guard source.count == Self.width*Self.height, x <= right, y <= bottom else { return }
        let left = max(0,x), top = max(0,y), endX = min(319,right), endY = min(199,bottom)
        guard left <= endX, top <= endY else { return }
        for row in top...endY { for column in left...endX { pixel(column,row,source[row*320+column]) } }
    }
}

extension NativeGameView {
    func drawEnding() throws {
        guard let ending = session.activeEnding else { return }
        if ending.reason == .midnight { try drawWorld(); return }
        let timeline = EndingTimeline(ending,data: endingData)
        canvas.clip = (0,15,320,145)
        let background = endingData.hallways[ending.room]+190
        canvas.draw(try content.bitmap(String(format: "DMOCKET.GRA.%04x",background)),x: 0,y: 15)
        canvas.draw(try content.bitmap("DMOCKET.GRA.1b58"),x: 152,y: 22,transparent: true)
        var base = canvas.pixels
        var caption: (String,Int,Int)?
        var bonus: (String,Int)?
        func restore(_ command: OriginalEndingData.Command) {
            canvas.restoreEndingRect(base,x: command.x*4,y: command.y,right: command.right*4+3,bottom: command.bottom)
        }
        func sprite(_ id: Int,_ x: Int,_ y: Int) throws {
            let file = id < 10000 ? "FASTLOAD.GRA" : (ending.won ? "CLOSE1.GRA" : "CLOSE2.GRA")
            let index = id < 10000 ? id : id-10000
            canvas.draw(try content.bitmap(String(format: "%@.%03d",file,index)),x: x*4,y: y,transparent: true)
        }
        for event in timeline.events where event.ticks <= ending.elapsedTicks {
            switch event.action {
            case let .command(command,commands):
                if command.resource == -1 { restore(command) }
                else if command.resource >= 0 {
                    if command.restoreCommand > 0 { restore(commands[command.restoreCommand-1]) }
                    try sprite(command.resource,command.x,command.y)
                }
            case .snapshot: base = canvas.pixels
            case .restoreAll: canvas.restoreEndingRect(base,x: 0,y: 15,right: 319,bottom: 159)
            case .restorePeek: canvas.restoreEndingRect(base,x: 96,y: 20,right: 219,bottom: 100)
            case let .sprite(id,x,y): try sprite(id,x,y)
            case let .caption(text,x,y): caption = (text,x,y)
            case .clearCaption: caption = nil
            case let .bonus(label,amount): bonus = (label,amount)
            case .hideBonus: bonus = nil
            case let .clip(right): canvas.clip = (0,15,right,145)
            case .tally, .sound: break
            }
        }
        canvas.clip = nil
        if let caption { canvas.text(caption.0,font: try content.font("MOCKET.DAT.1393"),x: caption.1,y: caption.2,color: 0,lineHeight: 10) }
        if let bonus {
            canvas.fill(64,16,192,60,0); canvas.fill(69,17,182,57,14); canvas.fill(74,20,172,51,11)
            canvas.fill(78,23,164,45,12); canvas.fill(84,52,152,15,8); canvas.fill(86,53,148,13,0)
            let titleFont = try content.font("MOCKET.DAT.1392"), title = "! & % ( '"
            for offset in 0..<6 { canvas.text(title,font: titleFont,x: 160-titleFont.width(of: title)/2+offset,y: 31-offset,color: 0) }
            canvas.text(title,font: titleFont,x: 166-titleFont.width(of: title)/2,y: 25,color: bonus.0 == "Winning Game" ? 14 : 15)
            let text = bonus.0+": "+Int(bonus.1).formatted(.number.grouping(.automatic))
            let font = try content.font("MOCKET.DAT.1393")
            canvas.text(text,font: font,x: 160-font.width(of: text)/2,y: 54,color: 15)
        }
    }
    func drawResults() throws {
        if session.activeEnding?.won != true {
            try drawEnding()
            let font = try content.font("MOCKET.DAT.1393")
            canvas.text("Press \u{85} to continue.",font: font,x: 20,y: 180,color: 15)
            return
        }
        canvas.clear(0)
        for (index,y) in [(0,0),(16,45),(17,90),(18,134)] {
            canvas.draw(try content.bitmap(String(format: "TROPHY.GRA.%03d",index)),x: 0,y: y)
        }
        let font = try content.font("MOCKET.DAT.1393"), small = try content.font("MOCKET.DAT.1396")
        canvas.text("Points",font: font,x: 212,y: 0,color: 15); canvas.text("Rank",font: font,x: 267,y: 0,color: 14)
        let ys = [163,148,132,115,93,69,43,13] // Original DS:0fb9
        for i in 0..<8 {
            let points = VerifiedRank.thresholds[i].formatted(.number.grouping(.automatic))
            canvas.text(points,font: small,x: 250-small.width(of: points),y: ys[i],color: 15)
            canvas.text(VerifiedRank.allCases[i].rawValue,font: small,x: 255,y: ys[i],color: 14)
        }
        let name = profileStore.document.profiles.first { $0.id == session.profileID }?.name ?? "Player"
        canvas.text(name,font: font,x: 73-font.width(of: name)/2,y: 113,color: 1)
        for (title,value,y) in [("Game",Int(session.score),129),("Total",session.lifetimePoints,141)] {
            canvas.text(title,font: font,x: 22,y: y,color: 1)
            let text = value.formatted(.number.grouping(.automatic))
            canvas.text(text,font: font,x: 123-font.width(of: text),y: y,color: 1)
        }
        let prompt = "Press \u{85} to continue."
        canvas.text(prompt,font: font,x: 160-font.width(of: prompt)/2,y: 187,color: 15)
    }
}
