import Foundation

//Native data schedules translated from original activity modules.
//Random checkpoints are applied only when their source phase is reached.
struct NativeActivityPlan {
    struct Frame { let at: Int;let marks: [Int];let completed: Int }
    struct Sound: Equatable { let at: Int;let index: Int? } //nil is original stop
    struct RandomStep { let at: Int;let state: UInt32;let drawCount: Int }
    static let hotspots: Set<Int> = [1,2,3,4,5,6,7,8,9]
    let frames: [Frame]
    let sounds: [Sound]
    let duration: Int
    let randomSteps: [RandomStep]
    init(frames: [Frame],sounds: [Sound],duration: Int,randomSteps: [RandomStep] = []) {
        self.frames = frames;self.sounds = sounds;self.duration = duration;self.randomSteps = randomSteps
    }
    init(_ challenge: OriginalChallenge,randomState: UInt32? = nil) throws {
        if [2,3,4,6,7].contains(challenge.hotspot) { self = try Self.effects(challenge,randomState: randomState);return }
        guard Self.hotspots.contains(challenge.hotspot) else { throw ContentError.invalid("No recovered activity timeline") }
        var frames: [Frame] = [],sounds: [Sound] = [],time = 0
        func frame(_ marks: [Int],_ completed: Int = 0) { frames.append(Frame(at: time,marks: marks,completed: completed)) }
        func sound(_ index: Int?) { sounds.append(Sound(at: time,index: index)) }
        switch challenge.hotspot {
        case 1:
            let count = try challenge.originalWord(at: 2),base = try challenge.originalWord(at: 8),interval = try challenge.originalWord(at: 9)
            guard (1...5).contains(count),interval > 0 else { throw ContentError.invalid("Invalid bar timeline") }
            var marks = Array(repeating: 0,count: count);frame(marks)
            for i in 0..<count {
                let height = try (challenge.originalWord(at: 3+i)-base)*16/interval
                guard (0...106).contains(height) else { throw ContentError.invalid("Invalid bar timeline extent") }
                sound(27)
                if height > 0 { for row in 1...height {
                    marks[i] = row;frame(marks,i);time += 5+10/row
                } }
                frame(marks,i+1);sound(nil)
            }
        case 5:
            var marks = Array(repeating: -1,count: 3);frame(marks)
            for i in 0..<3 {
                let reading = try challenge.originalWord(at: 24+i)
                guard (0...9).contains(reading) else { throw ContentError.invalid("Invalid slider timeline") }
                if reading != 0 { sound(27) }
                for step in 0...reading*9 {
                    time += 90/(step+1);marks[i] = step;frame(marks,i)
                }
                sound(nil)
            }
        case 8:
            let count = try challenge.originalWord(at: 2)
            let series = challenge.bitmap_record_id == 8521 ? try challenge.originalWord(at: 3) : 1
            guard (2...5).contains(count),(1...2).contains(series) else { throw ContentError.invalid("Invalid plot timeline") }
            var marks = Array(repeating: 0,count: series)
            for s in 0..<series {
                marks[s] = 1;frame(marks,s)
                for point in 2...count {
                    marks[s] = point;frame(marks,s);sound(29);time += 150;sound(nil)
                }
            }
        case 9:
            var marks = Array(repeating: 0,count: 4)
            for i in 0..<4 {
                marks[3-i] = 1;frame(marks,i);sound(32);time += 60-10*i;sound(nil)
            }
        default: break
        }
        self.frames = frames;self.sounds = sounds;duration = time;randomSteps = []
    }
    func frame(at ticks: Int) -> Frame { frames.last(where: { $0.at <= ticks })! }
}

struct NativeActivityPresentation: Codable {
    let challengeID: Int,seed: Int,variant: Int,hotspot: Int
    var elapsedIRQTicks = 0
    var appliedSoundCount = 0
    var initialRandomState: UInt32?
    var appliedRandomCount: Int?
    init(_ challenge: OriginalChallenge,randomState: UInt32? = nil) {
        initialRandomState = randomState;appliedRandomCount = 0
        challengeID = challenge.id;seed = challenge.seed;variant = challenge.variant;hotspot = challenge.hotspot
    }
    func valid(for challenge: OriginalChallenge) -> Bool {
        guard challengeID == challenge.id,seed == challenge.seed,variant == challenge.variant,hotspot == challenge.hotspot,
              let plan = try? NativeActivityPlan(challenge,randomState: initialRandomState) else { return false }
        return (0...plan.duration).contains(elapsedIRQTicks) &&
            appliedSoundCount == plan.sounds.prefix(while: { $0.at <= elapsedIRQTicks }).count &&
            (appliedRandomCount ?? 0) == (plan.randomSteps.last(where: { $0.at <= elapsedIRQTicks })?.drawCount ?? 0)
    }
    mutating func advance(irqTicks: Int,plan: NativeActivityPlan) -> [NativeActivityPlan.Sound] {
        elapsedIRQTicks = min(plan.duration,elapsedIRQTicks+max(0,irqTicks))
        let end = plan.sounds.prefix(while: { $0.at <= elapsedIRQTicks }).count
        let result = Array(plan.sounds[appliedSoundCount..<end]);appliedSoundCount = end
        appliedRandomCount = plan.randomSteps.last(where: { $0.at <= elapsedIRQTicks })?.drawCount ?? 0
        return result
    }
}
