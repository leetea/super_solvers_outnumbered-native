import Foundation

// The DOS program shares one13-byte record between custom games and practice.
// Its first byte's low bits mean math level in a game, set size in practice.
struct OriginalGameSettings: Codable, Equatable {
    var bytes: [UInt8]
    static func defaults(tier: Int) -> Self { Self(bytes: OriginalDrillGenerator.defaults[tier]) }
    var selection: Int { get { Int(bytes[0] & 3) } set { bytes[0] = (bytes[0] & 28) | UInt8(newValue & 3) } }
    var practiceQuestionCount: Int { (selection+1)*5 }
    var questionSettings: OriginalQuestionSettings {
        OriginalQuestionSettings(mathLevel: selection,enabledOperationRows: (0..<4).map { bytes[$0] & 16 != 0 })
    }
    func enabled(_ index: Int,mask: UInt8) -> Bool { bytes[index] & mask != 0 }
    mutating func set(_ index: Int,mask: UInt8,enabled: Bool) { bytes[index] = enabled ? bytes[index] | mask : bytes[index] & ~mask }
    var validationMessage: String? {
        guard bytes.count == 13, bytes.allSatisfy({ $0 <= 31 }) else { return "Invalid settings record." }
        guard bytes.prefix(4).contains(where: { $0 & 16 != 0 }), bytes.contains(where: { $0 & 4 != 0 }), bytes.prefix(3).contains(where: { $0 & 8 != 0 }) else {
            return "You need to have at least one box checked in each area."
        }
        if bytes[3] & 16 != 0 && bytes.prefix(3).allSatisfy({ $0 & 16 == 0 }) && bytes[0] & 4 != 0 && bytes.dropFirst().allSatisfy({ $0 & 4 == 0 }) {
            return "You need to choose more numbers to do division."
        }
        return nil
    }
    var valid: Bool { validationMessage == nil }
}

struct NativePractice {
    let settings: OriginalGameSettings
    var generator: DecoderGenerator
    var drill: NativeDrill
    private(set) var attempts = 1
    private(set) var correctAnswers = 0
    private(set) var resultAcknowledgement = ""
    private(set) var resultSound = 40
    private var recordedCorrect = 0
    init(settings: OriginalGameSettings,seed: UInt32) throws {
        guard settings.valid else { throw DrillError.invalidSettings }
        self.settings = settings
        var generator = DecoderGenerator(seed: seed)
        drill = try NativeDrill(tier: 0,nextRandom: { generator.nextRandomValue() },settings: settings,practice: true)
        self.generator = generator
    }
    mutating func advance(irqTicks: Int) throws -> [Int] {
        let before = drill.phase
        _ = try drill.advance(irqTicks: irqTicks,nextRandom: { generator.nextRandomValue() })
        var sounds: [Int] = []
        // Original increments attempts when displaying a problem, correct
        // answers at the end of the first240-tick acknowledgement wait.
        if before != .between && drill.phase == .between { attempts = (attempts+1)%10_000 }
        if drill.phase != .correctFeedback && drill.correct > recordedCorrect {
            correctAnswers = (correctAnswers+drill.correct-recordedCorrect)%10_000
            recordedCorrect = drill.correct; sounds.append(37)
        }
        if before != .finished && drill.phase == .finished {
            if drill.correct == drill.questionCount { resultAcknowledgement = "All correct!"; resultSound = 40 }
            else {
                // The source makes two independent draws for this response.
                resultSound = [28,34][generator.nextRandomValue()%2]
                resultAcknowledgement = ["Keep practicing!","Try another set!"][generator.nextRandomValue()%2]
            }
            sounds.append(resultSound)
        }
        return sounds
    }
    mutating func submit() -> Bool? { drill.submit(nextRandom: { generator.nextRandomValue() }) }
    mutating func nextSet() throws {
        guard drill.phase == .finished else { return }
        drill = try NativeDrill(tier: 0,nextRandom: { generator.nextRandomValue() },settings: settings,practice: true)
        attempts = (attempts+1)%10_000
        recordedCorrect = 0; resultAcknowledgement = ""
    }
}
