import Cocoa

extension NativeGameView {
    func prepareActivityState(_ challenge: OriginalChallenge,regenerating: Bool = false) throws {
        if regenerating {
            guard let state = challenge.post_generation_rng_state else { throw ContentError.invalid("Missing original question random state") }
            session.generator.restoreRandomState(state)
        }
        guard [4,7].contains(challenge.hotspot) else { return }
        if !regenerating && session.activityStates?[challenge.hotspot]?.matches(challenge) == true { return }
        var generator = session.generator
        if !regenerating, let state = challenge.post_generation_rng_state { generator.restoreRandomState(state) }
        let state = try OriginalActivityState.make(challenge,nextRandom: { generator.nextRandomValue() })
        session.generator = generator
        if session.activityStates == nil { session.activityStates = [:] }
        session.activityStates?[challenge.hotspot] = state
    }
    @objc func referenceSpinner() { activityCheckpoint(id: 9120,hotspot: 3,scene: 12) }
    @objc func referenceMusic() { activityCheckpoint(id: 9050,hotspot: 4,scene: 15) }
    @objc func referenceSupplies() { activityCheckpoint(id: 9040,hotspot: 7,scene: 14) }
    @objc func referenceJuniorQuestions() {
        session = NativeSession(profileID: UUID(),seed: 1,lifetimePoints: 5_000)
        session.position = NativePosition(scene: 10,playerUnit: 15,cameraUnit: 0,facing: 1)
        session.returnPosition = NativePosition(scene: 1,playerUnit: 52,cameraUnit: 38,facing: 1)
        referenceMode = true; screen = .world; held.removeAll(); interact()
    }
    func activityCheckpoint(id: Int,hotspot: Int,scene: Int) {
        session = NativeSession(profileID: UUID(),seed: 1,lifetimePoints: 30_000)
        session.position = NativePosition(scene: scene,playerUnit: 15,cameraUnit: 0,facing: 1)
        let hallway = OriginalWorld.hallway(forRoom: scene)!
        session.returnPosition = NativePosition(scene: hallway,playerUnit: hallway*38+15,cameraUnit: hallway*38,facing: 1)
        referenceMode = true; screen = .world
        if let fixture = bank.cases.first(where: { $0.id == id && $0.seed == 1 && $0.variant == 0 && $0.hotspot == hotspot }) { open(fixture) }
    }
}
