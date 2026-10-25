import Foundation

@main enum DecoderChecks {
    static func main() throws {
        struct Fixture: Decodable {
            let difficulty: Int
            let seed: UInt32
            let secret: [UInt8]
            let rooms: [[UInt8]]
            let hideoutRoom: Int
            let finalRandomState: UInt32
        }
        struct RecoveredTables: Decodable { let seed_1_fixtures: [Fixture] }
        let fixturePath = CommandLine.arguments.dropFirst().first ?? "work/reimplementation/decoder-recovered-tables.json"
        let fixtureData = try Data(contentsOf: URL(fileURLWithPath: fixturePath))
        let fixtures = try JSONDecoder().decode(RecoveredTables.self, from: fixtureData)
        for fixture in fixtures.seed_1_fixtures {
            var generator = DecoderGenerator(seed: fixture.seed)
            let puzzle = generator.makePuzzle(difficulty: fixture.difficulty)
            assert(puzzle.secret.map { $0 & 0x3f } == fixture.secret)
            assert(puzzle.roomClues.map { $0.map { $0 & 0x3f } } == fixture.rooms)
            assert(puzzle.hideoutRoom == fixture.hideoutRoom)
            assert(generator.randomState == fixture.finalRandomState)
        }
        var random = DecoderGenerator(seed: 1)
        assert(random.nextRandomValue() == 346)
        var checked = 0
        var originalSemanticEdges = [0, 0, 0, 0]
        for difficulty in 0..<4 {
            for seed in UInt32(0)..<1000 {
                var generator = DecoderGenerator(seed: seed)
                var puzzle = generator.makePuzzle(difficulty: difficulty)
                var replay = DecoderGenerator(seed: seed)
                assert(puzzle == replay.makePuzzle(difficulty: difficulty))
                assert(puzzle.secret.count == 4 && puzzle.roomClues.count == 5)
                assert(puzzle.secret.allSatisfy { $0 & 0x80 != 0 && $0 & 0x3f < 20 })
                assert(puzzle.roomClues.flatMap { $0 }.allSatisfy { $0 & 0x80 != 0 && $0 & 0x3f < 20 })
                assert(puzzle.isWinningChoice(room: puzzle.hideoutRoom))
                assert(!puzzle.canDecide(energy: 12, pendingRecharge: 0))
                if !puzzle.rule.matches(secret: puzzle.secret, room: puzzle.roomClues[puzzle.hideoutRoom]) {
                    originalSemanticEdges[difficulty] += 1
                }
                assert(puzzle.collectClues(room: -1) == 0)
                assert(puzzle.collectClues(room: 0) == [4, 4, 2, 2][difficulty])
                if difficulty > 1 { assert(puzzle.collectClues(room: 0) == 2) }
                assert(puzzle.completedRoomCount == 1)
                assert(!puzzle.canDecide(energy: 12, pendingRecharge: 0))
                for _ in 0..<4 { assert(puzzle.collectSecret() != nil) }
                assert(puzzle.collectSecret() == nil && puzzle.capturedCount == 4)
                assert(puzzle.canDecide(energy: 12, pendingRecharge: 0))
                let saved = try JSONEncoder().encode(puzzle)
                let restored = try JSONDecoder().decode(DecoderPuzzle.self, from: saved)
                assert(restored == puzzle)
                checked += 1
            }
        }
        var generator = DecoderGenerator(seed: 123)
        var puzzle = generator.makePuzzle(difficulty: 3)
        for room in 0..<5 { _ = puzzle.collectClues(room: room); _ = puzzle.collectClues(room: room) }
        assert(puzzle.completedRoomCount == 5)
        assert(!puzzle.canDecide(energy: 1, pendingRecharge: 0))
        assert(!puzzle.canDecide(energy: 0, pendingRecharge: 1))
        assert(puzzle.canDecide(energy: 0, pendingRecharge: 0))
        _ = puzzle.collectSecret()
        assert(puzzle.canDecide(energy: 12, pendingRecharge: 0))
        assert(DecoderMatchRule.samePicturesSameOrder.matches(secret: [0,1,2,3], room: [0,1,2,3]))
        assert(DecoderMatchRule.samePicturesDifferentOrder.matches(secret: [0,1,2,3], room: [1,0,2,3]))
        assert(DecoderMatchRule.differentPicturesSamePattern.matches(secret: [0,1,0,2], room: [4,5,4,6]))
        assert(!DecoderMatchRule.differentPicturesSamePattern.matches(secret: [0,1,0,2], room: [4,4,5,6]))
        var malformed = try JSONSerialization.jsonObject(with: JSONEncoder().encode(puzzle)) as! [String: Any]
        malformed["difficulty"] = 99
        let badData = try JSONSerialization.data(withJSONObject: malformed)
        assert((try? JSONDecoder().decode(DecoderPuzzle.self, from: badData)) == nil)
        let generatorData = try JSONEncoder().encode(generator)
        var restoredGenerator = try JSONDecoder().decode(DecoderGenerator.self, from: generatorData)
        assert(generator.makePuzzle(difficulty: 3) == restoredGenerator.makePuzzle(difficulty: 3))
        print("Checked four independent raw-table fixtures, \(checked) seeded decoder puzzles, reveal/eligibility/save lifecycle, and rule helpers.")
        print("Preserved original generator semantic edge counts by tier: \(originalSemanticEdges)")
    }
}
