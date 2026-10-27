import Foundation

//MOCKET.DAT5000 rows and11b0:13b9/1732/135d:0cf5.
//State selected after a frame may differ from the sprite just drawn.
struct NativePlayerMotion: Codable {
    static let frames: [Int:[Int]] = [1:[0],2:Array(1...8),8:[34,35,36,37,38,39,35,34],9:[27,28,29,28,27,30,31,32,33],26:[40,41,42,43,43,43,43],27:[99,99,99,99,30,31,32,33],28:[44,45,46,44,45,46,44,35,35],30:[10008,10009,10008,10009]]
    var animation = 1
    var remaining = 1
    var horizontal = 0
    var vertical = 0
    var nextFrame = 0
    var sprite = 0
    var y = 81
    var displayedAnimation = 1
    var restoreWidth = 6
    var airborne: Bool { animation == 8 }
    var settled: Bool { animation < 3 }
    @discardableResult mutating func request(_ type: Int,horizontal: Int = 0,vertical: Int = 0,count: Int = -1) -> Bool {
        precondition(Self.frames[type] != nil)
        guard animation < 3 || type > 8 || remaining < 1 else { return false }
        animation = type; remaining = count == -1 ? Self.frames[type]!.count : count
        self.horizontal = horizontal; self.vertical = vertical; nextFrame = 0
        return true
    }
    mutating func walk(_ moving: Bool) {
        if moving { if animation != 2 { request(2,horizontal: 1,count: 1) } }
        else if animation == 2 { request(1,count: 1) }
    }
    //Called after camera/enemy preparation, before projectile/room actors.
    mutating func advance(horizontalArgument: Int,position: NativePosition) -> [Int] {
        let old = animation
        restoreWidth = old < 9 ? 6 : 10
        if horizontalArgument == 0 && old == 2 {
            request(9);remaining -= 1;restoreWidth = 8
        }
        if old == 8 && remaining == Self.frames[8]!.count/2 { vertical = -vertical }
        y += vertical
        sprite = Self.frames[animation]![nextFrame]
        displayedAnimation = animation
        nextFrame = (nextFrame+1)%Self.frames[animation]!.count
        if old < 3 {
            let hall = position.scene < 10 ? position.scene : OriginalWorld.hallway(forRoom: position.scene)!
            return [(position.scene < 10 ? 1 : 4)+(hall >= 5 ? 1 : 0)]
        }
        remaining -= 1
        var sounds: [Int] = []
        if old == 9 && remaining == 3 { sounds.append(20) }
        if remaining < 1 {
            if old == 9 || old == 27 { request(28) }
            else {
                if [8,26,28].contains(old) { sounds.append(38) }
                request(1,count: 1)
            }
        }
        return sounds
    }
    var valid: Bool {
        guard let frames = Self.frames[animation],Self.frames[displayedAnimation] != nil else { return false }
        return (0..<frames.count).contains(nextFrame) && (0...9).contains(remaining) && (-2...2).contains(horizontal) && [-12,0,12].contains(vertical) && (33...81).contains(y) && [6,8,10].contains(restoreWidth) && Self.frames[displayedAnimation]!.contains(sprite)
    }
}

//11b0:14fe waits200IRQ on a collision word before160c starts knockback.
struct NativeCollisionFlash: Codable {
    let actor: Int
    let sameFacing: Bool
    let projectileKind: Int
    let xUnit: Int
    var elapsedIRQTicks = 0
    var effect: OriginalCollisionEffect { OriginalCollisionEffect.forActor(actor,sameFacing: sameFacing,projectileKind: projectileKind)! }
    var valid: Bool { [4,5].contains(actor) && (22...25).contains(projectileKind) && (-3...34).contains(xUnit) && (0...200).contains(elapsedIRQTicks) }
}
