import Foundation

//135d:039b/0243: four panel frames and eight vertical bands use23IRQ;
//pose helper09af uses24IRQ. Alignment copies use the documented native4IRQ.
struct NativeElevatorTransition: Codable {
    let origin: NativePosition
    let startUnit: Int
    var elapsedIRQTicks = 0
    var destinationApplied = false
    var travelSoundStarted = false
    struct Frame {
        let position: NativePosition
        let ordinal: Int?
        let y: Int
        let panel: Int?
        let drawsPanels: Bool
        let playerInFront: Bool
        let scrollPixels: Int
        let destination: Bool
        let ticks: Int
    }
    var aligned: NativePosition { NativePosition(scene: origin.scene,playerUnit: origin.scene*38+startUnit+5,cameraUnit: origin.cameraUnit,facing: 1) }
    var exitPosition: NativePosition {
        let hall = OriginalWorld.elevatorDestination(from: origin.scene)!
        return NativePosition(scene: hall,playerUnit: hall*38+OriginalWorld.elevatorExitScreenUnit(from: origin.scene)!,cameraUnit: hall*38,facing: 1)
    }
    var finalPosition: NativePosition {
        var position = exitPosition; position.facing = origin.scene%5 == 0 ? 1 : -1; return position
    }
    var frames: [Frame] {
        var result: [Frame] = []
        func append(_ position: NativePosition,_ ordinal: Int?,_ y: Int,_ panel: Int? = nil,_ panels: Bool = false,_ front: Bool = true,_ scroll: Int = 0,_ destination: Bool = false,_ ticks: Int = 24) {
            result.append(Frame(position: position,ordinal: ordinal,y: y,panel: panel,drawsPanels: panels,playerInFront: front,scrollPixels: scroll,destination: destination,ticks: ticks))
        }
        let delta = aligned.playerUnit-origin.playerUnit
        if delta != 0 { for offset in 1...abs(delta) {
            var position = origin; position.playerUnit += offset*(delta < 0 ? -1 : 1); position.facing = delta < 0 ? -1 : 1
            append(position,1+(offset-1)%8,81,nil,false,true,0,false,4)
        } }
        for i in 0..<5 { append(aligned,9+i,78-i*3) }
        for panel in [177,176,175,nil] { append(aligned,13,66,panel,true,true,0,false,23) }
        for i in 0..<4 { append(aligned,19+i,62-i*4,nil,true) }
        for panel in 175...178 { append(aligned,22,50,panel,true,false,0,false,23) }
        for band in 1...8 { append(aligned,nil,50,nil,false,false,band == 8 ? 146 : band*18,false,23) }
        for panel in [177,176,175,nil] { append(exitPosition,23,50,panel,true,false,0,true,23) }
        for i in 0..<4 { append(exitPosition,23+i,54+i*4,nil,true,true,0,true) }
        for i in 0..<5 { append(exitPosition,14+i,69+i*3,nil,true,true,0,true) }
        for panel in 175...178 { append(exitPosition,18,81,panel,true,true,0,true,23) }
        return result
    }
    var duration: Int { frames.reduce(0) { $0+$1.ticks } }
    var currentFrame: Frame {
        var remainder = elapsedIRQTicks
        for frame in frames { if remainder < frame.ticks { return frame }; remainder -= frame.ticks }
        return frames.last!
    }
    var valid: Bool {
        guard origin.valid, OriginalWorld.elevatorDestination(from: origin.scene) != nil,
              startUnit == (origin.scene%5 == 0 ? 6 : 18) else { return false }
        let frame = currentFrame
        return (0...duration).contains(elapsedIRQTicks) && destinationApplied == frame.destination && travelSoundStarted == (frame.scrollPixels > 0 || frame.destination)
    }
}
