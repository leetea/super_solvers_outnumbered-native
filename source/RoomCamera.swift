import Foundation

//Actor2, MOCKET.DAT5000 row14;1b03:00f6/0119/0132.
//This is the room's ceiling security camera, not the energy machine.
struct NativeRoomCamera: Codable {
    static let frames = [3,4,5,6,7,6,5,4]
    var active = false
    var nextFrame = 0
    var ticksLeft = 4 // simulation updates, each24IRQ
    var sprite = 3
    mutating func start() { active = true;sprite = 3 }
    mutating func disable() { active = false } // direct flag clear during game/ending setup
    mutating func stop() { active = false;nextFrame = 0 } // source leaves hold counter intact
    mutating func step() {
        guard active else { return }
        sprite = Self.frames[nextFrame];ticksLeft -= 1
        if ticksLeft == 0 { ticksLeft = 4;nextFrame = (nextFrame+1)%Self.frames.count }
    }
    var valid: Bool { (0..<8).contains(nextFrame) && (1...4).contains(ticksLeft) && (3...7).contains(sprite) }
}
