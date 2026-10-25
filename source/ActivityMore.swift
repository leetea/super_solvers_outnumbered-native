import Foundation

// Direct Swift translations of recovered static endpoints of additional
// original activity drawing routines. No original machine code is interpreted.
struct ActivityMore {
    let content: OriginalContent
    static let supportedHotspots: Set<Int> = [1, 5, 8, 9]

    func draw(_ challenge: OriginalChallenge, on canvas: NativeCanvas) throws -> ActivityRenderSupport {
        switch challenge.hotspot {
        case 1:
            guard challenge.bitmap_record_id == 8503 else { throw ContentError.invalid("Unexpected original bar-chart bitmap") }
            try barChart(challenge,on: canvas)
            return .recoveredStatic(template: 8502,omittedAnimation: "Original upward bar-growth delays and sound; driver palette details remain under analysis")
        case 5:
            guard challenge.bitmap_record_id == 8509 else {
                throw ContentError.invalid("Unexpected original measurement bitmap")
            }
            try measurement(challenge, on: canvas)
            return .recoveredStatic(template: 8508, omittedAnimation: "Original incremental slider movement and backing-surface copy animation; driver masking remains under analysis")
        case 8:
            guard [8515,8521].contains(challenge.bitmap_record_id) else {
                throw ContentError.invalid("Unexpected original line-chart bitmap")
            }
            try lineChart(challenge, on: canvas)
            return .recoveredStatic(template: challenge.bitmap_record_id-1, omittedAnimation: "Original point-by-point plotting delays and sounds; driver palette details remain under analysis")
        case 9:
            guard challenge.bitmap_record_id == 8519 else {
                throw ContentError.invalid("Unexpected original cassette bitmap")
            }
            try cassettes(challenge, on: canvas)
            return .recoveredStatic(template: 8518, omittedAnimation: "Original timed cassette arrival and per-row audio effects; driver masking remains under analysis")
        default:
            return .unsupported(template: challenge.bitmap_record_id-1,
                                missing: "This original activity's dynamic graphics have not yet been translated.")
        }
    }

    private func background(_ challenge: OriginalChallenge, on canvas: NativeCanvas) throws {
        canvas.draw(try content.bitmap(String(format: "TEMPLATE.GRA.%04x", challenge.bitmap_record_id)), x: 8, y: 19)
    }

    private func barChart(_ challenge: OriginalChallenge,on canvas: NativeCanvas) throws {
        let count = try challenge.originalWord(at: 2), baseline = try challenge.originalWord(at: 8)
        let interval = try challenge.originalWord(at: 9), theme = try challenge.originalWord(at: 18)
        guard (1...5).contains(count), interval > 0, (0...3).contains(theme) else { throw ContentError.invalid("Invalid original bar-chart scale") }
        try background(challenge,on: canvas)
        let font = try content.font("MOCKET.DAT.1393"), small = try content.font("MOCKET.DAT.1396")
        for tick in 0..<6 {
            let text = String(baseline+tick*interval)
            canvas.text(text,font: small,x: max(0,44-small.width(of: text)),y: 121-16*tick,color: 0)
        }
        let vertical = try challenge.originalString(at: 16)
        var labelY = 85-(vertical.count*9-3)/2
        for letter in vertical {
            if letter == " " { labelY += 6 }
            else { let text = String(letter); canvas.text(text,font: font,x: 21-font.width(of: text)/2,y: labelY,color: 0); labelY += 9 }
        }
        let spacing = (121-count*17)/(count+1)
        for i in 0..<count {
            let text = try challenge.originalString(at: 10+i)
            canvas.text(text,font: small,x: (spacing+17)*i+spacing+56-small.width(of: text)/2,y: 127,color: 0)
        }
        let horizontal = try challenge.originalString(at: 15), title = try challenge.originalString(at: 17)
        canvas.text(horizontal,font: font,x: 108-font.width(of: horizontal)/2,y: 137,color: 0)
        canvas.text(title,font: font,x: 97-font.width(of: title)/2,y: 26,color: 0)
        for i in 0..<count {
            let value = try challenge.originalWord(at: 3+i)
            let left = 48+spacing+(17+spacing)*i, top = 125-(value-baseline)*16/interval
            guard (19...125).contains(top) else { throw ContentError.invalid("Original bar exceeds recovered chart extent") }
            //8502:0582 grows filled scanlines124 down through top. The
            //following15e3:01db call outlines inclusive bounds through125.
            canvas.fill(left,top,18,125-top,[3,5,2,12][theme])
            canvas.border(left,top,18,126-top,0)
        }
    }

    private func measurement(_ challenge: OriginalChallenge, on canvas: NativeCanvas) throws {
        let readings = try (24...26).map { try challenge.originalWord(at: $0) }
        guard readings.allSatisfy({ (0...9).contains($0) }) else {
            throw ContentError.invalid("Original measurement control is outside 0 through 9")
        }
        let title = try challenge.originalString(at: 9)
        try background(challenge, on: canvas)
        let font = try content.font("MOCKET.DAT.1393")
        // TEMPLATE8508 local0x0219..0x0250: title center99, top22.
        canvas.text(title, font: font, x: 99-font.width(of: title)/2, y: 22, color: 0)
        let centers = [34, 90, 146]
        let labels = ["100s", "10s", "1s"] // Original strings at8508:0x028c.
        let columns = [24, 80, 136] // Original table at8508:0x0280.
        let pointer = try content.bitmap("ROOMS.GRA.018")
        for index in 0..<3 {
            canvas.text(labels[index], font: font, x: centers[index]-font.width(of: labels[index])/2, y: 39, color: 0)
            // The original copies the column to a backing surface, starts at
            // row136, then moves one pixel upward for reading*9 increments.
            // Static endpoint is therefore136-reading*9. Relative cache10018
            // addresses ordinal18 of the appended ROOMS resource file.
            canvas.draw(pointer, x: columns[index], y: 136-readings[index]*9, transparent: true)
        }
    }

    private func cassettes(_ challenge: OriginalChallenge, on canvas: NativeCanvas) throws {
        let amounts = try (0..<4).map { try challenge.originalWord(at: $0) }
        guard amounts.allSatisfy({ $0 >= 0 }) else { throw ContentError.invalid("Negative original cassette amount") }
        let unit = try challenge.originalString(at: 4)
        try background(challenge, on: canvas)
        let font = try content.font("MOCKET.DAT.1396")
        let cassette = try content.bitmap("ROOMS.GRA.015")
        // TEMPLATE8518 draws relative cache10015 at byte-column14 (56px),
        // rows106,86,66,46. The initial letter'D' decreases with the loop.
        // Reversing the static traversal produces identical final placements.
        let names = ["A", "B", "C", "D"]
        for index in 0..<4 {
            let row = 46+index*20
            canvas.draw(cassette, x: 56, y: row)
            canvas.text(names[index], font: font, x: 83, y: row+5, color: 0)
            let number = String(amounts[index])
            canvas.text(number, font: font, x: 118-font.width(of: number), y: row+4, color: 0)
            canvas.text(unit, font: font, x: 130, y: row+4, color: 0)
        }
    }

    private func lineChart(_ challenge: OriginalChallenge, on canvas: NativeCanvas) throws {
        let compact = challenge.bitmap_record_id == 8521
        let count = try challenge.originalWord(at: 2)
        let baseline = try challenge.originalWord(at: 4)
        let interval = try challenge.originalWord(at: 5)
        guard (2...5).contains(count), interval > 0 else {
            throw ContentError.invalid("Invalid original line-chart scale")
        }
        let series = compact ? try challenge.originalWord(at: 3) : 1
        guard (1...2).contains(series) else { throw ContentError.invalid("Invalid original chart series count") }
        try background(challenge, on: canvas)
        let font = try content.font("MOCKET.DAT.1393")
        let small = try content.font("MOCKET.DAT.1396")
        let title = try challenge.originalString(at: 17)
        canvas.text(title, font: font, x: 101-font.width(of: title)/2, y: 22, color: 0)
        let verticalLabel = try challenge.originalString(at: 18)
        var labelY = max(compact ? 38 : 41, (compact ? 72 : 82)-verticalLabel.count*9/2)
        for letter in verticalLabel {
            if letter == " " { labelY += 6 }
            else {
                let text = String(letter)
                canvas.text(text, font: font, x: 23-font.width(of: text)/2, y: labelY, color: 0)
                labelY += 9
            }
        }
        let horizontalLabel = try challenge.originalString(at: 19)
        canvas.text(horizontalLabel, font: font, x: 109-font.width(of: horizontalLabel)/2, y: compact ? 120 : 137, color: 0)
        for tick in 0..<(compact ? 4 : 5) {
            let text = String(baseline+tick*interval)
            canvas.text(text, font: small, x: 49-small.width(of: text), y: (compact ? 93 : 110)-17*tick, color: 0)
        }
        // Identical four-entry spacing tables are embedded in8514:0630 and
        //8520:07cc. The plotting copies are at0640 and07dc respectively.
        let firstX = 53+[28,19,14,11][count-2]
        let spacing = [56,37,28,22][count-2]
        for index in 0..<count {
            let text = try challenge.originalString(at: 20+index)
            canvas.text(text, font: small, x: firstX+index*spacing-small.width(of: text)/2, y: compact ? 110 : 127, color: 0)
        }
        func y(_ value: Int) -> Int {
            let scaled = (value-baseline)*17
            // Original integer division and strict half-interval rounding.
            return (compact ? 97 : 114)-scaled/interval-(scaled%interval > interval/2 ? 1 : 0)
        }
        for seriesIndex in 0..<series {
            let color: UInt8 = seriesIndex == 0 ? 12 : 0
            let halfWidth = seriesIndex == 0 ? 1 : 0
            var previous: (Int,Int)?
            for index in 0..<count {
                let point = (firstX+index*spacing, y(try challenge.originalWord(at: (seriesIndex == 0 ? 6 : 11)+index)))
                if let previous { originalPlotLine(previous.0,previous.1,point.0,point.1,halfWidth: halfWidth,color:color,on:canvas) }
                let radius = seriesIndex == 0 ? 2 : 1
                canvas.fill(point.0-radius,point.1-radius,radius*2+1,radius*2+1,color)
                previous = point
            }
        }
        if compact && series > 1 {
            canvas.text(try challenge.originalString(at: 25), font: small, x: 53, y: 132, color: 0)
            canvas.text(try challenge.originalString(at: 26), font: small, x: 53, y: 142, color: 0)
            originalPlotLine(14,137,49,137,halfWidth:1,color:12,on:canvas)
            canvas.fill(14,147,36,1,0)
        }
    }

    // Explicit Swift translation of8514:045a /8520:05fa. The original
    // rasterizer emits vertical spans rather than a generic stroked path.
    private func originalPlotLine(_ ax: Int, _ ay: Int, _ bx: Int, _ by: Int,
                                  halfWidth: Int, color: UInt8, on canvas: NativeCanvas) {
        var x0=ax, y0=ay, x1=bx, y1=by
        let dx=abs(x1-x0), dy=abs(y1-y0)
        func point(_ x: Int, _ y: Int) { canvas.fill(x,y-halfWidth,1,halfWidth*2+1,color) }
        if dx < dy {
            if y1 < y0 { swap(&x0,&x1); swap(&y0,&y1) }
            let direction=x0<x1 ? 1 : -1
            var error=dx*2-dy
            point(x0,y0)
            if y0<y1 {
                for y in (y0+1)...y1 {
                    if error>=0 { x0+=direction; error+=(dx-dy)*2 }
                    else { error+=dx*2 }
                    point(x0,y)
                }
            }
        } else {
            if x1 < x0 { swap(&x0,&x1); swap(&y0,&y1) }
            let direction=y0<y1 ? 1 : -1
            var error=dy*2-dx
            var y=y0
            point(x0,y)
            if x0<x1 {
                for x in (x0+1)...x1 {
                    if error>=0 { y+=direction; error+=(dy-dx)*2 }
                    else { error+=dy*2 }
                    point(x,y)
                }
            }
        }
    }

}
