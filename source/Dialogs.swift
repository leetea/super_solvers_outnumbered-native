import Cocoa

struct OriginalConfirmation {
    let text: String
    let title: String?
    var selection: Int
    static func replay(won: Bool) -> Self {
        Self(text: won ? "Your score and rank have\nbeen saved.\n\nDo you or someone else want\nto play again?" : "The Master of Mischief has\ntaken over the TV station.\nNo points will be added to\nyour lifetime score, and\nyour rank will not change.\n\nDo you or someone else want\nto play again?",title: nil,selection: 1)
    }
    static func exit(saving: Bool) -> Self {
        Self(text: saving ? "You are about to exit\nthe program.\n\nYour game, score, and\nrank will be saved until\nthe next time you play.\n\nAre you sure you want to\nexit the program?" : "You are about to\nexit the program.\n\nAre you sure you\nwant to exit the\nprogram?",title: "Exit Program",selection: 0)
    }
    static let continueSaved = Self(text: "The last game you played was not\nfinished and is saved on this disk.\n\nIf you don't continue with your\nlast game now, you will lose the\npoints you earned during that game.\n\nDo you want to continue that saved\ngame?",title: nil,selection: 1)
    static func playAnother(practice: Bool) -> Self {
        Self(text: practice ? "Are you sure you want\nto stop playing Drill for\nSkill?" : "If you start another game,\nthe game you are now\nplaying will not be saved.\n\nAre you sure you want\nto start a new game?",title: "Play New Game",selection: 0)
    }
    static func newPlayer(practice: Bool) -> Self {
        Self(text: practice ? "You are about to go to the\nSign-In to start a new player.\n\nYour settings will be saved\nuntil the next time you play\nCustomized Drill for Skill.\n\nAre you sure you want to\nstart a new player?" : "You are about to go to the\nSign-In to start a new player.\n\nYour game, score, and rank\nwill be saved until the next\ntime you play.\n\nAre you sure you want to start\na new player?",title: "Start New Player",selection: 0)
    }
    static func remove(_ name: String) -> Self {
        //The native archive is recoverable. Keep this adaptation truthful.
        let lastLine = name.count > 8 ? name+"\nfrom the Sign-In list?" : name+" from the Sign-In list?"
        return Self(text: "When you remove a player's name,\nthat member leaves the Sign-In list.\nTheir score and saved game are kept.\n\nAre you sure you want to remove\n\(lastLine)",title: nil,selection: 0)
    }
    //1862:025d: arrows/Tab toggle; Y/N activate immediately; F1 ignored
    //when called with the confirmation's maximum selection1.
    mutating func key(_ code: UInt16,characters: String?) -> Int? {
        if code == 36 || code == 76 { return selection }
        if code == 53 { return -1 }
        if [48,123,124,125,126].contains(code) { selection ^= 1;return nil }
        if characters?.lowercased() == "y" { return 1 }
        if characters?.lowercased() == "n" { return 0 }
        return nil
    }
    struct Layout {
        let left: Int,top: Int,right: Int,bottom: Int,textX: Int,textY: Int
        //7312 is selection0 (No);7314 is selection1 (Yes).
        var noX: Int { right-55 }
        var yesX: Int { right-115 }
        var buttonY: Int { bottom-35 }
    }
    func displayText(font: OriginalFont) -> String {
        //Only legacy native names can exceed the original eight-character
        //limit. Wrap their display without changing stored names or IDs.
        var rows: [String] = []
        for line in text.components(separatedBy: "\n") {
            var row = ""
            for scalar in line.unicodeScalars {
                let next = row+String(scalar)
                if !row.isEmpty && font.width(of: next)+1 > 290 { rows.append(row);row = "" }
                row += String(scalar)
            }
            rows.append(row)
        }
        return rows.joined(separator: "\n")
    }
    func layout(font: OriginalFont) -> Layout {
        let lines = displayText(font: font).components(separatedBy: "\n")
        //1862:0305 width=max100,longest measured line+29), type3 adds25
        //to the common lines*10+20 height, and a title adds another12.
        let width = max(100,lines.map { font.width(of: $0)+1 }.max()!+29)
        let height = lines.count*10+45+(title == nil ? 0 : 12)
        let x = (320-width)/2,y = (200-height)/2
        return Layout(left: x,top: y,right: x+width,bottom: y+height,textX: x+14,textY: y+(title == nil ? 9 : 20))
    }
}

struct NativeConfirmation {
    var original: OriginalConfirmation
    let backdrop: [UInt8]
    let completion: (Int) -> Void
}

extension NativeGameView {
    func showConfirmation(_ original: OriginalConfirmation,completion: @escaping (Int) -> Void) {
        guard confirmation == nil else { return }
        do {
            try render()
            confirmation = NativeConfirmation(original: original,backdrop: canvas.pixels,completion: completion)
            keyboard.flush();held.removeAll();modalDepth += 1;needsDisplay = true
        } catch { present(error) }
    }
    func finishConfirmation(_ choice: Int) {
        guard let current = confirmation else { return }
        confirmation = nil;modalDepth -= 1;keyboard.flush();held.removeAll()
        if screen == .title { opening.restartWait();openingLastPulse = ProcessInfo.processInfo.systemUptime;openingFraction = 0 }
        current.completion(choice);needsDisplay = true
    }
    func confirmationKey(_ event: NSEvent) {
        guard confirmation != nil else { return }
        guard event.modifierFlags.intersection([.control,.command,.option]).isEmpty else { return }
        if event.keyCode == 48 && event.modifierFlags.contains(.shift) { return }
        if let choice = confirmation!.original.key(event.keyCode,characters: event.characters) { finishConfirmation(choice) }
        needsDisplay = true
    }
    func confirmationClick(x: Int,y: Int) {
        guard let dialog = confirmation,let font = try? content.font("MOCKET.DAT.1393") else { return }
        let layout = dialog.original.layout(font: font)
        guard (layout.buttonY+2...layout.buttonY+12).contains(y) else { return }
        if (layout.noX-4...layout.noX+44).contains(x) { finishConfirmation(0) }
        else if (layout.yesX-4...layout.yesX+44).contains(x) { finishConfirmation(1) }
    }
    func drawConfirmation(_ dialog: NativeConfirmation) throws {
        canvas.clip = nil;canvas.restoreEndingRect(dialog.backdrop,x: 0,y: 0,right: 319,bottom: 199)
        let font = try content.font("MOCKET.DAT.1393")
        let box = dialog.original.layout(font: font)
        canvas.originalHelpPanel(left: box.left,top: box.top,right: box.right,bottom: box.bottom,title: dialog.original.title,footer: "\u{84} to Go Back",font: font,bottomSeparator: 18,raisedTop: true)
        canvas.text(dialog.original.displayText(font: font),font: font,x: box.textX,y: box.textY,color: 1,lineHeight: 10)
        canvas.originalHelpButton("No",font: font,x: box.noX,y: box.buttonY,selected: dialog.original.selection == 0)
        canvas.originalHelpButton("Yes",font: font,x: box.yesX,y: box.buttonY,selected: dialog.original.selection == 1)
    }
}
