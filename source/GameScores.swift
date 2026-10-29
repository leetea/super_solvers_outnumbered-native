import Foundation

extension NativeGameView {
    #if canImport(AppKit) && !OUTNUMBERED_PORTABLE
    @objc
    #endif
    func showLifetimeScores() { showScores(highGames: false) }
    #if canImport(AppKit) && !OUTNUMBERED_PORTABLE
    @objc
    #endif
    func showHighGameScores() { showScores(highGames: true) }
    func showScores(highGames: Bool) {
        guard screen != .ending,session?.activeZap == nil,session?.activeFountain == nil else { return }
        if screen == .help { closeHelp() }
        if screen != .scores {
            scoreReturn = screen
            scoresPauseAdventure = session != nil && [.world,.question,.drill,.decoder].contains(screen)
            if scoresPauseAdventure { session.clock.pause() }
        }
        scoresShowHighGames = highGames; scorePage = 0; screen = .scores
        held.removeAll(); needsDisplay = true
    }
    func closeScores() {
        guard screen == .scores else { return }
        screen = scoreReturn
        if scoresPauseAdventure { session?.clock.resume() }
        scoresPauseAdventure = false; needsDisplay = true
    }
    func scoresKey(_ event: GameInputEvent) {
        if event.keyCode == 53 || event.keyCode == 36 || event.keyCode == 76 { closeScores(); return }
        guard !scoresShowHighGames else { return }
        let last = max(0,(profileStore.document.profiles.count-1)/10)
        if [124,125].contains(event.keyCode) { scorePage = min(last,scorePage+1) }
        else if [123,126].contains(event.keyCode) { scorePage = max(0,scorePage-1) }
        needsDisplay = true
    }
    func drawScores() throws {
        let font = try content.font("MOCKET.DAT.1393")
        try sprite(57,x: 0,y: 0,transparent: false)
        let title = scoresShowHighGames ? "High Game Scores" : "Lifetime Scores"
        //170d:091a/0a1f, common panel style7 at(16,26)..(300,179).
        // Style7 shares style0: bottom separator18, footer bottom-16.
        canvas.originalHelpPanel(left: 16,top: 26,right: 300,bottom: 179,title: title,footer: nil,font: font,bottomSeparator: 18)
        canvas.text("\u{84} to Go Back",font: font,x: 158-font.width(of: "\u{84} to Go Back")/2,y: 163,color: 1)
        canvas.text("Name",font: font,x: 32,y: 42,color: 1)
        canvas.text("Rank",font: font,x: 148,y: 42,color: 1)
        canvas.text(scoresShowHighGames ? "High Score" : "Lifetime",font: font,x: scoresShowHighGames ? 222 : 230,y: 42,color: 1)
        let underlineY = scoresShowHighGames ? 53 : 51
        canvas.fill(32,underlineY,33,1,1); canvas.fill(148,underlineY,28,1,1)
        canvas.fill(scoresShowHighGames ? 222 : 230,underlineY,scoresShowHighGames ? 66 : 50,1,1)
        let rows: [(String,VerifiedRank,Int)]
        if scoresShowHighGames {
            rows = (profileStore.document.highGameScores ?? []).map { ($0.name,$0.rank,Int($0.score)) }
        } else {
            rows = Array(OriginalScoreTable.lifetimeOrder(profileStore.document.profiles).dropFirst(scorePage*10).prefix(10)).map { ($0.name,VerifiedRank.forLifetimePoints($0.lifetimePoints ?? 0),$0.lifetimePoints ?? 0) }
        }
        for (i,row) in rows.enumerated() {
            let y = (scoresShowHighGames ? 55 : 53)+i*10
            canvas.clip = (30,y,108,10); canvas.text(row.0,font: font,x: 30,y: y,color: 1); canvas.clip = nil
            canvas.text(row.1.rawValue,font: font,x: 140,y: y,color: 1)
            let score = OriginalScoreTable.formatted(row.2)
            canvas.text(score,font: font,x: 272-font.width(of: score),y: y,color: 1)
        }
    }
}
