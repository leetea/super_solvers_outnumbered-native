import Foundation

enum DrillOperation: Int, Codable { case addition, multiplication, subtraction, division
    var glyph: String { ["+","*","-","\\"][rawValue] }
}
enum DrillBlank: Int, Codable { case result, left, right }
enum DrillError: Error { case invalidSettings, invalidPair }

struct OriginalDrillQuestion: Codable, Equatable {
    let encodedPair: UInt16
    let blank: DrillBlank
    let operation: DrillOperation
    let left: Int, right: Int, result: Int
    init(encodedPair: UInt16, blank: DrillBlank) throws {
        let low = Int(encodedPair & 15), high = Int((encodedPair >> 4) & 15)
        guard low <= 12, high <= 12, let operation = DrillOperation(rawValue: Int(encodedPair >> 8)) else { throw DrillError.invalidPair }
        self.encodedPair = encodedPair; self.blank = blank; self.operation = operation
        switch operation {
        case .addition: left = high; right = low; result = high+low
        case .multiplication: left = high; right = low; result = high*low
        case .subtraction: left = high+low; right = low; result = high
        case .division:
            let divisor = max(1,low)
            if blank == .right && high*low == 0 { left = divisor; right = divisor; result = 1 }
            else { left = high*low; right = divisor; result = high }
        }
    }
    var expected: Int { [result,left,right][blank.rawValue] }
    func accepts(_ answer: Int) -> Bool {
        guard (0...999).contains(answer) else { return false }
        // Original1fc6:04d8 accepts any operand in ?*0=0 or0*?=0.
        if operation == .multiplication && ((blank == .left && right == 0) || (blank == .right && left == 0)) { return true }
        return answer == expected
    }
    var valid: Bool { (try? OriginalDrillQuestion(encodedPair: encodedPair,blank: blank)) == self }
}

struct OriginalDrillGenerator: Codable {
    static let defaults: [[UInt8]] = [
        [28,4,20,4,4,4,0,0,0,0,0,0,0],
        [29,12,28,4,4,4,4,0,4,0,4,0,0],
        [30,20,20,20,4,4,4,4,4,4,4,0,0],
        [31,28,28,20,4,4,4,4,4,4,4,4,4]
    ]
    let settings: [UInt8]
    private(set) var pool: [UInt16]
    private(set) var remaining: Int
    init(settings: [UInt8]) throws {
        guard settings.count == 13, settings.allSatisfy({ $0 <= 31 }),
              settings.prefix(4).contains(where: { $0 & 16 != 0 }),
              settings.contains(where: { $0 & 4 != 0 }),
              settings.prefix(3).contains(where: { $0 & 8 != 0 }) else { throw DrillError.invalidSettings }
        self.settings = settings
        var recovered: [UInt16] = []
        for operation in 0..<4 where settings[operation] & 16 != 0 {
            var used = Set<Int>()
            for selected in 0...12 where settings[selected] & 4 != 0 {
                for other in 0...12 {
                    for (low,high) in [(selected,other),(other,selected)] {
                        let key = high+low*13
                        if !used.contains(key) && (low != 0 || operation < 3) {
                            recovered.append(UInt16((operation<<8)|(high<<4)|low)); used.insert(key)
                        }
                    }
                }
            }
        }
        guard !recovered.isEmpty else { throw DrillError.invalidSettings }
        pool = recovered; remaining = recovered.count
    }
    mutating func next(nextRandom: () -> Int) throws -> OriginalDrillQuestion {
        if remaining == 0 { remaining = pool.count }
        let selected = nextRandom()%remaining
        pool.swapAt(selected,remaining-1); remaining -= 1
        var blank: Int
        repeat { blank = nextRandom()%3 } while settings[blank] & 8 == 0
        return try OriginalDrillQuestion(encodedPair: pool[remaining],blank: DrillBlank(rawValue: blank)!)
    }
    var valid: Bool {
        guard let original = try? OriginalDrillGenerator(settings: settings), (0...pool.count).contains(remaining) else { return false }
        return pool.count == original.pool.count && Set(pool) == Set(original.pool)
    }
}

struct NativeDrill: Codable {
    enum Phase: String, Codable { case between, asking, correctFeedback, correctPause, wrongFeedback, showCorrect, finished }
    let questionCount: Int
    var generator: OriginalDrillGenerator
    var question: OriginalDrillQuestion
    var referenceQuestions: [OriginalDrillQuestion]?
    private(set) var answered = 0
    private(set) var correct = 0
    private(set) var phase = Phase.between
    private(set) var ticksRemaining = 240
    var input = ""
    private(set) var acknowledgement = ""
    var rewardApplied = false
    var capturedSymbol: UInt8?
    var resultTicksRemaining = 0
    static let acknowledgements = ["That's correct!","That's the answer!","That's right!","You're right!","Good job!"] // Original DS:5354 pointers.
    init(tier: Int, nextRandom: () -> Int, reference: Bool = false) throws {
        guard (0..<4).contains(tier) else { throw DrillError.invalidSettings }
        questionCount = tier*2+4
        var generator = try OriginalDrillGenerator(settings: OriginalDrillGenerator.defaults[tier])
        if reference {
            guard tier == 1 else { throw DrillError.invalidSettings }
            // Six equations/blank positions independently visible in the local
            // recording. These are a checkpoint, not a claim about its RNG seed.
            let pairs: [(UInt16,DrillBlank)] = [(0x029a,.left),(0x003c,.right),(0x00ac,.result),(0x0287,.right),(0x02ca,.left),(0x0293,.right)]
            let questions = try pairs.map { try OriginalDrillQuestion(encodedPair: $0.0,blank: $0.1) }
            referenceQuestions = questions; question = questions[0]
        } else { referenceQuestions = nil; question = try generator.next(nextRandom: nextRandom) }
        self.generator = generator
    }
    var entitledToCode: Bool { correct >= questionCount-1 }
    var displayParts: [String] {
        var values = [String(question.left),question.operation.glyph,String(question.right),"=",String(question.result)]
        let index = [4,0,2][question.blank.rawValue]
        values[index] = phase == .showCorrect ? String(question.expected) : (input.isEmpty ? "?" : input)
        return values
    }
    mutating func digit(_ value: Int) {
        guard phase == .asking, (0...9).contains(value), input.count < 3 else { return }
        if input == "0" { input = String(value) } else { input += String(value) }
    }
    mutating func erase() { if phase == .asking && !input.isEmpty { input.removeLast() } }
    @discardableResult mutating func submit(nextRandom: () -> Int) -> Bool? {
        guard phase == .asking, let answer = Int(input) else { return nil }
        let accepted = question.accepts(answer)
        answered += 1
        if accepted {
            correct += 1; acknowledgement = Self.acknowledgements[nextRandom()%Self.acknowledgements.count]
            phase = .correctFeedback; ticksRemaining = 240
        } else { phase = .wrongFeedback; ticksRemaining = 480 }
        return accepted
    }
    // Returns the original50-point award exactly at the first correct wait's
    // end. Further input is blocked during original feedback/wait phases.
    mutating func advance(irqTicks: Int, nextRandom: () -> Int) throws -> Int {
        guard irqTicks >= 0, phase != .asking && phase != .finished else { return 0 }
        var ticks = irqTicks, award = 0
        while ticks > 0 && phase != .asking && phase != .finished {
            let consumed = min(ticks,ticksRemaining); ticksRemaining -= consumed; ticks -= consumed
            guard ticksRemaining == 0 else { break }
            switch phase {
            case .between: phase = .asking
            case .correctFeedback: award += 50; phase = .correctPause; ticksRemaining = 240
            case .wrongFeedback: phase = .showCorrect; ticksRemaining = 720
            case .correctPause,.showCorrect:
                if answered >= questionCount { phase = .finished }
                else {
                    if let reference = referenceQuestions { question = reference[answered] }
                    else { question = try generator.next(nextRandom: nextRandom) }
                    input = ""; phase = .between; ticksRemaining = 120
                }
            case .asking,.finished: break
            }
        }
        return award
    }
    mutating func abort() { if phase == .asking { phase = .finished } }
    var valid: Bool {
        [4,6,8,10].contains(questionCount) && generator.valid && question.valid &&
        (0...questionCount).contains(answered) && (0...answered).contains(correct) &&
        (0...720).contains(ticksRemaining) && input.count <= 3 && input.utf8.allSatisfy { (48...57).contains($0) } &&
        (referenceQuestions == nil || (questionCount == 6 && referenceQuestions!.count == 6 && referenceQuestions!.allSatisfy(\.valid))) &&
        (capturedSymbol == nil || capturedSymbol! < 20) && (0...720).contains(resultTicksRemaining)
    }
}

struct NativeZap: Codable {
    let playerX: Int, playerY: Int, facing: Int, initialEnergy: Int
    let targetLeft: Int?, targetWidth: Int
    let hitEffect: String
    var elapsedIRQTicks = 0
    var soundStarted = false
    var schedule: OriginalZapSchedule { OriginalZapSchedule(playerX: playerX,playerY: playerY,facing: facing,energy: initialEnergy,targetLeft: targetLeft,targetWidth: targetWidth) }
    var valid: Bool { (1...33).contains(playerX) && playerY == 81 && [-1,1].contains(facing) && (0...127).contains(initialEnergy) && (0...90).contains(elapsedIRQTicks) && (0...9).contains(targetWidth) && (targetLeft == nil || (-32768...32767).contains(targetLeft!)) && OriginalZapHitEffect(rawValue: hitEffect) != nil }
}

enum OriginalSoundPolicy {
    // DS:4506 signed-word priorities. Slot51 reads the following original word
    //0x460c; its valid impact stream is retained, not treated as silence.
    static let priorities = [1,1,1,3,2,2,5,5,5,5,4,4,4,4,5,5,5,2,4,5,3,5,5,5,5,1,1,1,1,1,1,1,1,1,1,5,5,1,4,1,1,1,1,1,1,1,1,3,4,4,0,17932]
    static func accepts(incoming: Int,current: Int?,playing: Bool) -> Bool {
        guard priorities.indices.contains(incoming) else { return false }
        guard playing, let current, priorities.indices.contains(current) else { return true }
        return priorities[current] < priorities[incoming]
    }
}
