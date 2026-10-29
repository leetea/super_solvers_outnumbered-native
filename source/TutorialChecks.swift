import Foundation

func nativeTutorialChecks(root: URL,output: URL) throws -> [String:Bool] {
    var checks: [String:Bool] = [:]
    checks["source_music_only_indices_zero_through_five"] = (0..<6).allSatisfy { !OriginalSoundPolicy.accepts(incoming: $0,current: nil,playing: false,musicEnabled: false) } && (6..<52).allSatisfy { OriginalSoundPolicy.accepts(incoming: $0,current: nil,playing: false,musicEnabled: false) }
    checks["source_sound_off_blocks_music_and_effects"] = (0..<52).allSatisfy { !OriginalSoundPolicy.accepts(incoming: $0,current: nil,playing: false,soundEnabled: false) }
    checks["music_switch_does_not_bypass_strict_priority"] = !OriginalSoundPolicy.accepts(incoming: 6,current: 6,playing: true,musicEnabled: false) && OriginalSoundPolicy.accepts(incoming: 6,current: 0,playing: true)
    checks["all_eighteen_source_messages_retained"] = OriginalNewUserText.messages.count == 18 && OriginalNewUserText.messages[0].hasPrefix("Now the search begins!") && OriginalNewUserText.messages[17].contains("As a Trainee")
    let accessible = OriginalNewUserText.messages.map(OriginalNewUserText.accessible)
    checks["native_message_keycap_substitutions_readable"] = accessible.allSatisfy { !$0.unicodeScalars.contains(where: { (0x80...0x8d).contains($0.value) }) } && accessible[3].contains("[Tab]") && accessible[10].contains("[=]")
    var state = NativeNewUserMessages(enabled: false)
    state.queue(6); state.queue(1); state.queue(14)
    checks["queued_messages_record_while_disabled_without_showing"] = state.flags[1] == 1 && state.nextQueued(actorsSettled: true) == nil
    state.enabled = true
    checks["queued_first_thirteen_use_original_numeric_order"] = state.nextQueued(actorsSettled: true) == 1 && state.nextQueued(actorsSettled: false) == nil
    state.acknowledge(1); state.queue(1)
    checks["acknowledged_messages_cannot_requeue_or_show"] = state.flags[1] == -1 && !state.canShow(1) && state.nextQueued(actorsSettled: true) == 6
    state.acknowledge(6)
    checks["queue_does_not_automatically_show_indices_thirteen_plus"] = state.nextQueued(actorsSettled: true) == nil && state.canShow(14)
    state.chooseEnabled(true)
    checks["source_yes_resets_all_eighteen_seen_states"] = state.flags == Array(repeating: 0,count: 18)
    state.schedule(8,after: 720,now: 100)
    checks["tutorial_timer_strictly_after_source_deadline"] = state.takeExpired(now: 820) == nil && state.takeExpired(now: 821) == 8 && state.timedMessage == nil
    state.schedule(15,after: 1200,now: 100); state.cancelTimed()
    checks["first_input_cancels_and_marks_timed_message_seen"] = state.timedMessage == nil && state.flags[15] == -1 && !state.canShow(15)
    state.enabled = false; state.schedule(16,after: 1200,now: 100)
    checks["disabled_timed_message_expires_without_acknowledgement"] = state.takeExpired(now: 1301) == nil && state.flags[16] == 0 && state.timedMessage == nil
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent("outnumbered-tutorials-"+UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let view = try NativeGameView(root: root,saveDirectory: directory)
    view.timer?.invalidate(); view.zapTimer?.invalidate(); view.soundEnabled = false
    var shown: [Int] = [], pauses: [Int] = []
    view.messagePresenter = { id,_ in shown.append(id); pauses.append(view.session?.clock.pauseDepth ?? 0) }
    let player = try view.profileStore.create(name: "Tutorial test")
    view.begin(); let random = view.session.generator.randomState
    view.session.clock.applyMinutePenalty(2)
    let fixture = output.appendingPathComponent("tutorial-gui-players")
    try FileManager.default.createDirectory(at: fixture,withIntermediateDirectories: true)
    try Data(contentsOf: view.profileStore.file).write(to: fixture.appendingPathComponent("profiles-v1.json"))
    try NativeSessionStore(directory: fixture).save(view.session!)
    view.processTutorials(); view.processTutorials()
    checks["search_message_at_nine_oh_two_once"] = shown == [0] && view.session.newUserMessages?.flags[0] == -1
    checks["message_modal_owns_only_its_pause_and_keeps_rng"] = pauses == [1] && view.session.clock.pauseDepth == 0 && view.modalDepth == 0 && view.session.generator.randomState == random
    view.setNewUserMessages(true); view.processTutorials()
    checks["reset_messages_does_not_replay_clock_trigger_without_clock_update"] = shown == [0] && view.session.newUserMessages?.flags[0] == 0
    view.session.energy = 5; view.processTutorials()
    checks["energy_below_six_queues_low_zapper_message"] = shown.last == 11
    view.session.clock.applyMinutePenalty(58); view.processTutorials()
    checks["after_ten_with_missing_secrets_or_clues_offers_help"] = shown.last == 12
    view.setNewUserMessages(false); view.showNewUserMessage(5)
    checks["messages_no_stops_popup_without_erasing_states"] = shown.last == 12 && view.session.newUserMessages?.flags[11] == -1
    view.setNewUserMessages(true)
    let weather = view.bank.cases.first { $0.id == 9078 && $0.seed == 2 && $0.variant == 3 }!
    view.open(weather)
    checks["calculator_question_uses_original_tenth_message"] = shown.last == 10 && pauses.last == 2 && view.session.clock.pauseDepth == 1
    view.session.attempts[weather.hotspot]?.input = "644"; _ = view.session.resolve(weather); view.leaveQuestion()
    checks["correct_room_completion_explains_decoder_clues"] = shown.last == 7 && view.session.clock.pauseDepth == 0
    try view.saves.save(view.session!)
    let saved = try view.saves.load(player.id)!
    checks["original_message_flags_and_enable_choice_persist"] = saved.newUserMessages?.flags[7] == -1 && saved.newUserMessages?.enabled == true
    let encoder = JSONEncoder(); encoder.outputFormatting = .sortedKeys
    let adventure = try encoder.encode(view.session!)
    let adventureFile = try Data(contentsOf: view.saves.file(player.id))
    try view.launchPractice(settings: .defaults(tier: 0),seed: 1)
    view.showNewUserMessage(8)
    checks["practice_tutorial_state_does_not_change_suspended_adventure"] = try encoder.encode(view.session!) == adventure && view.practiceMessages.flags[8] == -1 && Data(contentsOf: view.saves.file(player.id)) == adventureFile
    view.preparePracticeMessages()
    checks["practice_message_states_survive_repeated_sets_or_launch"] = view.practiceMessages.flags[8] == -1
    view.screen = .world; view.tutorialPracticeContext = true
    view.showNewUserMessage(16); view.tutorialPracticeContext = false
    checks["practice_setup_guidance_keeps_suspended_clock_bytes_unchanged"] = try encoder.encode(view.session!) == adventure && Data(contentsOf: view.saves.file(player.id)) == adventureFile
    view.referenceQuestion(); view.showNewUserMessage(10)
    checks["isolated_reference_checkpoints_do_not_interrupt_with_tutorials"] = shown.last == 16
    view.lastSoundIndex = 20; view.setMusicEnabled(false)
    checks["music_off_stops_any_current_stream_without_master_toggle"] = view.lastSoundIndex == nil && !view.musicEnabled && !view.soundEnabled
    view.setSoundEnabled(true)
    checks["sound_on_does_not_reenable_music"] = view.soundEnabled && !view.musicEnabled
    view.setMusicEnabled(true)
    checks["music_on_waits_for_next_source_trigger"] = view.lastSoundIndex == nil && view.musicEnabled && view.soundEnabled
    // Audio probes exercise the real action dispatcher without an audio device.
    final class SoundProbe: NativeSoundPlayback {
        var isPlaying = false
        var currentTime = 0.0
        var plays = 0,stops = 0
        let index: Int
        init(_ index: Int) { self.index = index }
        func play() -> Bool { plays += 1;isPlaying = true;return true }
        func stop() -> Bool { stops += 1;isPlaying = false;return true }
    }
    var streams: [SoundProbe] = [],trace: [[String:Any]] = []
    view.soundFactory = { url in
        let index = Int(url.deletingPathExtension().lastPathComponent.suffix(2))!
        let stream = SoundProbe(index);streams.append(stream);return stream
    }
    view.stopSound();view.referenceMode = true;view.screen = .world
    view.session = NativeSession(profileID: UUID(),seed: 1)
    view.session.position = NativePosition(scene: 5,playerUnit: 210,cameraUnit: 190,facing: 1)
    view.clearTelly()
    view.effect(2);streams.last!.currentTime = 7.25;view.effect(2)
    checks["music_repeated_frame_requests_leave_active_cursor_untouched"] = streams.count == 1 && streams[0].plays == 1 && streams[0].currentTime == 7.25
    view.beginJump(direction: 0)
    for _ in 0..<8 { let movement = view.preparePlayerFrame();view.finishPlayerFrame(movement) }
    checks["jump_landing_effect_bookmarks_playing_music"] = view.lastSoundIndex == 38 && view.interruptedMusic?.index == 2 && view.interruptedMusic?.position == 7.25 && !streams[0].isPlaying
    view.effect(2)
    checks["music_resume_waits_for_higher_priority_effect_completion"] = streams.count == 2 && view.lastSoundIndex == 38
    streams.last!.isPlaying = false
    let movement = view.preparePlayerFrame();view.finishPlayerFrame(movement)
    checks["jump_landing_resumes_music_at_saved_position"] = view.lastSoundIndex == 2 && streams.last!.currentTime == 7.25 && view.interruptedMusic == nil
    // Space follows the ordinary held-key poll and timed zap completion path.
    for attempt in 1...3 {
        let position = 7.25+Double(attempt)*2
        streams.last!.currentTime = position
        let event = GameInputEvent.keyEvent(with: .keyDown,location: .zero,modifierFlags: [],timestamp: 0,windowNumber: 0,context: nil,characters: " ",charactersIgnoringModifiers: " ",isARepeat: false,keyCode: 49)!
        view.keyDown(with: event);view.pollWorldKeyboard();view.physicalKeyboard.release(49)
        let began = view.session.activeZap != nil
        view.lastZapPulse = ProcessInfo.processInfo.systemUptime-2;view.pulseZap()
        let preserved = view.interruptedMusic?.position == position && view.lastSoundIndex == 14
        // Equal-priority requests must not replace the original music bookmark.
        if attempt == 2 { view.effect(21) }
        streams.last!.isPlaying = false
        let movement = view.preparePlayerFrame();view.finishPlayerFrame(movement)
        checks["space_action_resumes_music_without_restarting_\(attempt)"] = began && preserved && view.session.activeZap == nil && view.lastSoundIndex == 2 && streams.last!.currentTime == position
        trace.append(["action":"Space","attempt":attempt,"interruptedSeconds":position,"resumedSeconds":streams.last!.currentTime])
    }
    streams.last!.currentTime = 14.5;view.effect(14);view.stopSound(resetMusic: false);view.effect(2)
    checks["effect_only_stop_preserves_music_bookmark"] = streams.last!.currentTime == 14.5 && view.interruptedMusic == nil
    streams.last!.currentTime = 15;view.effect(14);streams.last!.isPlaying = false;view.effect(1)
    checks["changing_background_tune_discards_old_music_bookmark"] = streams.last!.index == 1 && streams.last!.currentTime == 0 && view.interruptedMusic == nil
    streams.last!.currentTime = 3;streams.last!.isPlaying = false;view.effect(1)
    checks["natural_music_completion_starts_next_loop_at_zero"] = streams.last!.currentTime == 0 && view.interruptedMusic == nil
    streams.last!.currentTime = 4;view.effect(14);view.setMusicEnabled(false)
    let beforeMute = streams.count;view.effect(1)
    checks["music_off_clears_interrupted_bookmark_and_blocks_restart"] = view.interruptedMusic == nil && view.lastSoundIndex == nil && streams.count == beforeMute
    view.setMusicEnabled(true);view.effect(1)
    checks["music_reenabled_starts_fresh_on_next_trigger"] = streams.last!.currentTime == 0
    streams.last!.currentTime = 5;view.effect(14);view.setSoundEnabled(false);view.effect(1);view.effect(38)
    checks["sound_master_off_clears_bookmark_and_stops_all_audio"] = view.interruptedMusic == nil && view.lastSoundIndex == nil && !streams.last!.isPlaying
    view.setSoundEnabled(true);view.effect(1);streams.last!.currentTime = 6;view.effect(14);view.stopSound();view.effect(1)
    checks["explicit_scene_stop_does_not_leak_music_cursor_into_new_scene"] = streams.last!.currentTime == 0 && view.interruptedMusic == nil
    try JSONSerialization.data(withJSONObject: trace,options: [.prettyPrinted,.sortedKeys]).write(to: output.appendingPathComponent("music-resume-action-trace.json"))
    return checks
}
