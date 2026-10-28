import Foundation

struct OriginalActivityRow: Codable,Equatable {
    let name: String
    let labelY: Int, valueY: Int
    let first: Int, second: Int
    let third: Int?
    let unit: String
    let splitLabel: Bool
}

// Original compiled music/supply modules draw auxiliary random values AFTER
// question generation. Keep those values out of render(), and persist them.
struct OriginalActivityState: Codable,Equatable {
    let hotspot: Int, challengeID: Int, seed: Int, variant: Int
    let rows: [OriginalActivityRow]
    func matches(_ challenge: OriginalChallenge) -> Bool {
        hotspot == challenge.hotspot && challengeID == challenge.id && seed == challenge.seed && variant == challenge.variant
    }
    var valid: Bool {
        [4,7].contains(hotspot) && (7...8).contains(rows.count) && rows.allSatisfy {
            $0.name.utf8.count < 80 && $0.unit.utf8.count < 32 && (19...154).contains($0.labelY) &&
            (19...154).contains($0.valueY) && (0...32767).contains($0.first) && (0...32767).contains($0.second) &&
            (hotspot == 4 ? $0.third == nil : $0.third.map { (0...32767).contains($0) } == true)
        }
    }
    static func make(_ challenge: OriginalChallenge,nextRandom: () -> Int) throws -> OriginalActivityState {
        func word(_ index: Int) throws -> Int { try challenge.originalWord(at: index) }
        func string(_ index: Int) throws -> String { try challenge.originalString(at: index) }
        func draw(_ low: Int,_ high: Int) throws -> Int {
            let value = nextRandom()
            guard (0...32767).contains(value), low <= high else { throw ContentError.invalid("Invalid original drawing random interval") }
            return low+value%(high-low+1)
        }
        var rows: [OriginalActivityRow] = []
        if challenge.hotspot == 4 {
            let firstRow = try word(2), secondRow = try word(3), extra = try word(20) > 7
            guard (0..<8).contains(firstRow), (0..<8).contains(secondRow), firstRow != secondRow else { throw ContentError.invalid("Invalid original song selection") }
            var first = [Int](), second = [Int](), names = [String](), filler = 14
            var used = [try word(4),try word(6)]
            if extra { used.append(try word(22)) }
            for row in 0..<8 {
                if row == firstRow { names.append(try string(12)) }
                else if row == secondRow { names.append(try string(13)) }
                else { names.append(try string(filler)); filler += 1 }
                if row == firstRow { first.append(try word(4)) }
                else if row == secondRow { first.append(try word(6)) }
                else if row == 2 && extra { first.append(try word(22)) }
                else {
                    var value = 0, attempts = 0
                    repeat { value = try draw(word(8),word(9)); attempts += 1 } while used.contains(value) && attempts < 10000
                    guard !used.contains(value) else { throw ContentError.invalid("Original unique drawing range exhausted") }
                    first.append(value); used.append(value)
                }
            }
            for row in 0..<8 {
                if row == firstRow { second.append(try word(5)) }
                else if row == secondRow { second.append(try word(7)) }
                else if row == 2 && extra { second.append(try word(23)) }
                else { second.append(try draw(word(10),word(11))) }
                rows.append(OriginalActivityRow(name: names[row],labelY: 65+row*11,valueY: 65+row*11,first: first[row],second: second[row],third: nil,unit: "",splitLabel: false))
            }
        } else if challenge.hotspot == 7 {
            let selected = try word(0), name = try string(10), split = name.contains(" ")
            guard (0..<8).contains(selected) else { throw ContentError.invalid("Invalid original equipment selection") }
            var positions: [(String,Int,Int,Bool,String)] = [], row = 0, filler = 0
            while row < 8 {
                let chosen = row == selected
                let title = chosen ? name : try string(11+filler)
                let unit = chosen ? try string(18) : try string(19+filler)
                positions.append((title,66+row*11,66+row*11+(chosen && split ? 5 : 0),chosen,unit.count == 1 ? "" : unit))
                if !chosen { filler += 1 }
                row += chosen && split ? name.filter { $0 == " " }.count+1 : 1
            }
            var quantities = [Int](), days = [Int](), costs = [Int]()
            for position in positions { quantities.append(position.3 ? try word(1) : try draw(word(4),word(5))) }
            for position in positions { days.append(position.3 ? try word(2) : try draw(word(6),word(7))) }
            for position in positions { costs.append(position.3 ? try word(3) : try draw(word(8),word(9))) }
            for (i,position) in positions.enumerated() { rows.append(OriginalActivityRow(name: position.0,labelY: position.1,valueY: position.2,first: quantities[i],second: days[i],third: costs[i],unit: position.4,splitLabel: position.3 && split)) }
        } else { throw ContentError.invalid("This activity has no original random drawing context") }
        let result = OriginalActivityState(hotspot: challenge.hotspot,challengeID: challenge.id,seed: challenge.seed,variant: challenge.variant,rows: rows)
        guard result.valid else { throw ContentError.invalid("Invalid recovered activity drawing state") }
        return result
    }
}

struct ActivityFinal {
    let content: OriginalContent
    static let supportedHotspots: Set<Int> = [3,4,7]
    func draw(_ challenge: OriginalChallenge,state: OriginalActivityState?,on canvas: NativeCanvas,progress: NativeActivityPlan.Frame? = nil) throws -> ActivityRenderSupport {
        canvas.draw(try content.bitmap(String(format: "TEMPLATE.GRA.%04x",challenge.bitmap_record_id)),x: 8,y: 19)
        if challenge.hotspot == 3 { try spinner(challenge,on: canvas,progress: progress) }
        else {
            guard let state, state.valid, state.matches(challenge) else { throw ContentError.invalid("Missing original activity drawing state") }
            if challenge.hotspot == 4 { try music(challenge,state: state,on: canvas) }
            else if challenge.hotspot == 7 { try equipment(challenge,state: state,on: canvas,progress: progress) }
            else { return .unsupported(template: challenge.bitmap_record_id-1,missing: "Unknown original activity") }
        }
        if challenge.hotspot == 4, progress?.marks.first == 12 {
            canvas.replaceActivityColor(left: 12,top: 36,right: 98,bottom: 54,from: 14,to: 12)
        }
        return .recoveredStatic(template: challenge.bitmap_record_id-1,omittedAnimation: "Native timelines restore spin/color effects; complete campaign RNG stream and driver palette details remain under validation")
    }
    private func spinner(_ challenge: OriginalChallenge,on canvas: NativeCanvas,progress: NativeActivityPlan.Frame?) throws {
        guard challenge.bitmap_record_id == 8511 else { throw ContentError.invalid("Unexpected original spinner bitmap") }
        let title = try challenge.originalString(at: 17), subtitle = try challenge.originalString(at: 18)
        let small = try content.font("MOCKET.DAT.1396"), large = try content.font("MOCKET.DAT.1395")
        var font = large
        if !title.hasPrefix(" ") {
            font = small
            canvas.text(title,font: small,x: 94-small.width(of: title)/2,y: 77,color: 1)
            if title == "LAST" { canvas.text("SPIN",font: small,x: 94-small.width(of: "SPIN")/2,y: 100,color: 1) }
            if subtitle.hasPrefix(" ") { canvas.fill(17,84,98,15,13) }
            else { font = large; canvas.text(subtitle,font: large,x: 94-large.width(of: subtitle)/2,y: 88,color: 1) }
        }
        let xs = [87,122,136,136,122,87,53,39,39,53], ys = [23,36,57,81,102,115,102,81,57,36]
        for i in 0..<10 {
            let text = String(try challenge.originalWord(at: 5+i))
            canvas.text(text,font: font,x: xs[i]+8-font.width(of: text)/2,y: ys[i]+19,color: 1)
        }
        let selected = try progress?.marks.first ?? challenge.originalWord(at: 2)
        guard (0..<10).contains(selected) else { throw ContentError.invalid("Invalid original spinner position") }
        let rectangles = [
            ([82,125,146,146,123,81,42,19,19,41],[13,28,52,82,108,127,109,83,53,29],[94,134,156,156,134,94,52,30,30,50],[18,36,62,91,116,132,117,92,63,37]),
            ([84,100,110,111,101,84,62,51,52,62],[36,45,61,74,89,97,89,75,61,45],[90,112,122,124,112,90,74,62,64,74],[47,54,66,80,98,108,98,80,66,54])]
        for rect in rectangles {
            for y in (rect.1[selected]+19)...(rect.3[selected]+19) {
                for x in (rect.0[selected]+8)...(rect.2[selected]+8) where canvas.pixels[y*320+x] == 14 { canvas.pixel(x,y,12) }
            }
        }
    }
    private func music(_ challenge: OriginalChallenge,state: OriginalActivityState,on canvas: NativeCanvas) throws {
        guard challenge.bitmap_record_id == 8507 else { throw ContentError.invalid("Unexpected original music bitmap") }
        let font = try content.font("MOCKET.DAT.1393"), small = try content.font("MOCKET.DAT.1396")
        canvas.text("Great Eight",font: font,x: 97-font.width(of: "Great Eight")/2,y: 20,color: 1)
        canvas.text("Song",font: small,x: (113-small.width(of: "Song"))/2,y: 42,color: 1)
        let headings = [["Last","Wk's","Pos."],["Weeks","on","Chart"],["Calls","This","Week"],["Calls","Last","Month"]]
        for column in 0..<2 {
            let selector = try challenge.originalWord(at: column)-3
            guard headings.indices.contains(selector) else { throw ContentError.invalid("Invalid original music heading") }
            for row in 0..<3 {
                let text = headings[selector][row]
                let x = column == 0 ? (247-small.width(of: text))/2 : (327-small.width(of: text))/2
                canvas.text(text,font: small,x: x,y: [33,42,50][row],color: 1)
            }
        }
        let right1 = (247+small.width(of: String(try challenge.originalWord(at: 9))))/2
        let right2 = (327+small.width(of: String(try challenge.originalWord(at: 11))))/2
        for (i,row) in state.rows.enumerated() {
            canvas.text("\(i+1).",font: small,x: 13,y: row.labelY,color: 1)
            canvas.text(row.name,font: small,x: 23,y: row.labelY,color: 1)
            let first = String(row.first), second = String(row.second)
            canvas.text(first,font: small,x: right1-small.width(of: first),y: row.valueY,color: 1)
            canvas.text(second,font: small,x: right2-small.width(of: second),y: row.valueY,color: 1)
        }
    }
    private func equipment(_ challenge: OriginalChallenge,state: OriginalActivityState,on canvas: NativeCanvas,progress: NativeActivityPlan.Frame?) throws {
        guard challenge.bitmap_record_id == 8517 else { throw ContentError.invalid("Unexpected original equipment-list bitmap") }
        let font = try content.font("MOCKET.DAT.1393"), small = try content.font("MOCKET.DAT.1396")
        canvas.text("Equipment List",font: font,x: 97-font.width(of: "Equipment List")/2,y: 20,color: 1)
        let colors: [UInt8] = [13,11,14,10]
        let rotation = progress.map { ($0.marks[0]+1)%4 } ?? 0
        for (i,column) in [(10,49),(60,55),(116,31),(148,34)].enumerated() { canvas.fill(column.0,32,column.1,28,colors[(i+rotation)%4]) }
        for (text,y,sum,offset) in [("Item",41,71,0),("Quantity",37,177,0),("on Hand",46,177,0),("Days",37,265,0),("Used",46,265,0),("Cost",33,333,0),("per",41,333,1),("Item",50,333,0)] {
            canvas.text(text,font: small,x: (sum-small.width(of: text))/2+offset,y: y,color: 1)
        }
        let daysRight = (265+small.width(of: "180"))/2, costRight = (332+small.width(of: "$1500"))/2
        for row in state.rows {
            let parts = row.splitLabel ? row.name.components(separatedBy: " ") : [row.name]
            for (i,part) in parts.enumerated() { canvas.text((i == 0 ? "" : " ")+part,font: small,x: 12,y: row.labelY+i*11,color: 1) }
            let quantity = String(row.first)+row.unit, days = String(row.second), cost = String(row.third!)
            canvas.text(quantity,font: small,x: (177-small.width(of: quantity))/2,y: row.valueY,color: 1)
            canvas.text(days,font: small,x: daysRight-small.width(of: days),y: row.valueY,color: 1)
            canvas.text("$",font: small,x: costRight-small.width(of: "$1500"),y: row.valueY,color: 1)
            canvas.text(cost,font: small,x: costRight-small.width(of: cost),y: row.valueY,color: 1)
        }
    }
}
