import Cocoa

// Native infrastructure only. Original game rules are added after their evidence is recovered.
enum VerifiedRank: String, CaseIterable, Codable {
    case trainee = "Trainee", junior = "Junior", senior = "Senior", pro = "Pro", expert = "Expert", master = "Master", allStar = "All-Star", champion = "Champion"
    static let thresholds = [0, 5_000, 30_000, 60_000, 120_000, 200_000, 300_000, 500_000]
    static func forLifetimePoints(_ points: Int) -> VerifiedRank {
        allCases[thresholds.lastIndex(where: { $0 <= max(0, points) })!]
    }
}

// PIT divisor 5041 and one counter increment per IRQ are verified in original bytes.
// 1,193,182 Hz is the conventional rounded PC PIT input, not a measured oscillator.
// Each call to pollAfterIRQTicks corresponds to one original main-loop clock poll.
struct VerifiedClock: Codable {
    static let pitInputHz = 1_193_182.0
    static let pitDivisor = 5_041.0
    static let irqTicksPerGameMinute: UInt64 = 780
    static let nominalSecondsPerGameMinute = Double(irqTicksPerGameMinute) * pitDivisor / pitInputHz
    private(set) var counterTicks: UInt64 = 0
    private(set) var nextMinuteTick: UInt64 = irqTicksPerGameMinute
    private(set) var elapsedMinutes = 0
    private(set) var pauseDepth = 0
    private var remainingAtPause: UInt64 = 0
    private var fractionalIRQTicks: Double = 0
    var elapsedGameSeconds: Double { Double(elapsedMinutes * 60) }
    var secondsAfterMidnight: Double { 21 * 3600 + elapsedGameSeconds }
    var expired: Bool { elapsedMinutes >= 180 }
    var roomChallengeActive: Bool { pauseDepth > 0 }
    var hasValidPersistenceState: Bool {
        counterTicks <= UInt64.max / 4 && nextMinuteTick <= UInt64.max / 4 &&
        (0...180).contains(elapsedMinutes) && (0...16).contains(pauseDepth) &&
        remainingAtPause <= Self.irqTicksPerGameMinute &&
        fractionalIRQTicks.isFinite && fractionalIRQTicks >= 0 && fractionalIRQTicks < 1
    }
    mutating func pause() {
        if pauseDepth == 0 { remainingAtPause = nextMinuteTick > counterTicks ? nextMinuteTick - counterTicks : 0 }
        pauseDepth += 1
    }
    mutating func resume() {
        guard pauseDepth > 0 else { return }
        pauseDepth -= 1
        if pauseDepth == 0 { nextMinuteTick = counterTicks + remainingAtPause }
    }
    mutating func pollAfterIRQTicks(_ ticks: UInt64, processMinute: Bool = true) {
        counterTicks += min(ticks, UInt64.max - counterTicks - Self.irqTicksPerGameMinute)
        guard processMinute, !roomChallengeActive, !expired, counterTicks > nextMinuteTick else { return }
        elapsedMinutes += 1
        nextMinuteTick = counterTicks + Self.irqTicksPerGameMinute
    }
    mutating func advance(realSeconds: Double) {
        guard realSeconds.isFinite, realSeconds > 0 else { return }
        let ticks = realSeconds * Self.pitInputHz / Self.pitDivisor + fractionalIRQTicks
        guard ticks.isFinite else { return }
        let integralTicks = UInt64(min(ticks.rounded(.down), Double(UInt64.max / 4)))
        fractionalIRQTicks = ticks - ticks.rounded(.down)
        pollAfterIRQTicks(integralTicks)
    }
    mutating func restart() { self = VerifiedClock() }
    mutating func applyMinutePenalty(_ minutes: Int) {
        guard minutes >= 0 else { return }
        elapsedMinutes = min(180,elapsedMinutes+min(180,minutes))
    }
}

struct VerifiedScore {
    // Four tuning rows serve pairs of the eight lifetime ranks (rank index >> 1).
    struct Tuning {
        let roomBase: Int, wrongAnswerDeduction: Int, victoryBonus: Int, perEnergy: Int, perMinute: Int, refillCredits: Int
    }
    static let tuning = [
        Tuning(roomBase: 300, wrongAnswerDeduction: 100, victoryBonus: 1000, perEnergy: 100, perMinute: 25, refillCredits: 2),
        Tuning(roomBase: 300, wrongAnswerDeduction: 100, victoryBonus: 2000, perEnergy: 150, perMinute: 35, refillCredits: 2),
        Tuning(roomBase: 600, wrongAnswerDeduction: 200, victoryBonus: 3000, perEnergy: 300, perMinute: 50, refillCredits: 2),
        Tuning(roomBase: 600, wrongAnswerDeduction: 200, victoryBonus: 5000, perEnergy: 400, perMinute: 60, refillCredits: 2)
    ]
    static let drillCorrectAnswerAward = 50
    static let drillCodePieceAward = 100
    static func values(for rank: VerifiedRank) -> Tuning { tuning[VerifiedRank.allCases.firstIndex(of: rank)! >> 1] }
    static func roomAward(rank: VerifiedRank, previousWrongAnswers: Int) -> Int? {
        guard (0...2).contains(previousWrongAnswers) else { return nil }
        let row = values(for: rank)
        return row.roomBase - row.wrongAnswerDeduction * previousWrongAnswers
    }
    static func adding(_ delta: Int, to sessionScore: UInt16) -> UInt16 { sessionScore &+ UInt16(truncatingIfNeeded: delta) }
    static func winningScore(sessionScore: UInt16, rank: VerifiedRank, energy: Int, minutesRemaining: Int) -> UInt16? {
        guard (0...127).contains(energy), (0...180).contains(minutesRemaining) else { return nil }
        let row = values(for: rank)
        return adding(row.victoryBonus + row.perEnergy * energy + row.perMinute * minutesRemaining, to: sessionScore)
    }
    static func lifetimeAfterSession(current: Int, sessionScore: UInt16, won: Bool) -> Int {
        min(9_999_999, min(9_999_999, max(0, current)) + (won ? Int(sessionScore) : 0))
    }
}

struct VerifiedEnergy {
    static let initial = 12
    static let displayedMaximum = 24 // A display saturation point, not an internal energy cap.
    static let lowEnergyWarningBelow = 6
    static let zapCost = 1
    static let collisionCost = 1
    static func applying(_ delta: Int, to energy: Int) -> Int? {
        guard (-128...127).contains(energy), (-32768...32767).contains(delta) else { return nil }
        let sum = Int(Int16(truncatingIfNeeded: energy + delta))
        return sum < 0 ? energy : Int(Int8(truncatingIfNeeded: sum))
    }
}

struct NativeProfile: Codable, Identifiable {
    let id: UUID
    var name: String
    let createdAt: Date
    var updatedAt: Date
    var lifetimePoints: Int?
    var lastResultRunID: UUID?
    var customGameSettings: OriginalGameSettings?
    var practiceSettings: OriginalGameSettings?
}

struct NativeSaveFile: Codable {
    var formatVersion = 1
    var selectedProfileID: UUID?
    var profiles: [NativeProfile] = []
    var highGameScores: [NativeHighGameScore]?
}

enum NativeSaveError: LocalizedError {
    case invalidName, duplicateName, unknownProfile, unsupportedVersion(Int), invalidDocument
    var errorDescription: String? {
        switch self {
        case .invalidName: return "Enter a name of 1–32 characters, without control characters."
        case .duplicateName: return "A native profile already uses that name."
        case .unknownProfile: return "That native profile could not be found."
        case .unsupportedVersion(let version): return "This save uses unsupported format version \(version). It has not been changed."
        case .invalidDocument: return "The native profile file is invalid. It has not been changed."
        }
    }
}

final class NativeProfileStore {
    let file: URL
    private(set) var document: NativeSaveFile
    static var defaultDirectory: URL {
        if let override = ProcessInfo.processInfo.environment["OUTNUMBERED_NATIVE_DATA_DIR"], !override.isEmpty { return URL(fileURLWithPath: override, isDirectory: true) }
        return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("OutnumberedNativeReimplementation", isDirectory: true)
    }
    init(directory: URL) throws {
        file = directory.appendingPathComponent("profiles-v1.json")
        if FileManager.default.fileExists(atPath: file.path) {
            let decoder = JSONDecoder(); decoder.dateDecodingStrategy = .iso8601
            document = try decoder.decode(NativeSaveFile.self, from: Data(contentsOf: file))
            guard document.formatVersion == 1 else { throw NativeSaveError.unsupportedVersion(document.formatVersion) }
            guard Set(document.profiles.map(\.id)).count == document.profiles.count,
                  document.profiles.allSatisfy({ Self.validName($0.name) && ($0.lifetimePoints == nil || (0...9_999_999).contains($0.lifetimePoints!)) && ($0.customGameSettings == nil || $0.customGameSettings!.valid) && ($0.practiceSettings == nil || $0.practiceSettings!.valid) }),
                  Self.validHighGameScores(document.highGameScores),
                  document.selectedProfileID == nil || document.profiles.contains(where: { $0.id == document.selectedProfileID }) else { throw NativeSaveError.invalidDocument }
        } else { document = NativeSaveFile() }
    }
    private static func validHighGameScores(_ scores: [NativeHighGameScore]?) -> Bool {
        guard let scores else { return true }
        return scores.count <= 10 && Set(scores.map(\.runID)).count == scores.count && scores.allSatisfy { validName($0.name) && $0.score > 0 } && zip(scores,scores.dropFirst()).allSatisfy { $0.score >= $1.score }
    }
    private static func validName(_ name: String) -> Bool {
        !name.isEmpty && name.count <= 32 && name == name.trimmingCharacters(in: .whitespacesAndNewlines) && name.rangeOfCharacter(from: .controlCharacters) == nil
    }
    private func commit(_ updated: NativeSaveFile) throws {
        let encoder = JSONEncoder(); encoder.outputFormatting = [.prettyPrinted, .sortedKeys]; encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(updated)
        try FileManager.default.createDirectory(at: file.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: file, options: .atomic)
        document = updated
    }
    @discardableResult func create(name: String) throws -> NativeProfile {
        let clean = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard Self.validName(clean) else { throw NativeSaveError.invalidName }
        guard !document.profiles.contains(where: { $0.name.caseInsensitiveCompare(clean) == .orderedSame }) else { throw NativeSaveError.duplicateName }
        let now = Date(), profile = NativeProfile(id: UUID(), name: clean, createdAt: now, updatedAt: now)
        var updated = document; updated.profiles.append(profile); updated.selectedProfileID = profile.id
        try commit(updated)
        return profile
    }
    func select(_ id: UUID) throws {
        guard document.profiles.contains(where: { $0.id == id }) else { throw NativeSaveError.unknownProfile }
        var updated = document; updated.selectedProfileID = id
        try commit(updated)
    }
    func recordFinishedSession(profileID: UUID,runID: UUID,score: UInt16,won: Bool,lifetimeBefore: Int) throws -> Int {
        guard let index = document.profiles.firstIndex(where: { $0.id == profileID }) else { throw NativeSaveError.unknownProfile }
        if document.profiles[index].lastResultRunID == runID { return document.profiles[index].lifetimePoints ?? lifetimeBefore }
        var updated = document
        let total = VerifiedScore.lifetimeAfterSession(current: updated.profiles[index].lifetimePoints ?? lifetimeBefore,sessionScore: score,won: won)
        if won {
            let entry = NativeHighGameScore(name: updated.profiles[index].name,score: score,rank: VerifiedRank.forLifetimePoints(updated.profiles[index].lifetimePoints ?? lifetimeBefore),runID: runID)
            updated.highGameScores = OriginalScoreTable.adding(entry,to: updated.highGameScores ?? [])
        }
        updated.profiles[index].lifetimePoints = total; updated.profiles[index].lastResultRunID = runID
        updated.profiles[index].updatedAt = Date(); try commit(updated)
        return total
    }
    func saveSettings(profileID: UUID,settings: OriginalGameSettings,practice: Bool) throws {
        guard settings.valid else { throw DrillError.invalidSettings }
        guard let index = document.profiles.firstIndex(where: { $0.id == profileID }) else { throw NativeSaveError.unknownProfile }
        var updated = document
        if practice { updated.profiles[index].practiceSettings = settings }
        else { updated.profiles[index].customGameSettings = settings }
        updated.profiles[index].updatedAt = Date(); try commit(updated)
    }
}

final class ProfileController: NSViewController {
    let store: NativeProfileStore
    let picker = NSPopUpButton()
    let nameField = NSTextField()
    let message = NSTextField(wrappingLabelWithString: "")
    let selectButton = NSButton(title: "Select profile", target: nil, action: nil)
    init(store: NativeProfileStore) { self.store = store; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError("Not used") }
    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 760, height: 620))
        let title = NSTextField(labelWithString: "Outnumbered")
        title.font = .boldSystemFont(ofSize: 34)
        let subtitle = NSTextField(labelWithString: "Native reimplementation • development build")
        subtitle.textColor = .secondaryLabelColor
        let explanation = NSTextField(wrappingLabelWithString: "Native player profiles are available. Recovered game content and rules will be enabled as they are verified.")
        nameField.placeholderString = "New player name"
        nameField.setAccessibilityLabel("New native player name")
        nameField.target = self; nameField.action = #selector(createProfile)
        let add = NSButton(title: "Create profile", target: self, action: #selector(createProfile))
        let createRow = NSStackView(views: [nameField, add]); createRow.spacing = 12
        nameField.widthAnchor.constraint(greaterThanOrEqualToConstant: 240).isActive = true
        picker.setAccessibilityLabel("Saved native profiles")
        selectButton.target = self; selectButton.action = #selector(selectProfile)
        let chooseRow = NSStackView(views: [picker, selectButton]); chooseRow.spacing = 12
        picker.widthAnchor.constraint(greaterThanOrEqualToConstant: 240).isActive = true
        message.textColor = .secondaryLabelColor
        message.setAccessibilityLabel("Profile status")
        let evidence = NSTextField(wrappingLabelWithString: "Verified: 9 PM–midnight; room challenges pause the clock. Rank thresholds are recovered. Clock timer and score tables are recovered. Question rules and navigation are still under analysis.")
        evidence.textColor = .secondaryLabelColor
        let note = NSTextField(wrappingLabelWithString: "Native saves use a separate Application Support folder. Original DOS assets and player files remain unchanged.")
        note.textColor = .secondaryLabelColor; note.font = .systemFont(ofSize: 11)
        let stack = NSStackView(views: [title, subtitle, explanation, createRow, chooseRow, message, evidence, note])
        stack.orientation = .vertical; stack.alignment = .leading; stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 48),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -48),
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 42),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -30),
            explanation.widthAnchor.constraint(equalTo: stack.widthAnchor),
            message.widthAnchor.constraint(equalTo: stack.widthAnchor),
            evidence.widthAnchor.constraint(equalTo: stack.widthAnchor),
            note.widthAnchor.constraint(equalTo: stack.widthAnchor)
        ])
        refresh()
    }
    private func refresh() {
        picker.removeAllItems()
        for profile in store.document.profiles { picker.addItem(withTitle: profile.name) }
        if let selected = store.document.selectedProfileID, let index = store.document.profiles.firstIndex(where: { $0.id == selected }) { picker.selectItem(at: index) }
        picker.isEnabled = !store.document.profiles.isEmpty
        selectButton.isEnabled = !store.document.profiles.isEmpty
        if store.document.profiles.isEmpty { message.stringValue = "Create a native profile to prepare a save slot." }
    }
    @objc private func createProfile() {
        do {
            let profile = try store.create(name: nameField.stringValue)
            nameField.stringValue = ""; refresh(); message.stringValue = "Profile “\(profile.name)” saved. Game content is still being verified."
        } catch { message.stringValue = error.localizedDescription }
    }
    @objc private func selectProfile() {
        let index = picker.indexOfSelectedItem
        guard store.document.profiles.indices.contains(index) else { return }
        do {
            let profile = store.document.profiles[index]
            try store.select(profile.id)
            message.stringValue = "Selected “\(profile.name)”. Game content is still being verified."
        } catch { message.stringValue = error.localizedDescription }
    }
}

final class ReimplementationDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    func applicationDidFinishLaunching(_ notification: Notification) {
        let root = NSMenu(), appItem = NSMenuItem(), appMenu = NSMenu()
        root.addItem(appItem); appItem.submenu = appMenu
        appMenu.addItem(withTitle: "Quit Outnumbered", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        NSApp.mainMenu = root
        do {
            let store = try NativeProfileStore(directory: NativeProfileStore.defaultDirectory)
            window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 760, height: 620), styleMask: [.titled, .closable, .miniaturizable], backing: .buffered, defer: false)
            window.title = "Outnumbered — Native Reimplementation (Development)"
            window.contentViewController = ProfileController(store: store)
            window.center(); window.makeKeyAndOrderFront(nil); NSApp.activate(ignoringOtherApps: true)
        } catch {
            let alert = NSAlert(); alert.messageText = "Native profiles could not be opened"; alert.informativeText = error.localizedDescription
            alert.runModal(); NSApp.terminate(nil)
        }
    }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
}

func nativeInfrastructureSelfTest() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent("outnumbered-save-test-" + UUID().uuidString, isDirectory: true)
    defer { try? FileManager.default.removeItem(at: root) }
    var checks: [String: Bool] = [:]
    let store = try NativeProfileStore(directory: root)
    checks["does_not_create_save_on_read"] = !FileManager.default.fileExists(atPath: root.path)
    let first = try store.create(name: "  Ada  "), second = try store.create(name: "Grace")
    checks["profile_name_trimmed"] = first.name == "Ada"
    checks["unique_ids"] = first.id != second.id
    try store.select(first.id)
    let loaded = try NativeProfileStore(directory: root)
    checks["round_trip_profiles"] = loaded.document.profiles.map(\.name) == ["Ada", "Grace"]
    checks["round_trip_selection"] = loaded.document.selectedProfileID == first.id
    let original = try Data(contentsOf: store.file)
    do { try store.create(name: "\n"); checks["reject_empty"] = false } catch { checks["reject_empty"] = true }
    do { try store.create(name: "ada"); checks["reject_duplicate_name"] = false } catch { checks["reject_duplicate_name"] = true }
    do { try store.select(UUID()); checks["reject_unknown_profile"] = false } catch { checks["reject_unknown_profile"] = true }
    checks["invalid_actions_preserve_save"] = try Data(contentsOf: store.file) == original
    var invalid = store.document; invalid.formatVersion = 99
    let encoder = JSONEncoder(); encoder.dateEncodingStrategy = .iso8601
    let future = try encoder.encode(invalid); try future.write(to: store.file, options: .atomic)
    do { _ = try NativeProfileStore(directory: root); checks["reject_future_version"] = false } catch { checks["reject_future_version"] = true }
    checks["future_file_preserved"] = try Data(contentsOf: store.file) == future
    for (i, threshold) in VerifiedRank.thresholds.enumerated() {
        checks["rank_at_\(threshold)"] = VerifiedRank.forLifetimePoints(threshold) == VerifiedRank.allCases[i]
        if i > 0 { checks["rank_before_\(threshold)"] = VerifiedRank.forLifetimePoints(threshold - 1) == VerifiedRank.allCases[i - 1] }
    }
    checks["negative_rank_clamped"] = VerifiedRank.forLifetimePoints(-1) == .trainee
    var clock = VerifiedClock()
    checks["clock_starts_at_nine"] = clock.secondsAfterMidnight == 21 * 3600 && !clock.expired
    clock.pollAfterIRQTicks(780)
    checks["clock_deadline_is_strict"] = clock.elapsedMinutes == 0
    clock.pollAfterIRQTicks(1)
    checks["clock_advances_one_minute"] = clock.elapsedMinutes == 1
    clock.pause(); clock.pollAfterIRQTicks(10000)
    checks["room_challenge_pauses_clock"] = clock.elapsedMinutes == 1
    clock.pause(); clock.resume(); clock.pollAfterIRQTicks(10000)
    checks["nested_pause_stays_paused"] = clock.roomChallengeActive && clock.elapsedMinutes == 1
    clock.resume(); clock.pollAfterIRQTicks(780)
    checks["resume_preserves_remaining_deadline"] = clock.elapsedMinutes == 1
    clock.pollAfterIRQTicks(1)
    checks["clock_resumes"] = clock.elapsedMinutes == 2
    for _ in 0..<178 { clock.pollAfterIRQTicks(781) }
    checks["clock_ends_at_midnight"] = clock.expired && clock.secondsAfterMidnight == 24 * 3600
    clock.pollAfterIRQTicks(10000)
    checks["clock_does_not_pass_midnight"] = clock.elapsedMinutes == 180
    clock.restart(); checks["clock_restart"] = !clock.expired && clock.elapsedMinutes == 0 && !clock.roomChallengeActive
    clock.advance(realSeconds: .nan); clock.advance(realSeconds: -1)
    checks["invalid_time_ignored"] = clock.counterTicks == 0
    for rank in VerifiedRank.allCases {
        let row = VerifiedScore.values(for: rank)
        checks["room_award_" + rank.rawValue] = (0...2).allSatisfy { VerifiedScore.roomAward(rank: rank, previousWrongAnswers: $0) == row.roomBase - row.wrongAnswerDeduction * $0 }
    }
    checks["reject_invalid_attempt_count"] = VerifiedScore.roomAward(rank: .trainee, previousWrongAnswers: 3) == nil
    checks["trainee_first_answer_300"] = VerifiedScore.roomAward(rank: .trainee, previousWrongAnswers: 0) == 300
    checks["paired_rank_tuning"] = VerifiedScore.values(for: .junior).roomBase == 300 && VerifiedScore.values(for: .senior).victoryBonus == 2000 && VerifiedScore.values(for: .expert).roomBase == 600
    checks["trainee_victory_bonus"] = VerifiedScore.winningScore(sessionScore: 300, rank: .trainee, energy: 12, minutesRemaining: 100) == 5000
    checks["session_score_word_wraps"] = VerifiedScore.adding(100, to: 65500) == 64
    checks["loss_keeps_lifetime"] = VerifiedScore.lifetimeAfterSession(current: 1000, sessionScore: 300, won: false) == 1000
    checks["win_adds_lifetime"] = VerifiedScore.lifetimeAfterSession(current: 1000, sessionScore: 300, won: true) == 1300
    checks["lifetime_cap"] = VerifiedScore.lifetimeAfterSession(current: 9_999_950, sessionScore: 100, won: true) == 9_999_999
    checks["initial_energy_12"] = VerifiedEnergy.initial == 12
    checks["zap_cost_one"] = VerifiedEnergy.applying(-1, to: 12) == 11
    checks["empty_energy_not_negative"] = VerifiedEnergy.applying(-1, to: 0) == 0
    checks["energy_not_capped_by_meter"] = VerifiedEnergy.applying(2, to: 24) == 26
    let failureStore = try NativeProfileStore(directory: root.appendingPathComponent("failed-write"))
    _ = try failureStore.create(name: "Existing")
    try FileManager.default.removeItem(at: failureStore.file)
    try FileManager.default.createDirectory(at: failureStore.file, withIntermediateDirectories: false)
    do { try failureStore.create(name: "Unsaved"); checks["failed_write_throws"] = false } catch { checks["failed_write_throws"] = true }
    checks["failed_write_preserves_memory"] = failureStore.document.profiles.map(\.name) == ["Existing"]
    let report: [String: Any] = ["kind": "Native profile, verified rank and clock checks; isolated temporary directory", "passed": checks.values.allSatisfy { $0 }, "checks": checks, "game_rules_verified": false, "gui_verified": false]
    print(String(data: try JSONSerialization.data(withJSONObject: report, options: [.prettyPrinted, .sortedKeys]), encoding: .utf8)!)
    if !checks.values.allSatisfy({ $0 }) { exit(1) }
}

#if FOUNDATION_APP
@main struct FoundationApplication {
    static func main() {
        if CommandLine.arguments.contains("--self-test") {
            do { try nativeInfrastructureSelfTest() } catch { fputs("Self-test failed: \(error)\n", stderr); exit(1) }
        } else {
            let app = NSApplication.shared; app.setActivationPolicy(.regular)
            let delegate = ReimplementationDelegate(); app.delegate = delegate; app.run()
        }
    }
}
#endif
