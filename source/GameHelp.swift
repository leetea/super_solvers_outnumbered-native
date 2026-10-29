import Cocoa

extension NativeGameView {
    func closeHelp() {
        guard screen == .help else { return }
        screen = helpReturn
        if screen == .title { openingLastPulse = ProcessInfo.processInfo.systemUptime }
        if helpPausesAdventure { session?.clock.resume() }
        helpPausesAdventure = false; helpBrowser = nil; needsDisplay = true
    }
    func helpKey(_ event: NSEvent) {
        guard var browser = helpBrowser else { return }
        if browser.topic == nil {
            if event.keyCode == 123 { closeHelp();showOptions();return }
            if event.keyCode == 124 { closeHelp();showFileMenu();return }
        }
        if event.keyCode == 53 {
            closeHelp();return
        } else if event.keyCode == 122 && browser.topic != nil {
            browser.returnToTopics();browser.selectedTopic = 0
        } else if event.keyCode == 36 || event.keyCode == 76 {
            if browser.activate(book: helpBook) { browser.returnToTopics();browser.selectedTopic = 0 }
        } else if browser.topic == nil {
            if event.keyCode == 125 { browser.cycleTopic(1) }
            else if event.keyCode == 126 { browser.cycleTopic(-1) }
        } else if [48,123,124,125,126].contains(event.keyCode) { browser.cycleButton() }
        helpBrowser = browser; needsDisplay = true
    }
    func helpClick(x: Int,y: Int) {
        guard var browser = helpBrowser else { return }
        if browser.topic == nil {
            let font = try? content.font("MOCKET.DAT.1393")
            let width = max(123,browser.availableTopics.map { font?.width(of: browser.practice ? "About Drill for Skill" : helpBook.topics[$0].title) ?? 0 }.max()!+14)
            guard x >= 4 && x <= width-6 && y >= 17 && y < 17+browser.availableTopics.count*12 else { return }
            browser.selectedTopic = (y-17)/12
        } else {
            guard (170...184).contains(y) else { return }
            if (28...136).contains(x) && browser.page > 0 { browser.selectedButton = 0 }
            else if (180...288).contains(x) { browser.selectedButton = 1 }
            else { return }
        }
        if browser.activate(book: helpBook) { browser.returnToTopics();browser.selectedTopic = 0 }
        helpBrowser = browser; needsDisplay = true
    }
    func drawOriginalHelp() throws {
        guard let browser = helpBrowser else { return }
        let font = try content.font("MOCKET.DAT.1393")
        try sprite(57,x: 0,y: 0,transparent: false)
        guard let topic = browser.topic else {
            try sprite(61,x: 0,y: 0,transparent: false)
            let titles = browser.availableTopics.map { browser.practice ? "About Drill for Skill" : helpBook.topics[$0].title }
            let width = max(123,titles.map { font.width(of: $0) }.max()!+14), bottom = 12+titles.count*12+25
            canvas.originalHelpPanel(left: 0,top: 12,right: width,bottom: bottom,title: nil,footer: "\u{84} to Go Back",font: font,bottomSeparator: 18)
            for (i,title) in titles.enumerated() { canvas.text(title,font: font,x: 6,y: 17+i*12,color: 1) }
            canvas.invert(4,16+browser.selectedTopic*12,width-9,13)
            return
        }
        //1862:05f9, style4, bounds(16,19)..(300,189); recovered shadow,
        // title rule and bottom separator. Source drawing colors11/ff.
        let title = helpBook.topics[topic].title
        canvas.originalHelpPanel(left: 16,top: 19,right: 300,bottom: 189,title: title,footer: nil,font: font)
        let page = helpBook.topics[topic].pages[browser.page]
        if let image = page.illustration { canvas.draw(try content.bitmap(image.resource),x: image.x,y: image.y) }
        for run in page.runs { canvas.text(run.text,font: font,x: run.x,y: run.y,color: 1,lineHeight: 10) }
        if browser.page > 0 { canvas.originalHelpButton("Go Back a Page",font: font,x: 32,y: 170,selected: browser.selectedButton == 0) }
        let next = browser.page+1 == helpBook.topics[topic].pages.count ? "   Done   " : "See Next Page"
        canvas.originalHelpButton(next,font: font,x: 184,y: 170,selected: browser.selectedButton == 1)
    }
}
