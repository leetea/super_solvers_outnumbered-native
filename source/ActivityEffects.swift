import Foundation

extension NativeActivityPlan {
    static func effects(_ challenge: OriginalChallenge,randomState: UInt32?) throws -> NativeActivityPlan {
        var frames: [Frame] = [],sounds: [Sound] = [],randomSteps: [RandomStep] = [],time = 0
        func frame(_ marks: [Int]) { frames.append(Frame(at: time,marks: marks,completed: 0)) }
        func sound(_ index: Int?) { sounds.append(Sound(at: time,index: index)) }
        switch challenge.hotspot {
        case 2:
            guard let seed = randomState ?? challenge.post_generation_rng_state else { throw ContentError.invalid("Missing original prize random state") }
            var rng = DecoderGenerator(seed: seed),drawCount = 0
            func draw(_ low: Int,_ high: Int) -> Int { drawCount += 1;return low+rng.nextRandomValue()%(high-low+1) }
            func checkpoint() { randomSteps.append(RandomStep(at: time,state: rng.randomState,drawCount: drawCount)) }
            let flashes = draw(5,8)
            var previous = -1,prices = Array(repeating: -1,count: 4)
            for _ in 0..<flashes {
                var selected: Int
                repeat { selected = draw(0,3) } while selected == previous
                previous = selected
                var text: Int,outline: Int
                repeat { text = draw(0,15) } while [14,15].contains(text)
                repeat { outline = draw(0,15) } while [0,1,4,8,9,10,14,15].contains(outline)
                checkpoint();prices[selected] = text
                frame(prices+[selected,outline]);sound(31);time += 20
                prices[selected] = 15
            }
            var used = Set<Int>()
            for _ in 0..<4 {
                var selected: Int
                repeat { selected = draw(0,3) } while selected == previous || used.contains(selected)
                used.insert(selected);previous = -1;checkpoint();prices[selected] = 1
                frame(prices+[-1,14]);sound(31);time += 20
            }
            frame(prices+[-1,14])
        case 3:
            let selected = try challenge.originalWord(at: 2)
            guard (0..<10).contains(selected) else { throw ContentError.invalid("Invalid original spinner position") }
            sound(30)
            var step = 0
            while true {
                frame([step%10]);time += 20
                if step > 13 && step%10 == selected { break }
                step += 1
            }
            sound(nil)
        case 4:
            sound(33)
            for wait in [60,20,20,20,60,60,60,60] {
                frame([12]);time += wait;frame([14]);time += wait
            }
            sound(nil)
        case 7:
            sound(34)
            for phase in 0..<8 { frame([phase]);time += 50 }
        case 6:
            guard let seed = randomState ?? challenge.post_generation_rng_state else { throw ContentError.invalid("Missing original television random state") }
            var rng = DecoderGenerator(seed: seed),drawCount = 0,count = 51,points: [Int] = []
            for step in 0..<60 {
                if step%4 == 0 { count -= 1 }
                if step%2 == 0 {
                    points = []
                    //The no-argument command23 reads saved DI=0 / SI=0x2140
                    //as range bounds. Preserve this caller-stack quirk.
                    for _ in 0..<count {
                        points.append((rng.nextRandomValue()%8513)%136+29)
                        points.append((rng.nextRandomValue()%8513)%95+29)
                    }
                    drawCount += count*2
                    randomSteps.append(RandomStep(at: time,state: rng.randomState,drawCount: drawCount))
                }
                //Odd iterations XOR the same pixels again, restoring the table.
                frame(step%2 == 0 ? points : []);sound(23);time += 3;sound(nil);time += 3
            }
            frame([])
        default: throw ContentError.invalid("Unknown original activity effect")
        }
        return NativeActivityPlan(frames: frames,sounds: sounds,duration: time,randomSteps: randomSteps)
    }
}

extension NativeCanvas {
    func xorTelevisionNoise(_ points: [Int]) {
        //104b:0964's two-pixel call uses these EGA byte masks. In particular
        //the crossing-byte case writes both masks to the SAME byte.
        let masks: [UInt8] = [0xfc,0xfe,0xff,0xff,0xff,0xff,0xfc,0x7e]
        for i in stride(from: 0,to: points.count-1,by: 2) {
            let x = points[i],y = points[i+1],left = x & ~7,mask = masks[x&7]
            for bit in 0..<8 where mask & (0x80 >> bit) != 0 {
                let column = left+bit
                if (0..<320).contains(column),(0..<200).contains(y) { pixel(column,y,pixels[y*320+column] ^ 14) }
            }
        }
    }
    //104b:003a compares only matching source-color pixels inside inclusive bounds.
    func replaceActivityColor(left: Int,top: Int,right: Int,bottom: Int,from: UInt8,to: UInt8) {
        guard left <= right,top <= bottom else { return }
        for y in max(0,top)...min(199,bottom) { for x in max(0,left)...min(319,right) where pixels[y*320+x] == from { pixel(x,y,to) } }
    }
}
