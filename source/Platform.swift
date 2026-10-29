import Foundation
#if canImport(AppKit) && !OUTNUMBERED_PORTABLE
import AppKit
#endif

struct GamePoint { var x:Double;var y:Double;static let zero=Self(x:0,y:0) }
struct GameViewport { var width:Double;var height:Double }

// Codes identify the existing logical game controls, never Windows virtual keys.
struct GameInputEvent {
    enum EventType { case keyDown, keyUp }
    struct ModifierFlags: OptionSet {
        let rawValue: Int
        static let shift = Self(rawValue:1), control = Self(rawValue:2), command = Self(rawValue:4), option = Self(rawValue:8)
    }
    var keyCode: UInt16
    var characters: String?
    var charactersIgnoringModifiers: String?
    var isARepeat: Bool
    var modifierFlags: ModifierFlags = []
    var locationInWindow: GamePoint
    init(keyCode:UInt16,characters:String = "",repeatKey:Bool = false,location:GamePoint = .zero) {
        self.keyCode=keyCode;self.characters=characters;self.charactersIgnoringModifiers=characters;self.isARepeat=repeatKey;self.locationInWindow=location
    }
    static func keyEvent(with type:EventType,location:GamePoint,modifierFlags:ModifierFlags,timestamp:Double,windowNumber:Int,context:Any?,characters:String,charactersIgnoringModifiers:String,isARepeat:Bool,keyCode:UInt16) -> Self? {
        var event=Self(keyCode:keyCode,characters:characters,repeatKey:isARepeat,location:location)
        event.modifierFlags=modifierFlags;event.charactersIgnoringModifiers=charactersIgnoringModifiers;return event
    }
}

final class RasterImage {
    let bitmapData: UnsafeMutablePointer<UInt8>?
    init(pixels:[UInt8],palette:[(UInt8,UInt8,UInt8)]) {
        let data=UnsafeMutablePointer<UInt8>.allocate(capacity:320*200*4)
        for i in pixels.indices { let c=palette[Int(pixels[i])];data[i*4]=c.0;data[i*4+1]=c.1;data[i*4+2]=c.2;data[i*4+3]=255 }
        bitmapData=data
    }
    deinit { bitmapData?.deallocate() }
    // Small dependency-free PNG encoder: filter 0, stored DEFLATE blocks.
    func png() -> Data {
        func be(_ n:UInt32)->[UInt8] { [UInt8(truncatingIfNeeded:n>>24),UInt8(truncatingIfNeeded:n>>16),UInt8(truncatingIfNeeded:n>>8),UInt8(truncatingIfNeeded:n)] }
        func chunk(_ name:String,_ bytes:[UInt8])->[UInt8] {
            let payload=Array(name.utf8)+bytes
            var crc:UInt32=0xffffffff
            for b in payload { crc ^= UInt32(b);for _ in 0..<8 { crc=(crc>>1)^((crc&1)==1 ? 0xedb88320:0) } }
            return be(UInt32(bytes.count))+payload+be(crc ^ 0xffffffff)
        }
        var raw=[UInt8]();raw.reserveCapacity(256200)
        for y in 0..<200 { raw.append(0);raw.append(contentsOf:UnsafeBufferPointer(start:bitmapData!+y*1280,count:1280)) }
        var z:[UInt8]=[0x78,0x01],offset=0
        while offset<raw.count { let count=min(65535,raw.count-offset);z.append(offset+count==raw.count ? 1:0);let n=UInt16(count),inverse = ~n;z += [UInt8(truncatingIfNeeded:n),UInt8(n>>8),UInt8(truncatingIfNeeded:inverse),UInt8(inverse>>8)];z.append(contentsOf:raw[offset..<offset+count]);offset+=count }
        var a:UInt32=1,b:UInt32=0
        for value in raw { a=(a+UInt32(value))%65521;b=(b+a)%65521 };z += be((b<<16)|a)
        return Data([137,80,78,71,13,10,26,10]+chunk("IHDR",be(320)+be(200)+[8,6,0,0,0])+chunk("IDAT",z)+chunk("IEND",[]))
    }
}

#if canImport(AppKit) && !OUTNUMBERED_PORTABLE
typealias PlatformSound = NSSound
enum PlatformServices {
    static func exit() { NSApplication.shared.terminate(nil) }
    static func error(_ message:String) { let alert=NSAlert();alert.messageText="Outnumbered";alert.informativeText=message;alert.runModal() }
    static func restoreMember(_ game:NativeGameView,_ members:[NativeProfile]) {
        let alert=NSAlert();alert.messageText="Restore Removed Member"
        guard !members.isEmpty else { alert.informativeText="There are no removed members.";alert.runModal();return }
        let picker=NSPopUpButton(frame:NSRect(x:0,y:0,width:260,height:28));picker.addItems(withTitles:members.map(\.name));alert.accessoryView=picker;alert.addButton(withTitle:"Restore");alert.addButton(withTitle:"Cancel")
        game.modalDepth+=1;defer { game.modalDepth-=1 }
        if alert.runModal() == .alertFirstButtonReturn { do { try game.profileStore.restore(members[picker.indexOfSelectedItem].id);game.choosePlayer() } catch { game.present(error) } }
    }
}
#else
final class PlatformSound {
    static var start: ((URL)->Void)?
    static var stopPlayback: (()->Void)?
    static var playing: (()->Bool)?
    let url:URL
    init?(contentsOf url:URL,byReference:Bool) { self.url=url }
    var isPlaying:Bool { Self.playing?() ?? false }
    func stop() { Self.stopPlayback?() }
    func play() { Self.start?(url) }
}
enum PlatformServices {
    static var shouldExit=false
    static var showError: ((String)->Void)?
    static var restore: ((NativeGameView,[NativeProfile])->Void)?
    static func exit() { shouldExit=true }
    static func error(_ message:String) { showError?(message) }
    static func restoreMember(_ game:NativeGameView,_ members:[NativeProfile]) { restore?(game,members) }
}
#endif
