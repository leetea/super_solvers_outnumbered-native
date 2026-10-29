#if os(Windows)
import Foundation
import OutnumberedHost

func runWindowsGame() {
    guard ow_open() != 0 else { ow_error("The Windows display or audio device could not be opened.");ow_close();return }
    defer { ow_close() }
    PlatformServices.showError = { ow_error($0) }
    PlatformSound.start = { _ = ow_sound($0.path) }
    PlatformSound.stopPlayback = { ow_stop_sound() }
    PlatformSound.playing = { ow_sound_playing() != 0 }
    PlatformServices.restore = { game,members in
        guard !members.isEmpty else { ow_error("There are no removed members.");return }
        game.modalDepth += 1;defer { game.modalDepth -= 1;game.lastZapPulse=ProcessInfo.processInfo.systemUptime;game.lastEndingPulse=game.lastZapPulse;game.openingLastPulse=game.lastZapPulse }
        var index=0
        while true {
            let choice=ow_choose_member(members[index].name)
            if choice==1 { do { try game.profileStore.restore(members[index].id);game.choosePlayer() } catch { game.present(error) };break }
            if choice != 2 { break };index=(index+1)%members.count
        }
    }
    do {
        let game=try NativeGameView(root:NativeApplication.assets)
        game.timer?.invalidate();game.zapTimer?.invalidate()
        let interval=Double(OriginalWorld.frameIRQTicks)*VerifiedClock.pitDivisor/VerifiedClock.pitInputHz
        var nextStep=ProcessInfo.processInfo.systemUptime+interval
        var nextPulse=ProcessInfo.processInfo.systemUptime
        var event=OWEvent()
        while !PlatformServices.shouldExit {
            while ow_poll(&event) != 0 {
                var input=GameInputEvent(keyCode:event.key,repeatKey:event.repeat != 0)
                input.modifierFlags = .init(rawValue:Int(event.modifiers))
                let text=withUnsafePointer(to:&event.text) { ptr in ptr.withMemoryRebound(to:CChar.self,capacity:64) { String(cString:$0) } }
                input.characters=text;input.charactersIgnoringModifiers=text
                switch event.type {
                case 1:game.confirmNativeExit()
                case 2:
                    if input.modifierFlags.contains(.control),input.modifierFlags.contains(.shift),text.lowercased()=="r",game.screen == .signin { game.restoreMember() }
                    else { game.keyDown(with:input) }
                case 3:game.keyUp(with:input)
                case 4:
                    if event.x>=0 && event.x<320 && event.y>=0 && event.y<200 { input.locationInWindow=GamePoint(x:Double(event.x),y:Double(event.y));game.mouseDown(with:input) }
                case 5:_ = game.resignFirstResponder()
                default:break
                }
            }
            let now=ProcessInfo.processInfo.systemUptime
            if now>=nextStep { game.step();nextStep=now+interval }
            if now>=nextPulse {
                game.pulseZap();nextPulse=now+1.0/60
                if game.needsDisplay { try game.render();let image=try game.canvas.representation();ow_frame(image.bitmapData);try game.recordPresentedFrame();game.needsDisplay=false }
            }
            ow_delay()
        }
        game.save()
    } catch { ow_error(error.localizedDescription) }
}
// CI uses dummy SDL devices: exercises the native host, not an interactive test.
func windowsHostSmokeTest() throws {
    guard ow_open() != 0 else { throw ContentError.invalid("SDL host failed to initialize") }
    defer { ow_close() }
    let temp=FileManager.default.temporaryDirectory.appendingPathComponent("outnumbered-host-"+UUID().uuidString)
    defer { try? FileManager.default.removeItem(at:temp) }
    let game=try NativeGameView(root:NativeApplication.assets,saveDirectory:temp,automaticallyPresentMessages:false)
    game.timer?.invalidate();game.zapTimer?.invalidate();game.soundEnabled=false
    try game.render();let image=try game.canvas.representation();ow_frame(image.bitmapData)
    for index in 0..<52 {
        let path=NativeApplication.assets.appendingPathComponent(String(format:"audio/effect-%02d.wav",index)).path
        guard ow_sound(path) != 0 else { throw ContentError.invalid("SDL WAV playback setup failed: \(index)") }
        ow_stop_sound()
    }
    print("{\"passed\":true,\"backend\":\"SDL3\",\"soundStreamsOpened\":52,\"interactiveVerified\":false}")
}
#endif
