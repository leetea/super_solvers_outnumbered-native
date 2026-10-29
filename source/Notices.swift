import Foundation

//1862:0305: type2 waits for Enter/Escape; type7 returns to its caller,
//which reads one key (the calculator switch accepts Enter only).
struct OriginalNotice {
    let text: String
    let title: String?
    var style = 2
    func layout(font: OriginalFont) -> OriginalConfirmation.Layout {
        let lines = text.components(separatedBy: "\n")
        let width = max(150,(lines.map { font.width(of: $0)+1 }.max() ?? 0)+29)
        let height = lines.count*10+35+(title == nil ? 0 : 12)
        let left = (320-width)/2,top = (200-height)/2
        return .init(left: left,top: top,right: left+width,bottom: top+height,textX: left+14,textY: top+(title == nil ? 9 : 20))
    }
    func accepts(_ code: UInt16) -> Bool { style == 7 || [36,76,53].contains(code) }
}

struct NativeOriginalNotice {
    let original: OriginalNotice
    let backdrop: [UInt8]
    let completion: (UInt16) -> Void
}

extension NativeGameView {
    func showOriginalNotice(_ original: OriginalNotice,completion: @escaping (UInt16) -> Void = { _ in }) {
        guard originalNotice == nil else { return }
        do {
            try render()
            originalNotice = NativeOriginalNotice(original: original,backdrop: canvas.pixels,completion: completion)
            modalDepth += 1;keyboard.flush();held.removeAll();needsDisplay = true
        } catch { present(error) }
    }
    func originalNoticeKey(_ event: GameInputEvent) {
        guard let notice = originalNotice,event.modifierFlags.intersection([.control,.command,.option]).isEmpty,
              notice.original.accepts(event.keyCode) else { return }
        originalNotice = nil;modalDepth -= 1;keyboard.flush();held.removeAll()
        notice.completion(event.keyCode);needsDisplay = true
    }
    func drawOriginalNotice(_ notice: NativeOriginalNotice) throws {
        canvas.clip = nil;canvas.restoreEndingRect(notice.backdrop,x: 0,y: 0,right: 319,bottom: 199)
        let font = try content.font("MOCKET.DAT.1393")
        let box = notice.original.layout(font: font)
        canvas.originalHelpPanel(left: box.left,top: box.top,right: box.right,bottom: box.bottom,title: notice.original.title,footer: notice.original.style == 2 ? "\u{85} to Continue" : "\u{84} to Go Back",font: font,bottomSeparator: 18,raisedTop: true)
        canvas.text(notice.original.text,font: font,x: box.textX,y: box.textY,color: 1,lineHeight: 10)
    }
}
