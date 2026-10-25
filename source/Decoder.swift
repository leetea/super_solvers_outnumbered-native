import Foundation

// Recovered from 18e7/199f code and DS:39d8..3a79. Symbol bytes retain
// the original 0x80 hidden flag; sprite ID = (byte & 0x3f) + 0x4e.
enum DecoderMatchRule: Int, Codable {
    case samePicturesSameOrder = 0
    case samePicturesDifferentOrder = 1
    case differentPicturesSamePattern = 2

    func matches(secret: [UInt8], room: [UInt8]) -> Bool {
        guard secret.count == 4, room.count == 4 else { return false }
        let a = secret.map { $0 & 0x3f }, b = room.map { $0 & 0x3f }
        switch self {
        case .samePicturesSameOrder: return a == b
        case .samePicturesDifferentOrder: return Set(a) == Set(b) && a != b
        case .differentPicturesSamePattern:
            func pattern(_ values: [UInt8]) -> [Int] {
                var seen: [UInt8] = []
                return values.map { value in
                    if let index = seen.firstIndex(of: value) { return index }
                    seen.append(value)
                    return seen.count - 1
                }
            }
            return Set(a) != Set(b) && pattern(a) == pattern(b)
        }
    }
}

struct DecoderPuzzle: Codable, Equatable {
    // Original row order, not hallway order.
    static let roomIDs = [10, 12, 13, 14, 15]
    static let roomNames = ["News Room", "Game Show Room", "Cartoon Room", "Equipment Room", "Sound Room"]
    let difficulty: Int
    let rule: DecoderMatchRule
    let hideoutRoom: Int
    private(set) var secret: [UInt8]
    private(set) var roomClues: [[UInt8]]
    private enum CodingKeys: String, CodingKey { case difficulty, rule, hideoutRoom, secret, roomClues }

    var capturedCount: Int { secret.filter { $0 & 0x80 == 0 }.count }
    var completedRoomCount: Int { roomClues.filter { $0.allSatisfy { $0 & 0x80 == 0 } }.count }
    var cluesPerChallenge: Int { [4, 4, 2, 2][difficulty] }

    @discardableResult mutating func collectClues(room: Int) -> Int {
        guard roomClues.indices.contains(room) else { return 0 }
        var count = 0
        for index in roomClues[room].indices where roomClues[room][index] & 0x80 != 0 {
            guard count < cluesPerChallenge else { break }
            roomClues[room][index] &= 0x7f
            count += 1
        }
        return count
    }

    @discardableResult mutating func collectSecret() -> UInt8? {
        guard let index = secret.firstIndex(where: { $0 & 0x80 != 0 }) else { return nil }
        secret[index] &= 0x7f
        return secret[index] & 0x3f
    }

    func canDecide(energy: Int, pendingRecharge: Int) -> Bool {
        (capturedCount == 4 && completedRoomCount > 0) ||
        (completedRoomCount == 5 && (capturedCount > 0 || (energy == 0 && pendingRecharge == 0)))
    }

    // The original compares selection with DS:5beb. It does not run the
    // semantic Match Rule at confirmation or require four captured pieces.
    func isWinningChoice(room: Int) -> Bool { room == hideoutRoom }
}

// Keep this state between puzzles: DOS mutates both pools between games.
// The seed is the state immediately before the decoder's first rand call;
// other DOS gameplay consumes the same RNG, so video timestamps are not seeds.
struct DecoderGenerator: Codable {
    private(set) var randomState: UInt32
    private var symbols: [UInt8] = Array(0..<20)
    private var patterns: [[UInt8]] = [
        [0,0,1,1], [0,0,1,2], [0,1,0,1], [0,1,0,2], [0,1,1,0],
        [0,1,1,2], [0,1,2,0], [0,1,2,1], [0,1,2,2]
    ]
    private enum CodingKeys: String, CodingKey { case randomState, symbols, patterns }

    init(seed: UInt32) { randomState = seed }
    mutating func restoreRandomState(_ state: UInt32) { randomState = state }

    // Turbo C rand at 236a:0013: seed = seed * 015a4e35h + 1;
    // return (seed >> 16) & 7fffh. Overflow is intentional.
    mutating func nextRandomValue() -> Int {
        randomState = randomState &* 0x015a4e35 &+ 1
        return Int((randomState >> 16) & 0x7fff)
    }

    private mutating func shuffle(_ values: [UInt8]) -> [UInt8] {
        var result = values
        for count in stride(from: result.count, through: 1, by: -1) {
            result.swapAt(nextRandomValue() % count, count - 1)
        }
        return result
    }

    private mutating func drawThree() -> [UInt8] {
        var result: [UInt8] = []
        for count in stride(from: 20, through: 18, by: -1) {
            let index = nextRandomValue() % count
            result.append(symbols[index])
            symbols.swapAt(index, count - 1)
        }
        return result
    }

    mutating func makePuzzle(difficulty: Int) -> DecoderPuzzle {
        precondition((0..<4).contains(difficulty), "Decoder difficulty must be 0...3")
        symbols = shuffle(symbols)
        var secret = Array(symbols[16..<20])
        var rooms = Array(repeating: secret, count: 5)
        var rule = DecoderMatchRule.samePicturesSameOrder

        switch difficulty {
        case 0:
            for (room, replacements) in [1, 2, 2, 3].enumerated() {
                var positions = [0, 1, 2, 3]
                for remaining in stride(from: 4, to: 4 - replacements, by: -1) {
                    let selected = nextRandomValue() % remaining
                    let position = positions[selected]
                    positions.swapAt(selected, remaining - 1)
                    rooms[room + 1][position] = symbols[nextRandomValue() % 16]
                }
            }
        case 1:
            // Lexicographic permutations, exactly DS:3a10's 24 rows.
            let permutations = [
                [0,1,2,3], [0,1,3,2], [0,2,1,3], [0,2,3,1], [0,3,1,2], [0,3,2,1],
                [1,0,2,3], [1,0,3,2], [1,2,0,3], [1,2,3,0], [1,3,0,2], [1,3,2,0],
                [2,0,1,3], [2,0,3,1], [2,1,0,3], [2,1,3,0], [2,3,0,1], [2,3,1,0],
                [3,0,1,2], [3,0,2,1], [3,1,0,2], [3,1,2,0], [3,2,0,1], [3,2,1,0]
            ]
            var index: Int
            repeat { index = nextRandomValue() % 24 } while index < 2 || index > 21
            let alphabet = secret
            rooms = [0, -2, -1, 1, 2].map { delta in
                permutations[index + delta].map { alphabet[$0] }
            }
            secret = rooms[0]
        case 2:
            rule = .samePicturesDifferentOrder
            secret = Array(symbols[10..<14])
            rooms = [secret, Array(symbols[9..<13]), Array(symbols[11..<15]),
                     Array(symbols[12..<16]), secret]
            rooms[4][1] = symbols[9]
            rooms[4][2] = symbols[14]
            for index in rooms.indices { rooms[index] = shuffle(rooms[index]) }
        default:
            rule = .differentPicturesSamePattern
            let index = nextRandomValue() % 9
            let correctPattern = patterns[index]
            patterns.swapAt(index, 8)
            let codeAlphabet = drawThree()
            secret = correctPattern.map { codeAlphabet[Int($0)] }
            let roomAlphabet = drawThree()
            rooms[0] = correctPattern.map { roomAlphabet[Int($0)] }
            for room in 1..<5 {
                let pattern = patterns[nextRandomValue() % 8]
                let alphabet = drawThree()
                rooms[room] = pattern.map { alphabet[Int($0)] }
            }
        }

        // Original generators do not reject accidental equal order/picture
        // sets in tiers 2/3. Retain the stored winning row even in that case.
        let order = shuffle([0, 1, 2, 3, 4]).map(Int.init)
        return DecoderPuzzle(difficulty: difficulty, rule: rule,
            hideoutRoom: order.firstIndex(of: 0)!,
            secret: secret.map { $0 | 0x80 },
            roomClues: order.map { rooms[$0].map { $0 | 0x80 } })
    }
}

extension DecoderPuzzle {
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        difficulty = try c.decode(Int.self, forKey: .difficulty)
        rule = try c.decode(DecoderMatchRule.self, forKey: .rule)
        hideoutRoom = try c.decode(Int.self, forKey: .hideoutRoom)
        secret = try c.decode([UInt8].self, forKey: .secret)
        roomClues = try c.decode([[UInt8]].self, forKey: .roomClues)
        guard (0..<4).contains(difficulty), (0..<5).contains(hideoutRoom),
              secret.count == 4, roomClues.count == 5, roomClues.allSatisfy({ $0.count == 4 }),
              (secret + roomClues.flatMap { $0 }).allSatisfy({ $0 & 0x3f < 20 }),
              rule.rawValue == [0, 0, 1, 2][difficulty] else {
            throw DecodingError.dataCorrupted(.init(codingPath: c.codingPath, debugDescription: "Invalid decoder puzzle state"))
        }
    }
}

extension DecoderGenerator {
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        randomState = try c.decode(UInt32.self, forKey: .randomState)
        symbols = try c.decode([UInt8].self, forKey: .symbols)
        patterns = try c.decode([[UInt8]].self, forKey: .patterns)
        guard symbols.sorted() == Array(0..<20), patterns.count == 9,
              patterns.allSatisfy({ $0.count == 4 && $0.allSatisfy { $0 < 3 } }) else {
            throw DecodingError.dataCorrupted(.init(codingPath: c.codingPath, debugDescription: "Invalid decoder generator state"))
        }
    }
}
