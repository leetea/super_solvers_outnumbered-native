import Foundation

//135d:072b/0a1c and09af. Unpaced104b:04de copies are presented for
//4 IRQ ticks (~one native60Hz refresh); this is a native timing adaptation.
struct NativeDoorTransition: Codable {
    let entering: Bool
    let origin: NativePosition
    let hallway: NativePosition
    let doorStartUnit: Int
    var elapsedIRQTicks = 0
    var auxiliaryFramesApplied: Int? = 0 // nil in pre-0.17 saves
    var usesOriginalMovement: Bool? = true // nil retains pre-0.18 frame positions
    var destinationApplied = false
    struct Frame {
        let position: NativePosition
        let ordinal: Int
        let y: Int
        let doorOrdinal: Int?
        let ticks: Int
        let destination: Bool
    }
    var destination: NativePosition {
        entering ? NativePosition(scene: OriginalWorld.roomScene(throughHallway: hallway.scene)!,playerUnit: 5,cameraUnit: 0,facing: 1) : hallway
    }
    var frames: [Frame] {
        var result: [Frame] = []
        let aligned = entering ? hallway : NativePosition(scene: origin.scene,playerUnit: 5,cameraUnit: 0,facing: 1)
        let delta = aligned.playerUnit-origin.playerUnit
        if delta != 0 {
            let recovered = usesOriginalMovement == true ? OriginalMovement.alignment(from: origin,to: aligned.playerUnit) : []
            for offset in 1...abs(delta) {
                var position = recovered.isEmpty ? origin : recovered[offset-1]
                if recovered.isEmpty { position.playerUnit += offset*(delta < 0 ? -1 : 1) }
                position.facing = origin.facing
                result.append(Frame(position: position,ordinal: 1+(offset-1)%8,y: 81,doorOrdinal: nil,ticks: 4,destination: false))
            }
        }
        for index in 0..<5 {
            result.append(Frame(position: aligned,ordinal: 9+index,y: 78-index*3,doorOrdinal: nil,ticks: 24,destination: false))
        }
        if entering {
            for panel in 134...136 { result.append(Frame(position: aligned,ordinal: 13,y: 66,doorOrdinal: panel,ticks: 4,destination: false)) }
        }
        for index in 0..<4 {
            result.append(Frame(position: aligned,ordinal: 19+index,y: 62-index*4,doorOrdinal: entering ? 136 : nil,ticks: 24,destination: false))
        }
        for index in 0..<4 {
            result.append(Frame(position: destination,ordinal: 23+index,y: 54+index*4,doorOrdinal: entering ? nil : 136,ticks: 24,destination: true))
        }
        if !entering {
            for panel in stride(from: 136,through: 134,by: -1) { result.append(Frame(position: destination,ordinal: 18,y: 66,doorOrdinal: panel,ticks: 4,destination: true)) }
        }
        for index in 0..<5 {
            result.append(Frame(position: destination,ordinal: 14+index,y: 69+index*3,doorOrdinal: entering ? nil : 134,ticks: 24,destination: true))
        }
        return result
    }
    var duration: Int { frames.reduce(0) { $0+$1.ticks } }
    var currentFrameIndex: Int {
        var remainder = elapsedIRQTicks
        for (index,frame) in frames.enumerated() { if remainder < frame.ticks { return index }; remainder -= frame.ticks }
        return frames.count-1
    }
    var currentFrame: Frame { frames[currentFrameIndex] }
    var valid: Bool {
        guard origin.valid, hallway.valid, OriginalWorld.roomScene(throughHallway: hallway.scene) != nil,
              (1...30).contains(doorStartUnit), hallway.playerUnit == hallway.scene*38+doorStartUnit+1,
              hallway.facing == 1, entering ? origin.scene == hallway.scene : origin.scene == OriginalWorld.roomScene(throughHallway: hallway.scene) else { return false }
        return (0...duration).contains(elapsedIRQTicks) && (auxiliaryFramesApplied == nil || auxiliaryFramesApplied == currentFrameIndex+1) && destinationApplied == (currentFrame.destination || elapsedIRQTicks == duration)
    }
}
