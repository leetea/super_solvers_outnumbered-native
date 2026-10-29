import Cocoa

struct NativeDecoderPanel {
    enum Mode { case rule(DecoderMatchRule), decision(Int,OriginalConfirmation) }
    var mode: Mode
    let backdrop: [UInt8]
}

extension NativeGameView {
    func openDecoder() {
        guard session != nil,screen == .world else { return }
        sound?.stop();lastSoundIndex = nil;selectedRoom = 0;decoderButton = 0;decoderBlinkIRQ = 0
        decoderConfirmationPending = false;decoderFooterBlank = false;screen = .decoder;session.clock.pause();keyboard.flush();held.removeAll()
        showNewUserMessage(13);needsDisplay = true
    }
    func closeDecoder() {
        guard screen == .decoder else { return }
        screen = .world;session.clock.resume();keyboard.flush();held.removeAll();save();needsDisplay = true
    }
    func decoderKey(_ event: NSEvent) {
        guard event.modifierFlags.intersection([.control,.command,.option]).isEmpty else { return }
        decoderFooterBlank = false //07de restores the saved footer before dispatching input.
        switch event.keyCode {
        case 53: closeDecoder()
        case 48: decoderButton = (decoderButton+(event.modifierFlags.contains(.shift) ? 2 : 1))%3
        case 124: decoderButton = (decoderButton+1)%3
        case 123: decoderButton = (decoderButton+2)%3
        case 125: selectedRoom = (selectedRoom+1)%5
        case 126: selectedRoom = (selectedRoom+4)%5
        case 36,76:
            decoderBlinkIRQ = 100 //07de restores the blink before dispatch.
            if decoderButton == 0 { closeDecoder() }
            else if decoderButton == 1 { showMatchRule() }
            else { confirmDecision() }
        default: break
        }
        if originalNotice == nil,decoderPanel == nil,confirmation == nil { decoderBlinkIRQ = 0 }
        needsDisplay = true
    }
    func showMatchRule() {
        guard screen == .decoder,decoderPanel == nil,originalNotice == nil,confirmation == nil else { return }
        do {
            decoderBlinkIRQ = 100;try render()
            decoderPanel = NativeDecoderPanel(mode: .rule(session.decoder.rule),backdrop: canvas.pixels)
            modalDepth += 1;keyboard.flush();held.removeAll();needsDisplay = true
        } catch { present(error) }
    }
    func confirmDecision() {
        guard screen == .decoder,decoderPanel == nil,originalNotice == nil,confirmation == nil else { return }
        decoderBlinkIRQ = 100
        guard session.decoder.canDecide(energy: session.energy,pendingRecharge: session.pendingRecharge) else {
            showOriginalNotice(OriginalNotice(text: OriginalDecoderDialog.ineligible,title: nil)) { [weak self] _ in self?.decoderBlinkIRQ = 0 }
            return
        }
        do {
            try render()
            decoderPanel = NativeDecoderPanel(mode: .decision(selectedRoom,OriginalConfirmation(text: "",title: nil,selection: 0)),backdrop: canvas.pixels)
            modalDepth += 1;keyboard.flush();held.removeAll();needsDisplay = true
        } catch { present(error) }
    }
    func finishDecoderPanel(_ result: Int = 0) {
        guard let panel = decoderPanel else { return }
        decoderPanel = nil;modalDepth -= 1;keyboard.flush();held.removeAll();decoderBlinkIRQ = 0
        //1998f restores only the right HUD. The next07de off phase restores buttons.
        if case .rule = panel.mode { decoderFooterBlank = true }
        if case .decision(let room,_) = panel.mode,result == 1 {
            decoderConfirmationPending = true
            let text = OriginalDecoderDialog.confirmPrefix+DecoderPuzzle.roomNames[room].uppercased()+"?"
            showConfirmation(OriginalConfirmation(text: text,title: nil,selection: 1)) { [weak self] choice in
                guard let self else { return }
                self.decoderConfirmationPending = false;self.decoderBlinkIRQ = 0
                if choice == 1 { self.startEnding(room: room) }
            }
        }
        needsDisplay = true
    }
    func decoderPanelKey(_ event: NSEvent) {
        guard let panel = decoderPanel,event.modifierFlags.intersection([.control,.command,.option]).isEmpty else { return }
        switch panel.mode {
        case .rule:
            if event.keyCode == 36 || event.keyCode == 76 { finishDecoderPanel() }
        case .decision(let room,var model):
            if event.keyCode == 48 && event.modifierFlags.contains(.shift) { return }
            let result = model.key(event.keyCode,characters: event.characters)
            decoderPanel!.mode = .decision(room,model)
            if let result { finishDecoderPanel(result) }
        }
        needsDisplay = true
    }
    func decoderPanelClick(x: Int,y: Int) {
        guard let panel = decoderPanel,case .decision = panel.mode,(186...194).contains(y) else { return }
        //Native mouse adaptation over the source button faces.
        if (116...164).contains(x) { finishDecoderPanel(0) }
        else if (41...89).contains(x) { finishDecoderPanel(1) }
    }
    func drawDecoderPanel(_ panel: NativeDecoderPanel) throws {
        canvas.clip = nil;canvas.restoreEndingRect(panel.backdrop,x: 0,y: 0,right: 319,bottom: 199)
        let font = try content.font("MOCKET.DAT.1393"),small = try content.font("MOCKET.DAT.1396")
        switch panel.mode {
        case .rule(let rule):
            canvas.fill(5,163,308,34,15);canvas.border(4,162,310,36,1)
            let lines = OriginalDecoderDialog.matchLines[rule.rawValue]
            canvas.text(lines[0],font: small,x: 8,y: 164,color: 1)
            canvas.text(lines[1],font: small,x: 8,y: 174,color: 1)
            canvas.text("Press",font: small,x: 8,y: 186,color: 1)
            canvas.text("\u{85}",font: font,x: 41,y: 186,color: 1)
            canvas.text("to continue.",font: small,x: 101,y: 186,color: 1)
        case .decision(let room,let model):
            canvas.fill(5,163,211,34,15);canvas.border(4,162,213,36,1)
            canvas.text("Is the Master of Mischief's",font: font,x: 15,y: 164,color: 1)
            let prefix = "hideout in the",roomText = DecoderPuzzle.roomNames[room].uppercased()
            canvas.text(prefix,font: font,x: 15,y: 174,color: 1)
            canvas.text(roomText,font: small,x: font.width(of: prefix)+23,y: 174,color: 1)
            canvas.text("?",font: font,x: font.width(of: prefix)+small.width(of: roomText)+25,y: 174,color: 1)
            canvas.originalHelpButton("No",font: font,x: 120,y: 182,selected: model.selection == 0)
            canvas.originalHelpButton("Yes",font: font,x: 45,y: 182,selected: model.selection == 1)
        }
    }
}
