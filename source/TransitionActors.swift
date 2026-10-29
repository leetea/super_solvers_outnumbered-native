import Foundation

extension NativeGameView {
    //11b0:1559(0): Telly, player step sound, projectile, LiveWire. Context
    //uses player X before its pose movement. Spawning and main-loop collisions
    //are disabled here, but actor motion, animation and RNG are not frozen.
    func updateTransitionActors(at position: NativePosition,playerStepSound: Int? = nil) {
        var enemy = session.telly ?? (try! OriginalTelly(tier: session.decoder.difficulty))
        enemy.beginFrame()
        var generator = session.generator
        let screenX = position.scene < 10 ? position.playerUnit-position.cameraUnit : position.playerUnit
        let context = OriginalTellyContext(hallway: position.scene < 10,allowSpawning: false,playerHasMoved: true,cameraSegment: position.cameraUnit/38,playerScreenUnit: screenX,capturedCodePieces: session.decoder.capturedCount)
        for sound in enemy.step(context: context,nextRandom: { generator.nextRandomValue() }).sounds { effect(sound) }
        if let playerStepSound { effect(playerStepSound) }
        for sound in enemy.stepProjectile().sounds { effect(sound) }
        session.generator = generator; session.telly = enemy
        if position.scene >= 10, var wire = session.liveWire {
            wire.beginFrame()
            for sound in wire.step().sounds { effect(sound) }
            session.liveWire = wire
        }
        updateRoomCamera(at: position)
    }
    func transitionWalkSound(at position: NativePosition,ordinal: Int?) -> Int? {
        guard let ordinal, (1...8).contains(ordinal) else { return nil }
        let hallway = position.scene < 10 ? position.scene : OriginalWorld.hallway(forRoom: position.scene)!
        return (position.scene < 10 ? 1 : 4)+(hallway >= 5 ? 1 : 0)
    }
}
