import Foundation

// Original16c0:000b placement and1b03:013f interaction. The approach
// uses the documented4IRQ native adaptation for unpaced copies; the two
// player animations and dispenser waits retain24/30IRQ timings. Nil origin
// retains the pre0.20 in-progress action's timing/positions on decode.
struct NativeFountain: Codable {
    enum Phase { case approach, entering, dispensing, leaving, finished }
    let initialPlayerUnit: Int
    let targetPlayerUnit: Int
    let machineWorldUnit: Int
    let initialFacing: Int
    let credits: Int
    let origin: NativePosition?
    var auxiliaryFramesApplied: Int? = 0
    private(set) var elapsedIRQTicks = 0
    private(set) var awardIssued = false
    var distance: Int { abs(initialPlayerUnit-targetPlayerUnit) }
    var direction: Int { targetPlayerUnit >= initialPlayerUnit ? 1 : -1 }
    init(initialPlayerUnit: Int,targetPlayerUnit: Int,machineWorldUnit: Int,initialFacing: Int,credits: Int,origin: NativePosition? = nil) {
        self.initialPlayerUnit = initialPlayerUnit;self.targetPlayerUnit = targetPlayerUnit;self.machineWorldUnit = machineWorldUnit;self.initialFacing = initialFacing;self.credits = credits;self.origin = origin
    }
    var alignmentTicks: Int { distance*(origin == nil ? 24 : 4) }
    var dispenseStart: Int { alignmentTicks+120 }
    var dispenseDuration: Int { credits > 0 ? 270 : 120 }
    var duration: Int { dispenseStart+dispenseDuration+120 }
    var sound: Int { credits > 0 ? 35 : 36 }
    var playerUnit: Int { origin == nil ? initialPlayerUnit+direction*min(distance,elapsedIRQTicks/24) : currentFrame.position.playerUnit }
    var phase: Phase {
        if elapsedIRQTicks < alignmentTicks { return .approach }
        if elapsedIRQTicks < dispenseStart { return .entering }
        if elapsedIRQTicks < dispenseStart+dispenseDuration { return .dispensing }
        return elapsedIRQTicks < duration ? .leaving : .finished
    }
    var playerFrame: Int {
        if origin != nil { return phase == .finished ? 0 : currentFrame.ordinal }
        switch phase {
        case .approach: return 1+(elapsedIRQTicks/24)%8
        case .entering: return [9,10,11,12,203][min(4,(elapsedIRQTicks-distance*24)/24)]
        case .dispensing: return 203
        case .leaving: return [14,15,16,17,18][min(4,(elapsedIRQTicks-dispenseStart-dispenseDuration)/24)]
        case .finished: return 0
        }
    }
    var playerY: Int { origin == nil || phase == .finished ? 81 : currentFrame.y }
    var machineSprite: Int {
        guard phase == .dispensing else { return 195 }
        let index = (elapsedIRQTicks-dispenseStart)/30
        return credits > 0 ? 196+index%2 : 199+index%3
    }
    var facing: Int { phase == .finished ? initialFacing : (origin == nil ? (phase == .approach ? direction : 1) : currentFrame.position.facing) }
    struct Frame {
        let position: NativePosition
        let ordinal: Int
        let y: Int
        let ticks: Int
        let phase: Phase
        var updatesActors: Bool { phase != .dispensing }
    }
    var frames: [Frame] {
        guard let origin else { return [] }
        let approach = OriginalMovement.alignment(from: origin,to: targetPlayerUnit)
        var aligned = approach.last ?? origin;aligned.facing = 1
        var result = approach.enumerated().map { Frame(position: $0.element,ordinal: 1+$0.offset%8,y: 81,ticks: 4,phase: .approach) }
        for (i,ordinal) in [9,10,11,12,203].enumerated() { result.append(Frame(position: aligned,ordinal: ordinal,y: 78-i*3,ticks: 24,phase: .entering)) }
        for _ in 0..<(credits > 0 ? 9 : 4) { result.append(Frame(position: aligned,ordinal: 203,y: 66,ticks: 30,phase: .dispensing)) }
        for i in 0..<5 { result.append(Frame(position: aligned,ordinal: 14+i,y: 69+i*3,ticks: 24,phase: .leaving)) }
        return result
    }
    var currentFrameIndex: Int {
        var ticks = elapsedIRQTicks
        for (i,frame) in frames.enumerated() { if ticks < frame.ticks { return i };ticks -= frame.ticks }
        return max(0,frames.count-1)
    }
    var currentFrame: Frame { frames[currentFrameIndex] }
    // Report entry into dispensing once, including across native save/resume.
    mutating func advance(irqTicks: Int) -> Bool {
        guard irqTicks >= 0 else { return false }
        elapsedIRQTicks += min(irqTicks,duration-elapsedIRQTicks)
        guard !awardIssued, elapsedIRQTicks >= dispenseStart else { return false }
        awardIssued = true; return true
    }
    var valid: Bool {
        (1...375).contains(initialPlayerUnit) && (1...375).contains(targetPlayerUnit) &&
        (0...374).contains(machineWorldUnit) && targetPlayerUnit == machineWorldUnit+1 &&
        abs(initialPlayerUnit-targetPlayerUnit) <= 38 && [-1,1].contains(initialFacing) &&
        (0...20).contains(credits) && (0...duration).contains(elapsedIRQTicks) &&
        awardIssued == (elapsedIRQTicks >= dispenseStart)
        && (origin == nil || (origin!.valid && origin!.scene < 10 && origin!.playerUnit == initialPlayerUnit && origin!.facing == initialFacing && (auxiliaryFramesApplied == nil || auxiliaryFramesApplied == currentFrameIndex+1)))
    }
}
