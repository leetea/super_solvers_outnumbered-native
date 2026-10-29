import Foundation

func nativeSignInChecks(root: URL,output: URL) throws -> [String:Bool] {
    var checks: [String:Bool] = [:],name = OriginalMemberName()
    for c in " a!b@c#123456" { name.append(c) }
    checks["member_name_original_ascii_limit_and_first_capital"] = name.text == "Abc12345"
    name.erase();checks["member_name_backspace_one_slot"] = name.text == "Abc1234"
    var blank = OriginalMemberName();blank.append(" ")
    checks["member_name_blank_and_leading_space_ignored"] = blank.submitted == nil && blank.display == "________"
    for c in "joe  " { blank.append(c) }
    checks["member_name_interior_spaces_and_enter_trims_trailing"] = blank.text == "Joe  " && blank.submitted == "Joe"
    blank.append("é");blank.append("😃")
    checks["member_name_non_ascii_ignored"] = blank.text == "Joe  "
    var model = NativeMemberSignIn(memberCount: 2)
    checks["member_picker_initially_selects_new_member"] = model.mode == .select && model.selection == 2
    model.move(1,memberCount: 2);checks["member_picker_down_wraps_to_first"] = model.selection == 0
    model.move(-1,memberCount: 2);checks["member_picker_up_wraps_to_new"] = model.selection == 2
    model.mode = .remove;model.selection = 0;model.move(-1,memberCount: 2)
    checks["member_remove_picker_excludes_new_member_row"] = model.selection == 1
    checks["member_empty_store_opens_name_dialog"] = NativeMemberSignIn().mode == .newName
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent("outnumbered-members-"+UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let view = try NativeGameView(root: root,saveDirectory: directory,automaticallyPresentMessages: false)
    view.timer?.invalidate();view.zapTimer?.invalidate();view.soundEnabled = false
    let first = try view.profileStore.create(name: "First")
    let second = try view.profileStore.create(name: "Second")
    _ = try view.profileStore.recordFinishedSession(profileID: second.id,runID: UUID(),score: 1000,won: true,lifetimeBefore: 0)
    _ = try view.profileStore.create(name: "Existing Native Long Name")
    checks["member_picker_uses_original_lifetime_sort"] = view.orderedMembers.map(\.id).prefix(2) == [second.id,first.id]
    try view.profileStore.select(first.id);view.begin();view.session.score = 123
    let encoder = JSONEncoder();encoder.outputFormatting = .sortedKeys;encoder.dateEncodingStrategy = .iso8601
    let snapshot = try encoder.encode(view.session!)
    let random = view.session.generator.randomState
    view.choosePlayer();let before = try Data(contentsOf: view.saves.directory.appendingPathComponent("session-\(view.session.profileID.uuidString)-v1.json"))
    view.step();view.step()
    checks["member_picker_freezes_suspended_session_and_rng"] = try encoder.encode(view.session!) == snapshot && view.session.generator.randomState == random
    try view.render();let pixels = view.canvas.pixels;try view.render()
    checks["member_picker_repeatable_render_without_rng"] = pixels == view.canvas.pixels && view.session.generator.randomState == random
    try view.canvas.writePNG(to: output.appendingPathComponent("native-member-signin.png"))
    view.signIn.mode = .newName;view.signIn.name = OriginalMemberName();for c in "jo  " { view.signIn.name.append(c) }
    try view.render();try view.canvas.writePNG(to: output.appendingPathComponent("native-member-new-name.png"))
    view.submitMemberName()
    checks["member_native_creation_selects_profile_and_play_menu"] = view.selectedProfile?.name == "Jo" && view.screen == .menu && view.session == nil
    let after = try Data(contentsOf: view.saves.directory.appendingPathComponent("session-\(try JSONDecoder().decode(NativeSession.self,from: snapshot).profileID.uuidString)-v1.json"))
    checks["member_creation_preserves_previous_unfinished_file"] = before == after
    view.choosePlayer();view.signIn.mode = .newName;for c in "jo" { view.signIn.name.append(c) };view.submitMemberName()
    checks["member_duplicate_does_not_create_or_select_another"] = view.signIn.error != nil && view.profileStore.document.profiles.count == 4 && view.screen == .signin
    view.signIn.error = nil
    let selectedBeforeRemoval = view.selectedProfile!.id
    let profileBytes = try encoder.encode(view.selectedProfile!)
    try view.removeMember(selectedBeforeRemoval)
    checks["member_removal_archives_instead_of_deletes"] = view.profileStore.document.profiles.count == 3 && view.profileStore.document.archivedProfiles?.count == 1 && view.profileStore.document.selectedProfileID == nil
    let reopened = try NativeProfileStore(directory: directory)
    checks["member_archive_survives_atomic_reload"] = try encoder.encode(reopened.document.archivedProfiles!.first!) == profileBytes
    try reopened.restore(selectedBeforeRemoval)
    checks["member_restore_retains_same_id_name_settings_and_scores"] = try encoder.encode(reopened.document.profiles.first { $0.id == selectedBeforeRemoval }!) == profileBytes
    let retainedHighScores = try encoder.encode(reopened.document.highGameScores)
    try reopened.archive(second.id);try reopened.restore(second.id)
    checks["member_remove_restore_preserves_high_game_history"] = try encoder.encode(reopened.document.highGameScores) == retainedHighScores
    // Isolate File/menu checks from the reopened store above.
    try view.profileStore.select(first.id)
    view.referenceQuestion();let session = try encoder.encode(view.session!)
    view.showFileMenu();view.step();try view.render()
    checks["file_original_five_adventure_items_and_freezes_question"] = try view.screen == .file && view.fileItems == ["Lifetime Scores","High Game Scores","Play Another Game","Start New Player","Exit and Save"] && encoder.encode(view.session!) == session
    try view.canvas.writePNG(to: output.appendingPathComponent("native-file-menu.png"))
    view.fileSelection = 0;view.activateFileItem()
    checks["file_scores_return_to_original_screen"] = view.screen == .scores && view.scoreReturn == .question
    view.closeScores();checks["file_scores_close_preserves_parent_pause"] = view.screen == .question && view.session.clock.pauseDepth == 1
    view.showFileMenu();view.fileSelection = 2;view.activateFileItem();view.keyDown(with: GameInputEvent.keyEvent(with: .keyDown,location: .zero,modifierFlags: [],timestamp: 0,windowNumber: 0,context: nil,characters: "y",charactersIgnoringModifiers: "y",isARepeat: false,keyCode: 16)!);try view.render()
    checks["file_play_another_opens_original_three_choice_menu"] = view.screen == .menu && NativeGameView.playerMenuItems == ["Regular Game","Customized Game","Customized Drill for Skill"]
    try view.canvas.writePNG(to: output.appendingPathComponent("native-play-choice-menu.png"))
    view.activatePlayerMenu(-1)
    checks["play_menu_escape_returns_to_member_signin"] = view.screen == .signin
    try view.launchPractice(settings: .defaults(tier: 0),seed: 1)
    let practice = view.practice!.drill.ticksRemaining
    view.showFileMenu();view.step()
    checks["file_practice_original_three_items_and_freezes_practice"] = view.fileItems == ["Play Another Game","Start New Player","Exit the Program"] && view.practice!.drill.ticksRemaining == practice
    view.closeFileMenu();checks["file_escape_restores_practice"] = view.screen == .practice
    let xor = NativeCanvas();xor.clear(15);xor.xorMemberSelection(40,63,255,10)
    checks["member_selection_original_xor14_inclusive_bounds"] = xor.pixels[63*320+40] == 1 && xor.pixels[72*320+294] == 1 && xor.pixels[73*320+294] == 15 && xor.pixels[63*320+295] == 15
    let reload = try NativeProfileStore(directory: directory)
    checks["member_existing_long_native_names_remain_unmodified"] = reload.document.profiles.contains { $0.name == "Existing Native Long Name" }
    return checks
}
