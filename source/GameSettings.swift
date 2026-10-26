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
    enum Presentation { case introduction, questions, response, waitingForSound, continuePrompt }
    enum AudioEvent: Equatable { case sound(Int), stop }
    let settings: OriginalGameSettings
    var generator: DecoderGenerator
    var drill: NativeDrill
    private(set) var presentation = Presentation.introduction
    private(set) var presentationTicks = 0
    private(set) var attempts = 0
    private(set) var correctAnswers = 0
    private(set) var elapsedSeconds = 0
    private var questionTicks = 0
    private var nextSecond = 240
    private(set) var resultSound = 40
    private(set) var resultVariant = 2
    private var recordedCorrect = 0
    private var countedProblem = false
    private var introductionStarted = false
    var acceptsAnswer: Bool { presentation == .questions && drill.phase == .asking }
    var presentationBusy: Bool { presentation != .questions && presentation != .continuePrompt }
    init(settings: OriginalGameSettings,seed: UInt32) throws {
        guard settings.valid else { throw DrillError.invalidSettings }
        self.settings = settings
        var generator = DecoderGenerator(seed: seed)
        drill = try NativeDrill(tier: 0,nextRandom: { generator.nextRandomValue() },settings: settings,practice: true)
        self.generator = generator
    }
    mutating func advance(irqTicks: Int,soundPlaying: Bool = false) throws -> [AudioEvent] {
        guard irqTicks >= 0 else { return [] }
        var ticks = irqTicks, events: [AudioEvent] = []
        while ticks > 0 {
            switch presentation {
            case .introduction:
                if !introductionStarted { events.append(.sound(23)); introductionStarted = true }
                let consumed = min(ticks,20-presentationTicks%20)
                ticks -= consumed; presentationTicks += consumed
                if presentationTicks == 160 {
                    events.append(.stop); presentation = .questions; presentationTicks = 0
                } else if presentationTicks%20 == 0 { events.append(.sound(23)) }
            case .questions:
                if drill.phase == .asking {
                    questionTicks += ticks
                    updateTimer()
                    return events
                }
                let before = drill.phase
                // Both waits around the practice counter are120 IRQ ticks.
                let boundary = before == .between && !countedProblem ? 120 : 0
                let consumed = min(ticks,max(1,drill.ticksRemaining-boundary))
                _ = try drill.advance(irqTicks: consumed,nextRandom: { generator.nextRandomValue() })
                ticks -= consumed; questionTicks += consumed
                if drill.phase == .asking { updateTimer() }
                if before == .between && !countedProblem && drill.ticksRemaining <= 120 {
                    attempts = (attempts+1)%10_000; countedProblem = true
                }
                if before != .between && drill.phase == .between { countedProblem = false }
                if drill.phase != .correctFeedback && drill.correct > recordedCorrect {
                    correctAnswers = (correctAnswers+drill.correct-recordedCorrect)%10_000
                    recordedCorrect = drill.correct; events.append(.sound(37))
                }
                if drill.phase == .finished {
                    if drill.correct == drill.questionCount { resultSound = 40; resultVariant = 2 }
                    else {
                        // Independent source draws: first sound, then animation.
                        resultSound = [28,34][generator.nextRandomValue()%2]
                        resultVariant = generator.nextRandomValue()%2
                    }
                    events.append(.stop); events.append(.sound(resultSound))
                    presentation = .response; presentationTicks = 0
                    // Playback begins when the caller receives these events.
                    return events
                }
            case .response:
                let consumed = min(ticks,OriginalPracticePresentation.duration(resultVariant)-presentationTicks)
                ticks -= consumed; presentationTicks += consumed
                if presentationTicks == OriginalPracticePresentation.duration(resultVariant) { presentation = .waitingForSound }
            case .waitingForSound:
                guard !soundPlaying else { return events }
                presentation = .continuePrompt
            case .continuePrompt: return events
            }
        }
        return events
    }
    private mutating func updateTimer() {
        // Source updates from the input poll, once per expired240-tick deadline;
        // waits do not catch up every missed second when input resumes.
        if questionTicks >= nextSecond {
            elapsedSeconds = (elapsedSeconds+1)%60_000; nextSecond = questionTicks+240
        }
    }
    mutating func submit() -> Bool? {
        guard acceptsAnswer else { return nil }
        return drill.submit(nextRandom: { generator.nextRandomValue() })
    }
    mutating func nextSet() throws {
        guard presentation == .continuePrompt else { return }
        drill = try NativeDrill(tier: 0,nextRandom: { generator.nextRandomValue() },settings: settings,practice: true)
        presentation = .introduction; presentationTicks = 0; introductionStarted = false
        countedProblem = false; recordedCorrect = 0
    }
}
