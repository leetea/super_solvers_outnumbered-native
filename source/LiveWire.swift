import Foundation

// Pure port of135d:06ee,1b03:000e/0054/0065 and1afb:0082.
// The caller owns room transitions, original RNG state, zap timing and collision effects.
enum OriginalLiveWireState: Int, Codable { case removed = -1, absent = 0, walking = 1, dissipating = 3 }
enum OriginalLiveWireError: Error { case invalidTier }

struct OriginalLiveWireStep: Equatable {
    var sounds: [Int] = []
    var spawned = false
    var removed = false
}

struct OriginalLiveWire: Codable, Equatable {
    static let spawnThresholds = [40,50,70,80] // DS:11cf + tier*26; draw1...100 < threshold.
    static let walkingFrames = [10000,10001,10002] // MOCKET.DAT:5000 animation13.
    static let dissipationFrames = [10010,10011,10012,10013,10014] // Animation31.
    static let yPixels = 118
    static let restorationWidthPixels = 88
    static let restorationHeightPixels = 32
    let tier: Int
    private(set) var state = OriginalLiveWireState.absent
    private(set) var xUnits = 20 // Original actor1 before the first spawn overwrites X.
    private(set) var facing = 1
    private(set) var renderMirrored = false
    private(set) var sprite: Int?
    private(set) var dissipationTicksRemaining = 0 // Original signed byte DS:7346.
    private(set) var walkingFrameIndex = 0 // Original DS:687e, explicitly reset by0054.
    private(set) var dissipationFrameIndex = 0 // Retained across interrupted dissolves.
    var collisionLeftUnit: Int { xUnits + 1 }
    var collisionWidthUnits: Int { 9 }
    var collisionEnabled: Bool { state.rawValue > 0 }
    var canDisperseFromZap: Bool { state == .walking }
    var hasValidPersistenceState: Bool {
        OriginalLiveWire.spawnThresholds.indices.contains(tier) &&
        (-32768...32767).contains(xUnits) && [-1,1].contains(facing) &&
        (-1...5).contains(dissipationTicksRemaining) && (state != .dissipating || dissipationTicksRemaining >= 0) &&
        Self.walkingFrames.indices.contains(walkingFrameIndex) &&
        Self.dissipationFrames.indices.contains(dissipationFrameIndex) &&
        (sprite == nil || (Self.walkingFrames + Self.dissipationFrames).contains(sprite!))
    }
    init(tier: Int) throws {
        guard Self.spawnThresholds.indices.contains(tier) else { throw OriginalLiveWireError.invalidTier }
        self.tier = tier
    }
    // Call ONLY where the original calls135d:06ee: room entry and after an actual room challenge.
    // It consumes exactly one original rand() value, including unsuccessful attempts.
    @discardableResult mutating func attemptSpawn(playerScreenUnit: Int, nextRandom: () -> Int) -> OriginalLiveWireStep {
        let value = nextRandom()
        precondition((0...0x7fff).contains(value), "Supply original rand() values in0...32767")
        guard value % 100 + 1 < Self.spawnThresholds[tier] else { return OriginalLiveWireStep() }
        state = .walking
        if playerScreenUnit > 20 { xUnits = 3; facing = 1 }
        else { xUnits = 30; facing = -1 }
        //000e draws frame10000 without advancing/resetting the global animation record.
        sprite = 10000; renderMirrored = false
        return OriginalLiveWireStep(spawned: true)
    }
    // Original14b7 first erases actors whose flags are nonzero, then clears−1 to0.
    mutating func beginFrame() {
        if state == .removed { state = .absent; sprite = nil }
    }
    // Original1b03:0054 resets the WALK animation phase, not the dissolve phase/counter.
    mutating func clear(deferErase: Bool = false) {
        state = deferErase ? .removed : .absent
        walkingFrameIndex = 0
        if !deferErase { sprite = nil }
    }
    // Original1afb:0082; high-level135d:0667 calls this only for an energized state1 hit.
    @discardableResult mutating func disperseFromZap() -> Bool {
        guard state == .walking else { return false }
        state = .dissipating; dissipationTicksRemaining = 5
        return true
    }
    // Original11b0:160c actor1 path also emits sound19, warning6 and one energy cost.
    // Those common effects are supplied by OriginalCollisionEffect.forActor(1,...).
    mutating func collideWithPlayer() { clear(deferErase: true) }
    // One original simulation update, after enemy/player/projectile updates in11b0:1559.
    @discardableResult mutating func step() -> OriginalLiveWireStep {
        guard state != .absent, state != .removed else { return OriginalLiveWireStep() }
        renderMirrored = facing != -1 // Set before movement/boundary turn, as original DS:5b16.
        if state == .walking {
            xUnits += facing == -1 ? -1 : 1
            sprite = Self.walkingFrames[walkingFrameIndex]
            walkingFrameIndex = (walkingFrameIndex + 1) % Self.walkingFrames.count
            if xUnits < 3 { facing = 1 }
            if xUnits > 25 { facing = -1 }
            return OriginalLiveWireStep(sounds: [18])
        }
        if dissipationTicksRemaining == 0 {
            dissipationTicksRemaining = -1
            clear(deferErase: true)
            return OriginalLiveWireStep(removed: true)
        }
        dissipationTicksRemaining -= 1
        sprite = Self.dissipationFrames[dissipationFrameIndex]
        dissipationFrameIndex = (dissipationFrameIndex + 1) % Self.dissipationFrames.count
        return OriginalLiveWireStep()
    }
}
