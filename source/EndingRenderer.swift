import Foundation

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
        if ending.reason == .midnight { try drawWorld();try drawEndingMeter(ticks: ending.elapsedTicks);return }
        let timeline = EndingTimeline(ending,data: endingData)
        if let rankStart = timeline.events.first(where: { if case .rankStart = $0.action { return true };return false }),ending.elapsedTicks >= rankStart.ticks {
            try drawRankPresentation(ending,ticks: ending.elapsedTicks-rankStart.ticks,showPrompt: false);return
        }
        canvas.clip = (0,15,320,145)
        let background = endingData.hallways[ending.room]+190
        canvas.draw(try content.bitmap(String(format: "DMOCKET.GRA.%04x",background)),x: 0,y: 15)
        canvas.draw(try content.bitmap("DMOCKET.GRA.1b58"),x: 152,y: 22,transparent: true)
        var base = canvas.pixels
        var caption: (String,Int,Int)?
        var bonus: (String,Int,Int)?
        var bonusClosing: Int?
        func restore(_ command: OriginalEndingData.Command) {
            canvas.restoreEndingRect(base,x: command.x*4,y: command.y,right: command.right*4+3,bottom: command.bottom)
        }
        func sprite(_ id: Int,_ x: Int,_ y: Int,_ flags: Int = 64) throws {
            let file = id < 10000 ? "FASTLOAD.GRA" : (ending.won ? "CLOSE1.GRA" : "CLOSE2.GRA")
            let index = id < 10000 ? id : id-10000
            canvas.draw(try content.bitmap(String(format: "%@.%03d",file,index)),x: x*4,y: y,transparent: flags&64 != 0,flipped: flags&32 != 0)
        }
        for event in timeline.events where event.ticks <= ending.elapsedTicks {
            switch event.action {
            case let .command(command,commands):
                if command.resource == -1 { restore(command) }
                else if command.resource >= 0 {
                    if command.restoreCommand > 0 { restore(commands[command.restoreCommand-1]) }
                    try sprite(command.resource,command.x,command.y,command.flags)
                }
            case .snapshot: base = canvas.pixels
            case .restoreAll: canvas.restoreEndingRect(base,x: 0,y: 15,right: 319,bottom: 159)
            case .restorePeek: canvas.restoreEndingRect(base,x: 96,y: 20,right: 219,bottom: 100)
            case let .sprite(id,x,y): try sprite(id,x,y)
            case let .caption(text,x,y): caption = (text,x,y)
            case .clearCaption: caption = nil
            case let .bonus(label,amount): bonus = (label,amount,event.ticks)
            case .bonusClosing: bonusClosing = event.ticks
            case .hideBonus: bonus = nil
            case let .clip(right): canvas.clip = (0,15,right,145)
            case .tally, .sound, .meterStart, .rankStart, .stopSound: break
            }
        }
        canvas.clip = nil
        if let caption { canvas.text(caption.0,font: try content.font("MOCKET.DAT.1393"),x: caption.1,y: caption.2,color: 1,lineHeight: 10) }
        if let meter = timeline.events.first(where: { if case .meterStart = $0.action { return true };return false }),ending.elapsedTicks >= meter.ticks {
            try drawEndingMeter(ticks: ending.elapsedTicks-meter.ticks)
        }
        if let bonus {
            let underBonus = canvas.pixels
            canvas.fill(64,16,192,60,1); canvas.fill(69,17,182,57,bonus.0 == "Winning Game" ? 12 : 14); canvas.fill(74,20,172,51,bonus.0 == "Winning Game" ? 1 : 11)
            canvas.fill(78,23,164,45,12); canvas.fill(84,52,152,15,9); canvas.fill(86,53,148,13,1)
            let titleFont = try content.font("MOCKET.DAT.1392"), title = "! & % ( '"
            for offset in 0..<6 { canvas.text(title,font: titleFont,x: 160-titleFont.width(of: title)/2+offset,y: 31-offset,color: 1) }
            canvas.text(title,font: titleFont,x: 166-titleFont.width(of: title)/2,y: 25,color: bonus.0 == "Winning Game" ? 14 : 15)
            let text = bonus.0+": "+Int(bonus.1).formatted(.number.grouping(.automatic))
            let font = try content.font("MOCKET.DAT.1393")
            canvas.text(text,font: font,x: 160-font.width(of: text)/2,y: 54,color: 15)
            //14df2/14d28 copy a progressively cropped offscreen panel to
            //fixed64,16. They do not translate it below the top of the room.
            let crop: Int,height: Int
            if let start = bonusClosing {
                let frame = min(58,max(0,(ending.elapsedTicks-start)/5))
                crop = 16+frame;height = 59-frame
            } else if bonus.0 == "Energy Left" && ending.elapsedTicks-bonus.2 < 295 {
                let frame = min(58,max(0,(ending.elapsedTicks-bonus.2)/5))
                crop = 74-frame;height = 2+frame
            } else { crop = 16;height = 60 }
            if crop != 16 || height != 60 {
                let panel = canvas.pixels
                canvas.restoreEndingRect(underBonus,x: 64,y: 16,right: 255,bottom: 75)
                for y in 0..<height { for x in 64...255 { canvas.pixel(x,16+y,panel[(crop+y)*320+x]) } }
            }
        }
    }
    func drawResults() throws {
        if session.activeEnding?.won != true {
            try drawEnding()
            let font = try content.font("MOCKET.DAT.1393")
            canvas.text("Press \u{85} to continue.",font: font,x: 20,y: 180,color: 15)
            return
        }
        guard let ending = session.activeEnding else { return }
        let rank = OriginalRankTimeline(lifetime: endingFinalLifetime(ending),data: endingData)
        try drawRankPresentation(ending,ticks: rank.duration,showPrompt: true)
    }
}
