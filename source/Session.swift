import Foundation

struct NativePosition: Codable, Equatable {
    var scene = 2
    var playerUnit = 96
    var cameraUnit = 76
    var facing = 1
    var valid: Bool {
        guard [-1,1].contains(facing) else { return false }
        if (0..<10).contains(scene) {
            let floorStart = (scene/5)*190
            //A two-unit frame can scroll151->153 before the original
            //right-edge predicate closes; screen X is still bounded at33.
            return (floorStart+1...floorStart+186).contains(playerUnit) && (floorStart...floorStart+153).contains(cameraUnit)
        }
        return [10,12,13,14,15].contains(scene) && (1...33).contains(playerUnit) && cameraUnit == 0
    }
}

struct NativeSession: Codable {
    let formatVersion: Int
    let profileID: UUID
    var lifetimePoints: Int
    var position = NativePosition()
    var returnPosition: NativePosition?
    var clock = VerifiedClock()
    var score: UInt16 = 0
    var energy = VerifiedEnergy.initial
    var pendingRecharge = 0
    var completed: Set<Int> = []
    var attempts: [Int: RoomAttempt] = [:]
    var assignedChallenges: [Int: OriginalChallenge] = [:]
    var decoder: DecoderPuzzle
    var generator: DecoderGenerator
    var activeChallenge: OriginalChallenge?
    var telly: OriginalTelly?
    var activeDrill: NativeDrill?
    var activeZap: NativeZap?
    var playerHasMoved: Bool?
    var energyMachineSlot: Int?
    var activeFountain: NativeFountain?
    var activeDoor: NativeDoorTransition?
    var activeElevator: NativeElevatorTransition?
    var playerMotion: NativePlayerMotion?
    var activeCollision: NativeCollisionFlash?
    var roomCamera: NativeRoomCamera?
    var liveWire: OriginalLiveWire?
    var calculator: NativeCalculator?
    var calculatorEnabled: Bool?
    var activityPresentation: NativeActivityPresentation?
    var activityStates: [Int:OriginalActivityState]?
    var questionSetup: OriginalQuestionSetup?
    var migratedQuestionSetup: Bool?
    var runID: UUID?
    var activeEnding: NativeEnding?
    var gameSettings: OriginalGameSettings?
    var newUserMessages: NativeNewUserMessages?
    var outcome = "active"
    var rank: VerifiedRank { VerifiedRank.forLifetimePoints(lifetimePoints) }
    init(profileID: UUID, seed: UInt32, lifetimePoints: Int = 0, settings: OriginalGameSettings? = nil, previousGenerator: DecoderGenerator? = nil, previousRoomCamera: NativeRoomCamera? = nil) {
        formatVersion = 1; self.profileID = profileID; self.lifetimePoints = lifetimePoints
        runID = UUID()
        newUserMessages = NativeNewUserMessages(enabled: lifetimePoints < 5000)
        roomCamera = previousRoomCamera;roomCamera?.disable()
        var generator = previousGenerator ?? DecoderGenerator(seed: seed)
        let tier = VerifiedRank.allCases.firstIndex(of: VerifiedRank.forLifetimePoints(lifetimePoints))! >> 1
        let settings = settings ?? .defaults(tier: tier)
        precondition(settings.valid)
        gameSettings = settings
        generator.restoreRandomState(seed & 65535) // original srand takes a 16-bit seed
        questionSetup = try! OriginalQuestionSetup(tier: tier,settings: settings.questionSettings,generator: &generator)
        decoder = generator.makePuzzle(difficulty: tier)
        energyMachineSlot = OriginalWorld.energyMachineCandidates[generator.nextRandomValue()%9]
        self.generator = generator
        telly = try! OriginalTelly(tier: decoder.difficulty)
        liveWire = try! OriginalLiveWire(tier: decoder.difficulty)
    }
    var valid: Bool {
        formatVersion == 1 && (0...9_999_999).contains(lifetimePoints) && clock.hasValidPersistenceState &&
        (0...127).contains(energy) && (0...20).contains(pendingRecharge) &&
        completed.allSatisfy { (0..<10).contains($0) } &&
        position.valid && (returnPosition == nil || (returnPosition!.valid && returnPosition!.scene < 10)) &&
        ["active","won","lost"].contains(outcome) &&
        attempts.allSatisfy { (0..<10).contains($0.key) && (0...2).contains($0.value.wrongAnswers) && $0.value.input.count <= 4 && $0.value.input.utf8.allSatisfy { (48...57).contains($0) } } &&
        assignedChallenges.allSatisfy { (0..<10).contains($0.key) && $0.key == $0.value.hotspot } &&
        (questionSetup == nil || questionSetup!.valid) &&
        (gameSettings == nil || gameSettings!.valid) &&
        (newUserMessages == nil || newUserMessages!.valid) &&
        (playerMotion == nil || playerMotion!.valid) &&
        (roomCamera == nil || roomCamera!.valid) &&
        (activeCollision == nil || (activeCollision!.valid && activeDoor == nil && activeElevator == nil && activeChallenge == nil && activeDrill == nil && activeZap == nil && activeFountain == nil && activeEnding == nil)) &&
        (activeEnding == nil || (activeEnding!.valid && runID != nil && activeChallenge == nil && activeDrill == nil && activeZap == nil && activeFountain == nil)) &&
        (telly == nil || telly!.hasValidPersistenceState) &&
        (activeDrill == nil || activeDrill!.valid) && (activeZap == nil || activeZap!.valid) &&
        (activeDrill == nil || (activeChallenge == nil && activeZap == nil)) &&
        (energyMachineSlot == nil || OriginalWorld.energyMachineCandidates.contains(energyMachineSlot!)) &&
        (activeFountain == nil || (activeFountain!.valid && activeDrill == nil && activeZap == nil && activeChallenge == nil && (activeFountain!.awardIssued ? pendingRecharge == 0 : pendingRecharge == activeFountain!.credits))) &&
        (liveWire == nil || liveWire!.hasValidPersistenceState) &&
        (activeDoor == nil || (activeDoor!.valid && activeElevator == nil && activeChallenge == nil && activeDrill == nil && activeZap == nil && activeFountain == nil && activeEnding == nil && position == (activeDoor!.destinationApplied ? activeDoor!.destination : activeDoor!.origin))) &&
        (activeElevator == nil || (activeElevator!.valid && activeDoor == nil && activeChallenge == nil && activeDrill == nil && activeZap == nil && activeFountain == nil && activeEnding == nil && position == (activeElevator!.destinationApplied ? activeElevator!.exitPosition : activeElevator!.origin))) &&
        (activityPresentation == nil || activeChallenge.map { activityPresentation!.valid(for: $0) } == true) &&
        (calculator == nil || calculator!.valid) &&
        (activityStates == nil || activityStates!.allSatisfy { [4,7].contains($0.key) && $0.value.hotspot == $0.key && $0.value.valid })
    }
    @discardableResult mutating func resolve(_ challenge: OriginalChallenge) -> Bool? {
        guard !completed.contains(challenge.hotspot) else { return nil }
        var attempt = attempts[challenge.hotspot] ?? RoomAttempt()
        let result = attempt.submit(expected: challenge.answer)
        attempts[challenge.hotspot] = attempt
        if let result, attempt.result != .editing {
            completed.insert(challenge.hotspot)
            if result {
                score = VerifiedScore.adding(VerifiedScore.roomAward(rank: rank, previousWrongAnswers: attempt.wrongAnswers)!, to: score)
                pendingRecharge += VerifiedScore.values(for: rank).refillCredits
            }
            if let room = DecoderPuzzle.roomIDs.firstIndex(of: position.scene) { _ = decoder.collectClues(room: room) }
        }
        return result
    }
}

final class NativeSessionStore {
    let directory: URL
    init(directory: URL) { self.directory = directory }
    func file(_ id: UUID) -> URL { directory.appendingPathComponent("session-\(id.uuidString)-v1.json") }
    func load(_ id: UUID) throws -> NativeSession? {
        let path = file(id)
        guard FileManager.default.fileExists(atPath: path.path) else { return nil }
        let value = try JSONDecoder().decode(NativeSession.self, from: Data(contentsOf: path))
        guard value.profileID == id, value.valid else { throw ContentError.invalid("The saved game is invalid or uses a newer version. It has not been changed.") }
        return value
    }
    func save(_ session: NativeSession) throws {
        guard session.valid else { throw ContentError.invalid("Invalid native game state") }
        // Validate an existing save before replacing it. Never destroy a future
        // version or corrupt document while trying to autosave a new game.
        _ = try load(session.profileID)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try JSONEncoder().encode(session).write(to: file(session.profileID), options: .atomic)
    }
}
