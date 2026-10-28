import Foundation

// Static activity content recovered from the original compiled TEMPLATE
// modules. This renders the data needed to solve the activity; it deliberately
// does not invent the still-unrecovered decorative introductory animations.
enum ActivityRenderSupport: Equatable {
    case recoveredStatic(template: Int, omittedAnimation: String)
    case unsupported(template: Int, missing: String)

    var limitations: [String] {
        switch self {
        case .recoveredStatic(let template, let animation):
            var result = [animation]
            if template == 8504 {
                result.append("Original prize background palette and driver masking differ from the local recording and remain under analysis.")
            }
            return result
        case .unsupported(_, let missing):
            return [missing]
        }
    }

    var providesActivityContext: Bool {
        if case .recoveredStatic = self { return true }
        return false
    }
}

extension OriginalChallenge {
    // Original compiled templates receive one flattened far-pointer array. Each
    // pointer addresses one generated item, in group and item order.
    private func originalItem(at index: Int) throws -> [UInt8] {
        guard index >= 0 else { throw ContentError.invalid("Negative original activity field") }
        var remaining = index
        for entry in groups {
            if remaining < entry.count {
                let bytes = entry.bytes(remaining)
                guard bytes.count == entry.item_size else {
                    throw ContentError.invalid("Invalid original activity field extent")
                }
                return bytes
            }
            remaining -= entry.count
        }
        throw ContentError.invalid("Missing original activity field \(index)")
    }

    func originalWord(at index: Int) throws -> Int {
        let bytes = try originalItem(at: index)
        guard bytes.count >= 2 else { throw ContentError.invalid("Truncated original activity number") }
        return Int(Int16(bitPattern: UInt16(bytes[0]) | UInt16(bytes[1]) << 8))
    }

    func originalString(at index: Int) throws -> String {
        let bytes = try originalItem(at: index)
        guard let terminator = bytes.firstIndex(of: 0),
              let string = String(bytes: bytes[..<terminator], encoding: .ascii) else {
            throw ContentError.invalid("Invalid original activity text")
        }
        return string
    }
}

struct ActivityTemplates {
    let content: OriginalContent
    static let supportedHotspots: Set<Int> = [2, 6]

    func draw(_ challenge: OriginalChallenge, on canvas: NativeCanvas,progress: NativeActivityPlan.Frame? = nil) throws -> ActivityRenderSupport {
        switch challenge.hotspot {
        case 2:
            guard challenge.bitmap_record_id == 8505 else {
                throw ContentError.invalid("Unexpected original prize-board bitmap")
            }
            try drawPrizeBoard(challenge, on: canvas,progress: progress)
            return .recoveredStatic(template: 8504, omittedAnimation: "Native timeline restores price flashes and source-color replacement; full driver palette details remain under analysis")
        case 6:
            guard challenge.bitmap_record_id == 8513 else {
                throw ContentError.invalid("Unexpected original television bitmap")
            }
            try drawTelevisionTable(challenge, on: canvas)
            if let progress { canvas.xorTelevisionNoise(progress.marks) }
            return .recoveredStatic(template: 8512, omittedAnimation: "Native timeline restores the60-step XOR effect and caller-stack random bounds; full driver palette/mask parity remains under analysis")
        default:
            return .unsupported(template: challenge.bitmap_record_id - 1,
                                missing: "Dynamic chart, label, scale or object drawing has not yet been translated from this original template.")
        }
    }

    private func background(_ challenge: OriginalChallenge, on canvas: NativeCanvas) throws {
        canvas.draw(try content.bitmap(String(format: "TEMPLATE.GRA.%04x", challenge.bitmap_record_id)), x: 8, y: 19)
    }

    private func drawPrizeBoard(_ challenge: OriginalChallenge, on canvas: NativeCanvas,progress: NativeActivityPlan.Frame?) throws {
        try background(challenge, on: canvas)
        // TEMPLATE8504: loop0x0087 reads flattened fields1..4, prefixes '$',
        // measures each string, and uses tables0x0414/0x041c for placement.
        // Final placement0x037f repeats this after the flashing intro.
        // INT60 command9(4) and local-video glyph comparison identify font1396.
        let font = try content.font("MOCKET.DAT.1396")
        let centers = [54, 83, 155, 157]
        let rows = [85, 43, 50, 98]
        for index in 0..<4 {
            let amount = try challenge.originalWord(at: index + 1)
            guard amount >= 0 else { throw ContentError.invalid("Invalid original prize amount") }
            let text = "$\(amount)"
            let color = progress?.marks[index] ?? 1
            if color >= 0 { canvas.text(text, font: font, x: centers[index] - font.width(of: text)/2, y: rows[index], color: UInt8(color)) }
        }
        if let marks = progress?.marks, marks[4] >= 0 {
            let i = marks[4]
            canvas.replaceActivityColor(left: [34,106,5,107][i]+7,top: [20,27,62,75][i]+19,
                                        right: [52,124,23,126][i]+10,bottom: [37,44,79,92][i]+19,
                                        from: 14,to: UInt8(marks[5]))
        }
    }

    private func drawTelevisionTable(_ challenge: OriginalChallenge, on canvas: NativeCanvas) throws {
        try background(challenge, on: canvas)
        // TEMPLATE8512: title is flattened field24 (0x0063); six row labels
        // field5+i, numbers field11+i and units field17+i (0x00bd..0x0164).
        let titleFont = try content.font("MOCKET.DAT.1393")
        let rowFont = try content.font("MOCKET.DAT.1396")
        let title = try challenge.originalString(at: 24)
        canvas.text(title, font: titleFont, x: 10 + (174-titleFont.width(of: title))/2, y: 29, color: 1)
        for index in 0..<6 {
            let row = 45 + index*13
            let label = try challenge.originalString(at: 5 + index)
            let number = String(try challenge.originalWord(at: 11 + index))
            let unit = try challenge.originalString(at: 17 + index)
            canvas.text(label, font: rowFont, x: 30, y: row, color: 1)
            canvas.text(number, font: rowFont, x: 133-rowFont.width(of: number), y: row, color: 1)
            canvas.text(unit, font: rowFont, x: 139, y: row, color: 1)
        }
    }
}
