import Cocoa

func nativeHelpChecks(root: URL,output: URL) throws -> [String:Bool] {
    var checks: [String:Bool] = [:]
    let book = try JSONDecoder().decode(OriginalHelpBook.self,from: Data(contentsOf: root.appendingPathComponent("help-pages.json")))
    checks["help_original_eight_topics_22_pages"] = book.valid && book.topics.map(\.title) == ["Using the Keyboard","Playing the Game","Capturing Secret Code","Collecting Clues","Using the Calculator","Winning the Game","Moving Up in Rank","Playing Drill for Skill"]
    let offsets = book.topics.flatMap { $0.pages.map(\.sourceOffset) }
    checks["help_all_original_header_text_offsets"] = offsets == [96,335,560,736,2100,2408,2721,3136,3428,4782,4993,6333,6681,6991,8306,8697,8913,9225,9592,9933,10339,10614]
    let images = book.topics.flatMap { $0.pages.compactMap(\.illustration) }
    checks["help_four_embedded_illustration_positions_and_extents"] = images.map(\.sourceOffset) == [1072,3754,5329,7146] && images.map(\.x) == [36,36,36,96] && images.map(\.y) == [37,37,37,67] && images.map(\.width) == [48,48,48,120] && images.map(\.height) == [42,42,41,19]
    let keyboard = book.topics[0].pages[0]
    checks["help_keyboard_columns_and_original_keycap_codes"] = keyboard.runs.count == 2 && keyboard.runs[0].x == 28 && keyboard.runs[0].y == 37 && keyboard.runs[0].text.hasPrefix("\u{83} or \u{82}") && keyboard.runs[1].x == 101 && keyboard.runs[1].y == 37 && keyboard.runs[1].text.hasPrefix("Move left or right.")
    var browser = NativeHelpBrowser(practice: false)
    browser.cycleTopic(-1)
    checks["help_topic_selection_wraps_back_to_practice_chapter"] = browser.selectedTopic == 7
    _ = browser.activate(book: book)
    checks["help_single_page_chapter_done_closes"] = browser.topic == 7 && browser.activate(book: book)
    browser = NativeHelpBrowser(practice: false)
    _ = browser.activate(book: book); _ = browser.activate(book: book)
    browser.cycleButton(); _ = browser.activate(book: book)
    checks["help_back_a_page_returns_first_page_and_next_button"] = browser.topic == 0 && browser.page == 0 && browser.selectedButton == 1
    _ = browser.activate(book: book); _ = browser.activate(book: book)
    checks["help_done_available_after_last_original_page"] = browser.page == 2 && browser.activate(book: book)
    browser = NativeHelpBrowser(practice: true)
    _ = browser.activate(book: book)
    checks["practice_help_uses_original_drill_only_topic"] = browser.availableTopics == [7] && browser.topic == 7 && browser.activate(book: book)
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent("outnumbered-help-"+UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let view = try NativeGameView(root: root,saveDirectory: directory)
    view.timer?.invalidate(); view.zapTimer?.invalidate(); view.soundEnabled = false
    func key(_ code: UInt16) {
        view.keyDown(with: NSEvent.keyEvent(with: .keyDown,location: .zero,modifierFlags: [],timestamp: 0,windowNumber: 0,context: nil,characters: "",charactersIgnoringModifiers: "",isARepeat: false,keyCode: code)!)
    }
    key(122)
    checks["native_f1_help_available_before_player_session"] = view.screen == .help && view.helpReturn == .title && view.session == nil
    key(36); try view.render()
    try view.canvas.writePNG(to: output.appendingPathComponent("native-help-keyboard.png"))
    checks["native_help_title_frame_and_footer_separator"] = view.canvas.pixels[34*320+19] == 1 && view.canvas.pixels[168*320+19] == 1 && view.canvas.pixels[100*320+18] == 1
    key(53)
    checks["native_help_escape_page_returns_to_topic_menu"] = view.screen == .help && view.helpBrowser?.topic == nil
    key(53)
    checks["native_help_escape_menu_restores_title"] = view.screen == .title && view.session == nil
    _ = try view.profileStore.create(name: "Help test")
    view.referenceQuestion(); let before = view.session.generator.randomState
    key(122); key(36)
    view.needsDisplay = false
    for _ in 0..<100 { view.step() }
    checks["static_help_does_not_reinvalidate_unchanged_text"] = !view.needsDisplay
    checks["help_pauses_question_without_changing_random_stream"] = view.session.clock.elapsedMinutes == 0 && view.session.clock.pauseDepth == 2 && view.session.generator.randomState == before && view.session.activeChallenge?.answer == 644
    var rendered = 0
    for topic in book.topics.indices {
        for page in book.topics[topic].pages.indices {
            view.helpBrowser?.topic = topic; view.helpBrowser?.page = page; view.helpBrowser?.selectedButton = 1
            try view.render(); let pixels = view.canvas.pixels; try view.render()
            if view.canvas.pixels == pixels { rendered += 1 }
            if let image = book.topics[topic].pages[page].illustration {
                try view.canvas.writePNG(to: output.appendingPathComponent("native-help-illustration-\(image.sourceOffset).png"))
            }
        }
    }
    checks["all_22_original_help_pages_render_repeatably_without_rng_draws"] = rendered == 22 && view.session.generator.randomState == before
    view.helpBrowser?.topic = 1; view.helpBrowser?.page = 0; try view.render()
    checks["original_help_illustration_pixel_at_source_coordinates"] = view.canvas.pixels[37*320+36] == 8 && view.canvas.pixels[36*320+36] == 15
    view.closeHelp()
    checks["help_close_retains_parent_question_pause"] = view.screen == .question && view.session.clock.pauseDepth == 1 && view.session.activeChallenge?.answer == 644
    key(122); key(120)
    checks["f2_from_help_cleans_only_help_pause"] = view.screen == .menu && view.session.clock.pauseDepth == 1 && view.helpBrowser == nil
    view.screen = .world; view.session.activeChallenge = nil; view.session.clock.resume()
    try view.launchPractice(settings: .defaults(tier: 0),seed: 1)
    let encoder = JSONEncoder(); encoder.outputFormatting = .sortedKeys
    let adventure = try encoder.encode(view.session!), practice = view.practice!.drill.ticksRemaining
    key(122); key(36)
    for _ in 0..<100 { view.step() }
    checks["practice_help_freezes_practice_and_keeps_suspended_adventure_exact"] = try view.screen == .help && view.helpBrowser?.topic == 7 && view.practice!.drill.ticksRemaining == practice && encoder.encode(view.session!) == adventure
    key(36)
    checks["practice_help_done_returns_to_same_set"] = view.screen == .practice && view.practice!.drill.ticksRemaining == practice
    view.screen = .menu; key(122); try view.render()
    checks["help_can_open_over_player_menu"] = view.screen == .help && view.helpReturn == .menu && !view.helpPausesAdventure
    view.closeHelp()
    checks["help_over_menu_does_not_mutate_suspended_game"] = try view.screen == .menu && encoder.encode(view.session!) == adventure
    return checks
}
