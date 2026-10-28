import Cocoa

func nativePaletteChecks(root: URL,output: URL) throws -> [String:Bool] {
    var checks: [String:Bool] = [:]
    let canvas = NativeCanvas()
    func rgb(_ index: Int) -> [UInt8] {
        let value = NativeCanvas.palette[index];return [value.0,value.1,value.2]
    }
    checks["EGA_driver_0298_register_zero_blue_one_black"] = rgb(0) == [0,0,170] && rgb(1) == [0,0,0]
    var bytes = [UInt8](repeating: 0,count: 18)
    bytes[16] = 1;bytes[17] = 4
    bytes += [0x01,0x23,0x45,0x67,0x89,0xab,0xcd,0xef]
    let bitmap = try OriginalBitmap(Data(bytes))
    canvas.clear(5);canvas.draw(bitmap,x: 10,y: 10)
    checks["EGA_bitmap_retains_all_sixteen_source_indices"] = (0..<16).allSatisfy { index in
        let row = 10+index/4, column = 10+index%4
        return canvas.pixels[row*320+column] == UInt8(index)
    }
    let rep = try canvas.representation()
    checks["EGA_opaque_bitmap_zero_blue_one_black_RGBA"] = (0..<4).map { rep.bitmapData![((10*320+10)*4)+$0] } == [0,0,170,255] && (0..<4).map { rep.bitmapData![((10*320+11)*4)+$0] } == [0,0,0,255]
    canvas.clear(5);canvas.draw(bitmap,x: 10,y: 10,transparent: true)
    checks["EGA_transparency_skips_zero_but_keeps_opaque_black"] = canvas.pixels[10*320+10] == 5 && canvas.pixels[10*320+11] == 1
    canvas.clear(5);canvas.draw(bitmap,x: 10,y: 10,transparent: true,flipped: true)
    checks["EGA_flipped_sprite_preserves_transparent_and_black_indices"] = canvas.pixels[10*320+13] == 5 && canvas.pixels[10*320+12] == 1
    canvas.clear(1);canvas.xorMemberSelection(0,0,4,1)
    checks["EGA_selection_black_to_white_and_white_to_black"] = canvas.pixels.prefix(4).allSatisfy { $0 == 15 } && { canvas.xorMemberSelection(0,0,4,1);return canvas.pixels.prefix(4).allSatisfy { $0 == 1 } }()
    canvas.clear(1);canvas.xorTelevisionNoise([80,40])
    checks["EGA_TV_noise_black_to_white_preserves_low_plane"] = canvas.pixels[40*320+80] == 15 && canvas.pixels[40*320+86] == 1 && rgb(15) == [255,255,255]
    canvas.clear(0);canvas.xorTelevisionNoise([80,40])
    checks["EGA_TV_noise_blue_to_yellow_remains_distinct"] = canvas.pixels[40*320+80] == 14 && canvas.pixels[40*320+86] == 0 && rgb(14) == [255,255,85]
    let font = try OriginalContent(root: root).font("MOCKET.DAT.1393")
    canvas.clear(15);canvas.text("Black",font: font,x: 20,y: 20,color: 1)
    let textPixels = canvas.pixels.enumerated().filter { $0.element != 15 }
    let textRep = try canvas.representation()
    checks["EGA_original_text_pen_one_renders_black_without_bitmap_remap"] = !textPixels.isEmpty && textPixels.allSatisfy { i,value in value == 1 && (0..<3).allSatisfy { textRep.bitmapData![i*4+$0] == 0 } }
    let bank = try JSONDecoder().decode(ChallengeBank.self,from: Data(contentsOf: root.appendingPathComponent("challenges.json")))
    let prize = bank.cases.first { $0.id == 9100 && $0.seed == 1 && $0.variant == 0 }!
    checks["EGA_prize_source_final_pen_11_kept_as_index_one"] = try NativeActivityPlan(prize).frames.last!.marks.prefix(4).allSatisfy { $0 == 1 }
    let view = try NativeGameView(root: root,saveDirectory: output.appendingPathComponent("palette-players"),automaticallyPresentMessages: false)
    view.timer?.invalidate();view.zapTimer?.invalidate();view.soundEnabled = false
    try view.profileStore.create(name: "Palette")
    view.choosePlayer();try view.render()
    try view.canvas.writePNG(to: output.appendingPathComponent("native-palette-member-signin.png"))
    checks["EGA_clipboard_selection_keeps_black_text_white_highlight"] = view.canvas.pixels.contains(1) && view.canvas.pixels.contains(15)
    checks["EGA_member_footer_matches_local_video_black"] = view.canvas.pixels[199*320+100] == 1
    view.showPlayerMenu();try view.render()
    checks["EGA_play_menu_footer_matches_local_video_black"] = view.canvas.pixels[199*320+100] == 1
    view.referenceQuestion();try view.render()
    try view.canvas.writePNG(to: output.appendingPathComponent("native-palette-weather.png"))
    return checks
}
