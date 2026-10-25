import Cocoa

enum ContentError: Error, LocalizedError {
    case invalid(String)
    var errorDescription: String? { if case .invalid(let message) = self { return message }; return nil }
}

struct OriginalBitmap {
    let width: Int
    let height: Int
    let pixels: [UInt8]
    init(_ data: Data, permitDocumentedTrailer: Bool = false) throws {
        let bytes = [UInt8](data)
        guard bytes.count >= 18 else { throw ContentError.invalid("Truncated original bitmap") }
        width = Int(bytes[16]) * 4; height = Int(bytes[17])
        let count = width * height
        guard width > 0, height > 0, bytes.count >= 18 + count / 2,
              permitDocumentedTrailer || bytes.count == 18 + count / 2 else { throw ContentError.invalid("Original bitmap extent mismatch") }
        pixels = bytes[18..<(18+count/2)].flatMap { [$0 >> 4, $0 & 15] }
    }
}

struct OriginalFont {
    struct Glyph {
        let x: Int, y: Int, width: Int, height: Int, rowBytes: Int
        let bits: [UInt8]
        var advance: Int { width + 1 }
    }
    let spaceWidth: Int
    let glyphs: [UInt32: Glyph]
    init(_ data: Data) throws {
        let bytes = [UInt8](data)
        func word(_ offset: Int) throws -> Int {
            guard offset >= 0, offset + 2 <= bytes.count else { throw ContentError.invalid("Truncated original font") }
            return Int(bytes[offset]) | Int(bytes[offset+1]) << 8
        }
        let count = try word(0)
        spaceWidth = try word(2)
        guard (1...256).contains(count), (1...64).contains(spaceWidth), 4+count*2 <= bytes.count else { throw ContentError.invalid("Invalid original font header") }
        var recovered: [UInt32: Glyph] = [:]
        for index in 0..<count {
            let start = try 4 + count*2 + word(4+index*2)
            let x = try word(start), y = try word(start+2), width = try word(start+4)
            let rowBytes = try word(start+6), height = try word(start+8)
            guard x < 320, y < 200, width <= 128, height <= 128, rowBytes <= 32,
                  rowBytes*8 >= width, start+10+rowBytes*height <= bytes.count else { throw ContentError.invalid("Invalid original glyph bounds") }
            recovered[UInt32(index+33)] = Glyph(x: x, y: y, width: width, height: height, rowBytes: rowBytes, bits: Array(bytes[(start+10)..<(start+10+rowBytes*height)]))
        }
        glyphs = recovered
    }
    func width(of text: String) -> Int {
        max(0, text.unicodeScalars.reduce(0) { $0 + ($1.value == 32 ? spaceWidth + 1 : glyphs[$1.value]?.advance ?? spaceWidth + 1) } - 1)
    }
}

final class OriginalContent {
    let root: URL
    private var bitmaps: [String: OriginalBitmap] = [:]
    private var fonts: [String: OriginalFont] = [:]
    init(root: URL) { self.root = root }
    func bitmap(_ filename: String) throws -> OriginalBitmap {
        if let cached = bitmaps[filename] { return cached }
        guard !filename.contains("/"), !filename.contains("..") else { throw ContentError.invalid("Invalid original resource name") }
        // The catalog retains exact declared dimensions and every trailer. The
        // native renderer deliberately displays only declared bitmap pixels.
        let value = try OriginalBitmap(Data(contentsOf: root.appendingPathComponent("catalog/decoded/" + filename + ".bin")), permitDocumentedTrailer: true)
        bitmaps[filename] = value; return value
    }
    func font(_ filename: String = "MOCKET.DAT.1396") throws -> OriginalFont {
        if let cached = fonts[filename] { return cached }
        guard !filename.contains("/"), !filename.contains("..") else { throw ContentError.invalid("Invalid font name") }
        let value = try OriginalFont(Data(contentsOf: root.appendingPathComponent("catalog/decoded/" + filename + ".bin")))
        fonts[filename] = value; return value
    }
}

final class NativeCanvas {
    static let width = 320, height = 200
    static let palette: [(UInt8,UInt8,UInt8)] = [(0,0,0),(0,0,170),(0,170,0),(0,170,170),(170,0,0),(170,0,170),(170,85,0),(170,170,170),(85,85,85),(85,85,255),(85,255,85),(85,255,255),(255,85,85),(255,85,255),(255,255,85),(255,255,255)]
    private(set) var pixels = [UInt8](repeating: 0, count: width*height)
    var clip: (x: Int, y: Int, width: Int, height: Int)?
    func clear(_ color: UInt8 = 0) { pixels = [UInt8](repeating: color & 15, count: Self.width*Self.height) }
    func pixel(_ x: Int, _ y: Int, _ color: UInt8) {
        guard (0..<Self.width).contains(x), (0..<Self.height).contains(y) else { return }
        if let clip, !(clip.x..<clip.x+clip.width).contains(x) || !(clip.y..<clip.y+clip.height).contains(y) { return }
        pixels[y*Self.width+x] = color & 15
    }
    func fill(_ x: Int, _ y: Int, _ width: Int, _ height: Int, _ color: UInt8) {
        guard width > 0, height > 0 else { return }
        let left = max(0,x), right = min(Self.width,x+width), top = max(0,y), bottom = min(Self.height,y+height)
        guard left < right, top < bottom else { return }
        for row in top..<bottom { for column in left..<right { pixels[row*Self.width+column] = color & 15 } }
    }
    func border(_ x: Int, _ y: Int, _ width: Int, _ height: Int, _ color: UInt8) {
        fill(x,y,width,1,color); fill(x,y+height-1,width,1,color)
        fill(x,y,1,height,color); fill(x+width-1,y,1,height,color)
    }
    func draw(_ bitmap: OriginalBitmap, x: Int, y: Int, transparent: Bool = false, flipped: Bool = false) {
        for row in 0..<bitmap.height {
            for column in 0..<bitmap.width {
                let value = bitmap.pixels[row*bitmap.width+column]
                // Local-video comparison of static menu/wall/player artwork
                // establishes index 1 as opaque black in the bitmap path.
                // Native fill/text color 1 remains blue. Full driver masking
                // semantics remain separately under recovery.
                if !transparent || value != 0 { pixel(x + (flipped ? bitmap.width-1-column : column),y+row,value == 1 ? 0 : value) }
            }
        }
    }
    @discardableResult func text(_ text: String, font: OriginalFont, x: Int, y: Int, color: UInt8, wrapWidth: Int? = nil, lineHeight: Int = 10) -> Int {
        var left = x, top = y
        func glyph(_ scalar: UnicodeScalar) {
            if scalar.value == 32 { left += font.spaceWidth; return }
            guard let glyph = font.glyphs[scalar.value] else { left += font.spaceWidth; return }
            for row in 0..<glyph.height {
                for column in 0..<glyph.width {
                    if glyph.bits[row*glyph.rowBytes+column/8] & (0x80 >> (column%8)) != 0 { pixel(left+glyph.x+column,top+glyph.y+row,color) }
                }
            }
            left += glyph.advance
        }
        for (lineIndex,line) in text.components(separatedBy: "\n").enumerated() {
            if lineIndex > 0 { left = x; top += lineHeight }
            let words = line.components(separatedBy: " ")
            var measuredLine = ""
            for (index,word) in words.enumerated() {
                let candidate = measuredLine.isEmpty ? word : measuredLine + " " + word
                if let width = wrapWidth, left > x, font.width(of: candidate) > width { left = x; top += lineHeight; measuredLine = "" }
                else if index > 0 { glyph(" ") }
                for scalar in word.unicodeScalars { glyph(scalar) }
                measuredLine = measuredLine.isEmpty ? word : measuredLine + " " + word
            }
        }
        return top + lineHeight
    }
    func representation() throws -> NSBitmapImageRep {
        guard let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Self.width, pixelsHigh: Self.height, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: Self.width*4, bitsPerPixel: 32), let data = rep.bitmapData else { throw ContentError.invalid("Native bitmap allocation failed") }
        for i in pixels.indices {
            let color = Self.palette[Int(pixels[i])]
            data[i*4] = color.0; data[i*4+1] = color.1; data[i*4+2] = color.2; data[i*4+3] = 255
        }
        return rep
    }
    func writePNG(to url: URL) throws {
        guard let data = try representation().representation(using: .png, properties: [:]) else { throw ContentError.invalid("Native PNG encoding failed") }
        try data.write(to: url)
    }
}
