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
                used.insert(selected);previous = -1;checkpoint();prices[selected] = 0
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
        default: throw ContentError.invalid("Unknown original activity effect")
        }
        return NativeActivityPlan(frames: frames,sounds: sounds,duration: time,randomSteps: randomSteps)
    }
}

extension NativeCanvas {
    //104b:003a compares only matching source-color pixels inside inclusive bounds.
    func replaceActivityColor(left: Int,top: Int,right: Int,bottom: Int,from: UInt8,to: UInt8) {
        guard left <= right,top <= bottom else { return }
        for y in max(0,top)...min(199,bottom) { for x in max(0,left)...min(319,right) where pixels[y*320+x] == from { pixel(x,y,to) } }
    }
}
