import Cocoa

//Decoded original DS4ecc/50ca records. Data only; no original CPU code.
struct OriginalSettingsControl {
    let kind: Int,x: Int,y: Int,text: String,neighbors: [Int]
    static let practice: [Self] = [
        .init(kind: 0,x: 53,y: 43,text: "Type of Problems:",neighbors: [255, 255, 255, 255, 255, 255]),
        .init(kind: 1,x: 55,y: 53,text: "Addition",neighbors: [2, 2, 3, 24, 24, 6]),
        .init(kind: 1,x: 175,y: 53,text: "Multiplication",neighbors: [1, 1, 4, 27, 24, 6]),
        .init(kind: 1,x: 55,y: 64,text: "Subtraction",neighbors: [4, 4, 6, 1, 24, 6]),
        .init(kind: 1,x: 175,y: 64,text: "Division",neighbors: [3, 3, 9, 2, 24, 6]),
        .init(kind: 0,x: 53,y: 80,text: "Numbers Used in Drill Problems:",neighbors: [255, 255, 255, 255, 255, 255]),
        .init(kind: 1,x: 55,y: 90,text: "0",neighbors: [10, 7, 11, 3, 1, 20]),
        .init(kind: 1,x: 95,y: 90,text: "1",neighbors: [6, 8, 12, 3, 1, 20]),
        .init(kind: 1,x: 135,y: 90,text: "2",neighbors: [7, 9, 13, 3, 1, 20]),
        .init(kind: 1,x: 175,y: 90,text: "3",neighbors: [8, 10, 14, 4, 1, 20]),
        .init(kind: 1,x: 215,y: 90,text: "4",neighbors: [9, 6, 15, 4, 1, 20]),
        .init(kind: 1,x: 55,y: 101,text: "5",neighbors: [15, 12, 16, 6, 1, 20]),
        .init(kind: 1,x: 95,y: 101,text: "6",neighbors: [11, 13, 17, 7, 1, 20]),
        .init(kind: 1,x: 135,y: 101,text: "7",neighbors: [12, 14, 18, 8, 1, 20]),
        .init(kind: 1,x: 175,y: 101,text: "8",neighbors: [13, 15, 18, 9, 1, 20]),
        .init(kind: 1,x: 215,y: 101,text: "9",neighbors: [14, 11, 18, 10, 1, 20]),
        .init(kind: 1,x: 55,y: 112,text: "10",neighbors: [18, 17, 20, 11, 1, 20]),
        .init(kind: 1,x: 95,y: 112,text: "11",neighbors: [16, 18, 20, 12, 1, 20]),
        .init(kind: 1,x: 135,y: 112,text: "12",neighbors: [17, 16, 21, 13, 1, 20]),
        .init(kind: 0,x: 53,y: 128,text: "Format of Drill Problems:",neighbors: [255, 255, 255, 255, 255, 255]),
        .init(kind: 1,x: 55,y: 138,text: "3+5=?",neighbors: [22, 21, 28, 16, 6, 28]),
        .init(kind: 1,x: 110,y: 138,text: "?+5=8",neighbors: [20, 22, 28, 17, 6, 28]),
        .init(kind: 1,x: 165,y: 138,text: "3+?=8",neighbors: [21, 20, 28, 18, 6, 28]),
        .init(kind: 0,x: 53,y: 17,text: "Number of Problems in Each Set:",neighbors: [255, 255, 255, 255, 255, 255]),
        .init(kind: 5,x: 55,y: 27,text: "5",neighbors: [27, 25, 1, 28, 28, 1]),
        .init(kind: 5,x: 95,y: 27,text: "10",neighbors: [24, 26, 1, 28, 28, 1]),
        .init(kind: 5,x: 135,y: 27,text: "15",neighbors: [25, 27, 1, 28, 28, 1]),
        .init(kind: 5,x: 175,y: 27,text: "20",neighbors: [26, 24, 2, 28, 28, 1]),
        .init(kind: 2,x: 55,y: 156,text: "OK",neighbors: [29, 29, 24, 20, 20, 29]),
        .init(kind: 3,x: 220,y: 156,text: "Undo",neighbors: [28, 28, 27, 22, 28, 24]),
    ]
}

struct OriginalSettingsEditor {
    let original: OriginalGameSettings
    let practice: Bool
    var value: OriginalGameSettings
    var sourceRecord: OriginalGameSettings
    var focus = 28
    var phase = 0
    var idleIRQ = 0
    var guidanceWaiting = true
    var warning: String?
    var warningFocus = 1
    init(settings: OriginalGameSettings,practice: Bool) { original = settings;value = settings;sourceRecord = settings;self.practice = practice }
    var cursorVisible: Bool { phase < 23 }
    var controls: [OriginalSettingsControl] { OriginalSettingsControl.practice }
    func label(_ index: Int) -> String {
        if !practice && index == 23 { return "Select Settings for Level:" }
        if !practice && (24...27).contains(index) { return ["1","2","3","4 (selects all)"][index-24] }
        return controls[index].text
    }
    func checked(_ index: Int) -> Bool {
        switch index {
        case 1...4: return value.enabled(index-1,mask: 16)
        case 6...18: return value.enabled(index-6,mask: 4)
        case 20...22: return value.enabled(index-20,mask: 8)
        case 24...27: return value.selection == index-24
        default: return false
        }
    }
    //Original idle loop waits23 IRQ selected, then40 IRQ unselected.
    //A keyboard poll drains to the latest key at the next63-IRQ boundary.
    mutating func advance(_ irqTicks: Int) -> Bool {
        guard warning == nil else { return false }
        idleIRQ += irqTicks
        let old = phase;phase = (phase+irqTicks)%63
        return old+irqTicks >= 63
    }
    mutating func navigate(_ neighbor: Int) {
        let next = controls[focus].neighbors[neighbor]
        if controls.indices.contains(next),controls[next].kind != 0 { focus = next }
        phase = 0
    }
    var committedValue: OriginalGameSettings {
        //1f13:02bf clears all13 bytes before rebuilding only visible bits.
        var result = OriginalGameSettings(bytes: [UInt8](repeating: 0,count: 13))
        for i in 0..<4 { result.set(i,mask: 16,enabled: checked(i+1)) }
        for i in 0..<13 { result.set(i,mask: 4,enabled: checked(i+6)) }
        for i in 0..<3 { result.set(i,mask: 8,enabled: checked(i+20)) }
        result.selection = value.selection
        return result
    }
    enum Result { case accepted(OriginalGameSettings),cancelled }
    mutating func activate() -> Result? {
        phase = 0
        switch focus {
        case 1...4: value.set(focus-1,mask: 16,enabled: !checked(focus))
        case 6...18: value.set(focus-6,mask: 4,enabled: !checked(focus))
        case 20...22: value.set(focus-20,mask: 8,enabled: !checked(focus))
        case 24...27:
            let selected = focus-24
            if practice { value.selection = selected }
            else { value = .defaults(tier: selected);sourceRecord = value;focus = 28 }
        case 28:
            if let error = committedValue.validationMessage {
                warning = error
                if !value.bytes.prefix(4).contains(where: { $0 & 16 != 0 }) { warningFocus = 1 }
                else if !value.bytes.contains(where: { $0 & 4 != 0 }) || error.contains("more numbers") { warningFocus = 6 }
                else { warningFocus = 20 }
            } else { return .accepted(committedValue) }
        case 29: value = original;sourceRecord = original;focus = 28
        default: break
        }
        return nil
    }
    mutating func key(_ code: UInt16,shift: Bool = false) -> Result? {
        if warning != nil {
            if [36,76,53].contains(code) { warning = nil;focus = warningFocus;phase = 0 }
            return nil
        }
        if code == 53 { return .cancelled }
        switch code {
        case 123: navigate(0)
        case 124: navigate(1)
        case 125: navigate(2)
        case 126: navigate(3)
        case 48: navigate(shift ? 4 : 5)
        case 36,76,49: return activate()
        default: break
        }
        return nil
    }
}

struct NativeSettingsEditor {
    var model: OriginalSettingsEditor
    let backdrop: [UInt8]
    let previousTutorialContext: Bool
    let profileID: UUID?
    let completion: (OriginalGameSettings?) -> Void
}

extension NativeGameView {
    func beginSettingsEditor(_ settings: OriginalGameSettings,practice: Bool,profileID: UUID? = nil,completion: @escaping (OriginalGameSettings?) -> Void) {
        guard decoderPanel == nil,settingsEditor == nil,confirmation == nil,originalNotice == nil,optionsMenu == nil else { return }
        do {
            try render()
            settingsEditor = NativeSettingsEditor(model: OriginalSettingsEditor(settings: settings,practice: practice),backdrop: canvas.pixels,previousTutorialContext: tutorialPracticeContext,profileID: profileID,completion: completion)
            tutorialPracticeContext = practice;modalDepth += 1;keyboard.flush();held.removeAll();needsDisplay = true
        } catch { present(error) }
    }
    func finishSettingsEditor(_ result: OriginalGameSettings?) {
        guard let editor = settingsEditor else { return }
        settingsEditor = nil;modalDepth -= 1;tutorialPracticeContext = editor.previousTutorialContext
        keyboard.flush();held.removeAll()
        //2144:0009 writes the shared custom-game record after Cancel too.
        //Only level defaults/Undo changed that record before an accepted OK.
        if result == nil,!editor.model.practice,editor.model.sourceRecord != editor.model.original,let id = editor.profileID {
            do { try profileStore.saveSettings(profileID: id,settings: editor.model.sourceRecord,practice: false) }
            catch { present(error) }
        }
        editor.completion(result);needsDisplay = true
    }
    func cancelSettingsGuidance() {
        guard settingsEditor?.model.guidanceWaiting == true else { return }
        settingsEditor!.model.guidanceWaiting = false
        if automaticallyPresentMessages,!referenceMode {
            var state = tutorialState;state.acknowledge(settingsEditor!.model.practice ? 16 : 15);tutorialState = state
        }
    }
    func settingsKey(_ event: NSEvent) {
        guard settingsEditor != nil else { return }
        cancelSettingsGuidance()
        guard event.modifierFlags.intersection([.control,.command,.option]).isEmpty else { return }
        let result = settingsEditor!.model.key(event.keyCode,shift: event.modifierFlags.contains(.shift))
        if let result {
            switch result { case let .accepted(settings): finishSettingsEditor(settings);case .cancelled: finishSettingsEditor(nil) }
        }
        needsDisplay = true
    }
    func stepSettingsEditor() {
        guard settingsEditor != nil,modalDepth == 1 else { return }
        if settingsEditor!.model.warning != nil {
            //Type2 notice uses FIFO03ad and flushes after Enter/Escape.
            while let event = keyboard.read() {
                settingsKey(event)
                if settingsEditor?.model.warning == nil { keyboard.flush();break }
            }
            return
        }
        let ready = settingsEditor!.model.advance(OriginalWorld.frameIRQTicks)
        if ready,let event = keyboard.drainLatest() { settingsKey(event) }
        if ready,settingsEditor?.model.guidanceWaiting == true,settingsEditor!.model.idleIRQ-settingsEditor!.model.phase >= 1200 {
            settingsEditor!.model.guidanceWaiting = false;showNewUserMessage(settingsEditor!.model.practice ? 16 : 15)
        }
        needsDisplay = true
    }
    func settingsClick(x: Int,y: Int) {
        guard settingsEditor != nil,settingsEditor!.model.warning == nil,let font = try? content.font("MOCKET.DAT.1396") else { return }
        cancelSettingsGuidance()
        let model = settingsEditor!.model
        if let index = model.controls.indices.first(where: { index in
            let c = model.controls[index],width = font.width(of: model.label(index))+(c.kind == 1 || c.kind == 5 ? 12 : 3)
            return c.kind != 0 && (c.x-2...c.x+width+4).contains(x) && (c.y-2...c.y+11).contains(y)
        }) {
            settingsEditor!.model.focus = index
            if let result = settingsEditor!.model.activate() {
                switch result { case let .accepted(settings): finishSettingsEditor(settings);case .cancelled: finishSettingsEditor(nil) }
            }
            needsDisplay = true
        }
    }
    func drawSettingsEditor(_ editor: NativeSettingsEditor) throws {
        canvas.clip = nil;canvas.restoreEndingRect(editor.backdrop,x: 0,y: 0,right: 319,bottom: 199)
        let model = editor.model,font = try content.font("MOCKET.DAT.1396"),titleFont = try content.font("MOCKET.DAT.1393")
        canvas.originalHelpPanel(left: 47,top: 4,right: 275,bottom: 174,title: nil,footer: nil,font: titleFont,raisedTop: true)
        canvas.fill(51,6,219,163,15)
        canvas.fill(50,16,221,1,1);canvas.fill(50,152,221,1,1)
        if !model.practice { canvas.fill(60,40,201,1,1) }
        canvas.fill(0,178,320,22,1)
        canvas.text("\u{83}\u{81}\u{80}\u{82} to Cycle",font: titleFont,x: 0,y: 179,color: 15)
        canvas.text("\u{84} to Go Back",font: titleFont,x: 0,y: 190,color: 15)
        let select = "\u{85} to Select";canvas.text(select,font: titleFont,x: 319-titleFont.width(of: select),y: 180,color: 15)
        let title = model.practice ? "Customize Drill for Skill Settings" : "Customize Game Settings"
        canvas.text(title,font: titleFont,x: 160-titleFont.width(of: title)/2,y: 6,color: 1)
        for i in model.controls.indices {
            let c = model.controls[i],selected = i == model.focus && model.cursorVisible
            var offset = 0
            if c.kind == 1 || c.kind == 5 {
                let flags = (model.checked(i) ? 1 : 0)+(selected ? 2 : 0),glyph = (c.kind == 1 ? 127 : 131)+flags
                let shift = c.kind == 1 && selected ? 1 : 0
                if c.kind == 1 { canvas.fill(c.x-shift-1,c.y,13+shift,10,15) }
                else { canvas.fill(c.x,c.y,11,11,15) }
                canvas.text(String(UnicodeScalar(glyph)!),font: font,x: c.x-shift,y: c.y,color: 1);offset = 12
            } else if c.kind > 0 {
                let width = font.width(of: model.label(i))
                canvas.border(c.x-1,c.y-1,width+5,12,1)
                canvas.border(c.x-2,c.y-2,width+7,14,selected ? 1 : 15);offset = 1
            }
            canvas.text(model.label(i),font: font,x: c.x+offset,y: c.y,color: 1)
        }
        if let warning = model.warning {
            //Original type2 notice: font1393, minimum width150, extra15,
            //and an Enter-to-Continue footer. Validation remains in editor.
            let text = warning == "You need to choose more numbers to do division." ? "You need to choose more\nnumbers to do division." : "You need to have at least\none box checked in each\narea."
            let lines = text.components(separatedBy: "\n"),width = max(150,(lines.map { titleFont.width(of: $0)+1 }.max() ?? 0)+29),height = lines.count*10+35
            let left = (320-width)/2,top = (200-height)/2
            canvas.originalHelpPanel(left: left,top: top,right: left+width,bottom: top+height,title: nil,footer: "\u{85} to Continue",font: titleFont,bottomSeparator: 18,raisedTop: true)
            canvas.text(text,font: titleFont,x: left+14,y: top+9,color: 1,lineHeight: 10)
        }
    }
}
