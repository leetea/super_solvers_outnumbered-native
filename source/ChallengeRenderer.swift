import Foundation

struct OriginalChallenge: Codable {
    struct Group: Codable {
        let group: Int
        let count: Int
        let item_size: Int
        let offset: Int
        let items_hex: [String]
        func bytes(_ index: Int) -> [UInt8] {
            guard items_hex.indices.contains(index) else { return [] }
            let characters = Array(items_hex[index]); var result: [UInt8] = []
            for i in stride(from: 0, to: characters.count-1, by: 2) {
                guard let byte = UInt8(String(characters[i...i+1]), radix: 16) else { return [] }
                result.append(byte)
            }
            return result
        }
    }
    let id: Int, seed: Int, variant: Int, hotspot: Int
    let bitmap_record_id: Int
    let title: String, question: String, answer: Int, hint: String
    let question_parts: [String]
    let groups: [Group]
    let post_generation_rng_state: UInt32?
    func strings(group: Int) -> [String] {
        guard let entry = groups.first(where: { $0.group == group }) else { return [] }
        return entry.items_hex.indices.map { String(bytes: entry.bytes($0).prefix { $0 != 0 }, encoding: .ascii) ?? "" }
    }
}

struct ChallengeBank: Decodable {
    let cases: [OriginalChallenge]
}

struct MapCoordinates: Decodable {
    struct Point: Decodable { let x: Int, y: Int }
    struct Entry: Decodable { let city: String; let label_anchor: Point; let marker_coordinate: Point }
    let entries: [Entry]
}

struct ChallengeRenderer {
    let content: OriginalContent
    let coordinates: MapCoordinates
    // TEMPLATE 8500 recovered city table and arithmetic; the origin is also
    // independently corroborated by the supplied local video.
    func draw(_ challenge: OriginalChallenge, on canvas: NativeCanvas) throws {
        guard challenge.hotspot == 0 else { throw ContentError.invalid("This activity is not available in this development build.") }
        canvas.draw(try content.bitmap(String(format: "TEMPLATE.GRA.%04x", challenge.bitmap_record_id)), x: 8, y: 19)
        let font = try content.font("MOCKET.DAT.1393")
        canvas.text(challenge.title, font: font, x: 96-font.width(of: challenge.title)/2, y: 21, color: 1)
        let cities = challenge.strings(group: 2), values = challenge.strings(group: 4)
        for (i, city) in cities.enumerated() {
            guard values.indices.contains(i), let coordinate = coordinates.entries.first(where: { $0.city == city }) else {
                throw ContentError.invalid("Missing recovered map label coordinates")
            }
            let cityX = max(11, min(177-font.width(of: city), coordinate.label_anchor.x-font.width(of: city)/2))
            let valueX = max(11, min(177-font.width(of: values[i]), coordinate.label_anchor.x-font.width(of: values[i])/2))
            canvas.text(city, font: font, x: cityX, y: coordinate.label_anchor.y, color: 1)
            canvas.text(values[i], font: font, x: valueX, y: coordinate.label_anchor.y+10, color: 1)
            canvas.fill(coordinate.marker_coordinate.x,coordinate.marker_coordinate.y,2,2,1)
        }
    }
}

// Original non-calculator answer path: up to four digits; first wrong answer
// gives reading advice, second exposes the generated hint, third resolves.
struct RoomAttempt: Codable {
    enum Result: String, Codable { case editing, correct, failed }
    var wrongAnswers = 0
    var input = ""
    var result = Result.editing
    var awaitingHintAcknowledgement = false
    mutating func digit(_ value: Int) {
        guard result == .editing, !awaitingHintAcknowledgement, (0...9).contains(value), input.count < 4 else { return }
        if input == "0" { input = String(value) } else { input += String(value) }
    }
    mutating func submit(expected: Int) -> Bool? {
        guard result == .editing, !awaitingHintAcknowledgement, let value = Int(input) else { return nil }
        if value == expected { result = .correct; return true }
        if wrongAnswers == 2 { result = .failed }
        else { wrongAnswers += 1; input = ""; awaitingHintAcknowledgement = wrongAnswers == 2 }
        return false
    }
}
