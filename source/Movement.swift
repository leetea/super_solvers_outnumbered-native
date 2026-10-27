import Foundation

//11b0:0b1b/0c96/0b6b, then1732. Camera shifts precede enemy and
//player updates. Keep signed animation motion separate from actor facing:
//door alignment can walk backwards without turning the actor.
struct OriginalMovement {
    let scrolled: NativePosition
    let destination: NativePosition
    let cameraShift: Int
    let horizontalArgument: Int
    static func frame(from origin: NativePosition,horizontal: Int,facing: Int) -> OriginalMovement {
        precondition([-1,1].contains(facing) && (-2...2).contains(horizontal))
        var prior = origin; prior.facing = facing
        let requested = horizontal*facing, magnitude = abs(horizontal)
        let screen = origin.playerUnit-origin.cameraUnit
        var shift = 0
        if origin.scene < 10 {
            let scene = origin.playerUnit/38
            if requested < 0 && screen >= 6 && screen-magnitude < 6 &&
                (![0,5].contains(scene) || scene*38 <= origin.cameraUnit-magnitude) {
                shift = -(6-(screen-magnitude))
            } else if requested > 0 && screen+magnitude >= 26 &&
                (![4,9].contains(scene) || scene*38 > origin.cameraUnit) {
                shift = screen+magnitude-26
            }
        }
        prior.cameraUnit += shift
        let x = prior.playerUnit-prior.cameraUnit
        let predicted = x+requested
        let actual = predicted <= 1 ? x-1 : (predicted >= 33 ? 33-x : horizontal)
        var next = prior; next.playerUnit += actual*facing
        if origin.scene < 10 { next.scene = next.playerUnit/38 }
        return OriginalMovement(scrolled: prior,destination: next,cameraShift: shift,horizontalArgument: actual)
    }
    static func alignment(from origin: NativePosition,to target: Int) -> [NativePosition] {
        var position = origin, frames: [NativePosition] = []
        //Original alignment requests exactly one world unit per update.
        for _ in 0..<abs(target-origin.playerUnit) {
            let direction = target < position.playerUnit ? -1 : 1
            position = frame(from: position,horizontal: direction*origin.facing,facing: origin.facing).destination
            frames.append(position)
        }
        return frames
    }
}
