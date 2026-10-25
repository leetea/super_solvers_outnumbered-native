import Foundation

// Original16c0:000b placement and1b03:013f interaction. The approach
// uses native simulation steps; the two player animations and dispenser
// waits retain original resource5000 frames and24/30IRQ timings.
struct NativeFountain: Codable {
    enum Phase { case approach, entering, dispensing, leaving, finished }
    let initialPlayerUnit: Int
    let targetPlayerUnit: Int
    let machineWorldUnit: Int
    let initialFacing: Int
    let credits: Int
    private(set) var elapsedIRQTicks = 0
    private(set) var awardIssued = false
    var distance: Int { abs(initialPlayerUnit-targetPlayerUnit) }
    var direction: Int { targetPlayerUnit >= initialPlayerUnit ? 1 : -1 }
    var dispenseStart: Int { distance*24+120 }
    var dispenseDuration: Int { credits > 0 ? 270 : 120 }
    var duration: Int { dispenseStart+dispenseDuration+120 }
    var sound: Int { credits > 0 ? 35 : 36 }
    var playerUnit: Int { initialPlayerUnit+direction*min(distance,elapsedIRQTicks/24) }
    var phase: Phase {
        if elapsedIRQTicks < distance*24 { return .approach }
        if elapsedIRQTicks < dispenseStart { return .entering }
        if elapsedIRQTicks < dispenseStart+dispenseDuration { return .dispensing }
        return elapsedIRQTicks < duration ? .leaving : .finished
    }
    var playerFrame: Int {
        switch phase {
        case .approach: return 1+(elapsedIRQTicks/24)%8
        case .entering: return [9,10,11,12,203][min(4,(elapsedIRQTicks-distance*24)/24)]
        case .dispensing: return 203
        case .leaving: return [14,15,16,17,18][min(4,(elapsedIRQTicks-dispenseStart-dispenseDuration)/24)]
        case .finished: return 0
        }
    }
    var machineSprite: Int {
        guard phase == .dispensing else { return 195 }
        let index = (elapsedIRQTicks-dispenseStart)/30
        return credits > 0 ? 196+index%2 : 199+index%3
    }
    var facing: Int { phase == .approach ? direction : (phase == .finished ? initialFacing : 1) }
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
    }
}
