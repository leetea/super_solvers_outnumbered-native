import Foundation

// The original MOCKET.DAT resource 5000 is decoded directly; no invented world graph.
struct OriginalWorldObject {
    let slot: Int
    let kind: Int
    let startUnit: Int
    let drawY: Int
    let endUnit: Int
    let sprite: Int
    var pixelX: Int { startUnit * 8 }
    var challengeIndex: Int? { (11...20).contains(kind) ? kind - 11 : nil }
    func overlapsPlayer(at unit: Int) -> Bool {
        (startUnit <= unit && unit < endUnit) || (unit < startUnit && startUnit < unit + 6)
    }
}

struct OriginalAnimation {
    let id: Int
    let initialFrameIndex: Int
    let frames: [Int]
    let initialTicksRemaining: Int
    let ticksPerFrame: Int
}

struct OriginalActor {
    let id: Int
    let xUnits: Int
    let yPixels: Int
    let restoreWidthUnits: Int
    let restoreHeightPixels: Int
    let backupXUnits: Int
    let backupYPixels: Int
    let collisionEnabled: Bool
    let collisionLeftOffsetUnits: Int
    let collisionWidthUnits: Int
}

enum OriginalWorldError: Error { case unexpectedResourceSize, invalidAnimation }

struct OriginalWorld {
    static let resourceSize = 1402
    static let resourceSHA256 = "977269778d70cf0f7430faad53d9eef7299a300fa9ea31ef29dc28f77ffb327a"
    static let backgroundOrigin = (x: 0, y: 15)
    static let wallOrigin = (x: 8, y: 31)
    static let wallStripCount = 38
    static let frameIRQTicks = 24
    static let initialHallway = 2
    static let initialCameraWorldUnit = 76
    static let initialPlayerWorldUnit = 96
    static let initialPlayerScreenUnit = 20
    static let initialPlayerY = 81
    // Recovered executable table DS:3382, flattened sceneIndex*4+objectSlot.
    static let energyMachineCandidates = [2, 6, 14, 16, 22, 24, 28, 34, 36]
    let scenes: [[OriginalWorldObject]]
    let animations: [OriginalAnimation]
    let actors: [OriginalActor]

    init(resource: Data) throws {
        guard resource.count == Self.resourceSize else { throw OriginalWorldError.unexpectedResourceSize }
        let bytes = Array(resource)
        func word(_ offset: Int) -> Int { Int(bytes[offset]) | Int(bytes[offset + 1]) << 8 }
        func signedWord(_ offset: Int) -> Int { Int(Int16(bitPattern: UInt16(word(offset)))) }
        func signedByte(_ offset: Int) -> Int { Int(Int8(bitPattern: bytes[offset])) }
        scenes = (0..<16).map { scene in
            (0..<4).map { slot in
                let offset = scene * 24 + slot * 6
                return OriginalWorldObject(slot: slot, kind: signedByte(offset), startUnit: signedByte(offset + 1), drawY: signedByte(offset + 2), endUnit: signedByte(offset + 3), sprite: word(offset + 4))
            }
        }
        animations = try (0..<35).map { id in
            let offset = 384 + id * 26, count = signedWord(offset)
            guard (0...9).contains(count) else { throw OriginalWorldError.invalidAnimation }
            return OriginalAnimation(id: id, initialFrameIndex: signedWord(offset + 2), frames: (0..<count).map { signedWord(offset + 4 + $0 * 2) }, initialTicksRemaining: signedWord(offset + 22), ticksPerFrame: signedWord(offset + 24))
        }
        actors = (0..<6).map { id in
            let offset = 0x50e + id * 18
            return OriginalActor(id: id, xUnits: signedWord(offset), yPixels: signedWord(offset + 2), restoreWidthUnits: signedWord(offset + 4), restoreHeightPixels: signedWord(offset + 6), backupXUnits: signedWord(offset + 8), backupYPixels: signedWord(offset + 10), collisionEnabled: signedWord(offset + 12) != 0, collisionLeftOffsetUnits: signedWord(offset + 14), collisionWidthUnits: signedWord(offset + 16))
        }
    }
    func objects(scene: Int, energyMachineSlot: Int? = nil) -> [OriginalWorldObject] {
        guard scenes.indices.contains(scene) else { return [] }
        return scenes[scene].map { object in
            guard scene*4+object.slot == energyMachineSlot else { return object }
            return OriginalWorldObject(slot: object.slot,kind: 9,startUnit: object.startUnit,drawY: 37,endUnit: object.startUnit+12,sprite: 195)
        }
    }
    func object(scene: Int, overlappingPlayerAt unit: Int, energyMachineSlot: Int? = nil) -> OriginalWorldObject? {
        guard scenes.indices.contains(scene) else { return nil }
        // Original FUN_11b0_0a5c scans all four slots; the final matching slot wins.
        return objects(scene: scene,energyMachineSlot: energyMachineSlot).last { $0.overlapsPlayer(at: unit) }
    }
    static func adjacentHallway(_ scene: Int, direction: Int) -> Int? {
        guard (0...9).contains(scene), direction == -1 || direction == 1,
              (0...4).contains(scene % 5 + direction) else { return nil }
        return scene + direction
    }
    static func elevatorDestination(from hallway: Int) -> Int? {
        switch hallway { case 0: return 5; case 5: return 0; case 4: return 9; case 9: return 4; default: return nil }
    }
    static func roomScene(throughHallway hallway: Int) -> Int? {
        switch hallway { case 1: return 10; case 3: return 12; case 6: return 13; case 7: return 14; case 8: return 15; default: return nil }
    }
    static func hallway(forRoom scene: Int) -> Int? {
        switch scene { case 10: return 1; case 12: return 3; case 13: return 6; case 14: return 7; case 15: return 8; default: return nil }
    }
    static func backgroundSelector(forRoom scene: Int) -> Int? {
        switch scene { case 10: return 191; case 12: return 193; case 13: return 197; case 14: return 198; case 15: return 196; default: return nil }
    }
    static func elevatorExitScreenUnit(from hallway: Int) -> Int? {
        switch hallway { case 0, 5: return 12; case 4, 9: return 24; default: return nil }
    }
    static let jumpYOffsets = [-12, -24, -36, -48, -36, -24, -12, 0]
    static func flipXOffsets(facing: Int) -> [Int] { (1...8).map { $0 * 16 * (facing < 0 ? -1 : 1) } }

    static func selfChecks(resource: Data) throws -> [String: Bool] {
        let world = try OriginalWorld(resource: resource)
        var checks: [String: Bool] = [:]
        checks["world_sixteen_records"] = world.scenes.count == 16 && world.scenes.allSatisfy { $0.count == 4 }
        checks["world_thirty_five_animations"] = world.animations.count == 35
        checks["world_six_actors"] = world.actors.count == 6
        checks["world_exact_ten_challenges"] = world.scenes.flatMap { $0 }.compactMap(\.challengeIndex).sorted() == Array(0...9)
        checks["world_news_door"] = roomScene(throughHallway: 1) == 10 && backgroundSelector(forRoom: 10) == 191
        checks["world_game_show_door"] = roomScene(throughHallway: 3) == 12 && backgroundSelector(forRoom: 12) == 193
        checks["world_cartoon_door"] = roomScene(throughHallway: 6) == 13
        checks["world_equipment_door"] = roomScene(throughHallway: 7) == 14
        checks["world_sound_door"] = roomScene(throughHallway: 8) == 15
        checks["world_lobby_has_no_invented_room"] = roomScene(throughHallway: 2) == nil && hallway(forRoom: 11) == nil
        checks["world_elevators_are_paired"] = [0,4,5,9].allSatisfy { elevatorDestination(from: elevatorDestination(from: $0)!) == $0 }
        checks["world_floor_edges_stay_separate"] = adjacentHallway(4, direction: 1) == nil && adjacentHallway(5, direction: -1) == nil
        checks["world_contiguous_hallway"] = adjacentHallway(2, direction: -1) == 1 && adjacentHallway(7, direction: 1) == 8
        checks["world_room_round_trip"] = [1,3,6,7,8].allSatisfy { hallway(forRoom: roomScene(throughHallway: $0)!) == $0 }
        checks["world_last_overlapping_hotspot_wins"] = world.object(scene: 10, overlappingPlayerAt: 10)?.kind == 12
        checks["world_strict_near_edge"] = world.object(scene: 10, overlappingPlayerAt: 9)?.kind == 1
        checks["world_exclusive_hotspot_end"] = world.object(scene: 10, overlappingPlayerAt: 18) == nil
        checks["world_full_walk_cycle"] = world.animations[2].frames == Array(1...8) && world.animations[2].ticksPerFrame == 1
        checks["world_flip_frames"] = world.animations[8].frames == [34,35,36,37,38,39,35,34]
        checks["world_flip_returns_to_ground"] = jumpYOffsets.count == 8 && jumpYOffsets.last == 0 && flipXOffsets(facing: 1).last == 128
        checks["world_player_start"] = world.actors[3].xUnits == 20 && world.actors[3].yPixels == 81 && world.actors[3].restoreWidthUnits == 6 && world.actors[3].restoreHeightPixels == 64
        checks["world_background_y_fifteen"] = backgroundOrigin.y == 15
        checks["world_candidate_fountain_positions"] = energyMachineCandidates.count == 9 && energyMachineCandidates.allSatisfy { world.scenes[$0 / 4][$0 % 4].kind == 0 }
        return checks
    }
}
