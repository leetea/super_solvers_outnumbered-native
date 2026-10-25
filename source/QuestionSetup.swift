import Foundation

struct OriginalQuestionSettings: Codable,Equatable {
    var mathLevel: Int
    var enabledOperationRows: [Bool]
    var valid: Bool { (0..<4).contains(mathLevel) && enabledOperationRows.count == 4 && enabledOperationRows.contains(true) }
    static func defaults(tier: Int) -> OriginalQuestionSettings {
        // Original DS:1277, four 13-byte settings records. Bit 0x10 of
        // each of the first four bytes enables that operation for rooms.
        let flags = [[28,4,20,4],[29,12,28,4],[30,20,20,20],[31,28,28,20]]
        return OriginalQuestionSettings(mathLevel: tier,enabledOperationRows: flags[tier].map { $0 & 16 != 0 })
    }
}

struct OriginalQuestionSetup: Codable,Equatable {
    static let familyBases = [9070,9010,9100,9120,9050,9140,9020,9040,9060,9130]
    // DS:4c6a translates the settings row into the template operation index.
    static let operationMap = [0,2,3,1]
    let settings: OriginalQuestionSettings
    let seeds: [Int], variants: [Int], operations: [Int]
    let enabled: [Bool]
    var valid: Bool {
        settings.valid && seeds.count == 10 && seeds.allSatisfy { (1...10).contains($0) } &&
        variants.count == 10 && variants.allSatisfy { (0..<4).contains($0) } &&
        operations.count == 10 && operations.allSatisfy { operation in
            Self.operationMap.indices.contains { Self.operationMap[$0] == operation && settings.enabledOperationRows[$0] }
        } && enabled.count == 10
    }
    init(tier: Int,settings: OriginalQuestionSettings,generator: inout DecoderGenerator) throws {
        guard (0..<4).contains(tier), settings.valid else { throw ContentError.invalid("Invalid original room question settings") }
        self.settings = settings
        // 1d06:0207 draws all ten seeds before the per-hotspot variant and
        // rejection-sampled operation. Preserve the draws for inactive slots.
        seeds = (0..<10).map { _ in generator.nextRandomValue()%10+1 }
        var variants: [Int] = [], operations: [Int] = []
        for _ in 0..<10 {
            variants.append(generator.nextRandomValue()%4)
            var row: Int
            repeat { row = generator.nextRandomValue()%4 } while !settings.enabledOperationRows[row]
            operations.append(Self.operationMap[row])
        }
        self.variants = variants; self.operations = operations
        if tier < 2 {
            var enabled = Array(repeating: false,count: 10)
            for pair in stride(from: 0,to: 10,by: 2) { enabled[pair+((generator.nextRandomValue()%100+1)&1)] = true }
            self.enabled = enabled
        } else { enabled = Array(repeating: true,count: 10) }
    }
    func recordID(hotspot: Int) -> Int {
        let operation = operations[hotspot]
        let band = settings.mathLevel == 0 || (settings.mathLevel != 3 && operation != 0 && operation != 3) ? 0 : 5
        return Self.familyBases[hotspot]+band+operation
    }
}

extension NativeSession {
    mutating func ensureQuestionSetup() {
        guard questionSetup == nil else { return }
        // Pre-0.7 saves have no original startup choices or original seed.
        // Preserve their decoder, assigned questions, and progress; draw the
        // missing choices once from their saved stream and identify migration.
        let tier = decoder.difficulty
        questionSetup = try! OriginalQuestionSetup(tier: tier,settings: .defaults(tier: tier),generator: &generator)
        migratedQuestionSetup = true
    }
    func questionEnabled(_ hotspot: Int) -> Bool {
        guard (0..<10).contains(hotspot) else { return false }
        return assignedChallenges[hotspot] != nil || questionSetup?.enabled[hotspot] == true
    }
    mutating func question(hotspot: Int,bank: ChallengeBank) throws -> OriginalChallenge? {
        guard (0..<10).contains(hotspot) else { throw ContentError.invalid("Invalid original question location") }
        ensureQuestionSetup()
        if let assigned = assignedChallenges[hotspot] { return assigned }
        guard questionEnabled(hotspot), let setup = questionSetup else { return nil }
        guard let challenge = bank.cases.first(where: { $0.id == setup.recordID(hotspot: hotspot) && $0.seed == setup.seeds[hotspot] && $0.variant == setup.variants[hotspot] }) else {
            throw ContentError.invalid("Missing recovered original question")
        }
        assignedChallenges[hotspot] = challenge
        return challenge
    }
}
