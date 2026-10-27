import Cocoa

extension NativeGameView {
    func ensureRoomCamera() {
        guard session.roomCamera == nil else { return }
        var camera = NativeRoomCamera()
        if session.position.scene >= 10 && (session.activeEnding == nil || session.activeEnding?.reason == .midnight) { camera.start() }
        session.roomCamera = camera
    }
    func startRoomCamera() {
        var camera = session.roomCamera ?? NativeRoomCamera();camera.start();session.roomCamera = camera
    }
    func stopRoomCamera() {
        var camera = session.roomCamera ?? NativeRoomCamera();camera.stop();session.roomCamera = camera
    }
    func disableRoomCamera() { session.roomCamera?.disable() }
    func updateRoomCamera(at position: NativePosition) {
        guard position.scene >= 10 else { return }
        ensureRoomCamera();session.roomCamera?.step()
    }
    func drawRoomCamera(at position: NativePosition) throws {
        guard position.scene >= 10 else { return }
        //A legacy room snapshot has no historical phase; show the initial
        //pose until its first simulation update initializes the new state.
        if let camera = session.roomCamera, !camera.active { return }
        canvas.draw(try content.bitmap(String(format:"ROOMS.GRA.%03d",session.roomCamera?.sprite ?? 3)),x: world.actors[2].xUnits*8,y: world.actors[2].yPixels,transparent: true)
    }
}
