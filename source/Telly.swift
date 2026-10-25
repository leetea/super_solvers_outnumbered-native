import Foundation

// Recovered 11b0:1559, 1592:* and MOCKET.DAT:5000 animation data.
// The caller supplies original rand() values, retaining shared RNG consumption.
struct OriginalTellyTuning: Codable, Equatable {
    let spawnThreshold: Int, stopThreshold: Int, resumeThreshold: Int
    let throwThreshold: Int, unlitThreshold: Int, walkingStep: Int, nearSpawnOffset: Int
    static let tiers = [
        OriginalTellyTuning(spawnThreshold: 10, stopThreshold: 60, resumeThreshold: 15, throwThreshold: 20, unlitThreshold: 0, walkingStep: 1, nearSpawnOffset: 8),
        OriginalTellyTuning(spawnThreshold: 15, stopThreshold: 50, resumeThreshold: 12, throwThreshold: 25, unlitThreshold: 30, walkingStep: 2, nearSpawnOffset: 6),
        OriginalTellyTuning(spawnThreshold: 30, stopThreshold: 40, resumeThreshold: 11, throwThreshold: 35, unlitThreshold: 40, walkingStep: 2, nearSpawnOffset: 4),
        OriginalTellyTuning(spawnThreshold: 40, stopThreshold: 30, resumeThreshold: 9, throwThreshold: 45, unlitThreshold: 50, walkingStep: 2, nearSpawnOffset: 2)
    ]
}

enum OriginalTellyError: Error { case invalidTier }
enum OriginalTellyState: Int, Codable { case removed = -1, absent = 0, walking = 3, standing = 4, throwing = 5, stunned = 7, appearing = 8, disappearing = 9 }

struct OriginalTellyContext {
    var hallway = true
    var allowSpawning = true // Original 11b0:1559's nonzero parameter, normally3 in main play.
    var playerHasMoved = true // Original DS:0096; false initially until the first non-idle action.
    var cameraSegment = 2
    var playerScreenUnit = 20
    var capturedCodePieces = 0
}

struct OriginalTellyFramePhase: Codable, Equatable {
    var index = 0
    var ticksLeft: Int
}

struct OriginalTellyProjectile: Codable, Equatable {
    let kind: Int // Original animation/type22..25.
    var xUnits: Int
    let yPixels: Int
    let collisionWidthUnits: Int
    var velocityUnits: Int
    var ticksRemaining = 0x7ffd
    var pendingRemoval = false
    var sprite: Int?
}

struct OriginalTellyStep {
    var sounds: [Int] = []
    var spawned = false
    var projectileCreated = false
    var removed = false
}

struct OriginalTelly: Codable {
    let tier: Int
    private(set) var state = OriginalTellyState.absent
    private(set) var xUnits = 0
    private(set) var yPixels = 77
    private(set) var facing = -1
    private(set) var bellyLit = false
    private(set) var eligibleForCode = false
    private(set) var sprite: Int?
    private(set) var bellySprite = 204
    private(set) var bellyOffsetY = 22
    private(set) var projectile: OriginalTellyProjectile?
    private var savedLitForThrow = false
    private var throwKind = 22
    private var transitionCount = 0 // DS:6d52, emergence/disappearance.
    private var stunCount = 0 // DS:5b84, independent blink duration.
    private var phases: [Int: OriginalTellyFramePhase] = [:]

    // Frame lists and hold counts are original resource5000 rows, not guessed rates.
    static let animationFrames: [Int: [Int]] = [
        10: [100,101,102,103], 11: [104,105,106,107],
        17: [105,113,114,113,105], 18: [105,180,181,182,105],
        19: [105,186,187,188,186,105], 20: [105,186,191,192,186,105],
        22: [115,116], 23: [183,184,185], 24: [189,190], 25: [193,194],
        32: [108,109,110,110,111], 33: [111,110,110,109,108],
        34: [100,112,100,112,100,112,100,112]
    ]
    static let releaseFrameIndices = [2,0,3,3] // DS:11ab, four words.
    static let impactSprites = [210,212,209,211] // DS:11b3.
    static let projectileY = [81,91,115,118] // Raw switch0x134d0..0x134ed, SI values.
    static let projectileWidths = [5,2,4,3] // Same switch, DI values.
    var tuning: OriginalTellyTuning { OriginalTellyTuning.tiers[tier] }
    var hittable: Bool { (1...6).contains(state.rawValue) }
    var collisionLeftUnit: Int { xUnits + 1 }
    var collisionWidthUnits: Int { 6 }
    var hasActiveProjectile: Bool { projectile != nil }
    var hasValidPersistenceState: Bool {
        guard OriginalTellyTuning.tiers.indices.contains(tier), [-1,1].contains(facing),
              (-32768...32767).contains(xUnits), yPixels == 77, (0...5).contains(transitionCount), (0...9).contains(stunCount),
              (22...25).contains(throwKind) else { return false }
        for (id, phase) in phases {
            guard let frames = Self.animationFrames[id], frames.indices.contains(phase.index),
                  (1...(id == 10 || id == 11 ? 2 : 1)).contains(phase.ticksLeft) else { return false }
        }
        if let projectile {
            guard (22...25).contains(projectile.kind), (-32768...32767).contains(projectile.xUnits),
                  projectile.yPixels == Self.projectileY[projectile.kind - 22],
                  projectile.collisionWidthUnits == Self.projectileWidths[projectile.kind - 22],
                  [-3,-2,-1,1,2,3].contains(projectile.velocityUnits), (0...0x7ffd).contains(projectile.ticksRemaining) else { return false }
        }
        return true
    }

    init(tier: Int) throws {
        guard OriginalTellyTuning.tiers.indices.contains(tier) else { throw OriginalTellyError.invalidTier }
        self.tier = tier
    }
    private static func draw(_ lower: Int, _ upper: Int, _ nextRandom: () -> Int) -> Int {
        let value = nextRandom()
        precondition((0...0x7fff).contains(value), "Supply original rand() values in0..32767")
        return value % (upper - lower + 1) + lower
    }
    private mutating func advanceAnimation(_ id: Int, asProjectile: Bool = false) -> Int {
        let frames = Self.animationFrames[id]!
        let hold = id == 10 || id == 11 ? 2 : 1
        var phase = phases[id] ?? OriginalTellyFramePhase(ticksLeft: hold)
        if asProjectile { projectile?.sprite = frames[phase.index] } else { sprite = frames[phase.index] }
        phase.ticksLeft -= 1
        if phase.ticksLeft == 0 { phase.ticksLeft = hold; phase.index = (phase.index + 1) % frames.count }
        phases[id] = phase
        return phase.index
    }
    // Call at the original erase/cleanup phase, before scrolling and enemy/player updates.
    mutating func beginFrame() {
        if state == .removed { state = .absent; sprite = nil }
        if projectile?.pendingRemoval == true { projectile = nil }
    }
    mutating func shiftForCamera(by units: Int) { if state != .absent { xUnits -= units }; projectile?.xUnits -= units }
    mutating func remove() { if state != .absent { state = .removed; bellyLit = false } }

    // One original simulation step. Call player movement after this, then stepProjectile().
    mutating func step(context: OriginalTellyContext, nextRandom: () -> Int) -> OriginalTellyStep {
        var result = OriginalTellyStep()
        if state == .removed { return result } // The caller must run beginFrame(), matching11b0:14b7.
        if state == .absent {
            let roll = Self.draw(1, 1000, nextRandom) // Draw even when the later spawn guards fail.
            guard roll < tuning.spawnThreshold, context.allowSpawning, context.hallway,
                  context.playerHasMoved, projectile == nil else { return result }
            state = .walking; eligibleForCode = false; bellyLit = false
            phases[32] = OriginalTellyFramePhase(ticksLeft: 1)
            phases[33] = OriginalTellyFramePhase(ticksLeft: 1)
            xUnits = 35
            if context.capturedCodePieces < 4 {
                eligibleForCode = Self.draw(1, 100, nextRandom) > tuning.unlitThreshold
            }
            facing = -1
            if context.playerScreenUnit + 3 > 20 { xUnits = -3; facing = 1 }
            let nearRoll = Self.draw(0, 100, nextRandom)
            if nearRoll < 50 || (context.cameraSegment % 5 == 0 && facing == 1) || (context.cameraSegment % 5 == 4 && facing == -1) {
                state = .appearing
                xUnits = context.playerScreenUnit - (tuning.nearSpawnOffset + 8) * facing
                result.sounds.append(50)
                _ = advanceAnimation(33)
                transitionCount = 0
            } else {
                result.sounds.append(17)
                bellyLit = eligibleForCode
                _ = advanceAnimation(10)
                bellySprite = 204; bellyOffsetY = 22
            }
            result.spawned = true
            return result
        }
        result.sounds.append(17)
        if context.hallway && state.rawValue > 2 && ((facing == -1 && xUnits + 8 < context.playerScreenUnit) || (facing == 1 && context.playerScreenUnit < xUnits - 8)) { facing = -facing }
        if state.rawValue < 5 {
            bellyLit = eligibleForCode
            var resumed = false
            if state == .standing && Self.draw(0, 100, nextRandom) < tuning.resumeThreshold { state = .walking; resumed = true }
            if !resumed {
                let stopRoll = Self.draw(1, 100, nextRandom)
                if stopRoll < tuning.stopThreshold && 5 < xUnits && xUnits < 19 { state = .standing }
            }
        }
        let throwRoll = Self.draw(1, 100, nextRandom) // Consumed in all active states.
        if throwRoll < tuning.throwThreshold && state == .standing && projectile == nil {
            state = .throwing; throwKind = Self.draw(22, 25, nextRandom)
            savedLitForThrow = bellyLit; bellyLit = false
        }
        let before = state
        let movement = before == .walking ? tuning.walkingStep : 0
        if before == .stunned {
            _ = advanceAnimation(34); stunCount += 1
            if stunCount > 8 { state = .disappearing }
        } else if before != .throwing && before.rawValue < 8 {
            if before == .standing { _ = advanceAnimation(11); bellySprite = 208; bellyOffsetY = 24 }
            else {
                let index = phases[10]?.index ?? 0
                xUnits += facing * movement
                _ = advanceAnimation(10); bellySprite = 204 + index; bellyOffsetY = 22
            }
        }
        if before == .throwing {
            let afterIndex = advanceAnimation(throwKind - 5)
            if afterIndex == 0 { state = .standing; bellyLit = savedLitForThrow }
            let index = throwKind - 22
            if afterIndex == Self.releaseFrameIndices[index] {
                let speed = Self.draw(tuning.walkingStep, tuning.walkingStep + 1, nextRandom) * facing
                var start = xUnits
                if facing == -1 { if throwKind == 22 || throwKind == 24 { start -= 4 } }
                else { start += 4 }
                projectile = OriginalTellyProjectile(kind: throwKind, xUnits: start, yPixels: Self.projectileY[index], collisionWidthUnits: Self.projectileWidths[index], velocityUnits: speed)
                result.projectileCreated = true
            }
        }
        if before == .disappearing {
            if transitionCount == 5 { transitionCount = 0; remove(); result.removed = true }
            else { _ = advanceAnimation(32); transitionCount += 1 }
            result.sounds.append(50)
        }
        if before == .appearing {
            result.sounds.append(50); _ = advanceAnimation(33); transitionCount += 1
            if transitionCount == 4 { state = .walking; transitionCount = 0 }
        } else if before.rawValue > 2 && (xUnits < -3 || xUnits > 35) { remove(); result.removed = true }
        return result
    }
    mutating func stepProjectile() -> OriginalTellyStep {
        var result = OriginalTellyStep()
        guard projectile != nil, projectile?.pendingRemoval == false else { return result }
        let kind = projectile!.kind
        projectile!.xUnits += projectile!.velocityUnits
        _ = advanceAnimation(kind, asProjectile: true)
        if projectile!.ticksRemaining % 3 == 0 { result.sounds.append(kind - 12) }
        projectile!.ticksRemaining -= 1
        if projectile!.ticksRemaining < 1 || projectile!.xUnits < 2 || projectile!.xUnits > 32 { projectile!.pendingRemoval = true }
        else if (facing == -1 && projectile!.xUnits - 1 < projectile!.velocityUnits) || (facing == 1 && 33 - projectile!.xUnits < projectile!.velocityUnits) {
            projectile!.velocityUnits = 2 // Original11b0:18c2 uses positive2, including its asymmetry.
        }
        return result
    }
    @discardableResult mutating func stun() -> Int {
        let sound = bellyLit ? 16 : 42
        state = .stunned; stunCount = 0; eligibleForCode = false; bellyLit = false
        return sound
    }
    mutating func collideWithPlayer() {
        //11b0:14fe clears an ordinary Telly before11b0:160c selects its exit animation.
        if state != .stunned && state != .disappearing { remove() }
        if state != .stunned { state = .disappearing }
    }
    mutating func removeProjectile() { projectile?.pendingRemoval = true }
}

struct OriginalZapFrame: Equatable {
    let ordinal: Int, xUnits: Int, yPixels: Int, durationIRQTicks: Int
}
struct OriginalZapSchedule {
    let playerFrames: [OriginalZapFrame]
    let beamFrames: [OriginalZapFrame]
    let hit: Bool
    let sound: Int
    let energyCost: Int
    // Target endpoints are computed from actor X+collision-left and collision width.
    init(playerX: Int, playerY: Int, facing: Int, energy: Int, targetLeft: Int? = nil, targetWidth: Int = 0) {
        let left = facing < 0, fireX = playerX - (left ? 4 : 0)
        playerFrames = (47...49).map { OriginalZapFrame(ordinal: $0, xUnits: fireX, yPixels: playerY, durationIRQTicks: 10) }
        var beamX = fireX + (left ? -3 : 8), hit = false, beams: [OriginalZapFrame] = []
        let leftShiftAfterFrame = [5,3,0,0,0,0] // Original signed bytes DS:00c0.
        for index in 0..<6 {
            if let endpoint = targetLeft, endpoint >= 0 {
                let right = endpoint + targetWidth
                if (beamX <= endpoint && endpoint <= beamX + 12) || (beamX <= right && right <= beamX + 12) { hit = true }
            }
            if energy != 0 { beams.append(OriginalZapFrame(ordinal: 50 + index, xUnits: beamX, yPixels: playerY + 12, durationIRQTicks: 10)) }
            if left { beamX -= leftShiftAfterFrame[index] }
        }
        beamFrames = beams; self.hit = hit; sound = energy == 0 ? 15 : 14; energyCost = energy == 0 ? 0 : 1
    }
    // Empty zaps still wait through the six beam iterations, although no beam is drawn.
    var soundStartIRQTicks: Int { 30 }
    var energyCostIRQTicks: Int { 90 }
    var totalDurationIRQTicks: Int { 90 }
}

enum OriginalZapHitEffect: String { case blocked, empty, miss, stunTelly, startDrill, disperseLiveWire }
func originalZapHitEffect(playerAnimation: Int, energy: Int, hit: Bool, hallway: Bool, tellyLit: Bool, liveWireState: Int) -> OriginalZapHitEffect {
    guard playerAnimation < 3 else { return .blocked }
    guard energy != 0 else { return .empty }
    guard hit else { return .miss }
    if !hallway { return liveWireState == 1 ? .disperseLiveWire : .miss }
    return tellyLit ? .startDrill : .stunTelly
}

struct OriginalEncounterWarnings: Codable {
    private(set) var states = Array(repeating: UInt8(0), count: 18) // 0unseen,1pending,255shown.
    mutating func queue(_ id: Int) { if states.indices.contains(id) && states[id] == 0 { states[id] = 1 } }
    mutating func takeAutomatic(enabled: Bool, tellyState: Int, projectileState: Int, playerAnimation: Int) -> Int? {
        guard enabled, tellyState == 0, projectileState == 0, playerAnimation < 3,
              let id = states.prefix(13).firstIndex(of: 1) else { return nil }
        states[id] = 255; return id
    }
    mutating func takeImmediate(_ id: Int, enabled: Bool) -> Bool {
        guard enabled, states.indices.contains(id), states[id] != 255 else { return false }
        states[id] = 255; return true
    }
}

struct OriginalCollisionEffect: Equatable {
    let energyCost: Int, timePenaltyMinutes: Int, playerAnimation: Int, playerHorizontalStep: Int
    let warningID: Int, sounds: [Int], impactSprite: Int?
    // Original collision priorities: projectile actor5, Telly actor4, LiveWire actor1.
    static func forActor(_ actor: Int, sameFacing: Bool, projectileKind: Int = 22) -> OriginalCollisionEffect? {
        switch actor {
        case 1: return OriginalCollisionEffect(energyCost: 1, timePenaltyMinutes: 0, playerAnimation: 30, playerHorizontalStep: -2, warningID: 6, sounds: [19], impactSprite: nil)
        case 4: return OriginalCollisionEffect(energyCost: 1, timePenaltyMinutes: 0, playerAnimation: sameFacing ? 26 : 27, playerHorizontalStep: 2, warningID: 2, sounds: [51,20], impactSprite: 211)
        case 5:
            guard (22...25).contains(projectileKind) else { return nil }
            let animation = projectileKind < 24 ? (sameFacing ? 26 : 27) : 9
            let step = projectileKind < 24 ? (sameFacing ? 2 : -2) : -1
            return OriginalCollisionEffect(energyCost: 0, timePenaltyMinutes: 15, playerAnimation: animation, playerHorizontalStep: step, warningID: 1, sounds: [20], impactSprite: OriginalTelly.impactSprites[projectileKind - 22])
        default: return nil
        }
    }
    static func horizontalGap(leftA: Int, widthA: Int, leftB: Int, widthB: Int) -> Int {
        leftB < leftA ? leftA - (leftB + widthB) : leftB - (leftA + widthA)
    }
}
