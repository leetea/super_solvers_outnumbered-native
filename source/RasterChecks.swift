import Cocoa

//Independent10684→11168 oracle: packed nibbles become four bitplanes;
//their OR is the write mask, while flag20h reverses bit order.
func nativeRasterChecks(root: URL,output: URL) throws -> [String:Bool] {
    let names = OriginalRasterFixtures.names
    let cases: [(Int,Int,Bool,Bool,(Int,Int,Int,Int)?)] = [
        (8,15,false,false,nil),(8,15,true,false,(8,15,304,143)),
        (-16,27,true,true,(8,15,304,143)),(88,-8,true,false,(8,15,304,143)),
        (172,17,true,true,(8,15,304,143)),(296,142,false,true,(8,15,304,143))
    ]
    var checks: [String:Bool] = [:],trailerCount = 0,aligned = true,compared = 0
    var passed = [Bool](repeating: true,count: cases.count),failures: [String] = []
    let canvas = NativeCanvas(),content = OriginalContent(root: root)
    let background = (0..<64000).map { UInt8(($0/320+$0%320)%16) }
    for name in names {
        let raw = [UInt8](try Data(contentsOf: root.appendingPathComponent("catalog/decoded/"+name+".bin")))
        let width = Int(raw[16])*4,height = Int(raw[17]),extent = width*height/2+18
        if raw.count > extent { trailerCount += 1 }
        aligned = aligned && width%8 == 0
        var planes = [UInt8](repeating: 0,count: width*height/2)
        //10684 consumes eight pixels/four bytes per group. Its output order
        //CL,CH,AL,AH gives least-significant color plane first.
        for group in 0..<(width*height/8) {
            for sourceByte in 0..<4 {
                let packed = raw[18+group*4+sourceByte]
                for bit in 0..<4 {
                    if packed & UInt8(1<<(bit+4)) != 0 { planes[group*4+bit] |= UInt8(0x80>>(sourceByte*2)) }
                    if packed & UInt8(1<<bit) != 0 { planes[group*4+bit] |= UInt8(0x80>>(sourceByte*2+1)) }
                }
            }
        }
        let bitmap = try content.bitmap(name)
        for (caseIndex,test) in cases.enumerated() {
            let (left,top,transparent,flipped,clip) = test
            var expected = background
            for group in 0..<(width*height/8) {
                let p = Array(planes[(group*4)..<(group*4+4)])
                let writeMask = transparent ? p.reduce(0,|) : 255
                for bit in 0..<8 {
                    let mask = UInt8(0x80>>bit)
                    if writeMask&mask == 0 { continue }
                    let sourceX = (group%(width/8))*8+bit
                    let x = left+(flipped ? width-1-sourceX : sourceX),y = top+group/(width/8)
                    if x < 0 || x >= 320 || y < 0 || y >= 200 { continue }
                    if let c = clip, x < c.0 || x >= c.0+c.2 || y < c.1 || y >= c.1+c.3 { continue }
                    var color: UInt8 = 0
                    for plane in 0..<4 { if p[plane]&mask != 0 { color |= UInt8(1<<plane) } }
                    expected[y*320+x] = color
                }
            }
            canvas.clip = nil;canvas.restoreEndingRect(background,x: 0,y: 0,right: 319,bottom: 199)
            canvas.clip = clip.map { (x:$0.0,y:$0.1,width:$0.2,height:$0.3) }
            canvas.draw(bitmap,x: left,y: top,transparent: transparent,flipped: flipped)
            let same = canvas.pixels == expected;passed[caseIndex] = passed[caseIndex] && same
            if !same { failures.append(name+"/"+String(caseIndex)) }
            compared += 1
        }
    }
    checks["graphics_original389_bitmap_extents_are_eight_pixel_aligned"] = names.count == 389 && aligned
    checks["graphics_original26_trailers_retained_outside_declared_height"] = trailerCount == 26
    for (i,result) in passed.enumerated() { checks["graphics_original_planar_mask_clip_mirror_case_\(i)_all389_bitmaps"] = result }
    let report: [String:Any] = ["sourceSHA256":"ff2e0d28e0a6aa8bcf86db1ea8a2980d2ccb1e10dd793bc15ab1bb929697b464","bitmapCount":names.count,"comparisonCount":compared,"caseResults":passed,"failures":failures,"trailingExtentsRetained":trailerCount,"method":"Independent packed-nibble→four-plane conversion and OR-mask composition from10684/11168; native canvas compared in six clipping/mirroring/opaque-transparent cases on16-color backgrounds.","limits":["Static-source algebra and native output; no original DOS execution or full-frame gameplay trace.","CGA/monochrome paths and originalCPU/display-speed dependence are outside the16-color target."]]
    try JSONSerialization.data(withJSONObject: report,options: [.prettyPrinted,.sortedKeys]).write(to: output.appendingPathComponent("graphics-planar-comparison.json"))
    return checks
}
