import Cocoa

struct OriginalMemberName {
    private(set) var text = ""
    //21b1:096f: eight characters, ASCII letters/digits, interior spaces,
    // first character capitalized; blank Enter is ignored, trailing spaces trim.
    mutating func append(_ character: Character) {
        guard text.count < 8,let scalar = character.asciiValue else { return }
        if scalar == 32 { if !text.isEmpty { text.append(character) };return }
        guard (48...57).contains(scalar) || (65...90).contains(scalar) || (97...122).contains(scalar) else { return }
        text += text.isEmpty ? String(character).uppercased() : String(character)
    }
    mutating func erase() { if !text.isEmpty { text.removeLast() } }
    var submitted: String? {
        let result = text.trimmingCharacters(in: .whitespaces)
        return result.isEmpty ? nil : result
    }
    var display: String { text+String(repeating: "_",count: 8-text.count) }
}

struct NativeMemberSignIn {
    enum Mode { case select, remove, newName }
    var mode: Mode
    var selection: Int
    var name = OriginalMemberName()
    var error: String?
    var blinkIRQ = 0
    init(memberCount: Int = 0) {
        mode = memberCount == 0 ? .newName : .select
        selection = memberCount // Original starts on New Member, not first name.
    }
    mutating func move(_ amount: Int,memberCount: Int) {
        let count = memberCount+(mode == .select ? 1 : 0)
        guard count > 0 else { return }
        selection = (selection+amount+count)%count
    }
    var firstVisibleRow: Int { selection/11*11 } // Native compatibility beyond DOS ten slots.
}

extension NativeCanvas {
    //104b:0964, same recovered EGA planes1..3 operation as TV static.
    func xorMemberSelection(_ x: Int,_ y: Int,_ width: Int,_ height: Int) {
        for row in max(0,y)..<min(200,y+height) {
            for column in max(0,x)..<min(320,x+width) { pixel(column,row,pixels[row*320+column]^14) }
        }
    }
}

extension NativeGameView {
    var orderedMembers: [NativeProfile] { OriginalScoreTable.lifetimeOrder(profileStore.document.profiles) }
    func finishMemberSelection(_ id: UUID) throws {
        try profileStore.select(id)
        session = nil;practice = nil;referenceMode = false
        menuMessages = NativeNewUserMessages(enabled: (selectedProfile?.lifetimePoints ?? 0) < 5000)
        screen = .menu;menuSelection = 0;status = "";held.removeAll()
        if menuMessages.enabled { showNewUserMessage(17,welcome: true) }
        needsDisplay = true
    }
    func submitMemberName() {
        guard let name = signIn.name.submitted else { return }
        do {
            // The original UI has ten slots. Existing larger native documents
            // remain selectable through pagination; their names are never cut.
            guard profileStore.document.profiles.count < 10 else {
                signIn.error = "The list of Club Members is full.\rYou must remove a name in order\rto play a game.";return
            }
            let profile = try profileStore.create(name: name)
            try finishMemberSelection(profile.id)
        } catch {
            signIn.error = error.localizedDescription
            signIn.name = OriginalMemberName()
        }
    }
    func signInKey(_ event: NSEvent) {
        defer { signIn.blinkIRQ = 0;needsDisplay = true }
        if signIn.error != nil {
            if [36,53].contains(event.keyCode) { signIn.error = nil;signIn.mode = orderedMembers.isEmpty ? .newName : .select;signIn.selection = orderedMembers.count }
            return
        }
        if signIn.mode == .newName {
            if event.keyCode == 36 { submitMemberName() }
            else if event.keyCode == 53 {
                if orderedMembers.isEmpty { confirmNativeExit() }
                else { signIn = NativeMemberSignIn(memberCount: orderedMembers.count) }
            } else if [51,117].contains(event.keyCode) { signIn.name.erase() }
            else if let characters = event.characters,characters.count == 1,let character = characters.first { signIn.name.append(character) }
            return
        }
        let members = orderedMembers
        if [125,126].contains(event.keyCode) { signIn.move(event.keyCode == 125 ? 1 : -1,memberCount: members.count);return }
        if event.keyCode == 53 {
            if signIn.mode == .remove { signIn = NativeMemberSignIn(memberCount: members.count) }
            else { confirmNativeExit() }
            return
        }
        if signIn.mode == .select && (event.characters == "\u{12}" || (event.modifierFlags.contains(.control) && event.charactersIgnoringModifiers?.lowercased() == "r")) {
            if !members.isEmpty { signIn.mode = .remove;signIn.selection = 0 }
            return
        }
        guard event.keyCode == 36 else { return }
        if signIn.mode == .remove {
            guard members.indices.contains(signIn.selection) else { return }
            let member = members[signIn.selection]
            modalDepth += 1;defer { modalDepth -= 1 }
            let alert = NSAlert();alert.messageText = "Remove \(member.name)?"
            alert.informativeText = "The member will leave the sign-in list. Their score and unfinished game are kept. Use Game → Restore Removed Member to bring them back."
            alert.addButton(withTitle: "No");alert.addButton(withTitle: "Remove Member")
            if alert.runModal() == .alertSecondButtonReturn {
                do { try removeMember(member.id) } catch { present(error) }
            } else { signIn = NativeMemberSignIn(memberCount: members.count) }
        } else if members.indices.contains(signIn.selection) {
            do { try finishMemberSelection(members[signIn.selection].id) } catch { present(error) }
        } else if members.count >= 10 {
            signIn.error = "The list of Club Members is full.\rYou must remove a name in order\rto play a game."
        } else { signIn.mode = .newName;signIn.name = OriginalMemberName() }
    }
    func removeMember(_ id: UUID) throws {
        save();try profileStore.archive(id)
        if session?.profileID == id { session = nil;referenceMode = false }
        signIn = NativeMemberSignIn(memberCount: orderedMembers.count)
        needsDisplay = true
    }
    @objc func restoreMember() {
        guard !isTransitioning,screen != .ending else { return }
        let members = profileStore.document.archivedProfiles ?? []
        let alert = NSAlert();alert.messageText = "Restore Removed Member"
        guard !members.isEmpty else { alert.informativeText = "There are no removed members.";alert.runModal();return }
        let picker = NSPopUpButton(frame: NSRect(x: 0,y: 0,width: 260,height: 28));picker.addItems(withTitles: members.map(\.name))
        alert.accessoryView = picker;alert.addButton(withTitle: "Restore");alert.addButton(withTitle: "Cancel")
        modalDepth += 1;defer { modalDepth -= 1 }
        if alert.runModal() == .alertFirstButtonReturn {
            do { try profileStore.restore(members[picker.indexOfSelectedItem].id);choosePlayer() } catch { present(error) }
        }
    }
    func confirmNativeExit() {
        modalDepth += 1;defer { modalDepth -= 1 }
        let alert = NSAlert();alert.messageText = "Exit Program?"
        alert.addButton(withTitle: "No");alert.addButton(withTitle: "Yes")
        if alert.runModal() == .alertSecondButtonReturn { save();NSApplication.shared.terminate(nil) }
    }
    func drawSignIn() throws {
        let font = try content.font("MOCKET.DAT.1393")
        canvas.draw(try content.bitmap("DMOCKET.GRA.1b62"),x: 0,y: 0)
        canvas.draw(try content.bitmap("DMOCKET.GRA.1b63"),x: 0,y: 94)
        canvas.fill(0,188,320,12,1)
        // DS58b5 uses font0's encoded glyph indices, not normal alphabet bytes.
        canvas.text("\".2* $+/*+1 '-,0)#0",font: try content.font("MOCKET.DAT.1392"),x: 43,y: 33,color: 1)
        canvas.text(signIn.mode == .remove ? "Remove a Member's Name" : "Select Member Name",font: font,x: signIn.mode == .remove ? 80 : 111,y: 49,color: 1)
        canvas.text("\u{80}\u{81} to Cycle",font: font,x: 10,y: 189,color: 15)
        let enter = signIn.mode == .remove ? "\u{85} to Remove" : "\u{85} to Select"
        canvas.text(enter,font: font,x: 310-font.width(of: enter),y: 189,color: 15)
        let members = orderedMembers,first = signIn.firstVisibleRow
        for index in first..<min(members.count,first+11) {
            let member = members[index],y = 63+(index-first)*11
            canvas.clip = (43,y,106,10);canvas.text(member.name,font: font,x: 43,y: y,color: 1);canvas.clip = nil
            canvas.text(VerifiedRank.forLifetimePoints(member.lifetimePoints ?? 0).rawValue,font: font,x: 153,y: y,color: 1)
            let score = OriginalScoreTable.formatted(member.lifetimePoints ?? 0)
            canvas.text(score,font: font,x: 285-font.width(of: score),y: y,color: 1)
        }
        if signIn.mode != .remove && (first..<first+11).contains(members.count) { canvas.text("New Member",font: font,x: 43,y: 63+(members.count-first)*11,color: 1) }
        if signIn.mode != .newName { canvas.xorMemberSelection(40,63+(signIn.selection-first)*11,255,10) }
        if signIn.mode == .newName {
            let lines = ["Type your name in the box below.","Then press \u{85}.","","",""]
            let width = max(150,(lines.map { font.width(of: $0)+1 }.max() ?? 0)+29)
            let left = (320-width)/2,top = (200-97)/2
            canvas.originalHelpPanel(left: left,top: top,right: left+width,bottom: top+97,title: "Enter New Member Name",footer: nil,font: font,bottomSeparator: 18)
            for (i,line) in lines.enumerated() { canvas.text(line,font: font,x: left+14,y: top+20+i*10,color: 1) }
            canvas.border(88,95,113,19,1);canvas.fill(89,96,111,17,15)
            canvas.text(signIn.name.display,font: font,x: 96,y: 100,color: 1)
            if signIn.blinkIRQ/51%2 == 0 {
                let text = signIn.name.text
                let cursorX = 96+(text.isEmpty ? 0 : font.width(of: text)+1)
                canvas.text("^",font: font,x: cursorX,y: 100,color: 1)
            }
        }
        if let error = signIn.error {
            let lines = error.components(separatedBy: "\r"),width = min(300,max(150,(lines.map { font.width(of: $0) }.max() ?? 0)+29))
            let left = (320-width)/2,height = lines.count*10+20,top = (200-height)/2
            canvas.originalHelpPanel(left: left,top: top,right: left+width,bottom: top+height,title: nil,footer: nil,font: font)
            for (i,line) in lines.enumerated() { canvas.text(line,font: font,x: left+14,y: top+9+i*10,color: 1) }
        }
    }
    var fileItems: [String] {
        fileReturn == .practice ? ["Play Another Game","Start New Player","Exit the Program"] : ["Lifetime Scores","High Game Scores","Play Another Game","Start New Player","Exit and Save"]
    }
    @objc func showFileMenu() {
        guard !isTransitioning,session?.activeZap == nil,session?.activeFountain == nil,screen != .ending,screen != .signin else { return }
        if screen == .file { closeFileMenu();return }
        if screen == .help { closeHelp() }
        if screen == .scores { closeScores() }
        save();fileReturn = screen;fileSelection = 0;screen = .file;held.removeAll();needsDisplay = true
    }
    func closeFileMenu() { screen = fileReturn;held.removeAll();needsDisplay = true }
    func fileKey(_ event: NSEvent) {
        if [53,120].contains(event.keyCode) { closeFileMenu();return }
        if [125,126].contains(event.keyCode) { fileSelection = (fileSelection+fileItems.count+(event.keyCode == 125 ? 1 : -1))%fileItems.count;needsDisplay = true;return }
        if event.keyCode == 122 { closeFileMenu();toggleHelp();return }
        if event.keyCode == 99 { closeFileMenu();showOptions();return }
        if event.keyCode == 36 { activateFileItem() }
    }
    func activateFileItem() {
        let item = fileItems[fileSelection];closeFileMenu()
        switch item {
        case "Lifetime Scores": showLifetimeScores()
        case "High Game Scores": showHighGameScores()
        case "Play Another Game": showPlayerMenu()
        case "Start New Player": choosePlayer()
        default: confirmNativeExit()
        }
    }
    func drawFileMenu() throws {
        let font = try content.font("MOCKET.DAT.1393")
        try sprite(57,x: 0,y: 0,transparent: false);try sprite(62,x: 48,y: 0,transparent: false)
        let width = max(123,fileItems.map { font.width(of: $0)+14 }.max() ?? 123),left = 52
        canvas.originalHelpPanel(left: left,top: 12,right: left+width,bottom: 12+fileItems.count*12+25,title: nil,footer: "\u{84} to Go Back",font: font)
        for (i,item) in fileItems.enumerated() { canvas.text(item,font: font,x: left+6,y: 17+i*12,color: 1) }
        canvas.xorMemberSelection(left+4,16+fileSelection*12,width-9,13)
    }
}
